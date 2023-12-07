//
//  WeatherViewController.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    var locationManager = CLLocationManager()

    private var weather: Weather? {
        didSet {
//            tableView.reloadData()
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My Location"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(named: NameColor.colorTitle.rawValue)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    lazy var titleCityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.textAlignment = .center
        label.textColor = UIColor(named: NameColor.colorTitle.rawValue)
        return label
    }()

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(named: NameColor.colorTitle.rawValue)
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(named: NameColor.colorTitle.rawValue)
        return label
    }()

    private lazy var imageIcon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.tintColor = .black
        image.layer.cornerRadius = 10
        return image
    }()

    lazy var temperatureStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [temperatureLabel, imageIcon],
                                    axis: .horizontal,
                                    spacing: 4,
                                    distribution: .equalSpacing)
        return stackView
    }()

    lazy var informationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, titleCityLabel, temperatureStackView, descriptionLabel],
                                    axis: .vertical,
                                    spacing: 4,
                                    distribution: .equalSpacing)
        return stackView
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(WeatherTableViewCell.self, forCellReuseIdentifier: WeatherTableViewCell.reuseIdentifier)
        table.backgroundColor = UIColor(named: NameColor.colorView.rawValue)
        return table
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = UIColor(named: NameColor.colorTitle.rawValue)
        indicator.style = .large
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }

    func setupConstraints() {
        informationStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationEnabled()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    func setupLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }



    func sendCoordinatesToAPI(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        //loading true
                NetworkManager.shared.getWeatherData(with: API.coordinate.getCoordinate(lat: latitude, lon: longitude)) { [self] result in
                        //loading false
                        switch result {
                        case .success(let weather):
                            self.weather = weather
                            print()
                        case .failure(let error):
                            switch error {
                            case .invalidData: self.invalidDataAlert()
                            case .invalidResponse: self.invalidResponseAlert()
                            case .invalidURL: self.invalidURLAlert()
                            case .unableToComplete: self.unableToCompleteAlert()
                            }
                        }
                    }
    }
}

// MARK: - TableViewDelegate
extension WeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }
}

// MARK: - TableViewDataSource
extension WeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfRows = weather?.list.count else { return 0}
        return numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? WeatherTableViewCell else {
            return UITableViewCell()
        }
        guard let item = weather?.list[indexPath.row] else {
            return UITableViewCell()
        }
        cell.configureCell(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        animationPushViewController(to: viewController)
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           guard let location = locations.last else {
               return
           }

           sendCoordinatesToAPI(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

        print("Location update method called")

           locationManager.stopUpdatingLocation()
       }

    func checkLocationEnabled() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.setupLocationManager()
                    self.checkAuthorization()
                }
            } else {
                self.presentSettingsLocationAlert()
            }
        }
    }
    func checkAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied:
            print("user dont allow")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default: break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization()
    }

}
