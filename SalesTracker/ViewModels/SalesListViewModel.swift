// ViewModels/SalesListViewModel.swift
import Foundation
import Combine

class SalesListViewModel: ObservableObject {
  @Published var sales: [Sale] = []

  /// Fetch all rows (newest-first) from your sheet
  func loadSales(sheetId: String) {
    // if there's no sheetId set yet, clear out and bail
    guard !sheetId.isEmpty else {
      self.sales = []
      return
    }

    SheetAPI.shared.getSales(sheetId: sheetId) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let list):
          self.sales = list
        case .failure(let err):
          print("Error loading sales:", err)
          self.sales = []
        }
      }
    }
  }
}

