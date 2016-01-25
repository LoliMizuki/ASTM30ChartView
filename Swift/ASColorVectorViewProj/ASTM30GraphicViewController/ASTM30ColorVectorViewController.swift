//
//  ASTM30GraphicViewController.swift
//
//  Created by Inaba Mizuki on 2016/1/21.
//  Copyright © 2016年 AsenseTek. All rights reserved.
//

import UIKit


enum ASTM30GraphicType: Int {
    case ColorVector
    case ColorDistortion
}

class ASTM30GraphicViewController: UIViewController {

    var coordinateSpace = ASTM30CoordinateSpace()

    var maskPointsInfoName: String? = nil

    var hasBackgroundMasked: Bool {
        return _colorVectorBackgroundView?.layer.mask != nil
    }

    private (set) var graphicType: ASTM30GraphicType = .ColorVector

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        refresh()
    }

    func addPointsInfo(info: ASTM30PointsInfo) {
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
        _setAndAddGridLayerToView(_colorVectorBackgroundView!)
        _setAndAddPointsLayersLayerViewToView(view)
        _setAndAddAllPoinsInfoLayersToView(_pointsLinesLayerView!)
        _setColorVectorBackgroundMaskWithPointsInfoName(maskPointsInfoName)
    }

    func setGraphicType(type: ASTM30GraphicType, animated: Bool = false, duration: CFTimeInterval = 0.25) {
        graphicType = type
        let enableMask = graphicType == .ColorDistortion

        if animated {
            _animateMaskEnable(enableMask, duration: duration)
        } else {
            _setColorVectorBackgroundWithMaskEnable(enableMask)
        }
    }

    
    // MARK: Private

    private var _pointsInfoToLayersDict = [ASTM30PointsInfo: CAShapeLayer]()

    private var _pointsLinesLayerView: UIView? = nil

    private var _colorVectorBackgroundView: UIImageView? = nil

    private var _colorVectorBackgroundGridLayer: CAShapeLayer? = nil

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

    private func _setAndAddGridLayerToView(view: UIView) {
        _colorVectorBackgroundGridLayer?.removeFromSuperlayer()

        let numberOfGrid: CGFloat = 5

        let interval = CGPoint(
            x: view.frame.size.width/numberOfGrid,
            y: view.frame.size.height/numberOfGrid
        )

        var paths = [UIBezierPath]()

        for i in 1..<Int(numberOfGrid) {
            let linePath = UIBezierPath()

            linePath.moveToPoint(CGPoint(x: 0, y: i.cgFloatValue*interval.y))
            linePath.addLineToPoint(CGPoint(x: view.frame.size.width, y: i.cgFloatValue*interval.y))

            linePath.moveToPoint(CGPoint(x: i.cgFloatValue*interval.x, y: 0))
            linePath.addLineToPoint(CGPoint(x: i.cgFloatValue*interval.x, y: view.frame.size.height))


            paths.append(linePath)
        }

        let resultPath = CGPathCreateMutable()

        paths.forEach { path in CGPathAddPath(resultPath, nil, path.CGPath) }

        let gridLayer = CAShapeLayer()
        gridLayer.frame = view.frame
        gridLayer.path = resultPath

        gridLayer.lineWidth = 2
        gridLayer.strokeColor = UIColor.grayColor().CGColor

        view.layer.addSublayer(gridLayer)

        _colorVectorBackgroundGridLayer = gridLayer
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

    private func _shapeLayerWithPointsInfo(pointsInfo: ASTM30PointsInfo) -> CAShapeLayer {
        func modifyPoint(point: CGPoint,
            inCoordinateSpace coordinateSpace: ASTM30CoordinateSpace)
        -> CGPoint {
            let realX = view.frame.width*((point.x - coordinateSpace.xMin)/coordinateSpace.xLength)
            let realY = view.frame.height - view.frame.height*((point.y - coordinateSpace.yMin)/coordinateSpace.yLength)

            return CGPoint(x: realX, y: realY)
        }

        let points = pointsInfo.points.map { p in return modifyPoint(p.value, inCoordinateSpace: self.coordinateSpace) }

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

    private func _setColorVectorBackgroundWithMaskEnable(maskEnable: Bool) {
        guard let backgroundView = _colorVectorBackgroundView else { return }
        guard let backgroundMaskLayer = _colorVectorBackgroundMaskLayer else { return }

        backgroundView.layer.mask = maskEnable ? backgroundMaskLayer : nil

        _pointsInfoToLayersDict.forEach {
            (info, shapeLayer) in
            let nextColorValue = maskEnable == true ? info.colorInMasked : info.color

            guard let nextColor = nextColorValue else { return }

            shapeLayer.strokeColor = nextColor.CGColor
        }

        _colorVectorBackgroundForFadeView?.hidden = maskEnable
    }

    private func _animateMaskEnable(maskEnable: Bool, duration: NSTimeInterval) {
        _animateMaskEnableToColorVectorBackground(maskEnable, duration: duration)
        _animateMaskEnableToColorVectorBackgroundForFade(maskEnable, duration: duration)
        _animateMaskEnableToColorVectorBackgroundGridLayer(maskEnable, duration: duration)
        _animateMaskEnableToPointsLinesLayer(maskEnable, duration: duration)
    }

    private func _animateMaskEnableToColorVectorBackground(maskEnable: Bool, duration: NSTimeInterval) {
        guard let view = _colorVectorBackgroundView else { return }
        guard let maskLayer = _colorVectorBackgroundMaskLayer else { return }

        if view.layer.mask == nil {
            view.layer.mask = maskLayer
        }

        let maxScale = 5.0
        let minScale = 1.0

        let scale = CAKeyframeAnimation(keyPath: "transform.scale")
        scale.duration = duration
        scale.keyTimes = [0.0, 1.0]
        scale.values = [
            (maskEnable ? maxScale : minScale),
            (maskEnable ? minScale : maxScale),
        ]
        scale.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        scale.fillMode = kCAFillModeForwards
        scale.removedOnCompletion = false

        maskLayer.removeAllAnimations()
        maskLayer.addAnimation(scale, forKey: "scale")
    }

    private func _animateMaskEnableToColorVectorBackgroundForFade(maskEnable: Bool, duration: NSTimeInterval) {
        guard let view = _colorVectorBackgroundForFadeView else { return }
        view.alpha = maskEnable ? 1 : 0
        UIView.animateWithDuration(duration,
            animations: { view.alpha = maskEnable ? 0 : 1 },
            completion: { _ in self._setColorVectorBackgroundWithMaskEnable(maskEnable) }
        )
    }

    private func _animateMaskEnableToColorVectorBackgroundGridLayer(maskEnable: Bool, duration: NSTimeInterval) {
        guard let layer = _colorVectorBackgroundGridLayer else { return }

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = maskEnable ? 1 : 0
        fade.toValue = maskEnable ? 0 : 1
        fade.duration = duration
        fade.fillMode = kCAFillModeForwards
        fade.removedOnCompletion = false

        layer.removeAllAnimations()
        layer.addAnimation(fade, forKey: "fade")
    }

    private func _animateMaskEnableToPointsLinesLayer(maskEnable: Bool, duration: NSTimeInterval) {
        _pointsInfoToLayersDict.forEach {
            (info, shapeLayer) in
            let nextColorValue = maskEnable == true ? info.colorInMasked : info.color

            guard let nextColor = nextColorValue else { return }

            let color = CABasicAnimation(keyPath: "strokeColor")
            color.fromValue = shapeLayer.strokeColor
            color.toValue = nextColor.CGColor
            color.duration = duration

            shapeLayer.addAnimation(color, forKey: "color")
        }
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
