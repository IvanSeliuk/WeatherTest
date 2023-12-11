//
//  LoadingViewModel.swift
//  WeatherTest
//
//  Created by Иван Селюк on 11.12.23.
//

import Foundation

final class LoadingViewModel {
    
    func calcTrig(segment: Segment, size: CGFloat, angle: CGFloat) -> [Segment: CGFloat] {
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
}
