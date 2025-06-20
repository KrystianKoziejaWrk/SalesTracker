/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");
const {google} = require("googleapis");

const app = express();
app.use(cors(), express.json());

// Secrets from Firebase config
const FUNCTIONS_SECRET = functions.config().app.secret;
const SERVICE_ACCOUNT_KEY = functions.config().service_account_key;

// Sheets API scope
const SCOPES = ["https://www.googleapis.com/auth/spreadsheets"];

// Helper to create a Sheets client
function sheetsClient() {
  const key = JSON.parse(SERVICE_ACCOUNT_KEY);
  const auth = new google.auth.JWT(
      key.client_email,
      null,
      key.private_key,
      SCOPES,
  );
  return google.sheets({version: "v4", auth});
}

// Append a sale with 11 columns
app.post("/appendSale", async (req, res) => {
  if (req.headers["x-app-secret"] !== FUNCTIONS_SECRET) {
    return res.status(401).send("Unauthorized");
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
    worked,
  } = req.body;

  if (!sheetId) {
    return res.status(400).send("Missing sheetId");
  }

  const row = [
    isNew ? "TRUE" : "FALSE",
    whoSold,
    name,
    cost,
    tip,
    notes,
    phone,
    dateOfJob,
    timeOfJob,
    collected,
    worked,
  ];

  try {
    const sheets = sheetsClient();
    await sheets.spreadsheets.values.append({
      spreadsheetId: sheetId,
      range: "Sales!A:K",
      valueInputOption: "USER_ENTERED",
      requestBody: {values: [row]},
    });
    res.json({success: true});
  } catch (err) {
    console.error("Append failed:", err);
    res.status(500).json({error: err.toString()});
  }
});

// Get all sales rows (raw 11-field JSON)
app.get("/getSales", async (req, res) => {
  if (req.headers["x-app-secret"] !== FUNCTIONS_SECRET) {
    return res.status(401).send("Unauthorized");
  }

  const {sheetId} = req.query;
  if (!sheetId) {
    return res.status(400).send("Missing sheetId");
  }

  try {
    const sheets = sheetsClient();
    const result = await sheets.spreadsheets.values.get({
      spreadsheetId: sheetId,
      range: "Sales!A2:K",
    });

    const rows = (result.data.values || []).map((r) => ({
      isNew: r[0] === "TRUE",
      whoSold: r[1],
      name: r[2],
      cost: parseFloat(r[3]) || 0,
      tip: parseFloat(r[4]) || 0,
      notes: r[5],
      phone: r[6],
      dateOfJob: r[7],
      timeOfJob: r[8],
      collected: parseFloat(r[9]) || 0,
      worked: r[10],
    }));

    res.json(rows);
  } catch (err) {
    console.error("Fetch failed:", err);
    res.status(500).json({error: err.toString()});
  }
});

// Export the API
exports.api = functions.https.onRequest(app);

