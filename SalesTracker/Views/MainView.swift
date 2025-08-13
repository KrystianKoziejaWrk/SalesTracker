//
//  MainView.swift
//  SalesTracker
//
//  Created by Krystian Kozieja on 6/20/25.
//
import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            SalesListView()
                .tabItem {
                    Label("View Sales", systemImage: "list.bullet")
                }
            SaleEntryView()
                .tabItem {
                    Label("Log Sale", systemImage: "plus.circle")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainView()
}
