import SwiftUI

struct HomeView: View {
    @AppStorage("knocked") private var knocked: Int = 0
    @AppStorage("answered") private var answered: Int = 0
    @AppStorage("sold") private var sold: Int = 0

    @ObservedObject var salesVM = SalesListViewModel()

    var totalRevenue: Double {
        salesVM.sales.reduce(0) { $0 + ($1.cost ?? 0) + ($1.tip ?? 0) }
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("Total Revenue: $\(totalRevenue, specifier: "%.2f")")
                .font(.title2)
                .bold()
                .padding(.top)
            CounterView(title: "Knocked", value: $knocked)
            CounterView(title: "Answered", value: $answered)
            CounterView(title: "Sold", value: $sold)
        }
        .padding()
        .navigationTitle("Home")
        .onAppear {
            let sheetId = UserDefaults.standard.string(forKey: "sheetId") ?? ""
            salesVM.loadSales(sheetId: sheetId)
        }
    }
}

struct CounterView: View {
    let title: String
    @Binding var value: Int

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
            HStack(spacing: 16) {
                Button(action: { value -= 1 }) {
                    Image(systemName: "minus.circle")
                        .font(.title)
                }
                Text("\(value)")
                    .font(.largeTitle)
                    .frame(width: 60)
                Button(action: { value += 1 }) {
                    Image(systemName: "plus.circle")
                        .font(.title)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
