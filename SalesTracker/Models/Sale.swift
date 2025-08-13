// Models/Sale.swift
import Foundation

struct Sale: Identifiable, Codable {
  // synthesized `init(from:)` will fill only the CodingKeys below;
  // all other vars get their default values:
  var id        = UUID()
  var sheetId   = ""         // ← default so Decodable init doesn’t need it
  var whoSold   = ""
  var name      = ""
  var cost: Double? = nil
  var tip: Double? = nil
  var notes     = ""
  var phone: String? = nil
  var dateOfJob = ""
  var timeOfJob = ""
  var collected: Double? = nil
  var worked    = ""
  var address: String? = nil
  var rowIndex: Int? = nil // Optional row index for editing

  private enum CodingKeys: String, CodingKey {
    // exactly the fields your GET endpoint returns:
    case whoSold, name, cost, tip,
         address, notes, phone, dateOfJob, timeOfJob,
         collected, worked, rowIndex
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    whoSold   = try container.decodeIfPresent(String.self, forKey: .whoSold) ?? ""
    name      = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    cost      = try container.decodeIfPresent(Double.self, forKey: .cost)
    tip       = try container.decodeIfPresent(Double.self, forKey: .tip)
    address   = try container.decodeIfPresent(String.self, forKey: .address)
    notes     = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
    phone     = try container.decodeIfPresent(String.self, forKey: .phone)
    dateOfJob = try container.decodeIfPresent(String.self, forKey: .dateOfJob) ?? ""
    timeOfJob = try container.decodeIfPresent(String.self, forKey: .timeOfJob) ?? ""
    collected = try container.decodeIfPresent(Double.self, forKey: .collected)
    worked    = try container.decodeIfPresent(String.self, forKey: .worked) ?? ""
    rowIndex  = try container.decodeIfPresent(Int.self, forKey: .rowIndex)
  }

  // Memberwise initializer for easy creation
  init(
    id: UUID = UUID(),
    sheetId: String = "",
    whoSold: String = "",
    name: String = "",
    cost: Double? = nil,
    tip: Double? = nil,
    notes: String = "",
    phone: String? = nil,
    dateOfJob: String = "",
    timeOfJob: String = "",
    collected: Double? = nil,
    worked: String = "",
    address: String? = nil,
    rowIndex: Int? = nil
  ) {
    self.id = id
    self.sheetId = sheetId
    self.whoSold = whoSold
    self.name = name
    self.cost = cost
    self.tip = tip
    self.notes = notes
    self.phone = phone
    self.dateOfJob = dateOfJob
    self.timeOfJob = timeOfJob
    self.collected = collected
    self.worked = worked
    self.address = address
    self.rowIndex = rowIndex
  }

  init(sheetId: String) {
    self.sheetId = sheetId
    self.whoSold = ""
    self.name = ""
    self.cost = nil
    self.tip = nil
    self.address = nil
    self.notes = ""
    self.phone = nil
    self.dateOfJob = ""
    self.timeOfJob = ""
    self.collected = nil
    self.worked = ""
    self.rowIndex = nil
  }
}

