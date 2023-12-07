//
//  LoadingViewController.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import UIKit
import SnapKit

final class LoadingViewController: UIViewController {

    // MARK: - Properties
    private lazy var textLabel: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = "Weather"
        text.textAlignment = .center
        text.textColor = .white
        text.font = UIFont(name: "MarkerFelt-Wide", size: 60)
        text.alpha = 0
        text.layer.shadowColor = UIColor.black.cgColor
        text.layer.shadowRadius = 5
        text.layer.shadowOpacity = 1
        text.layer.shadowOffset = CGSize(width: 10, height: 0)
        return text
    }()

    private lazy var shadowView: UIView = {
        let viewLabel = UIView()
        viewLabel.frame = view.bounds
        viewLabel.alpha = 0.90
        viewLabel.backgroundColor = UIColor(named: NameColor.colorDark.rawValue)
        return viewLabel
    }()

    // MARK: LifeCycleVc
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        rightShadow()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupCostraints()
    }

    // MARK: - Metods
    private func setupUI() {
        view.addSubview(shadowView)
        view.bringSubviewToFront(shadowView)
        view.backgroundColor = UIColor(named: NameColor.colorLight.rawValue)
        view.addSubview(textLabel)

    }

    private func setupCostraints() {
        textLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }

    private func calcTrig(segment: Segment, size: CGFloat, angle: CGFloat) -> [Segment: CGFloat] {
        switch segment {
        case .coordinateX:
            let coordinateX = size
            let coordinateY = tan(angle * .pi/180) * coordinateX
            let height = coordinateX / cos(angle * .pi/180)
            return [ .coordinateX: coordinateX, .coordinateY: coordinateY, .height: height]
        case .coordinateY:
            let coordinateY = size
            let coordinateX = coordinateY / tan(angle * .pi/180)
            let height = coordinateY / sin(angle * .pi/180)
            return [ .coordinateX: coordinateX, .coordinateY: coordinateY, .height: height]
        case .height:
            let height = size
            let coordinateX = cos(angle * .pi/180) * height
            let coordinateY = sin(angle * .pi/180) * height
            return [ .coordinateX: coordinateX, .coordinateY: coordinateY, .height: height]
        }
    }

    private func rightShadow() {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn) {
            self.textLabel.alpha = 0.75
            self.shadowView.alpha = 0.6
        } completion: { _ in
            self.rightHalfBottomShadow()
        }
    }

    private func rightHalfBottomShadow() {
        UIView.animate(withDuration: 0.75, delay: 0, options: .curveLinear) {
            self.textLabel.alpha = 1
            let trig = self.calcTrig(segment: .height, size: 10, angle: 22.5)
            let coordinateX = trig[.coordinateX]
            let coordinateY = trig[.coordinateY]
            guard let coordinateX = coordinateX, let coordinateY = coordinateY else { return }
            self.textLabel.layer.shadowOffset = CGSize(width: coordinateX, height: coordinateY)
            self.shadowView.alpha = 0.5
        } completion: { _ in
            self.rightBottomShadow()
        }
    }

    private func rightBottomShadow() {
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear) {
            let trig = self.calcTrig(segment: .height, size: 10, angle: 45)
            let coordinateX = trig[.coordinateX]
            let coordinateY = trig[.coordinateY]
            guard let coordinateX = coordinateX, let coordinateY = coordinateY else { return }
            self.textLabel.layer.shadowOffset = CGSize(width: coordinateX, height: coordinateY)
            self.shadowView.alpha = 0.4
        } completion: { _ in
            self.halfRightBottomShadow()
        }
    }

    private func halfRightBottomShadow() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            let trig = self.calcTrig(segment: .height, size: 10, angle: 67.5)
            let coordinateX = trig[.coordinateX]
            let coordinateY = trig[.coordinateY]
            guard let coordinateX = coordinateX, let coordinateY = coordinateY else { return }
            self.textLabel.layer.shadowOffset = CGSize(width: coordinateX, height: coordinateY)
            self.shadowView.alpha = 0.2
        } completion: { _ in
            self.bottomShadow()
        }
    }

    private func bottomShadow() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            let trig = self.calcTrig(segment: .height, size: 10, angle: 90)
            let coordinateX = trig[.coordinateX]
            let coordinateY = trig[.coordinateY]
            guard let coordinateX = coordinateX, let coordinateY = coordinateY else { return }
            self.textLabel.layer.shadowOffset = CGSize(width: coordinateX, height: coordinateY)
            self.shadowView.alpha = 0.3
        } completion: { _ in
            self.halfLeftBottomShadow()
        }
    }

    private func halfLeftBottomShadow() {
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveLinear) {
            let trig = self.calcTrig(segment: .height, size: 10, angle: 112.5)
            let coordinateX = trig[.coordinateX]
            let coordinateY = trig[.coordinateY]
            guard let coordinateX = coordinateX, let coordinateY = coordinateY else { return }
            self.textLabel.layer.shadowOffset = CGSize(width: coordinateX, height: coordinateY)
            self.shadowView.alpha = 0.5
        } completion: { _ in
            self.leftBottomShadow()
        }
    }

    private func leftBottomShadow() {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut) {
            let trig = self.calcTrig(segment: .height, size: 10, angle: 135)
            let coordinateX = trig[.coordinateX]
            let coordinateY = trig[.coordinateY]
            guard let coordinateX = coordinateX, let coordinateY = coordinateY else { return }
            self.textLabel.layer.shadowOffset = CGSize(width: coordinateX, height: coordinateY)
            self.textLabel.alpha = 0.75
            self.shadowView.alpha = 0.7
        } completion: { _ in
            self.lastShadow()
        }
    }

    private func lastShadow() {
        UIView.animate(withDuration: 1.8, delay: 0, options: .curveEaseOut) {
            let trig = self.calcTrig(segment: .height, size: 10, angle: 157.5)
            let coordinateX = trig[.coordinateX]
            let coordinateY = trig[.coordinateY]
            guard let coordinateX = coordinateX, let coordinateY = coordinateY else { return }
            self.textLabel.layer.shadowOffset = CGSize(width: coordinateX, height: coordinateY)
            self.textLabel.alpha = 0
            self.shadowView.alpha = 1.0
        } completion: { _ in
            let viewController = WeatherViewController()
            self.animationPushViewController(to: viewController)
        }
    }

    private func animationPushViewController(to viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.75
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = .fromRight
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
