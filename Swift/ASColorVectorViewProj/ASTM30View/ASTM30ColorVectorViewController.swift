//
//  ASTM30ColorVectorViewController.swift
//
//  Created by Inaba Mizuki on 2016/1/21.
//  Copyright © 2016年 AsenseTek. All rights reserved.
//

import UIKit

class ASTM30ColorVectorViewController: UIViewController {

    var coordinateRange = ASTM30ColorVectorCoordinateRange()

    var isBackgroundHasMask: Bool {
        return _backgroundView.layer.mask != nil
    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor.blackColor()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        _setBackgroundView()
        _setPointsView()
    }

    func addPointsInfo(info: ASTM30ColorVectorPointsInfo) {
        _pointsInfos.removeValueForKey(info)
        _pointsInfos[info] = _shapeLayerWithPointsInfo(info)
    }

    func setBackgroundMaskWithPointsInfoName(name: String) {
        let pointsInfoKeyValue = _pointsInfos.filter {
            (info, _) in return info.name == name
        }.first

        MZ.Debugs.assert(pointsInfoKeyValue != nil, "pointsInfo not found with name: \(name)")

        guard let layer = pointsInfoKeyValue?.1 else {
            MZ.Debugs.assertAlwayFalse("layer not found")
            return
        }

        _backgroundMaskLayer = _maskLayerFromLayer(layer)
    }

    func enableBackgroundMask(enable: Bool, animated: Bool = true) {
        if animated {
            let duration = 0.25
            _animateBackgroundMaskWithEnable(enable, duration: duration)
            performSelector("_setBackgroundMaskWithEnable:", withObject: enable, afterDelay: duration)
        } else {
            _setBackgroundMaskWithEnable(enable)
        }
    }

    private func _setBackgroundMaskWithEnable(enableValue: AnyObject) {
        let enable = enableValue as! Bool
        _backgroundView.layer.mask = enable ? _backgroundMaskLayer : nil
    }


    // MARK: Private

    private var _pointsInfos = [ASTM30ColorVectorPointsInfo: CAShapeLayer]()

    private var _backgroundView: UIImageView!

    private var _backgroundMaskLayer: CAShapeLayer!

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

        return layer
    }

    private func _maskLayerFromLayer(layer: CAShapeLayer) -> CAShapeLayer {
        let maskLayer = CAShapeLayer(layer: layer)
        maskLayer.frame.size = view.frame.size
        maskLayer.path = layer.path

        return maskLayer
    }

    private func _maskLayerFromPointsInfo(pointsInfo: ASTM30ColorVectorPointsInfo) -> CAShapeLayer {
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
        layer.frame.size = view.frame.size
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.path = path.CGPath

        return layer
    }

    private func _animateBackgroundMaskWithEnable(enable: Bool, duration: NSTimeInterval) {
        if _backgroundView.layer.mask == nil {
            _backgroundView.layer.mask = _backgroundMaskLayer
        }

        let maxScale = 10.0
        let minScale = 1.0

        let scale = CAKeyframeAnimation(keyPath: "transform.scale")
        scale.duration = duration
        scale.keyTimes = [0.0, 1.0]
        scale.values = [
            (enable ? maxScale : minScale),
            (enable ? minScale : maxScale),
        ]
        scale.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        scale.fillMode = kCAFillModeForwards
        scale.removedOnCompletion = false

        _backgroundMaskLayer.removeAllAnimations()
        _backgroundMaskLayer.addAnimation(scale, forKey: "animation")
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
}
