//
//  ASTM30ColorVectorViewController.swift
//
//  Created by Inaba Mizuki on 2016/1/21.
//  Copyright © 2016年 AsenseTek. All rights reserved.
//

import UIKit

class ASTM30ColorVectorViewController: UIViewController {

    var coordinateRange = ASTM30ColorVectorCoordinateSpace()

    var maskPointsInfoName: String? = nil

    var hasBackgroundMasked: Bool {
        return _colorVectorBackgroundView?.layer.mask != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        refresh()
    }

    func addPointsInfo(info: ASTM30ColorVectorPointsInfo) {
        _pointsInfoToLayersDict[info]?.removeFromSuperlayer()
        _pointsInfoToLayersDict.removeValueForKey(info)

        _pointsInfoToLayersDict[info] = CAShapeLayer()
    }

    func removePointsInfoWithName(name: String) {
        let target = _pointsInfoToLayersDict.keys.filter {
            info in info.name == name
        }.first

        guard let targetKey = target else { return }

        _pointsInfoToLayersDict.removeValueForKey(targetKey)
    }

    func removeAllPointsInfo() {
        _pointsInfoToLayersDict.values.forEach { layer in layer.removeFromSuperlayer() }
        _pointsInfoToLayersDict.removeAll()
    }

    func refresh() {
        _setAndAddColorVectorBackgroundViewToView(view)
        _setAndAddPointsLayersLayerViewToView(view)
        _setAndAddAllPoinsInfoLayersToView(_pointsLinesLayerView!)
        _setColorVectorBackgroundMaskWithPointsInfoName(maskPointsInfoName)
    }

    func enableBackgroundMask(enable: Bool, animated: Bool = true) {
        if animated {
            let duration = 1.0
            _animateColorVectorBackgroundMaskWithEnable(enable, duration: duration)
        } else {
            enableBackgroundMaskWithEnable(enable)
        }
    }

    func enableBackgroundMaskWithEnable(enable: Bool) {
        guard let backgroundView = _colorVectorBackgroundView else { return }
        guard let backgroundMaskLayer = _colorVectorBackgroundMaskLayer else { return }

        backgroundView.layer.mask = enable ? backgroundMaskLayer : nil

        _pointsInfoToLayersDict.forEach {
            (info, shapeLayer) in
            let nextColorValue = enable == true ? info.colorInMasked : info.color

            guard let nextColor = nextColorValue else { return }

            shapeLayer.strokeColor = nextColor.CGColor
        }

        _colorVectorBackgroundForFadeView?.hidden = enable
    }


    // MARK: Private

    private var _pointsInfoToLayersDict = [ASTM30ColorVectorPointsInfo: CAShapeLayer]()

    private var _pointsLinesLayerView: UIView? = nil

    private var _colorVectorBackgroundView: UIImageView? = nil

    private var _colorVectorBackgroundForFadeView: UIImageView? = nil

    private var _colorVectorBackgroundMaskLayer: CAShapeLayer? = nil

    private func _setAndAddColorVectorBackgroundViewToView(view: UIView) {
        _colorVectorBackgroundView?.removeFromSuperview()
        _colorVectorBackgroundForFadeView?.removeFromSuperview()

        func newImageView() -> UIImageView {
            let imageView = UIImageView(image: UIImage(named: "ColorVectorBackground"))
            imageView.frame = view.frame
            imageView.contentMode = .ScaleToFill

            return imageView
        }

        _colorVectorBackgroundView = newImageView()
        _colorVectorBackgroundForFadeView = newImageView()

        view.addSubview(_colorVectorBackgroundForFadeView!)
        view.addSubview(_colorVectorBackgroundView!)
    }

    private func _setAndAddPointsLayersLayerViewToView(view: UIView) {
        _pointsLinesLayerView?.removeFromSuperview()

        let pointsView = UIView(frame: view.frame)

        view.addSubview(pointsView)

        _pointsLinesLayerView = pointsView
    }

    private func _setAndAddAllPoinsInfoLayersToView(view: UIView) {
        _pointsInfoToLayersDict.values.forEach { layer in layer.removeFromSuperlayer() }
        let allInfos = _pointsInfoToLayersDict.keys
        _pointsInfoToLayersDict.removeAll(keepCapacity: true)

        allInfos.forEach {
            info in

            let shapeLayer = _shapeLayerWithPointsInfo(info)

            _pointsInfoToLayersDict[info] = shapeLayer
            view.layer.addSublayer(shapeLayer)
        }
    }

    private func _setColorVectorBackgroundMaskWithPointsInfoName(name: String?) {
        guard let name = name else { return }
        guard let colorVectorBackgroundView = _colorVectorBackgroundView else { return }

        let pointsInfoKeyValue = _pointsInfoToLayersDict.filter {
            (info, _) in return info.name == name
        }.first

        MZ.Debugs.assert(pointsInfoKeyValue != nil, "pointsInfo not found with name: \(name)")

        guard let layer = pointsInfoKeyValue?.1 else {
            MZ.Debugs.assertAlwayFalse("layer not found")
            return
        }

        colorVectorBackgroundView.layer.mask = nil

        _colorVectorBackgroundMaskLayer = _maskLayerFromLayer(layer)

        maskPointsInfoName = name
    }

    private func _shapeLayerWithPointsInfo(pointsInfo: ASTM30ColorVectorPointsInfo) -> CAShapeLayer {
        func modifyPoint(point: CGPoint,
            inCoordinateSpace coordinateSpace: ASTM30ColorVectorCoordinateSpace)
        -> CGPoint {
            let realX = view.frame.width*((point.x - coordinateSpace.xMin)/coordinateSpace.xLength)
            let realY = view.frame.height - view.frame.height*((point.y - coordinateSpace.yMin)/coordinateSpace.yLength)

            return CGPoint(x: realX, y: realY)
        }

        let points = pointsInfo.points.map { p in return modifyPoint(p.value, inCoordinateSpace: self.coordinateRange) }

        let path = UIBezierPath()
        path.moveToPoint(points[0])
        points[1..<points.endIndex].forEach { point in path.addLineToPoint(point) }

        if pointsInfo.closePath { path.closePath() }

        let layer = CAShapeLayer()
        layer.path = path.CGPath
        layer.lineWidth = pointsInfo.lineWidth
        layer.strokeColor = pointsInfo.color.CGColor
        layer.fillColor = UIColor.clearColor().CGColor

        let actions: [String: CAAction] = ["strokeColor": NSNull()]
        layer.actions = actions

        return layer
    }

    private func _maskLayerFromLayer(layer: CAShapeLayer) -> CAShapeLayer {
        let maskLayer = CAShapeLayer(layer: layer)
        maskLayer.frame.size = view.frame.size
        maskLayer.path = layer.path

        return maskLayer
    }

    private func _animateColorVectorBackgroundMaskWithEnable(enable: Bool, duration: NSTimeInterval) {
        guard let colorVectorBackgroundView = _colorVectorBackgroundView else { return }
        guard let colorVectorBackgroundMaskLayer = _colorVectorBackgroundMaskLayer else { return }

        if colorVectorBackgroundView.layer.mask == nil {
            colorVectorBackgroundView.layer.mask = colorVectorBackgroundMaskLayer
        }

        let maxScale = 5.0
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

        colorVectorBackgroundMaskLayer.removeAllAnimations()
        colorVectorBackgroundMaskLayer.addAnimation(scale, forKey: "scale")

        _pointsInfoToLayersDict.forEach {
            (info, shapeLayer) in
            let nextColorValue = enable == true ? info.colorInMasked : info.color

            guard let nextColor = nextColorValue else { return }

            let color = CABasicAnimation(keyPath: "strokeColor")
            color.fromValue = shapeLayer.strokeColor
            color.toValue = nextColor.CGColor
            color.duration = duration

            shapeLayer.addAnimation(color, forKey: "color")
        }

        guard let colorVectorBackgroundForFadeView = _colorVectorBackgroundForFadeView else { return }
        colorVectorBackgroundForFadeView.alpha = enable ? 1 : 0
        UIView.animateWithDuration(duration,
            animations: { colorVectorBackgroundForFadeView.alpha = enable ? 0 : 1 },
            completion: { _ in self.enableBackgroundMaskWithEnable(enable) }
        )
    }


    // useless now
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
