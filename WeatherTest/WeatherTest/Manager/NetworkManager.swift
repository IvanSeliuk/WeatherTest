//
//  NetworkManager.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import UIKit

final class NetworkManager {

    static let shared = NetworkManager()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}
    
    func getWeatherData(with url: URL?,
                       completion: @escaping (Result<Weather, APError>) -> Void) {
        guard let url else {
            DispatchQueue.main.async {
                completion(.failure(.invalidURL))
            }
            return
        }
        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let _ = error {
                DispatchQueue.main.async {
                    completion(.failure(.unableToComplete))
                }
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }

            guard let data else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                }
                return
            }

            do {
                let weather = try JSONDecoder().decode(Weather.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(weather))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                }
            }
        }
        .resume()
    }

    func downloadImage(with url: String,
                       completion: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: url)
        if let image = cache.object(forKey: cacheKey) {
            DispatchQueue.main.async {
                completion(image)
            }
            return
        }
        guard let url = URL(string: url) else {
            completion(nil)
            return
        }
        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
            guard let data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            self.cache.setObject(image, forKey: cacheKey)
            DispatchQueue.main.async {
                completion(image)
            }
        }
        .resume()
    }
}
