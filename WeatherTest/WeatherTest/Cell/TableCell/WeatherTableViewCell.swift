//
//  WeatherTableViewCell.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import UIKit
import SnapKit

final class WeatherTableViewCell: UITableViewCell {

    // MARK: - Properties
    static let reuseIdentifier = "WeatherTableViewCell"

    private lazy var dataLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
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
        image.tintColor = .white
        image.layer.cornerRadius = 10
        return image
    }()

    private lazy var informationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [temperatureLabel, descriptionForecastLabel],
                                    axis: .horizontal,
                                    spacing: 16,
                                    distribution: .equalSpacing)
        return stackView
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Metods
    private func setupView() {
        contentView.addSubview(informationStackView)
        contentView.addSubview(dataLabel)
        contentView.addSubview(imageIcon)
        contentView.backgroundColor = UIColor.clear
        setupConstraints()
    }

    private func extractDay(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "dd.MM"
            let timeString = dateFormatter.string(from: date)
            return timeString
        }
        return ""
    }

    func configureCell(with weather: List?) {
        guard let weather else { return }
        dataLabel.text = extractDay(from: weather.dtTxt)
        descriptionForecastLabel.text = "\(weather.weather.first?.description.firstWordCapitalized() ?? "")"
        
        if Setting.shared.currentLanguage == "en" {
            temperatureLabel.text = "\(Int(weather.main.temp))" + "ºC".localized
        } else {
            temperatureLabel.text = "\(weather.main.temp.celsius)" + "ºC".localized
        }

        FileServiceManager.shared.getImage(from: API.icon.getIconUrl(by: weather.weather.first?.icon ?? "")) { [weak self] image in
            guard let self = self else { return }
            self.imageIcon.image = image
        }
    }
}

// MARK: - Constraints
extension WeatherTableViewCell {
    private func setupConstraints() {
        dataLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        imageIcon.snp.makeConstraints { make in
            make.leading.equalTo(dataLabel.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        informationStackView.snp.makeConstraints { make in
            make.leading.equalTo(imageIcon.snp.trailing).inset(8)
            make.centerY.equalToSuperview()
        }
    }
}
