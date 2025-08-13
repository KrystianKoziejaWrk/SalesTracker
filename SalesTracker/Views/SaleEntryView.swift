import SwiftUI
import Foundation
import CoreLocation

struct SaleEntryView: View {
    @State private var sale: Sale
    private var isEditing: Bool
    private var rowIndex: Int?
    @State private var alertMsg  = ""
    @State private var showAlert = false
    @StateObject private var locationManager = LocationManager()

    init(editSale: Sale? = nil, rowIndex: Int? = nil) {
        if let editSale = editSale {
            _sale = State(initialValue: editSale)
            isEditing = true
            self.rowIndex = rowIndex
        } else {
            _sale = State(initialValue: Sale(sheetId: UserDefaults.standard.string(forKey: "sheetId") ?? ""))
            isEditing = false
            self.rowIndex = nil
        }
    }

    var body: some View {
        Form {
            Section {
                TextField("Who sold",  text: $sale.whoSold)
                TextField("Name",      text: $sale.name)
                TextField("Cost", value: $sale.cost, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Tip", value: $sale.tip, format: .number)
                    .keyboardType(.decimalPad)
                HStack {
                    TextField("Address", text: Binding(get: { sale.address ?? "" }, set: { sale.address = $0 }))
                    Button {
                        locationManager.requestLocation()
                    } label: {
                        Image(systemName: "location.fill")
                        Text("Grab Location")
                    }
                    .buttonStyle(.bordered)
                }
                .onChange(of: locationManager.address) { newAddress in
                    if let newAddress = newAddress {
                        sale.address = newAddress
                    }
                }
                if let locError = locationManager.error {
                    Text("Location error: \(locError)")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                TextField("Notes",     text: $sale.notes)
                TextField("Phone", text: Binding(get: { sale.phone ?? "" }, set: { sale.phone = $0 }))
                    .keyboardType(.numberPad)
                TextField("Date of job (e.g. 2025-06-29)", text: $sale.dateOfJob)
                TextField("Time of job (e.g. 14:30)",        text: $sale.timeOfJob)
                TextField("Collected", value: $sale.collected, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Worked (e.g. “2h”)", text: $sale.worked)
            } header: {
                Text("Sale details")
            }
            HStack {
                Button(isEditing ? "Update" : "Submit") {
                    if isEditing, let idx = rowIndex {
                        var updatedSale = sale
                        updatedSale.rowIndex = idx
                        SheetAPI.shared.updateSale(updatedSale) { result in
                            switch result {
                            case .success(let ok):
                                alertMsg = ok ? "✅ Updated!" : "⚠️ Server said no."
                            case .failure(let apiError):
                                switch apiError {
                                case .networkError(let underlying):
                                    print("🛠 NETWORK ERROR:", underlying)
                                    alertMsg = "Network error: \(underlying.localizedDescription)"
                                case .invalidURL:
                                    alertMsg = "Bad URL in SheetAPI."
                                case .serverError(let status, let msg):
                                    alertMsg = "Server \(status): \(msg)"
                                case .decodingError(let decodeErr):
                                    print("🛠 DECODING ERROR:", decodeErr)
                                    alertMsg = "Decoding error: \(decodeErr.localizedDescription)"
                                case .unknownResponse:
                                    alertMsg = "Unknown response from server."
                                }
                            }
                            showAlert = true
                        }
                    } else {
                        SheetAPI.shared.appendSale(sale) { result in
                            switch result {
                            case .success(let ok):
                                alertMsg = ok ? "✅ Saved!" : "⚠️ Server said no."
                                sale = Sale(sheetId: sale.sheetId) // Clear entries after submit
                            case .failure(let apiError):
                                switch apiError {
                                case .networkError(let underlying):
                                    print("🛠 NETWORK ERROR:", underlying)
                                    alertMsg = "Network error: \(underlying.localizedDescription)"
                                case .invalidURL:
                                    alertMsg = "Bad URL in SheetAPI."
                                case .serverError(let status, let msg):
                                    alertMsg = "Server \(status): \(msg)"
                                case .decodingError(let decodeErr):
                                    print("🛠 DECODING ERROR:", decodeErr)
                                    alertMsg = "Decoding error: \(decodeErr.localizedDescription)"
                                case .unknownResponse:
                                    alertMsg = "Unknown response from server."
                                }
                            }
                            showAlert = true
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                Button("Clear") {
                    sale = Sale(sheetId: sale.sheetId)
                }
                .buttonStyle(.bordered)
            }
        }
        .navigationTitle(isEditing ? "Edit Sale" : "Log a Sale")
        .alert(alertMsg, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

