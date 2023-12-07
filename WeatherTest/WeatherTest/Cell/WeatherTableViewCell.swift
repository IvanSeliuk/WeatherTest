//
//  WeatherTableViewCell.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import UIKit
import SnapKit

final class WeatherTableViewCell: UITableViewCell {

    // MARK: Properties
    static let reuseIdentifier = "WeatherTableViewCell"

    private lazy var imageNews: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.tintColor = .black
        image.layer.cornerRadius = 10
        return image
    }()

    private lazy var nameTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Optima", size: 16)
        label.textColor = UIColor(named: NameColor.colorTitle.rawValue)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var titleNews: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(named: NameColor.colorTitle.rawValue)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textAlignment = .right
        label.textColor = UIColor(named: NameColor.colorTitle.rawValue)
        return label
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
        [nameTitleLabel, titleNews, dateLabel, imageNews].forEach { views in
            contentView.addSubview(views)
        }
        setupConstraints()
    }

    private func dateFromApiString(_ currentDate: Int) -> String {
        let timeInterval = TimeInterval(currentDate)
        let myNSDate = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_ENG")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.dateFormat = "d MMM yyyy, HH:mm"
        return dateFormatter.string(from: myNSDate)
    }

    func configureCell(with weather: List) {
        titleNews.text = "\(weather.main.temp)"
        nameTitleLabel.text = "Lenta.ru"
        dateLabel.text = dateFromApiString(weather.dt)
//        FileServiceManager.shared.getImage(from: news.headline.titleImage.variants.first?.value.url ?? "",
//                                           completed: { [weak self] image in
//            guard let self = self else { return }
//            self.imageNews.image = image
//        })
    }

    // MARK: - Constraints
    private func setupConstraints() {
        imageNews.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalTo(140)
        }

        nameTitleLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
            make.leading.equalTo(imageNews.snp.trailing).offset(8)
        }

        titleNews.snp.makeConstraints { make in
            make.top.equalTo(nameTitleLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.leading.equalTo(imageNews.snp.trailing).offset(8)
        }
        titleNews.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        dateLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(titleNews.snp.bottom).offset(8)
            make.trailing.bottom.equalToSuperview().inset(8)
            make.leading.equalTo(imageNews.snp.trailing).offset(8)
        }
    }
}

