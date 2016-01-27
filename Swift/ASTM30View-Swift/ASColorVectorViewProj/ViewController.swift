//
//  ViewController.swift
//  ASTM30View-Swift
//
//  Created by Inaba Mizuki on 2016/1/22.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.blackColor()

        __testSetting()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        _tm30ViewController = segue.destinationViewController as! ASTM30GraphicViewController
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        _tm30ViewController.refresh()
    }


    // MARK: Private

    private var _tm30ViewController: ASTM30GraphicViewController! = nil
}


// MARK: IBActons

extension ViewController {

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

extension ViewController {

    private func __testSetting() {
        __addTestData()


//        __addTestDataAsLines()

//        __testPointsViewCenter()
    }

    private func __addTestData() {
        _tm30ViewController.coordinateSpace = ASTM30CoordinateSpace(
            xMin: -400, yMin: -400, xMax: 400, yMax: 400
        )

        _tm30ViewController.testSourceName = "TestSource"
        _tm30ViewController.referenceName = "Reference"

        let referencePoints = [
            CGPoint(x: -360, y: 0),
            CGPoint(x: -180, y: 180),
            CGPoint(x: 0, y: 360),
            CGPoint(x: 180, y: 180),
            CGPoint(x: 90, y: 90),
            CGPoint(x: 360, y: 0),
            CGPoint(x: 180, y: -180),
            CGPoint(x: 0, y: -360),
            CGPoint(x: -180, y: -180),
        ]

        let keys: [String] = {
            var keys = [String]()
            for var i = 0; i < referencePoints.count; i++ { keys.append("A\(i)") }
            return keys
        }()

        let infoForReference = ASTM30PointsInfo(name: "Reference")
        infoForReference.color = UIColor.blackColor()
        infoForReference.colorInMasked = UIColor.whiteColor()
        infoForReference.lineWidth = 4
        infoForReference.points = {
            var points = [ASTM30Point]()

            for var i = 0; i < keys.count; i++ {
                points.append(ASTM30Point(key: keys[i], value: referencePoints[i]))
            }

            return points
        }()
        _tm30ViewController.addPointsInfo(infoForReference)

        let infoForTestSource = ASTM30PointsInfo(name: "TestSource")
        infoForTestSource.color = UIColor.redColor()
        infoForTestSource.colorInMasked = UIColor.clearColor()
        infoForTestSource.lineWidth = 4
        infoForTestSource.points = {
            var points = [ASTM30Point]()

            for var i = 0; i < keys.count; i++ {
                let point = CGPoint(
                    x: referencePoints[i].x + MZ.Maths.randomFloat(min: -30, max: 30).cgFloatValue,
                    y: referencePoints[i].y + MZ.Maths.randomFloat(min: -30, max: 30).cgFloatValue
                )

                points.append(ASTM30Point(key: keys[i], value: point))
            }

            return points
        }()

        _tm30ViewController.addPointsInfo(infoForTestSource)
    }

    private func __addTestDataAsLines() {
        _tm30ViewController.coordinateSpace = ASTM30CoordinateSpace(
            xMin: -100, xMax: 100, yMin: 0, yMax: 100
        )

        let info = ASTM30PointsInfo(name: "Hello")
        info.color = UIColor.redColor()
        info.lineWidth = 4
        info.points = [
            ASTM30Point(key: "A", value: CGPoint(x: 0, y: 0)),
            ASTM30Point(key: "A", value: CGPoint(x: 25, y: 40)),
            ASTM30Point(key: "A", value: CGPoint(x: 50, y: 20)),
            ASTM30Point(key: "A", value: CGPoint(x: 75, y: 35)),
            ASTM30Point(key: "A", value: CGPoint(x: 100, y: 10)),
        ]
        info.closePath = false

        _tm30ViewController.addPointsInfo(info)
    }

//    private func __testPointsViewCenter() {
//        let centerPointLayer = CAShapeLayer()
//        centerPointLayer.path = UIBezierPath(
//            arcCenter: CGPoint.zero,
//            radius: 4,
//            startAngle: 0,
//            endAngle: CGFloat(2*M_PI),
//            clockwise: false
//            ).CGPath
//        centerPointLayer.fillColor = UIColor.greenColor().CGColor
//
//        let ref2PointLayer = CAShapeLayer()
//        ref2PointLayer.path = UIBezierPath(
//            arcCenter: CGPoint(x: -50, y: -50),
//            radius: 4,
//            startAngle: 0,
//            endAngle: CGFloat(2*M_PI),
//            clockwise: false
//            ).CGPath
//        ref2PointLayer.fillColor = UIColor.redColor().CGColor
//
//        let ref3PointLayer = CAShapeLayer()
//        ref3PointLayer.path = UIBezierPath(
//            arcCenter: CGPoint(x: 50, y: 50),
//            radius: 4,
//            startAngle: 0,
//            endAngle: CGFloat(2*M_PI),
//            clockwise: false
//            ).CGPath
//        ref3PointLayer.fillColor = UIColor.blueColor().CGColor
//
//        func addLayers(layers: [CALayer]) {
//            layers.forEach {
//                layer in
//                _pointsView.layer.addSublayer(layer)
//                layer.position = _pointsView.center
//            }
//        }
//        
//        addLayers([centerPointLayer, ref2PointLayer, ref3PointLayer])
//    }
}
