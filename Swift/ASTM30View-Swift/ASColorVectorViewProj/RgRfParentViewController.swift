//
//  RgRfParentViewController.swift
//  ASTM30View-Swift
//
//  Created by Inaba Mizuki on 2016/1/29.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

import UIKit

class RgRfParentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.blackColor()

        __testSetting()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let targetViewController = segue.destinationViewController as? ASTM30RgRfGraphicViewController else {
            MZ.Debugs.assertAlwayFalse("Not ASTM30RgRfGraphicViewController")
            return;
        }

        _graphicViewController = targetViewController
    }


    // MARK: Private

    var _graphicViewController: ASTM30RgRfGraphicViewController? = nil

}


// MARK: Test
extension RgRfParentViewController {

    private func __testSetting() {
        __addTestData()
    }

    private func __addTestData() {
        guard let graphicViewController = _graphicViewController else {
            MZ.Debugs.assertAlwayFalse("_graphicViewController is nil")
            return
        }

        graphicViewController.coordinateSpace = ASTM30CoordinateSpace(xMin: 50, yMin: 60, xMax: 100, yMax: 140)
        graphicViewController.points = __testPointsWithNumber(50)
    }
}


// MARK: Test Data
extension RgRfParentViewController {

    private func __testPointsWithNumber(number: Int) -> [ASTM30Point] {
        guard let graphicViewController = _graphicViewController else {
            MZ.Debugs.assertAlwayFalse("_graphicViewController is nil")
            return [ASTM30Point]()
        }

        let coordinateSpace = graphicViewController.coordinateSpace

        var testPoints = [ASTM30Point]()

        for _ in 0..<number {
            let a = ASTM30Point(key: "a",
                value: CGPoint(
                    x: MZ.Maths.randomFloat(min: coordinateSpace.xMin.mzFloatValue, max: coordinateSpace.xMax.mzFloatValue).cgFloatValue,
                    y: MZ.Maths.randomFloat(min: coordinateSpace.yMin.mzFloatValue, max: coordinateSpace.yMax.mzFloatValue).cgFloatValue
                ))

            testPoints.append(a)
        }

        return testPoints
    }
}