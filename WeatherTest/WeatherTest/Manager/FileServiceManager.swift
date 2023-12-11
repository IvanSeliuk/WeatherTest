//
//  FileServiceManager.swift
//  WeatherTest
//
//  Created by Иван Селюк on 10.12.23.
//

import UIKit

final class FileServiceManager {

    static let shared = FileServiceManager()
    private let cacheDirectory: URL
    private let pathComponent = "weatherCache.json"
    
    private init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        self.cacheDirectory = paths[0].appendingPathComponent("WeatherCache")
    }

    fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    func getImage(from stringUrl: String, completed: @escaping (UIImage?) -> Void) {
        let pathImage = stringUrl.replacingOccurrences(of: "https://", with: "")
        let imageUrl = cacheDirectory.appendingPathComponent(pathImage)
        if !directoryExistsAtPath(imageUrl.deletingLastPathComponent().path) {
            do {
                try FileManager.default.createDirectory(atPath: imageUrl.deletingLastPathComponent().path,
                                                        withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        guard let dataImage = FileManager.default.contents(atPath: imageUrl.path)
        else {
            DispatchQueue.global().async {
                guard let url = URL(string: stringUrl) else { return }

                if let newDataImage = try? Data(contentsOf: url) {
                    do {
                        try newDataImage.write(to: imageUrl)
                        DispatchQueue.main.async {
                            completed(UIImage(data: newDataImage))
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            return
        }
        DispatchQueue.main.async {
            completed(UIImage(data: dataImage))
        }
    }

    func saveWeatherData(_ weather: CoordinateWeather) {
        do {
            let data = try JSONEncoder().encode(weather)
            try createCacheDirectoryIfNotExists()
            let fileURL = cacheDirectory.appendingPathComponent(pathComponent)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save weather data to cache: \(error)")
        }
    }

    func loadWeatherData() -> CoordinateWeather? {
        do {
            let fileURL = cacheDirectory.appendingPathComponent(pathComponent)
            let data = try Data(contentsOf: fileURL)
            let weather = try JSONDecoder().decode(CoordinateWeather.self, from: data)
            return weather
        } catch {
            print("Failed to load weather data from cache: \(error)")
            return nil
        }
    }

    private func createCacheDirectoryIfNotExists() throws {
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
