/* eslint-disable */
const { onRequest }        = require('firebase-functions/v2/https');
const { setGlobalOptions } = require('firebase-functions/v2');
const express              = require('express');
const cors                 = require('cors');
const { google }           = require('googleapis');

// 1) Pin to Node18 & us-central1
setGlobalOptions({ region: 'us-central1', runtime: 'nodejs18' });

const app = express();
app.use(cors(), express.json());

// 2) Your one secret
const FUNCTIONS_SECRET = 'door2door123!@#';

// 3) Sheets scope
const SCOPES = ['https://www.googleapis.com/auth/spreadsheets'];

// 4) Build client via ADC
const auth = new google.auth.GoogleAuth({ scopes: SCOPES });
async function sheetsClient() {
  const client = await auth.getClient();
  return google.sheets({ version: 'v4', auth: client });
}

// 5) Debug headers
app.use((req, res, next) => {
  console.log('🔐 Expected secret:', FUNCTIONS_SECRET);
  console.log('🔑   Got header   :', req.headers['x-app-secret']);
  next();
});

// 6) appendSale endpoint
app.post('/appendSale', async (req, res) => {
  if (req.headers['x-app-secret'] !== FUNCTIONS_SECRET) {
    return res.status(401).send('Unauthorized');
  }
  const {
    sheetId, whoSold, name, cost,
    tip, address, notes, phone, dateOfJob,
    timeOfJob, collected, worked
  } = req.body;

  if (!sheetId) return res.status(400).send('Missing sheetId');

  const row = [
    whoSold, name, cost, tip,
    address, notes, phone, dateOfJob,
    timeOfJob, collected, worked
  ];

  try {
    const sheets = await sheetsClient();
    // Get all values in the sheet to find the last non-empty row
    const getResp = await sheets.spreadsheets.values.get({
      spreadsheetId: sheetId,
      range: 'Sales!A:K',
    });
    const allRows = getResp.data.values || [];
    // The next row index is allRows.length + 1 (1-based)
    const nextRow = allRows.length + 1;
    // Build the range for the next row, always starting at A
    const targetRange = `Sales!A${nextRow}:K${nextRow}`;
    // Write the new row to the next row, starting at column A
    await sheets.spreadsheets.values.update({
      spreadsheetId: sheetId,
      range: targetRange,
      valueInputOption: 'USER_ENTERED',
      requestBody: { values: [row] }
    });
    res.json({ success: true });
  } catch (err) {
    console.error('Append failed:', err);
    res.status(500).json({ error: err.toString() });
  }
});


// 6.5) getSales endpoint
app.get('/getSales', async (req, res) => {
  // 1) Check your secret header
  //what up
  if (req.headers['x-app-secret'] !== FUNCTIONS_SECRET) {
    return res.status(401).send('Unauthorized');
  }

  // 2) Expect sheetId as a query parameter
  const sheetId = req.query.sheetId;
  if (!sheetId) {
    return res.status(400).send('Missing sheetId');
  }

  try {
    const sheets = await sheetsClient();
    // 3) Read A:J (whoSold, name, cost, tip, notes, phone, dateOfJob, timeOfJob, collected, worked)
    const resp = await sheets.spreadsheets.values.get({
      spreadsheetId: sheetId,
      range: 'Sales!A:J',
    });

    const rows = (resp.data.values || []).reverse();

    // 4) Map each row array to an object, include rowIndex
    const sales = rows
      .map((cols, i) => ({
        whoSold:   cols[0] || '',
        name:      cols[1] || '',
        cost:      cols[2] ? parseFloat(cols[2]) : null,
        tip:       cols[3] ? parseFloat(cols[3]) : null,
        address:   cols[4] || '',
        notes:     cols[5] || '',
        phone:     cols[6] || '',
        dateOfJob: cols[7] || '',
        timeOfJob: cols[8] || '',
        collected: cols[9] ? parseFloat(cols[9]) : null,
        worked:    cols[10] || '',
        rowIndex: rows.length - i
      }))
      .filter(sale => sale.name || sale.worked || sale.collected || sale.address || sale.whoSold);

    // 5) Return JSON array
    res.json(sales);

  } catch (err) {
    console.error('Read failed:', err);
    res.status(500).json({ error: err.toString() });
  }
});

// 6.7) updateSale endpoint
app.post('/updateSale', async (req, res) => {
  if (req.headers['x-app-secret'] !== FUNCTIONS_SECRET) {
    return res.status(401).send('Unauthorized');
  }
  const {
    sheetId, rowIndex, whoSold, name, cost,
    tip, address, notes, phone, dateOfJob,
    timeOfJob, collected, worked
  } = req.body;

  if (!sheetId || !rowIndex) return res.status(400).send('Missing sheetId or rowIndex');

  const row = [
    whoSold, name, cost, tip,
    address, notes, phone, dateOfJob,
    timeOfJob, collected, worked
  ];

  try {
    const sheets = await sheetsClient();
    // Build the range for the target row, always starting at A
    const targetRange = `Sales!A${rowIndex}:K${rowIndex}`;
    // Overwrite the row at rowIndex
    await sheets.spreadsheets.values.update({
      spreadsheetId: sheetId,
      range: targetRange,
      valueInputOption: 'USER_ENTERED',
      requestBody: { values: [row] }
    });
    res.json({ success: true });
  } catch (err) {
    console.error('Update failed:', err);
    res.status(500).json({ error: err.toString() });
  }
});


// 7) Export
exports.api = onRequest(app);
