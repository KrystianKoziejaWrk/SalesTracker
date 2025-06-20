//
//  SheetAPI.swift
//  SalesTracker
//
//  Created by Krystian Kozieja on 6/16/25.
//

import Foundation

final class SheetAPI {
  static let shared = SheetAPI()
  private let baseURL = Constants.apiBaseURL
  private let secret  = Constants.apiSecret

  // Push a new sale
  func appendSale(_ sale: Sale, completion: @escaping (Result<Void,Error>) -> Void) {
    guard let sheetId = UserDefaults.standard.string(forKey: "sheetId") else {
      return completion(.failure(NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey:"Missing sheetId"])))
    }
    let url = URL(string: "\(baseURL)/appendSale")!
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue(secret, forHTTPHeaderField: "x-app-secret")
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")

    var body = sale.dictionary
    body["sheetId"] = sheetId

    do {
      req.httpBody = try JSONSerialization.data(withJSONObject: body)
    } catch {
      return completion(.failure(error))
    }

    URLSession.shared.dataTask(with: req) { _, resp, err in
      if let err = err { return completion(.failure(err)) }
      completion(.success(()))
    }.resume()
  }

  // Fetch all sales
  func getSales(completion: @escaping (Result<[Sale],Error>) -> Void) {
    guard let sheetId = UserDefaults.standard.string(forKey: "sheetId") else {
      return completion(.failure(NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey:"Missing sheetId"])))
    }
    let url = URL(string: "\(baseURL)/getSales?sheetId=\(sheetId)")!
    var req = URLRequest(url: url)
    req.setValue(secret, forHTTPHeaderField: "x-app-secret")

    URLSession.shared.dataTask(with: req) { data, _, err in
      if let err = err { return completion(.failure(err)) }
      guard let data = data else { return completion(.success([])) }
      do {
        let sales = try JSONDecoder().decode([Sale].self, from: data)
        completion(.success(sales))
      } catch {
        completion(.failure(error))
      }
    }.resume()
  }
}
