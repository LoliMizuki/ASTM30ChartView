//
//  ASTM30Point.swift
//
//  Created by Inaba Mizuki on 2016/1/22.
//  Copyright © 2016年 AsenseTek. All rights reserved.
//

import UIKit

// MARK: ASTM30Point

class ASTM30Point: NSObject {

    var key: String

    var value: CGPoint

    init(key: String, value: CGPoint) {
        self.key = key
        self.value = value
    }
}


// MARK: ASTM30PointsInfo

class ASTM30PointsInfo: NSObject {

    var name = String("")

    var lineWidth: CGFloat = 2.0

    var color = UIColor.blackColor()

    var colorInMasked: UIColor? = nil

    var points = [ASTM30Point]()

    var closePath: Bool = true

    init(name: String) {
        super.init()

        self.name = name
    }
}