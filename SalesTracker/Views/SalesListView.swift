// Views/SalesListView.swift
import SwiftUI

struct SalesListView: View {
  @StateObject private var vm = SalesListViewModel()
  @State private var showCopiedToast = false

  /// Read the sheet ID once from UserDefaults
  private var sheetId: String {
    UserDefaults.standard.string(forKey: "sheetId") ?? ""
  }

  var body: some View {
    NavigationView {
      List(vm.sales) { sale in
        VStack(alignment: .leading, spacing: 6) {
          // Name
          Text(sale.name)
            .font(.headline)

          // Cost & Tip
          HStack {
            Text("Cost: $\(sale.cost, specifier: "%.2f")")
            Text("Tip: $\(sale.tip, specifier: "%.2f")")
          }
          .font(.subheadline)

          // Notes (tap to copy)
          Text("Notes: \(sale.notes)")
            .font(.subheadline)
            .foregroundColor(.blue)
            .onTapGesture {
              UIPasteboard.general.string = sale.notes
              withAnimation { showCopiedToast = true }
              DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showCopiedToast = false }
              }
            }

          // Phone (tap to message)
          if let smsURL = URL(string: "sms:\(sale.phone)") {
            Link("📱 \(sale.phone)", destination: smsURL)
              .font(.subheadline)
          } else {
            Text("Phone: \(sale.phone)")
              .font(.subheadline)
          }

          // Date & Time
          HStack {
            Text("Date: \(sale.dateOfJob)")
            Spacer()
            Text("Time: \(sale.timeOfJob)")
          }
          .font(.footnote)
          .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
      }
      .navigationTitle("Customers")
      .onAppear {
        vm.loadSales(sheetId: sheetId)
      }
      .refreshable {
        vm.loadSales(sheetId: sheetId)
      }
      // Toast overlay
      .overlay(
        VStack {
          if showCopiedToast {
            Text("Copied to clipboard!")
              .padding(.horizontal, 12)
              .padding(.vertical, 8)
              .background(Color(.systemGray6))
              .cornerRadius(8)
              .transition(.move(edge: .top).combined(with: .opacity))
          }
          Spacer()
        }
        .padding()
      )
    }
  }
}

struct SalesListView_Previews: PreviewProvider {
  static var previews: some View {
    SalesListView()
  }
}

