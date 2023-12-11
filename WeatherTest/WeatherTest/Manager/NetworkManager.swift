//
//  NetworkManager.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import UIKit

final class NetworkManager {

    static let shared = NetworkManager()

    private init() {}

    func getWeatherData<T: Decodable>(with url: URL?,
                        completion: @escaping (Result<T, APError>, [AnyHashable: Any]?) -> Void) {
        guard let url = url else {
            DispatchQueue.main.async {
                completion(.failure(.invalidURL), nil)
            }
            return
        }

        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let _ = error {
                DispatchQueue.main.async {
                    completion(.failure(.unableToComplete), nil)
                }
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse), nil)
                }
                return
            }
            let headers = httpResponse.allHeaderFields

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidData), headers)
                }
                return
            }

            do {
                let weather = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(weather), headers)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.invalidData), headers)
                }
            }
        }
        .resume()
    }
}
