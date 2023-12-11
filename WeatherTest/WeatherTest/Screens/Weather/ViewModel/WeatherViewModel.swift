//
//  WeatherViewModel.swift
//  WeatherTest
//
//  Created by Иван Селюк on 11.12.23.
//

import Foundation
import CoreLocation

protocol WeatherViewModelDelegate: AnyObject {
    func didReloadListView()
    func didReloadStackView()
    func didStartFetchingData()
    func didFinishFetchingData()
    func alertInternetConnection()
    func pushViewController(weather: SearchWeather)
    func invalidDataAlert()
    func invalidResponseAlert()
    func invalidURLAlert()
    func unableToCompleteAlert()
    func updateBordersAndCornerRadius()
}

final class WeatherViewModel {

    weak var weatherDelegate: WeatherViewModelDelegate?
    var weather: Weather?

    // MARK: - Init
    init(weather: Weather?) {
        self.weather = weather
    }

    // MARK: Metods TableView
    func numberOfRowsTableView() -> Int {
        guard let weather = weather as? CoordinateWeather else {
            return 0
        }
        return weather.list.filter({ extractTime(from: $0.dtTxt) == "12" }).count
    }

    func filterWeatherCellForRow(at index: Int) -> List? {
        guard let weather = weather as? CoordinateWeather else {
            return nil
        }
        return weather.list.filter({ extractTime(from: $0.dtTxt) == "12" })[index]
    }

    private func extractTime(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "HH"
            let timeString = dateFormatter.string(from: date)
            return timeString
        }
        return ""
    }

    // MARK: - Metods CollectionView
    func cellForItemCollectionView(at index: Int) -> List? {
        guard let weather = weather as? CoordinateWeather else {
            return nil
        }
           return weather.list[index]
    }


    // MARK: - ReloadView
    func reloadView() {
        weatherDelegate?.didReloadListView()
        weatherDelegate?.didReloadStackView()
    }

    func setLocalized(weather: Weather?) -> String {
        guard let weather = weather as? CoordinateWeather, let item = weather.list.first else {
            return ""
        }

        let temperatureValue: String
        if Setting.shared.currentLanguage == "en" {
            temperatureValue = "\(Int(item.main.temp))"
        } else {
            temperatureValue = "\(item.main.temp.celsius)"
        }
        return temperatureValue
    }

    // MARK: - REST API
    func sendCoordinatesToAPI(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        weatherDelegate?.didStartFetchingData()
        NetworkManager.shared.getWeatherData(with: API.coordinate.getCoordinate(lat: latitude,
                                                                                lon: longitude)) {
            [self] (result: Result<CoordinateWeather, APError>, header) in
            self.weatherDelegate?.didFinishFetchingData()
            self.weatherDelegate?.updateBordersAndCornerRadius()
            switch result {
            case .success(let weather):
                self.weather = weather
                self.reloadView()
                FileServiceManager.shared.saveWeatherData(weather)
            case .failure(let error):
                switch error {
                case .invalidData: self.weatherDelegate?.invalidDataAlert()
                case .invalidResponse: self.weatherDelegate?.invalidResponseAlert()
                case .invalidURL: self.weatherDelegate?.invalidURLAlert()
                case .unableToComplete: self.weatherDelegate?.unableToCompleteAlert()
                }
            }

            if let headers = header, let dateString = headers[AnyHashable("Date")] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"

                if let date = dateFormatter.date(from: dateString) {
                    dateFormatter.dateFormat = "HH:mm:ss"
                    Setting.shared.requestDate = date
                }
            }
        }
    }

    func checkNetworkConnection(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        if NetworkMonitor.shared.isConnected {
            sendCoordinatesToAPI(latitude: latitude, longitude: longitude)
        } else {

            weatherDelegate?.alertInternetConnection()
        }
    }

    func getWeatherFrom(city: String?) {
        if let city = city {
            NetworkManager.shared.getWeatherData(with: API.citySearch.getCity(by: city)) { [self] (result: Result<SearchWeather, APError>, header) in
                switch result {
                case .success(let weather):
                    self.weather = weather
                    self.weatherDelegate?.pushViewController(weather: weather)
                case .failure(let error):
                    switch error {
                    case .invalidData: self.weatherDelegate?.invalidDataAlert()
                    case .invalidResponse: self.weatherDelegate?.invalidResponseAlert()
                    case .invalidURL: self.weatherDelegate?.invalidURLAlert()
                    case .unableToComplete: self.weatherDelegate?.unableToCompleteAlert()
                    }
                }
            }
        }
    }

    // MARK: - SetupUI
    func timeIntervalCalculation() -> String {
        let currentDate = Date()
        let timeDifference = currentDate.timeIntervalSince(Setting.shared.requestDate)

        let timeDifferenceOfMinute = Int(timeDifference) / 60
        let timeDifferenceInterval = UpdateDate(timeDifference: timeDifferenceOfMinute)

        var dateLabelText: String

        switch timeDifferenceInterval {
        case .lessThanMinute:
            dateLabelText = "Uploaded: less than a min"
        case .fromMinuteToHour:
            dateLabelText = "Uploaded: \(timeDifferenceOfMinute) min ago"
        case .fromHourTo23Hours:
            dateLabelText = "Uploaded: \((timeDifferenceOfMinute) / 60) hour ago"
        case .moreThanDay:
            dateLabelText = "Uploaded: \((timeDifferenceOfMinute) / 60 / 24) day ago"
        }

        return dateLabelText
    }
}
