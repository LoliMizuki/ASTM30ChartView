//
//  ASTM30ColorVectorViewController.swift
//
//  Created by Inaba Mizuki on 2016/1/21.
//  Copyright © 2016年 AsenseTek. All rights reserved.
//

import UIKit

class ASTM30ColorVectorViewController: UIViewController {

    var coordinateRange = ASTM30ColorVectorCoordinateRange()

    override func viewDidLoad() {
        view.backgroundColor = UIColor.blackColor()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        _setBackgroundView()
        _setPointsView()

        __testAction()
    }

    func addPointsInfo(info: ASTM30ColorVectorPointsInfo) {
        _pointsInfos.removeValueForKey(info)
        _pointsInfos[info] = _shapeLayerWithPointsInfo(info)
    }

    func clipBackgroundWithPointsInfoName(name: String) {
        let pointsInfo = _pointsInfos.filter {
            (info, _) in return info.name == name
        }.first

        guard let layer = pointsInfo?.1 else { return }

        let maskLayer = _maskLayerFromLayer(layer)
        _backgroundView.layer.mask = maskLayer

        maskLayer.transform = CATransform3DScale(
            maskLayer.transform, 1.3, 1.3, 0.0
        )
    }


    // MARK: Private

    private var _pointsInfos = [ASTM30ColorVectorPointsInfo: CAShapeLayer]()

    private var _backgroundView: UIImageView!

    private var _pointsView: UIView!

    private func _setBackgroundView() {
        _backgroundView = UIImageView(image: UIImage(named: "ColorVectorBackground"))
        _backgroundView.frame = view.frame
        _backgroundView.contentMode = .ScaleToFill

        view.addSubview(_backgroundView)
    }

    private func _setPointsView() {
        _pointsView = UIView(frame: view.frame)

        view.addSubview(_pointsView)
    }

    private func _shapeLayerWithPointsInfo(pointsInfo: ASTM30ColorVectorPointsInfo) -> CAShapeLayer {
        func modifyPoint(point: CGPoint,
            inCoordinateRange coordinateRange: ASTM30ColorVectorCoordinateRange)
        -> CGPoint {
            let realX = view.frame.width*((point.x - coordinateRange.xMin)/coordinateRange.xLength)
            let realY = view.frame.height - view.frame.height*((point.y - coordinateRange.yMin)/coordinateRange.yLength)

            return CGPoint(x: realX, y: realY)
        }

        let points = pointsInfo.points.map { p in return modifyPoint(p.value, inCoordinateRange: self.coordinateRange) }

        let path = UIBezierPath()
        path.moveToPoint(points[0])
        points[1..<points.endIndex].forEach { point in path.addLineToPoint(point) }

        if pointsInfo.closePath { path.closePath() }

        let layer = CAShapeLayer()
        layer.path = path.CGPath
        layer.lineWidth = pointsInfo.lineWidth
        layer.strokeColor = pointsInfo.color.CGColor
        layer.fillColor = UIColor.clearColor().CGColor

        _pointsView.layer.addSublayer(layer)

//        layer.transform = CATransform3DMakeScale(1.3, 1.3, 0)

        return layer
    }

    private func _maskLayerFromLayer(layer: CAShapeLayer) -> CALayer {
        let maskLayer = CAShapeLayer()
        maskLayer.path = layer.path



        return maskLayer
    }

    private func _colorAtPoint(point:CGPoint) -> UIColor {
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        var pixelData:[UInt8] = [0, 0, 0, 0]

        let context = CGBitmapContextCreate(&pixelData, 1, 1, 8, 4, colorSpace, bitmapInfo.rawValue)!
        CGContextTranslateCTM(context, -point.x, -point.y);
        view.layer.renderInContext(context)

        let red:CGFloat = CGFloat(pixelData[0])/CGFloat(255.0)
        let green:CGFloat = CGFloat(pixelData[1])/CGFloat(255.0)
        let blue:CGFloat = CGFloat(pixelData[2])/CGFloat(255.0)
        let alpha:CGFloat = CGFloat(pixelData[3])/CGFloat(255.0)

        let color:UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }


    // MARK: Test

    private func __testPointsViewCenter() {
        let centerPointLayer = CAShapeLayer()
        centerPointLayer.path = UIBezierPath(
            arcCenter: CGPoint.zero,
            radius: 4,
            startAngle: 0,
            endAngle: CGFloat(2*M_PI),
            clockwise: false
        ).CGPath
        centerPointLayer.fillColor = UIColor.greenColor().CGColor

        let ref2PointLayer = CAShapeLayer()
        ref2PointLayer.path = UIBezierPath(
            arcCenter: CGPoint(x: -50, y: -50),
            radius: 4,
            startAngle: 0,
            endAngle: CGFloat(2*M_PI),
            clockwise: false
        ).CGPath
        ref2PointLayer.fillColor = UIColor.redColor().CGColor

        let ref3PointLayer = CAShapeLayer()
        ref3PointLayer.path = UIBezierPath(
            arcCenter: CGPoint(x: 50, y: 50),
            radius: 4,
            startAngle: 0,
            endAngle: CGFloat(2*M_PI),
            clockwise: false
        ).CGPath
        ref3PointLayer.fillColor = UIColor.blueColor().CGColor

        func addLayers(layers: [CALayer]) {
            layers.forEach {
                layer in
                _pointsView.layer.addSublayer(layer)
                layer.position = _pointsView.center
            }
        }

        addLayers([centerPointLayer, ref2PointLayer, ref3PointLayer])
    }

    private func __testAction() {
        coordinateRange = ASTM30ColorVectorCoordinateRange(xMin: -400, yMin: -400, xMax: 400, yMax: 400)
        __addTestDataAsCircle2()
        __addTestDataAsCircle1()

//        __addTestDataAsLines()

//        __testPointsViewCenter()

//        _pointsView.layer.transform = CATransform3DScale(_pointsView.layer.transform, 2.0, 2.0, 0.0)
    }

    private func __addTestDataAsCircle1() {
        let info = ASTM30ColorVectorPointsInfo(name: "Hello")
        info.color = UIColor.redColor()
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

        addPointsInfo(info)
    }

    private func __addTestDataAsCircle2() {
        let info = ASTM30ColorVectorPointsInfo(name: "Oops")
        info.color = UIColor.whiteColor()
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

        addPointsInfo(info)
    }

    private func __addTestDataAsLines() {
        coordinateRange = ASTM30ColorVectorCoordinateRange(
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

        addPointsInfo(info)
    }
}
