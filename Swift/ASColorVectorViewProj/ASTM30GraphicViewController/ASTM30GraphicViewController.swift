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

    var testSourceName: String? = nil

    var referenceName: String? = nil

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

    func poinsInfoWithName(name: String) -> ASTM30PointsInfo? {
        return _pointsInfoToLayersDict.keys.filter {
            info in info.name == name
        }.first
    }

    func removePointsInfoWithName(name: String) {
        guard let targetKey = poinsInfoWithName(name) else { return }

        _pointsInfoToLayersDict.removeValueForKey(targetKey)
    }

    func removeAllPointsInfo() {
        _pointsInfoToLayersDict.values.forEach { layer in layer.removeFromSuperlayer() }
        _pointsInfoToLayersDict.removeAll()
    }

    func refresh() {
        _setAndAddGraphicBackgroundViewToView(view)
        _setAndAddGridLayerToView(_graphicBackgroundView!)
        _setAndAddPointsLayersViewToView(view)
        _setAndAddAllPoinsInfoLayersToView(_pointsLinesLayerView!)
        _setGraphicBackgroundMaskWithPointsInfoName(testSourceName)
        _setAndAddReferenceToTestSourceArrowsLayerToView(_pointsLinesLayerView!)
    }

    func setGraphicType(type: ASTM30GraphicType, animated: Bool = false, duration: CFTimeInterval = 0.25) {
        graphicType = type
        let enableMask = graphicType == .ColorDistortion

        if animated {
            _animateMaskEnable(enableMask, duration: duration)
        } else {
            _setGraphicBackgroundWithMaskEnable(enableMask)
        }
    }

    
    // MARK: Private

    private var _pointsInfoToLayersDict = [ASTM30PointsInfo: CAShapeLayer]()

    private var _pointsLinesLayerView: UIView? = nil

    private var _sourceToReferenceArrowsLayer: CAShapeLayer? = nil

    private var _graphicBackgroundView: UIImageView? = nil

    private var _graphicBackgroundGridLayer: CAShapeLayer? = nil

    private var _graphicBackgroundForFadeView: UIImageView? = nil

    private var _graphicBackgroundMaskLayer: CAShapeLayer? = nil

    private func _setGraphicBackgroundWithMaskEnable(maskEnable: Bool) {
        guard let backgroundView = _graphicBackgroundView else { return }
        guard let backgroundMaskLayer = _graphicBackgroundMaskLayer else { return }

        backgroundView.layer.mask = maskEnable ? backgroundMaskLayer : nil

        _pointsInfoToLayersDict.forEach {
            (info, shapeLayer) in
            let nextColorValue = maskEnable ? info.colorInMasked : info.color

            guard let nextColor = nextColorValue else { return }

            shapeLayer.strokeColor = nextColor.CGColor
        }

        _graphicBackgroundForFadeView?.hidden = maskEnable
    }
}


//  MARK: Present views and layers
extension ASTM30GraphicViewController {

    private func _setAndAddGraphicBackgroundViewToView(view: UIView) {
        _graphicBackgroundView?.removeFromSuperview()
        _graphicBackgroundForFadeView?.removeFromSuperview()

        func newGraphicView() -> UIImageView {
            let imageView = UIImageView(image: UIImage(named: "GraphicBackground"))
            imageView.frame = view.frame
            imageView.contentMode = .ScaleToFill

            return imageView
        }

        _graphicBackgroundView = newGraphicView()
        _graphicBackgroundForFadeView = newGraphicView()

        view.addSubview(_graphicBackgroundForFadeView!)
        view.addSubview(_graphicBackgroundView!)
    }

    private func _setAndAddGridLayerToView(view: UIView) {
        _graphicBackgroundGridLayer?.removeFromSuperlayer()

        let numberOfGrid: CGFloat = 5

        let interval = CGPoint(
            x: view.frame.size.width/numberOfGrid,
            y: view.frame.size.height/numberOfGrid
        )

        let path = UIBezierPath()

        for i in 1..<Int(numberOfGrid) {
            let linePath = UIBezierPath()

            linePath.moveToPoint(CGPoint(x: 0, y: i.cgFloatValue*interval.y))
            linePath.addLineToPoint(CGPoint(x: view.frame.size.width, y: i.cgFloatValue*interval.y))

            linePath.moveToPoint(CGPoint(x: i.cgFloatValue*interval.x, y: 0))
            linePath.addLineToPoint(CGPoint(x: i.cgFloatValue*interval.x, y: view.frame.size.height))


            path.appendPath(linePath)
        }

        let gridLayer = CAShapeLayer()
        gridLayer.frame = view.frame
        gridLayer.path = path.CGPath

        gridLayer.lineWidth = 2
        gridLayer.strokeColor = UIColor.grayColor().CGColor

        view.layer.addSublayer(gridLayer)

        _graphicBackgroundGridLayer = gridLayer
    }

    private func _setAndAddPointsLayersViewToView(view: UIView) {
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

    private func _setGraphicBackgroundMaskWithPointsInfoName(name: String?) {
        guard let name = name else { return }
        guard let graphicBackgroundView = _graphicBackgroundView else { return }

        let pointsInfoKeyValue = _pointsInfoToLayersDict.filter {
            (info, _) in return info.name == name
        }.first

        MZ.Debugs.assert(pointsInfoKeyValue != nil, "pointsInfo not found with name: \(name)")

        guard let layer = pointsInfoKeyValue?.1 else {
            MZ.Debugs.assertAlwayFalse("layer not found")
            return
        }

        graphicBackgroundView.layer.mask = nil

        _graphicBackgroundMaskLayer = _maskLayerFromLayer(layer)

        testSourceName = name
    }

    private func _setAndAddReferenceToTestSourceArrowsLayerToView(view: UIView) {
        _sourceToReferenceArrowsLayer?.removeFromSuperlayer()

        guard let testSourceName = testSourceName else { return }
        guard let referenceName = referenceName else { return }

        guard let toInfo = poinsInfoWithName(testSourceName) else { return }
        guard let fromInfo = poinsInfoWithName(referenceName) else { return }

        let path = UIBezierPath()

        for fromPoint in fromInfo.points {
            guard let toPoint = toInfo.pointWithKey(fromPoint.key) else {
                MZ.Debugs.assertAlwayFalse("Can not found point with key: \(fromPoint.key)")
                return
            }

            let modifiedFromPoint = _pointFrom(fromPoint.value, inCoordinateSpace: coordinateSpace)
            let modifiedToPoint = _pointFrom(toPoint.value, inCoordinateSpace: coordinateSpace)

            path.appendPath(_arrowPathFromPoint(modifiedFromPoint, toPoint: modifiedToPoint))
        }

        let layer = CAShapeLayer()
        layer.frame = view.frame
        layer.path = path.CGPath
        layer.strokeColor = UIColor.greenColor().CGColor
        layer.lineWidth = 1
        layer.lineCap = "round"
        layer.lineJoin = "bevel"
        view.layer.addSublayer(layer)
        
        _sourceToReferenceArrowsLayer = layer
    }

    private func _shapeLayerWithPointsInfo(pointsInfo: ASTM30PointsInfo) -> CAShapeLayer {
        let points = pointsInfo.points.map { p in return _pointFrom(p.value, inCoordinateSpace: self.coordinateSpace) }

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

    private func _arrowPathFromPoint(from: CGPoint, toPoint to: CGPoint) -> UIBezierPath {
        let lengthOfFromTo = MZ.Maths.distance(p1: from, p2: to)
        let degreesOfFromTo = MZ.Degrees.degressFromP1(from, toP2: to)
        let maxWingsLength = 10.cgFloatValue
        let wingsIntervalDegrees = 30.mzFloatValue

        let path = UIBezierPath()
        let zeroLeft = CGPoint(x: -lengthOfFromTo/2, y: 0)
        let zeroRight = CGPoint(x: lengthOfFromTo/2, y: 0)

        path.moveToPoint(zeroLeft)
        path.addLineToPoint(zeroRight)

        let wingsLength = min(maxWingsLength, lengthOfFromTo/3)
        let wingPoint1 = MZ.Maths.unitVectorFromDegrees(180-wingsIntervalDegrees)*wingsLength
        let wingPoint2 = MZ.Maths.unitVectorFromDegrees(180+wingsIntervalDegrees)*wingsLength

        path.moveToPoint(zeroRight)
        path.addLineToPoint(zeroRight + wingPoint1)
        path.moveToPoint(zeroRight)
        path.addLineToPoint(zeroRight + wingPoint2)

        let centerOfFromTo = CGPoint(x: (to.x + from.x)/2, y: (to.y + from.y)/2)
        let rotationAngle = MZ.Degrees.radiansFromDegrees(degreesOfFromTo).cgFloatValue
        path.applyTransform(CGAffineTransformMakeRotation(rotationAngle))
        path.applyTransform(CGAffineTransformMakeTranslation(centerOfFromTo.x, centerOfFromTo.y))

        return path
    }
}


// MARK: ASTM30GraphicType switch animations
extension ASTM30GraphicViewController {

    private func _animateMaskEnable(maskEnable: Bool, duration: NSTimeInterval) {
        _animateMaskEnableToGraphicBackground(maskEnable, duration: duration)
        _animateMaskEnableToGraphicBackgroundForFade(maskEnable, duration: duration)
        _animateFadeMaskEnableToLayer(_graphicBackgroundGridLayer, maskEnable: maskEnable, duration: duration)
        _animateFadeMaskEnableToLayer(_sourceToReferenceArrowsLayer, maskEnable: maskEnable, duration: duration)
        _animateMaskEnableToPointsLinesLayer(maskEnable, duration: duration)
    }

    private func _animateMaskEnableToGraphicBackground(maskEnable: Bool, duration: NSTimeInterval) {
        guard let view = _graphicBackgroundView else { return }
        guard let maskLayer = _graphicBackgroundMaskLayer else { return }

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

    private func _animateMaskEnableToGraphicBackgroundForFade(maskEnable: Bool, duration: NSTimeInterval) {
        guard let view = _graphicBackgroundForFadeView else { return }
        view.alpha = maskEnable ? 1 : 0
        UIView.animateWithDuration(duration,
            animations: { view.alpha = maskEnable ? 0 : 1 },
            completion: { _ in self._setGraphicBackgroundWithMaskEnable(maskEnable) }
        )
    }

    private func _animateFadeMaskEnableToLayer(layer: CAShapeLayer?, maskEnable: Bool, duration: NSTimeInterval) {
        guard let layer = layer else { return }

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
}


// MARK: Supports
extension ASTM30GraphicViewController {

    private func _pointFrom(point: CGPoint, inCoordinateSpace coordinateSpace: ASTM30CoordinateSpace)
    -> CGPoint {
        let realX = view.frame.width*((point.x - coordinateSpace.xMin)/coordinateSpace.xLength)
        let realY = view.frame.height - view.frame.height*((point.y - coordinateSpace.yMin)/coordinateSpace.yLength)

        return CGPoint(x: realX, y: realY)
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
