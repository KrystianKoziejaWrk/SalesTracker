//
//  SaleEditView.swift
//  SalesTracker
//
//  Created by Krystian Kozieja on 6/29/25.
//

import SwiftUI

struct SaleEditView: View {
  let sale: Sale
  var body: some View {
    List {
      Text("Name: \(sale.name)")
      Text("Date: \(sale.dateOfJob) at \(sale.timeOfJob)")
    }
    .navigationTitle("Edit Sale")
  }
}

