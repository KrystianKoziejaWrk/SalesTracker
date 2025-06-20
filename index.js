/* eslint-disable */
const functions = require('firebase-functions');
const express   = require('express');
const cors      = require('cors');
const { google } = require('googleapis');

const app = express();
app.use(cors(), express.json());

// Load secrets from Firebase config
const FUNCTIONS_SECRET      = functions.config().app.secret;
const SERVICE_ACCOUNT_KEY   = functions.config().service_account_key;

// Sheets API scope
const SCOPES = ['https://www.googleapis.com/auth/spreadsheets'];

// Helper to instantiate the Google Sheets client
function sheetsClient() {
  const key = JSON.parse(SERVICE_ACCOUNT_KEY);
  const auth = new google.auth.JWT(
    key.client_email,
    null,
    key.private_key,
    SCOPES
  );
  return google.sheets({ version: 'v4', auth });
}

// 1) Append a new sale (11-column row)
app.post('/appendSale', async (req, res) => {
  if (req.headers['x-app-secret'] !== FUNCTIONS_SECRET) {
    return res.status(401).send('Unauthorized');
  }

  const {
    sheetId,
    isNew,
    whoSold,
    name,
    cost,
    tip,
    notes,
    phone,
    dateOfJob,
    timeOfJob,
    collected,
    worked
  } = req.body;

  if (!sheetId) {
    return res.status(400).send('Missing sheetId');
  }

  const row = [
    isNew ? 'TRUE' : 'FALSE',
    whoSold,
    name,
    cost,
    tip,
    notes,
    phone,
    dateOfJob,
    timeOfJob,
    collected,
    worked
  ];

  try {
    const sheets = sheetsClient();
    await sheets.spreadsheets.values.append({
      spreadsheetId: sheetId,
      range: 'Sales!A:K',
      valueInputOption: 'USER_ENTERED',
      requestBody: { values: [row] }
    });
    res.json({ success: true });
  } catch (err) {
    console.error('Append failed:', err);
    res.status(500).json({ error: err.toString() });
  }
});

// 2) Update an existing sale by its row index
app.post('/updateSale', async (req, res) => {
  if (req.headers['x-app-secret'] !== FUNCTIONS_SECRET) {
    return res.status(401).send('Unauthorized');
  }

  const {
    sheetId,
    rowIndex,
    isNew,
    whoSold,
    name,
    cost,
    tip,
    notes,
    phone,
    dateOfJob,
    timeOfJob,
    collected,
    worked
  } = req.body;

  if (!sheetId || !rowIndex) {
    return res.status(400).send('Missing sheetId or rowIndex');
  }

  const row = [
    isNew ? 'TRUE' : 'FALSE',
    whoSold,
    name,
    cost,
    tip,
    notes,
    phone,
    dateOfJob,
    timeOfJob,
    collected,
    worked
  ];

  try {
    const sheets = sheetsClient();
    await sheets.spreadsheets.values.update({
      spreadsheetId: sheetId,
      range: `Sales!A${rowIndex}:K${rowIndex}`,
      valueInputOption: 'USER_ENTERED',
      requestBody: { values: [row] }
    });
    res.json({ success: true });
  } catch (err) {
    console.error('Update failed:', err);
    res.status(500).json({ error: err.toString() });
  }
});

// 3) Get all sales (raw 11-field JSON, including rowIndex)
app.get('/getSales', async (req, res) => {
  if (req.headers['x-app-secret'] !== FUNCTIONS_SECRET) {
    return res.status(401).send('Unauthorized');
  }

  const { sheetId } = req.query;
  if (!sheetId) {
    return res.status(400).send('Missing sheetId');
  }

  try {
    const sheets = sheetsClient();
    const result = await sheets.spreadsheets.values.get({
      spreadsheetId: sheetId,
      range: 'Sales!A2:K',
      valueRenderOption: 'UNFORMATTED_VALUE'
    });

    const rows = (result.data.values || []).map((r, i) => ({
      rowIndex:      i + 2,              // actual sheet row
      isNew:         r[0] === 'TRUE',
      whoSold:       r[1],
      name:          r[2],
      cost:          parseFloat(r[3]) || 0,
      tip:           parseFloat(r[4]) || 0,
      notes:         r[5],
      phone:         r[6],
      dateOfJob:     r[7],
      timeOfJob:     r[8],
      collected:     parseFloat(r[9]) || 0,
      worked:        r[10]
    }));

    res.json(rows);
  } catch (err) {
    console.error('Fetch failed:', err);
    res.status(500).json({ error: err.toString() });
  }
});

// Expose the Express API under the `api` function
exports.api = functions.https.onRequest(app);
