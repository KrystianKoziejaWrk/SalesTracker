//
//  SettingsView.swift
//  SalesTracker
//
//  Created by Krystian Kozieja on 6/20/25.
//

import SwiftUI

struct SettingsView: View {
  @State private var rawURL = ""
  @State private var message: String?

  var body: some View {
    Form {
      Section(header: Text("Sales Sheet")) {
        TextField("Enter Google Sheet URL or ID", text: $rawURL)
        Button("Save") { save() }
        if let msg = message {
          Text(msg).foregroundColor(.green)
        }
      }
    }
    .navigationTitle("Settings")
    .onAppear { rawURL = UserDefaults.standard.string(forKey: "sheetId") ?? "" }
  }

  func save() {
    // Extract sheetId from rawURL
    let pattern = "/d/([a-zA-Z0-9-_]+)"
    let id: String
    if let match = rawURL.range(of: pattern, options: .regularExpression) {
      let group = String(rawURL[match])
      id = group.replacingOccurrences(of: "/d/", with: "")
    } else {
      id = rawURL
    }
    UserDefaults.standard.set(id, forKey: "sheetId")
    message = "Sheet ID saved!"
  }
}
