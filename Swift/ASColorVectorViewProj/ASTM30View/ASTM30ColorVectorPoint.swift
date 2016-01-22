//
//  ASTM30ColorVectorPoint.swift
//
//  Created by Inaba Mizuki on 2016/1/22.
//  Copyright © 2016年 AsenseTek. All rights reserved.
//

import UIKit

// MARK: ASTM30ColorVectorPoint

class ASTM30ColorVectorPoint: NSObject {

    var key: String

    var value: CGPoint

    init(key: String, value: CGPoint) {
        self.key = key
        self.value = value
    }
}


// MARK: ASTM30ColorVectorPointsInfo

class ASTM30ColorVectorPointsInfo: NSObject {

    var name = String("")

    var lineWidth: CGFloat = 2.0

    var color = UIColor.blackColor()

    var points = [ASTM30ColorVectorPoint]()

    var closePath: Bool = true

    init(name: String) {
        super.init()

        self.name = name
    }
}
