//
//  DetailViewController.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//


import UIKit

final class DetailViewController: UIViewController {


    // MARK: - Properties
    var weather: SearchWeather?
    var weatherViewModel: DetailViewModel?

    // MARK: - Init
    init(weather: SearchWeather? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.weather = weather
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleCityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
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

    private lazy var temperatureStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [temperatureLabel, imageIcon],
                                    axis: .horizontal,
                                    spacing: 4,
                                    distribution: .equalSpacing)
        return stackView
    }()

    private lazy var informationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleCityLabel, temperatureStackView, descriptionForecastLabel],
                                    axis: .vertical,
                                    spacing: 4,
                                    distribution: .equalSpacing)
        return stackView
    }()

    // MARK: - LifeCycleVC
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupGradient()
        setupConstraints()
        setupNavigationBar()
    }

    // MARK: - Metods
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = UIColor.white
    }

    private func setupView() {
        view.addSubview(informationStackView)
        guard let weather else { return }
        configureWeatherForecast(weather: weather)
    }

    private func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.colorLight.cgColor, UIColor.colorDark.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func configureWeatherForecast(weather: SearchWeather) {
        titleCityLabel.text = weather.name.uppercased()

        if Setting.shared.currentLanguage == "en" {
            temperatureLabel.text = "\(Int(weather.main.temp))" + "ºC".localized
        } else {
            temperatureLabel.text = "\(weather.main.temp.celsius)" + "ºC".localized
        }

        descriptionForecastLabel.text = "\(weather.weather.first?.description.firstWordCapitalized() ?? "")"

        FileServiceManager.shared.getImage(from: API.icon.getIconUrl(by: weather.weather.first?.icon ?? "")) { [weak self] image in
            guard let self = self else { return }
            self.imageIcon.image = image
        }
    }
}

// MARK: - Constraints
extension DetailViewController {
    func setupConstraints() {
        informationStackView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
