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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
}


// Test

extension ViewController {

    private func __testSetting() {
        _tm30ViewController.coordinateSpace = ASTM30CoordinateSpace(
            xMin: -400, yMin: -400, xMax: 400, yMax: 400
        )
        __addTestDataAsCircle2()
        __addTestDataAsCircle1()
        _tm30ViewController.testSourceName = "TestSource"
        _tm30ViewController.referenceName = "Reference"

//        __addTestDataAsLines()

//        __testPointsViewCenter()
    }

    private func __addTestDataAsCircle1() {
        let info = ASTM30PointsInfo(name: "TestSource")
        info.color = UIColor.redColor()
        info.colorInMasked = UIColor.greenColor()
        info.lineWidth = 4
        info.points = [
            ASTM30Point(key: "A1", value: CGPoint(x: -100, y: 30)),
            ASTM30Point(key: "A2", value: CGPoint(x: -100, y: 140)),
            ASTM30Point(key: "A3", value: CGPoint(x: -50, y: 160)),
            ASTM30Point(key: "A4", value: CGPoint(x: 0, y: 200)),
            ASTM30Point(key: "A5", value: CGPoint(x: 50, y: 100)),
            ASTM30Point(key: "A6", value: CGPoint(x: 100, y: 10)),
            ASTM30Point(key: "A7", value: CGPoint(x: 150, y: -75)),
            ASTM30Point(key: "A8", value: CGPoint(x: 110, y: -134)),
            ASTM30Point(key: "A9", value: CGPoint(x: -10, y: -200)),
        ]

        _tm30ViewController.addPointsInfo(info)
    }

    private func __addTestDataAsCircle2() {
        let info = ASTM30PointsInfo(name: "Reference")
        info.color = UIColor.blackColor()
        info.colorInMasked = UIColor.redColor()
        info.lineWidth = 4
        info.points = [
            ASTM30Point(key: "A1", value: CGPoint(x: -170, y: 170)),
            ASTM30Point(key: "A2", value: CGPoint(x: -130, y: 160)),
            ASTM30Point(key: "A3", value: CGPoint(x: -60, y: 180)),
            ASTM30Point(key: "A4", value: CGPoint(x: 8, y: 280)),
            ASTM30Point(key: "A5", value: CGPoint(x: 55, y: 120)),
            ASTM30Point(key: "A6", value: CGPoint(x: 100, y: 30)),
            ASTM30Point(key: "A7", value: CGPoint(x: 150, y: -105)),
            ASTM30Point(key: "A8", value: CGPoint(x: 119, y: -154)),
            ASTM30Point(key: "A9", value: CGPoint(x: -10, y: -220)),
        ]

        _tm30ViewController.addPointsInfo(info)
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
