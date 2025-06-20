//
//  MainView.swift
//  SalesTracker
//
//  Created by Krystian Kozieja on 6/20/25.
//

import SwiftUI

struct MainView: View {
  var body: some View {
    NavigationView {
      List {
        NavigationLink("Log a Sale", destination: SaleEntryView())
        NavigationLink("View Sales", destination: SalesListView())
        NavigationLink("Settings", destination: SettingsView())
      }
      .navigationTitle("SalesTracker")
    }
  }
}
#Preview {
    MainView()
}
