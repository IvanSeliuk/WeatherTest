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

    // MARK: - Properties
    var weatherViewModel: WeatherViewModel?
    var locationManager = CLLocationManager()

    private var weather: Weather? {
        didSet {
            tableView.reloadData()
            collectionView.reloadData()
        }
    }

    private let numberOfItemsForDay = 9
    private var header: [AnyHashable: Any]?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var titleCityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 56, weight: .light)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private lazy var descriptionForecastLabel: UILabel = {
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

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        label.textAlignment = .center
        label.textColor = .white
        label.text = ""
        return label
    }()

    private lazy var loaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.5
        view.isHidden = true
        return view
    }()

    private lazy var temperatureStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [temperatureLabel, imageIcon],
                                    axis: .horizontal,
                                    spacing: 4,
                                    distribution: .equalSpacing)
        return stackView
    }()

    private lazy var informationStackView: UIStackView = {
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

    // MARK: - LifeCycleVC
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewModelInitialization()
        weatherViewModel?.weatherDelegate = self
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

    // MARK: - Metods
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

    private func viewModelInitialization() {
        weatherViewModel = WeatherViewModel(weather: weather)
    }

    private func configureWeatherForecast(weather: Weather?) {
        if let weather = weather as? CoordinateWeather {
            titleLabel.text = "My Location".localized
            titleCityLabel.text = weather.city.name.uppercased()

            guard let item = weather.list.first else { return }
            temperatureLabel.text = "\(weatherViewModel?.setLocalized(weather: weather) ?? "")" + "ºC".localized
            descriptionForecastLabel.text = "\(item.weather.first?.description.firstWordCapitalized() ?? "")"

            FileServiceManager.shared.getImage(from: API.icon.getIconUrl(by: item.weather.first?.icon ?? "")) { [weak self] image in
                guard let self = self else { return }
                self.imageIcon.image = image
            }
        }
    }
}

// MARK: - Constraints
extension WeatherViewController {
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
}

// MARK: - @objcMetods
extension WeatherViewController {
    @objc private func searchBarButtonAction() {
        textFieldCity.isHidden.toggle()
    }

    @objc private func ruLocalizeButtonAction(_ sender: UIBarButtonItem) {
        Setting.shared.currentLanguage = Setting.shared.languageCode[sender.tag]
        temperatureLabel.text = weatherViewModel?.setLocalized(weather: weather) ?? "" + "ºC".localized
        weatherViewModel?.reloadView()
    }

    @objc private func enLocalizeButtonAction(_ sender: UIBarButtonItem) {
        Setting.shared.currentLanguage = Setting.shared.languageCode[sender.tag]

        temperatureLabel.text = weatherViewModel?.setLocalized(weather: weather) ?? "" + "ºC".localized
        weatherViewModel?.reloadView()
    }
}

// MARK: - CollectionViewDataSource
extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsForDay
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemperatureCollectionViewCell.reuseIdentifier, for: indexPath) as? TemperatureCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configureCell(with: weatherViewModel?.cellForItemCollectionView(at: indexPath.row))
        
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
        return weatherViewModel?.numberOfRowsTableView() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? WeatherTableViewCell else {
            return UITableViewCell()
        }

        cell.configureCell(with: weatherViewModel?.filterWeatherCellForRow(at: indexPath.row))
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
        weatherViewModel?.checkNetworkConnection(latitude: location.coordinate.latitude, 
                                                 longitude: location.coordinate.longitude)
        locationManager.stopUpdatingLocation()
    }

    private func checkLocationEnabled() {
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

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func checkAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied:
            print("User don't allow")
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
        weatherViewModel?.getWeatherFrom(city: textField.text)
        textField.text = ""
        return true
    }
}

// MARK: - WeatherViewModelDelegate
extension WeatherViewController: WeatherViewModelDelegate {
    func didReloadStackView() {
        if let weather = weatherViewModel?.weather {
            configureWeatherForecast(weather: weather)
        }
    }

    func didStartFetchingData() {
        activityIndicator.startAnimating()
        loaderView.isHidden = false
    }

    func didFinishFetchingData() {
        activityIndicator.stopAnimating()
        loaderView.isHidden = true
    }

    func updateBordersAndCornerRadius() {
        tableView.layer.cornerRadius = 10
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 1
        collectionView.layer.cornerRadius = 10
        collectionView.layer.borderColor = UIColor.lightGray.cgColor
        collectionView.layer.borderWidth = 1
    }

    func didReloadListView() {
        tableView.reloadData()
        collectionView.reloadData()
    }

    func alertInternetConnection() {
        let alertController = UIAlertController(title: "No Internet connection",
                                                message: "Please, connect to the Internet. Would you like to download the data from the cache?",
                                                preferredStyle: .alert)
        let loadCache = UIAlertAction(title: "Yes", style: .default) {_ in
            self.weatherViewModel?.weather = FileServiceManager.shared.loadWeatherData()
            self.dateLabel.text = self.weatherViewModel?.timeIntervalCalculation()
            self.updateBordersAndCornerRadius()
            self.weatherViewModel?.reloadView()
        }
        let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)

        alertController.addAction(loadCache)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func pushViewController(weather: SearchWeather) {
        let viewController = DetailViewController(weather: weather)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func invalidDataAlert() {
        let alertController = UIAlertController(title: "Server Error",
                                                message: "The data received from the server was invalid. Please contact support.",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    //MARK: - Network Alert
    func invalidResponseAlert() {
        let alertController = UIAlertController(title: "Server Error",
                                                message: "Invalid response from the server. Please try again later or contact support.",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func invalidURLAlert() {
        let alertController = UIAlertController(title: "Server Error",
                                                message: "There was an issue connecting to the server. If this persists, please contact support.",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func unableToCompleteAlert() {
        let alertController = UIAlertController(title: "Server Error",
                                                message: "Unable to complete your request at this time. Please check your internet connection.",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
