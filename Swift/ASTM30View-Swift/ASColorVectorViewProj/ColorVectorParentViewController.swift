//
//  ColorVectorParentViewController.swift
//  ASTM30View-Swift
//
//  Created by Inaba Mizuki on 2016/1/22.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

import UIKit

class ColorVectorParentViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.blackColor()

        __testSetting()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        _tm30ViewController = segue.destinationViewController as! ASTM30ColorVectorViewController
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        _tm30ViewController?.refresh()
    }


    // MARK: Private

    private var _tm30ViewController: ASTM30ColorVectorViewController! = nil
}


// MARK: IBActons

extension ColorVectorParentViewController {

    @IBAction func didTouchUpInsideMaskButton(button: UIButton) {
        let type =
            _tm30ViewController.graphicType == .ColorVector ?
                ASTM30GraphicType.ColorDistortion :
                ASTM30GraphicType.ColorVector
        _tm30ViewController.setGraphicType(type, animated: true)
    }

    @IBAction func didTouchUpInsideRemoveButton(button: UIButton) {
        _tm30ViewController.view.removeFromSuperview()
        _tm30ViewController.removeFromParentViewController()

        _tm30ViewController.view = nil
        _tm30ViewController = nil
    }
}


// Test
extension ColorVectorParentViewController {

    private func __testSetting() {
        __addTestData()
    }

    private func __addTestData() {
        _tm30ViewController.coordinateSpace = ASTM30CoordinateSpace(
            xMin: -1.2, xMax: 1.2, yMin: -1.2, yMax: 1.2
        )

        _tm30ViewController.testSourceName = "TestSource"
        _tm30ViewController.referenceName = "Reference"

        let infoForReference = ASTM30PointsInfo(name: "Reference")
        infoForReference.color = UIColor.blackColor()
        infoForReference.colorInMasked = UIColor.whiteColor()
        infoForReference.lineWidth = 4
        infoForReference.points = {
            let rawPoints = _referencePoints()
            var points = [ASTM30Point]()

            for var i = 0; i < rawPoints.count; i++ {
                let key = "A\(i)"
                points.append(ASTM30Point(key: key, value: rawPoints[i]))
            }

            return points
        }()
        _tm30ViewController.addPointsInfo(infoForReference)

        let infoForTestSource = ASTM30PointsInfo(name: "TestSource")
        infoForTestSource.color = UIColor.redColor()
        infoForTestSource.colorInMasked = UIColor.clearColor()
        infoForTestSource.lineWidth = 4
        infoForTestSource.points = {
            let rawPoints = _testSourcePoints()
            var points = [ASTM30Point]()

            for var i = 0; i < rawPoints.count; i++ {
                let key = "A\(i)"
                points.append(ASTM30Point(key: key, value: rawPoints[i]))
            }

            return points
        }()
        _tm30ViewController.addPointsInfo(infoForTestSource)
    }
}


// MARK: Test Datas
extension ColorVectorParentViewController {

    func _referencePoints() -> [CGPoint] {
        return [
            CGPoint(x: 0.979482, y: 0.201533),
            CGPoint(x: 0.804753, y: 0.593609),
            CGPoint(x: 0.565791, y: 0.824548),
            CGPoint(x: 0.18508, y: 0.982723),
            CGPoint(x: -0.0885433, y:  0.996072),
            CGPoint(x: -0.516068, y:  0.856548),
            CGPoint(x: -0.841959, y:  0.539542),
            CGPoint(x: -0.993123, y:  0.117075),
            CGPoint(x: -0.987714, y:  -0.156275),
            CGPoint(x: -0.849281, y:  -0.527942),
            CGPoint(x: -0.592092, y:  -0.805871),
            CGPoint(x: -0.184827, y:  -0.982771),
            CGPoint(x: 0.112917, y: -0.993604),
            CGPoint(x: 0.597958, y: -0.801528),
            CGPoint(x: 0.827279, y: -0.561791),
            CGPoint(x: 0.983755, y: -0.179517),
        ]
    }

    private func _testSourcePoints() -> [CGPoint] {
        return [
            CGPoint(x: 0.830428, y: 0.152285),
            CGPoint(x: 0.665421, y: 0.600832),
            CGPoint(x: 0.390513, y: 0.869416),
            CGPoint(x: 0.0299235, y: 1.03496),
            CGPoint(x: -0.184857, y:  1.03375),
            CGPoint(x: -0.521905, y:  0.903854),
            CGPoint(x: -0.78017, y:  0.570425),
            CGPoint(x: -0.87806, y:  0.12918),
            CGPoint(x: -0.81089, y:  -0.222912),
            CGPoint(x: -0.631358, y:  -0.654632),
            CGPoint(x: -0.386599, y:  -0.931485),
            CGPoint(x: -0.0546757, y:  -1.06064),
            CGPoint(x: 0.170136, y: -1.10126),
            CGPoint(x: 0.610058, y: -0.96514),
            CGPoint(x: 0.742329, y: -0.761882),
            CGPoint(x: 0.903637, y: -0.259266),
        ]
    }
}
