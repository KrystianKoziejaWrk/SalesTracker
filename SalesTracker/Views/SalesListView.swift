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

              Text(sale.name)
                .font(.headline)

              // Cost & Tip
              HStack {
                Text("Cost: $\(sale.cost ?? 0, specifier: "%.2f")")
                Text("Tip: $\(sale.tip ?? 0, specifier: "%.2f")")
              }
              .font(.subheadline)

              // Notes 
              Text("Notes: \(sale.notes)")
                .font(.subheadline)
                .foregroundColor(.blue)
              //(tap to copy)
                .onTapGesture {
                  UIPasteboard.general.string = sale.notes
                  withAnimation { showCopiedToast = true }
                  DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { showCopiedToast = false }
                  }
                }

              // Phone NUmber
              if let phone = sale.phone, !phone.isEmpty {
                Text("📱 \(phone)")
                  .font(.subheadline)
                  .foregroundColor(.blue)
                  (tap to message)
                  .onTapGesture {
                    if let smsURL = URL(string: "sms:\(phone)") {
                      UIApplication.shared.open(smsURL)
                    }
                  }
              } else if let phone = sale.phone {
                Text("Phone: \(phone)")
                  .font(.subheadline)
              }

              // Address 
              Text("🏠 Address: \(sale.address ?? "")")
                .font(.subheadline)
                .foregroundColor(.blue)
                // (tap to open in Maps)
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
