//
//  ASTM30ColorVectorCoordinateSpace.swift
//
//  Created by Inaba Mizuki on 2016/1/22.
//  Copyright © 2016年 AsenseTek. All rights reserved.
//

import UIKit

class ASTM30ColorVectorCoordinateSpace: NSObject {

    var xMin: CGFloat
    var yMin: CGFloat
    var xMax: CGFloat
    var yMax: CGFloat

    var xLength: CGFloat { return xMax - xMin }

    var yLength: CGFloat { return yMax - yMin }

    init(xMin: CGFloat = -200, yMin: CGFloat = -200, xMax: CGFloat = 200, yMax: CGFloat = 200) {
        self.xMin = xMin
        self.xMax = xMax
        self.yMin = yMin
        self.yMax = yMax

        super.init()
    }

    override var description: String {
        return "x: [\(xMin), \(xMax)], y: [\(yMin), \(yMax)]"
    }
}
