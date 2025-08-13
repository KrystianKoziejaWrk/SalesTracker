import SwiftUI
import UIKit

struct SalesListView: View {
  @StateObject private var vm = SalesListViewModel()
  @State private var showCopiedToast = false

  private var sheetId: String {
    UserDefaults.standard.string(forKey: "sheetId") ?? ""
  }

  var body: some View {
    NavigationView {
      List {
        ForEach(vm.sales) { sale in
          NavigationLink(destination: SaleEntryView(editSale: sale, rowIndex: sale.rowIndex)) {
            VStack(alignment: .leading, spacing: 6) {
              // Name
              Text(sale.name)
                .font(.headline)

              // Cost & Tip (ensure they’re Doubles)
              HStack {
                Text("Cost: $\(sale.cost ?? 0, specifier: "%.2f")")
                Text("Tip: $\(sale.tip ?? 0, specifier: "%.2f")")
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
              if let phone = sale.phone {
                if let smsURL = URL(string: "sms:\(phone)") {
                  Link("📱 \(phone)", destination: smsURL)
                    .font(.subheadline)
                } else {
                  Text("Phone: \(phone)")
                    .font(.subheadline)
                }
              }

              // Address (tap to open in Maps)
              Text("🏠 Address: \(sale.address ?? "")")
                .font(.subheadline)
                .foregroundColor(.blue)
                .onTapGesture {
                    if let address = sale.address, !address.isEmpty {
                        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        if let url = URL(string: "http://maps.apple.com/?q=\(encoded)") {
                            UIApplication.shared.open(url)
                        }
                    }
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
        }
      }
      .navigationTitle("Customers")
      .onAppear { vm.loadSales(sheetId: sheetId) }
      .refreshable { vm.loadSales(sheetId: sheetId) }
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
