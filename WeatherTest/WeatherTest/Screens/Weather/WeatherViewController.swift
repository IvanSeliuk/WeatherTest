//
//  WeatherViewController.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import UIKit
import CoreLocation

protocol Weather {}

class WeatherViewController: UIViewController {

    var locationManager = CLLocationManager()

    private var weather: Weather? {
        didSet {
            tableView.reloadData()
            collectionView.reloadData()
        }
    }

    var header: [AnyHashable: Any]?

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    lazy var titleCityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 56, weight: .light)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    lazy var descriptionForecastLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
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

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        label.textAlignment = .center
        label.textColor = .white
        label.text = ""
        return label
    }()

    lazy var loaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.5
        view.isHidden = true
        return view
    }()

    lazy var temperatureStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [temperatureLabel, imageIcon],
                                    axis: .horizontal,
                                    spacing: 4,
                                    distribution: .equalSpacing)
        return stackView
    }()

    lazy var informationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, titleCityLabel, temperatureStackView, descriptionForecastLabel],
                                    axis: .vertical,
                                    spacing: 4,
                                    distribution: .equalSpacing)
        return stackView
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(TemperatureCollectionViewCell.self,
                                forCellWithReuseIdentifier: TemperatureCollectionViewCell.reuseIdentifier)
        collectionView.layer.cornerRadius = 10
        collectionView.layer.borderColor = UIColor.lightGray.cgColor
        collectionView.layer.borderWidth = 1
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(WeatherTableViewCell.self,
                       forCellReuseIdentifier: WeatherTableViewCell.reuseIdentifier)
        table.backgroundColor = UIColor.clear
        table.layer.cornerRadius = 10
        table.layer.borderColor = UIColor.lightGray.cgColor
        table.layer.borderWidth = 1
        table.allowsSelection = false
        table.showsVerticalScrollIndicator = false
        return table
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .white
        indicator.style = .large
        return indicator
    }()

    private lazy var searchBarButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 23)
        button.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: config), for: .normal)
        button.addTarget(self, action: #selector(searchBarButtonAction), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()

    private lazy var ruLocalizeButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "RU"
        button.style = .plain
        button.tintColor = .white
        button.tag = 0
        button.target = self
        button.action = #selector(ruLocalizeButtonAction)
        return button
    }()

    private lazy var enLocalizeButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "EN"
        button.style = .plain
        button.tintColor = .white
        button.tag = 1
        button.target = self
        button.action = #selector(enLocalizeButtonAction)
        return button
    }()

    private lazy var textFieldCity: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Weather in your city..."
        textField.returnKeyType = .done
        textField.borderStyle = .roundedRect
        textField.clipsToBounds = true
        textField.isHidden = true
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.autocapitalizationType = .words
        textField.backgroundColor = .white
        textField.delegate = self
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupNavigationBar()
        setupGradient()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationEnabled()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textFieldCity.resignFirstResponder()
    }

    private func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.colorLight.cgColor, UIColor.colorDark.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBarButton)
        navigationItem.leftBarButtonItems = [ruLocalizeButton, enLocalizeButton]
        navigationItem.titleView = dateLabel
    }

    private func setupView() {
        [informationStackView, collectionView, tableView, activityIndicator, textFieldCity, loaderView].forEach { views in
            view.addSubview(views)
        }
    }

    private func setupConstraints() {
        textFieldCity.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.centerX.equalToSuperview()
        }

        informationStackView.snp.makeConstraints { make in
            make.top.equalTo(textFieldCity.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(informationStackView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(160)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(24)
        }

        loaderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureWeatherForecast(weather: Weather) {
        if let weather = weather as? CoordinateWeather {
            titleLabel.text = "My Location".localized
            titleCityLabel.text = weather.city.name.uppercased()

            guard let item = weather.list.first else { return }
            setLocalized(weather: weather)
            descriptionForecastLabel.text = "\(item.weather.first?.description.firstWordCapitalized() ?? "")"

            FileServiceManager.shared.getImage(from: API.icon.getIconUrl(by: item.weather.first?.icon ?? "")) { [weak self] image in
                guard let self = self else { return }
                self.imageIcon.image = image
            }
        }
    }

    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func alertInternetConnection() {
        let alertController = UIAlertController(title: "No Internet connection",
                                                message: "Please, connect to the Internet. Would you like to download the data from the cache?",
                                                preferredStyle: .alert)
        let loadCache = UIAlertAction(title: "Yes", style: .default) {_ in
            self.weather = FileServiceManager.shared.loadWeatherData()
            guard let weather = self.weather else { return }
            self.configureWeatherForecast(weather: weather)
            self.lastUpdate()
            print("Нажата первая кнопка")
        }
        let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)

        alertController.addAction(loadCache)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func sendCoordinatesToAPI(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        activityIndicator.startAnimating()
        loaderView.isHidden = false
        NetworkManager.shared.getWeatherData(with: API.coordinate.getCoordinate(lat: latitude,
                                                                                lon: longitude)) {
            [self] (result: Result<CoordinateWeather, APError>, header) in
            self.activityIndicator.stopAnimating()
            loaderView.isHidden = true
            switch result {
            case .success(let weather):
                self.weather = weather
                print()
                FileServiceManager.shared.saveWeatherData(weather)
                self.configureWeatherForecast(weather: weather)
            case .failure(let error):
                switch error {
                case .invalidData: self.invalidDataAlert()
                case .invalidResponse: self.invalidResponseAlert()
                case .invalidURL: self.invalidURLAlert()
                case .unableToComplete: self.unableToCompleteAlert()
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

    func extractTime(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "HH"
            let timeString = dateFormatter.string(from: date)
            return timeString
        }
        return ""
    }

    func setLocalized(weather: Weather) {
        if let weather = weather as? CoordinateWeather {
            guard let item = weather.list.first else { return }
            if Setting.shared.currentLanguage == "en" {
                temperatureLabel.text = "\(Int(item.main.temp))" + "ºC".localized
            } else {
                temperatureLabel.text = "\(item.main.temp.celsius)" + "ºC".localized
            }
        }
    }

    private func lastUpdate() {
        let currentDate = Date()
        let timeDifference = currentDate.timeIntervalSince(Setting.shared.requestDate)

        let timeDifferenceOfMinute = Int(timeDifference) / 60
        let timeDifferenceInterval = UpdateDate(timeDifference: timeDifferenceOfMinute)

        switch timeDifferenceInterval {
        case .lessThanMinute:
            dateLabel.text = "Uploaded: less than a min"
        case .fromMinuteToHour:
            dateLabel.text = "Uploaded: \(timeDifferenceOfMinute) min ago"
        case .fromHourTo23Hours:
            dateLabel.text = "Uploaded: \(timeDifferenceOfMinute) / 60) hour ago"
        case .moreThanDay:
            dateLabel.text = "Uploaded: \(timeDifferenceOfMinute) / 60 / 24) day ago"
        }
    }

    private func reloadView() {
        guard let weather else { return }
        setLocalized(weather: weather)
        tableView.reloadData()
        collectionView.reloadData()
    }

    @objc private func searchBarButtonAction() {
        textFieldCity.isHidden.toggle()
    }

    @objc private func ruLocalizeButtonAction(_ sender: UIBarButtonItem) {
        Setting.shared.currentLanguage = Setting.shared.languageCode[sender.tag]
        reloadView()
    }

    @objc private func enLocalizeButtonAction(_ sender: UIBarButtonItem) {
        Setting.shared.currentLanguage = Setting.shared.languageCode[sender.tag]
        reloadView()
    }
}

// MARK: - CollectionViewDataSource
extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemperatureCollectionViewCell.reuseIdentifier, for: indexPath) as? TemperatureCollectionViewCell else {
            return UICollectionViewCell()
        }
        if let weather = weather as? CoordinateWeather {
            cell.configureCell(with: weather.list[indexPath.item])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return (CGSize(width: 80, height: 160))
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension WeatherViewController: UICollectionViewDelegateFlowLayout {}

// MARK: - TableViewDelegate
extension WeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - TableViewDataSource
extension WeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let weather = weather as? CoordinateWeather else {
            return 0
        }
        return weather.list.filter({ extractTime(from: $0.dtTxt) == "12" }).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? WeatherTableViewCell else {
            return UITableViewCell()
        }
        if let weather = weather as? CoordinateWeather {
            let item = weather.list.filter({ extractTime(from: $0.dtTxt) == "12" })[indexPath.row]
            cell.configureCell(with: item)
        }
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - LocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        if NetworkMonitor.shared.isConnected {
            sendCoordinatesToAPI(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        } else {
            self.alertInternetConnection()
        }
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

// MARK: - TextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let city = textField.text {
            NetworkManager.shared.getWeatherData(with: API.citySearch.getCity(by: city)) { [self] (result: Result<SearchWeather, APError>, header) in
                switch result {
                case .success(let weather):
                    self.weather = weather
                    let viewController = DetailViewController(weather: weather)
                    navigationController?.pushViewController(viewController, animated: true)
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
        textField.text = ""
        return true
    }
}
