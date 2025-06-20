//
//  SalesLiftView.swift
//  SalesTracker
//
//  Created by Krystian Kozieja on 6/20/25.
//

import SwiftUI

struct SalesListView: View {
  @State private var sales: [Sale] = []
  @State private var isLoading = true
  @State private var error: String?

  var body: some View {
    List {
      if isLoading { ProgressView() }
      ForEach(sortedSales) { sale in
        NavigationLink(destination: SaleEditView(sale: sale)) {
          VStack(alignment: .leading) {
            Text(sale.name)
              .font(.headline)
            Text(sale.dateOfJob + " at " + sale.timeOfJob)
              .font(.subheadline)
            HStack {
              Text("Cost: \(sale.cost, specifier: "%.2f")")
              Spacer()
              Text("Tip: \(sale.tip, specifier: "%.2f")")
            }
            .font(.caption)
          }
        }
      }
    }
    .navigationTitle("Sales")
    .onAppear(perform: fetch)
    .alert(item: $error) { msg in
      Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
    }
  }

  private var sortedSales: [Sale] {
    sales.sorted {
      // combine date & time into Date for comparison
      let d1 = ($0.dateOfJob + "T" + $0.timeOfJob + ":00").isoDateTime
      let d2 = ($1.dateOfJob + "T" + $1.timeOfJob + ":00").isoDateTime
      return d1 > d2
    }
  }

  func fetch() {
    isLoading = true
    SheetAPI.shared.getSales { result in
      DispatchQueue.main.async {
        isLoading = false
        switch result {
        case .success(let list): sales = list
        case .failure(let err): error = err.localizedDescription
        }
      }
    }
  }
}

private extension String {
  var isoDateTime: Date {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return f.date(from: self) ?? Date.distantPast
  }
}
