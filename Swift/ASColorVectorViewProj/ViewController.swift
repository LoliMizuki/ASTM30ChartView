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
        _tm30ViewController = segue.destinationViewController as! ASTM30ColorVectorViewController
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        _tm30ViewController.refresh()
    }


    // MARK: Private

    private var _tm30ViewController: ASTM30ColorVectorViewController! = nil
}


// MARK: IBActons

extension ViewController {

    @IBAction func didTouchUpInsideMaskButton(button: UIButton) {
        _tm30ViewController.enableBackgroundMask(!_tm30ViewController.hasBackgroundMasked, animated: true)
    }
}


// Test

extension ViewController {

    private func __testSetting() {
        _tm30ViewController.coordinateRange = ASTM30ColorVectorCoordinateSpace(
            xMin: -400, yMin: -400, xMax: 400, yMax: 400
        )
        __addTestDataAsCircle2()
        __addTestDataAsCircle1()
        _tm30ViewController.maskPointsInfoName = "Hello"
//        _tm30ViewController.setBackgroundMaskWithPointsInfoName("Hello")
//        _tm30ViewController.enableBackgroundMask(true, animated: true)

        //        __addTestDataAsLines()

        //        __testPointsViewCenter()

        //        _pointsView.layer.transform = CATransform3DScale(_pointsView.layer.transform, 2.0, 2.0, 0.0)
    }

    private func __addTestDataAsCircle1() {
        let info = ASTM30ColorVectorPointsInfo(name: "Hello")
        info.color = UIColor.redColor()
        info.colorInMasked = UIColor.greenColor()
        info.lineWidth = 4
        info.points = [
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: -150, y: 0)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: -100, y: 140)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: -50, y: 160)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 0, y: 200)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 50, y: 100)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 100, y: 10)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 150, y: -75)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 110, y: -134)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: -10, y: -200)),
        ]

        _tm30ViewController.addPointsInfo(info)
    }

    private func __addTestDataAsCircle2() {
        let info = ASTM30ColorVectorPointsInfo(name: "Oops")
        info.color = UIColor.whiteColor()
        info.colorInMasked = UIColor.redColor()
        info.lineWidth = 4
        info.points = [
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: -170, y: 0)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: -130, y: 140)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: -60, y: 160)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 8, y: 260)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 55, y: 100)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 100, y: 10)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 150, y: -85)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 119, y: -134)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: -10, y: -200)),        ]

        _tm30ViewController.addPointsInfo(info)
    }

    private func __addTestDataAsLines() {
        _tm30ViewController.coordinateRange = ASTM30ColorVectorCoordinateSpace(
            xMin: -100, xMax: 100, yMin: 0, yMax: 100
        )

        let info = ASTM30ColorVectorPointsInfo(name: "Hello")
        info.color = UIColor.redColor()
        info.lineWidth = 4
        info.points = [
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 0, y: 0)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 25, y: 40)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 50, y: 20)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 75, y: 35)),
            ASTM30ColorVectorPoint(key: "A", value: CGPoint(x: 100, y: 10)),
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
