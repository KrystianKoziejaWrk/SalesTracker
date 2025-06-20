// Models/Sale.swift
import Foundation

struct Sale: Identifiable, Codable {
  // synthesized `init(from:)` will fill only the CodingKeys below;
  // all other vars get their default values:
  var id        = UUID()
  var sheetId   = ""         // ← default so Decodable init doesn’t need it
  var whoSold   = ""
  var name      = ""
  var cost      = 0.0
  var tip       = 0.0
  var notes     = ""
  var phone     = ""
  var dateOfJob = ""
  var timeOfJob = ""
  var collected = 0.0
  var worked    = ""

  private enum CodingKeys: String, CodingKey {
    // exactly the fields your GET endpoint returns:
    case whoSold, name, cost, tip,
         notes, phone, dateOfJob, timeOfJob,
         collected, worked
  }
}

