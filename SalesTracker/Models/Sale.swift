//
//  Sale.swift
//  SalesTracker
//
//  Created by Krystian Kozieja on 6/16/25.
//
import Foundation

struct Sale: Codable, Identifiable {
  let id = UUID()
  var isNew: Bool
  var whoSold: String
  var name: String
  var cost: Double
  var tip: Double
  var notes: String
  var phone: String
  var dateOfJob: String     // e.g. "2025-06-17"
  var timeOfJob: String     // e.g. "14:30"
  var collected: Double
  var worked: String        // e.g. "2h" or number of hours

  var dictionary: [String:Any] {
    return [
      "isNew":        isNew,
      "whoSold":      whoSold,
      "name":         name,
      "cost":         cost,
      "tip":          tip,
      "notes":        notes,
      "phone":        phone,
      "dateOfJob":    dateOfJob,
      "timeOfJob":    timeOfJob,
      "collected":    collected,
      "worked":       worked
    ]
  }
}

