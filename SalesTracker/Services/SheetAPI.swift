import Foundation

struct RequestSale: Codable {
  let sheetId:   String
  let whoSold:   String
  let name:      String
  let cost:      Double?
  let tip:       Double?
  let notes:     String
  let phone:     String?
  let dateOfJob: String
  let timeOfJob: String
  let collected: Double?
  let worked:    String
  let address:   String?
}

enum APIError: Error {
  case invalidURL
  case networkError(Error)
  case serverError(status: Int, message: String)
  case decodingError(Error)
  case unknownResponse
}

final class SheetAPI {
  static let shared = SheetAPI()
  private let baseURL = "https://us-central1-salestrackerbackend.cloudfunctions.net/api"
  private let secret  = "door2door123!@#"
  private init() {}

  func appendSale(_ sale: Sale,
                  completion: @escaping (Result<Bool,APIError>) -> Void)
  {
    guard let url = URL(string: baseURL + "/appendSale") else {
      return completion(.failure(.invalidURL))
    }
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue(secret, forHTTPHeaderField: "x-app-secret")
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let liveSheetId = UserDefaults.standard.string(forKey: "sheetId") ?? sale.sheetId
    let reqObj = RequestSale(
      sheetId:   liveSheetId,
      whoSold:   sale.whoSold,
      name:      sale.name,
      cost:      sale.cost,
      tip:       sale.tip,
      notes:     sale.notes,
      phone:     sale.phone,
      dateOfJob: sale.dateOfJob,
      timeOfJob: sale.timeOfJob,
      collected: sale.collected,
      worked:    sale.worked,
      address:   sale.address
    )

    do {
      req.httpBody = try JSONEncoder().encode(reqObj)
    } catch {
      return completion(.failure(.decodingError(error)))
    }

    URLSession.shared.dataTask(with: req) { data, resp, err in
      if let err = err { return completion(.failure(.networkError(err))) }
      guard let http = resp as? HTTPURLResponse, let data = data else {
        return completion(.failure(.unknownResponse))
      }
      if http.statusCode == 200 {
        let ok = (try? JSONDecoder().decode([String:Bool].self, from: data)["success"]) ?? false
        completion(.success(ok))
      } else {
        completion(.failure(.serverError(
          status: http.statusCode,
          message: HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
        )))
      }
    }.resume()
  }

  func getSales(sheetId: String,
                completion: @escaping (Result<[Sale],APIError>) -> Void)
  {
    guard var comps = URLComponents(string: baseURL + "/getSales") else {
      return completion(.failure(.invalidURL))
    }
    comps.queryItems = [ URLQueryItem(name: "sheetId", value: sheetId) ]
    guard let url = comps.url else {
      return completion(.failure(.invalidURL))
    }
    var req = URLRequest(url: url)
    req.setValue(secret, forHTTPHeaderField: "x-app-secret")

    URLSession.shared.dataTask(with: req) { data, resp, err in
      if let err = err { return completion(.failure(.networkError(err))) }
      guard let http = resp as? HTTPURLResponse, let data = data else {
        return completion(.failure(.unknownResponse))
      }
      if http.statusCode == 200 {
        do {
          let list = try JSONDecoder().decode([Sale].self, from: data)
          completion(.success(list))
        } catch {
          completion(.failure(.decodingError(error)))
        }
      } else {
        completion(.failure(.serverError(
          status: http.statusCode,
          message: HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
        )))
      }
    }.resume()
  }

  func updateSale(_ sale: Sale,
                 completion: @escaping (Result<Bool,APIError>) -> Void)
  {
    guard let rowIndex = sale.rowIndex else {
      return completion(.failure(.invalidURL)) // Or a custom error for missing rowIndex
    }
    guard let url = URL(string: baseURL + "/updateSale") else {
      return completion(.failure(.invalidURL))
    }
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue(secret, forHTTPHeaderField: "x-app-secret")
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let liveSheetId = UserDefaults.standard.string(forKey: "sheetId") ?? sale.sheetId
    let reqObj: [String: Any] = [
      "sheetId": liveSheetId,
      "rowIndex": rowIndex,
      "whoSold": sale.whoSold,
      "name": sale.name,
      "cost": sale.cost ?? 0,
      "tip": sale.tip ?? 0,
      "notes": sale.notes,
      "phone": sale.phone ?? "",
      "dateOfJob": sale.dateOfJob,
      "timeOfJob": sale.timeOfJob,
      "collected": sale.collected ?? 0,
      "worked": sale.worked,
      "address": sale.address ?? ""
    ]
    do {
      req.httpBody = try JSONSerialization.data(withJSONObject: reqObj, options: [])
    } catch {
      return completion(.failure(.decodingError(error)))
    }

    URLSession.shared.dataTask(with: req) { data, resp, err in
      if let err = err { return completion(.failure(.networkError(err))) }
      guard let http = resp as? HTTPURLResponse, let data = data else {
        return completion(.failure(.unknownResponse))
      }
      if http.statusCode == 200 {
        let ok = (try? JSONDecoder().decode([String:Bool].self, from: data)["success"]) ?? false
        completion(.success(ok))
      } else {
        completion(.failure(.serverError(
          status: http.statusCode,
          message: HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
        )))
      }
    }.resume()
  }
}
