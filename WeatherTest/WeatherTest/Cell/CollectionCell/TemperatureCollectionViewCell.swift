//
//  TemperatureCollectionViewCell.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import UIKit
import SnapKit

final class TemperatureCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    static let reuseIdentifier = "TemperatureCollectionViewCell"

    private lazy var imageIcon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Metods
    private func setupView() {
        contentView.backgroundColor = .clear
        contentView.addSubview(imageIcon)
        contentView.addSubview(timeLabel)
        contentView.addSubview(temperatureLabel)
        setupConstraints()
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

    func configureCell(with weather: List) {
        timeLabel.text = extractTime(from: weather.dtTxt)

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
extension TemperatureCollectionViewCell {
    private func setupConstraints() {
        timeLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
        }

        imageIcon.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(8)
            make.height.width.equalTo(90)
            make.centerX.equalToSuperview()
        }

        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(imageIcon.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(8)
        }
    }
}
