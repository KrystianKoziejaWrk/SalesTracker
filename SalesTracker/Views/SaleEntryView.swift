import SwiftUI

struct SaleEntryView: View {
    // 1️⃣ Your mutable sale model
    @State private var sale = Sale(
        sheetId:   UserDefaults.standard.string(forKey: "sheetId") ?? "",
        whoSold:   "",
        name:      "",
        cost:      0,
        tip:       0,
        notes:     "",
        phone:     "",
        dateOfJob: "",      // you may want a Date picker
        timeOfJob: "",      // or string if you prefer
        collected: 0,
        worked:    ""
    )

    // 2️⃣ Alert state
    @State private var alertMsg  = ""
    @State private var showAlert = false

    var body: some View {
        Form {
            Section(header: Text("Sale details")) {
                TextField("Who sold",  text: $sale.whoSold)
                TextField("Name",      text: $sale.name)
                TextField("Cost",      value: $sale.cost,      format: .number)
                TextField("Tip",       value: $sale.tip,       format: .number)
                TextField("Notes",     text: $sale.notes)
                TextField("Phone",     text: $sale.phone)
                TextField("Date of job (e.g. 2025-06-29)", text: $sale.dateOfJob)
                TextField("Time of job (e.g. 14:30)",        text: $sale.timeOfJob)
                TextField("Collected", value: $sale.collected, format: .number)
                TextField("Worked (e.g. “2h”)", text: $sale.worked)
            }

            Button("Submit") {
                // 1) Call your API singleton
                SheetAPI.shared.appendSale(sale) { result in
                    switch result {
                    case .success(let ok):
                        // ok == true if server returned { "success": true }
                        alertMsg = ok ? "✅ Saved!" : "⚠️ Server said no." // HI

                    case .failure(let apiError):
                        // unwrap each error case for a clearer message
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

                    // 2) Show your alert
                    showAlert = true
                }
}
.buttonStyle(.borderedProminent)

            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Log a Sale")
        // 4️⃣ Attach the new alert modifier here:
        .alert(alertMsg, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

