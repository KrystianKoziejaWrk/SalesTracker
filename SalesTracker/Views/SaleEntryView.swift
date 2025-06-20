import SwiftUI

struct SaleEntryView: View {
  @Environment(\.presentationMode) var presentationMode
  @State private var sale = Sale(
    isNew: true,
    whoSold: "",
    name: "",
    cost: 0,
    tip: 0,
    notes: "",
    phone: "",
    dateOfJob: Date().isoDate,      // use a Date→String helper
    timeOfJob: Date().isoTime,
    collected: 0,
    worked: ""
  )
  @State private var isSaving = false
  @State private var errorMessage: String?

  var body: some View {
    Form {
      Section("Sale Info") {
        Toggle("New Job", isOn: $sale.isNew)
        TextField("Who Sold", text: $sale.whoSold)
        TextField("Customer Name", text: $sale.name)
        HStack {
          Text("Cost")
          Spacer()
          TextField("0", value: $sale.cost, formatter: NumberFormatter.currency)
            .keyboardType(.decimalPad)
        }
        HStack {
          Text("Tip")
          Spacer()
          TextField("0", value: $sale.tip, formatter: NumberFormatter.currency)
            .keyboardType(.decimalPad)
        }
        TextField("Notes", text: $sale.notes)
        TextField("Phone", text: $sale.phone)
      }
      Section("When & Hours") {
        DatePicker("Date of Job", selection: Binding(
          get: { sale.dateOfJob.isoDateToDate },
          set: { sale.dateOfJob = $0.isoDate }
        ), displayedComponents: .date)
        DatePicker("Time of Job", selection: Binding(
          get: { sale.timeOfJob.isoTimeToDate },
          set: { sale.timeOfJob = $0.isoTime }
        ), displayedComponents: .hourAndMinute)
        HStack {
          Text("Collected")
          Spacer()
          TextField("0", value: $sale.collected, formatter: NumberFormatter.currency)
            .keyboardType(.decimalPad)
        }
        TextField("Hours Worked", text: $sale.worked)
      }

      if let err = errorMessage {
        Text(err).foregroundColor(.red)
      }

      Button(action: save) {
        HStack {
          Spacer()
          if isSaving { ProgressView() }
          else { Text("Save & Push") }
          Spacer()
        }
      }
      .disabled(isSaving)
    }
    .navigationTitle("New Sale")
  }

  func save() {
    isSaving = true
    SheetAPI.shared.appendSale(sale) { result in
      DispatchQueue.main.async {
        isSaving = false
        switch result {
        case .success:
          presentationMode.wrappedValue.dismiss()
        case .failure(let err):
          errorMessage = err.localizedDescription
        }
      }
    }
  }
}

private extension Date {
  var isoDate: String { Self.dateFormatter.string(from: self) }
  var isoTime: String { Self.timeFormatter.string(from: self) }

  static let dateFormatter: DateFormatter = {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
  }()
  static let timeFormatter: DateFormatter = {
    let f = DateFormatter(); f.dateFormat = "HH:mm"; return f
  }()
}

private extension String {
  var isoDateToDate: Date {
    Date.dateFormatter.date(from: self) ?? Date()
  }
  var isoTimeToDate: Date {
    Date.timeFormatter.date(from: self) ?? Date()
  }
}

private extension NumberFormatter {
  static let currency: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.maximumFractionDigits = 2
    return f
  }()
}

