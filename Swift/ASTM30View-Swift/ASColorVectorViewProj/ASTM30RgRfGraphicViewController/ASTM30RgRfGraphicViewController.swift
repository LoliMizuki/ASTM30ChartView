//
//  ASTM30RgRfViewController.swift
//  ASTM30View-Swift
//
//  Created by Inaba Mizuki on 2016/1/28.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

import UIKit

class ASTM30RgRfGraphicViewController: UIViewController {

    var coordinateSpace = ASTM30CoordinateSpace()

    var points = [ASTM30Point]()

    override func viewDidLoad() {
        super.viewDidLoad()
        coordinateSpace = ASTM30CoordinateSpace(xMin: 50, yMin: 60, xMax: 100, yMax: 140)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        refresh()
    }

    func refresh() {
        _setAndAddCoordinateViewToView(view)
        _setGrayLayersToView(_coordinateView!)
        _setBoardLinesToView(_coordinateView!)
        _setCoordinateMarksToView(_coordinateView!)
        _setAndAddPointLayerToView(_coordinateView!)
        _setPointViewsToView(_coordinateView!)
//        _setPointsPathToLayer(_pointsLayer!)
    }


    // MARK: Private

    var _coordinateView: UIView? = nil

    var _pointsLayer: CAShapeLayer? = nil

    deinit {
        _pointsLayer?.removeFromSuperlayer()
        _coordinateView?.removeFromSuperview()
    }
}


// Graphic components
extension ASTM30RgRfGraphicViewController {

    private func _setAndAddCoordinateViewToView(view: UIView) {
        _coordinateView?.removeFromSuperview()

        let coordinateView = UIView(frame: view.frame*0.8)

        view.addSubview(coordinateView)
        coordinateView.center = view.center

        _coordinateView = coordinateView
    }

    private func _setGrayLayersToView(view: UIView) {
        func doubleTriangelPathWithSize(size: CGSize) -> UIBezierPath {
            let startPoint = CGPoint(x: view.frame.width, y: view.frame.height/2)
            let rect = CGRect(
                origin: CGPoint(x: startPoint.x - size.width, y: startPoint.y - size.height/2),
                size: CGSize(width: size.width, height: size.height)
            )

            let path = UIBezierPath()
            path.moveToPoint(startPoint)
            path.addLineToPoint(rect.topLeft)
            path.addLineToPoint(rect.topRight)
            path.closePath()

            path.moveToPoint(startPoint)
            path.addLineToPoint(rect.bottomLeft)
            path.addLineToPoint(rect.bottomRight)
            path.closePath()

            return path
        }

        let grayLayer = CAShapeLayer()
        grayLayer.path = doubleTriangelPathWithSize(view.frame.size).CGPath
        grayLayer.strokeColor = UIColor.clearColor().CGColor
        grayLayer.fillColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.0).CGColor
        view.layer.addSublayer(grayLayer)

        let darkGrayLayer = CAShapeLayer()
        darkGrayLayer.path = doubleTriangelPathWithSize(CGSize(width: view.frame.width*0.8, height: view.frame.height)).CGPath
        darkGrayLayer.strokeColor = UIColor.clearColor().CGColor
        darkGrayLayer.fillColor = UIColor(red: 0.745, green: 0.745, blue: 0.745, alpha: 1.0).CGColor
        view.layer.addSublayer(darkGrayLayer)
    }

    private func _setBoardLinesToView(view: UIView) {
        let layer = CAShapeLayer()
        layer.frame.size = view.frame.size
        layer.path = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: view.frame.size)).CGPath

        layer.lineWidth = 2
        layer.strokeColor = UIColor.blackColor().CGColor
        layer.fillColor = UIColor.clearColor().CGColor

        view.layer.addSublayer(layer)
    }

    private func _setCoordinateMarksToView(view: UIView) {
        let numberOfBlockAtX = 5
        let numberOfBlockAtY = 8

        _addMainGridLinesAndMarkTextToView(view,
            numberOfBlockAtX: numberOfBlockAtX,
            numberOfBlockAtY: numberOfBlockAtY
        )

        _addSubGridLinesToLayer(view,
            numberOfBlockAtX: numberOfBlockAtX,
            numberOfBlockAtY: numberOfBlockAtY
        )
    }

    private func _setAndAddPointLayerToView(view: UIView) {
        _pointsLayer?.removeFromSuperlayer()

        let layer = CAShapeLayer()
        layer.frame.size = view.frame.size
        layer.fillColor = UIColor(red: 0.129, green: 0.286, blue: 0.486, alpha: 1.0).CGColor

        view.layer.addSublayer(layer)

        _pointsLayer = layer
    }

    private func _setPointViewsToView(view: UIView) {
        // test data
        for i in 0..<10 {
            let a = ASTM30Point(key: "a",
                value: CGPoint(
                    x: MZ.Maths.randomFloat(min: coordinateSpace.xMin.mzFloatValue, max: coordinateSpace.xMax.mzFloatValue).cgFloatValue,
                    y: MZ.Maths.randomFloat(min: coordinateSpace.yMin.mzFloatValue, max: coordinateSpace.yMax.mzFloatValue).cgFloatValue
                ))

            points.append(a)
        }

        let pointsPath = UIBezierPath()

        // TODO: fix var names
        func realPointPositionFromPoint(point: ASTM30Point) -> CGPoint {
            let x = point.value.x - coordinateSpace.xMin
            let y = point.value.y - coordinateSpace.yMin

            let xx = (view.frame.width/coordinateSpace.xLength)*x
            let yy = (view.frame.height/coordinateSpace.yLength)*y

            return CGPoint(x: xx, y: yy)
        }

        var i = 0
        for point in points {
            let pointPath = UIBezierPath(arcCenter: CGPoint.zero,
                radius: 6,
                startAngle: 0,
                endAngle: (M_PI*2.0).cgFloatValue,
                clockwise: true
            )

            let pointLayer = CAShapeLayer()
            pointLayer.path = pointPath.CGPath
            pointLayer.fillColor = UIColor(red: 0.129, green: 0.286, blue: 0.486, alpha: 1.0).CGColor

            let pointView = UIView()
            pointView.frame.size = CGSize(width: 10, height: 10)
            pointView.layer.addSublayer(pointLayer)
            pointLayer.position = CGPoint(x: 5, y: 5)

            view.addSubview(pointView)
            pointView.center = realPointPositionFromPoint(point)

            pointView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0)

            UIView.animateWithDuration(2.0,
                delay: Double(i)*0.05,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: {
                    pointView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
                },
                completion: nil
            )

            i++
        }
    }

    private func _addMainGridLinesAndMarkTextToView(view: UIView, numberOfBlockAtX: Int, numberOfBlockAtY: Int) {
        var labelPositionsForXAxis = [CGPoint]()
        var labelPositionsForYAxis = [CGPoint]()

        let mainLineslayer = CAShapeLayer()
        mainLineslayer.frame.size = view.frame.size
        mainLineslayer.path = {
            let path = UIBezierPath()

            path.appendPath(_innerLinesPathAtXAxisFromMin(0,
                toMax: view.frame.width,
                numberOfLines: numberOfBlockAtX + 1,
                yBase: view.frame.height + 4,
                lengthOfLine: -16,
                isIncludeHeadAndTail: true,
                didAddLine: { from, _, _ in labelPositionsForXAxis.append(from) }
            ))

            path.appendPath(_innerLinesPathAtYAxisFromMin(0,
                toMax: view.frame.height,
                numberOfLines: numberOfBlockAtY + 1,
                xBase: -4,
                lengthOfLine: 16,
                isIncludeHeadAndTail: true,
                didAddLine: { from, _, _ in labelPositionsForYAxis.append(from) }
            ))

            return path.CGPath
        }()

        mainLineslayer.fillColor = UIColor.clearColor().CGColor
        mainLineslayer.strokeColor = UIColor.blackColor().CGColor
        mainLineslayer.lineWidth = 2

        view.layer.addSublayer(mainLineslayer)
        mainLineslayer.frame.origin = CGPoint.zero

        _addCoordinateMarkLabelsToView(view,
            textStartValue: coordinateSpace.xMin,
            positions: labelPositionsForXAxis,
            offset: CGPoint(x: 0, y: 10)
        )

        _addCoordinateMarkLabelsToView(view,
            textStartValue: coordinateSpace.yMin,
            textAlignmen: .Right,
            positions: labelPositionsForYAxis.reverse(),
            offset: CGPoint(x: -20, y: 0),
            useCommonFrameSize: true
        )
    }

    private func _addSubGridLinesToLayer(view: UIView, numberOfBlockAtX: Int, numberOfBlockAtY: Int) {
        let subLinesLayer = CAShapeLayer()
        subLinesLayer.frame = view.frame
        subLinesLayer.path = {
            let path = UIBezierPath()

            let xInterval = view.frame.width/numberOfBlockAtX.cgFloatValue
            for i in 0..<numberOfBlockAtX {
                path.appendPath(_innerLinesPathAtXAxisFromMin(xInterval*i.cgFloatValue,
                    toMax: xInterval*(i + 1).cgFloatValue,
                    numberOfLines: 4,
                    yBase: view.frame.height,
                    lengthOfLine: -8,
                    isIncludeHeadAndTail: false
                ))
            }

            let yInterval = view.frame.height/numberOfBlockAtY.cgFloatValue
            for i in 0..<numberOfBlockAtY {
                path.appendPath(_innerLinesPathAtYAxisFromMin(yInterval*i.cgFloatValue,
                    toMax: yInterval*(i + 1).cgFloatValue,
                    numberOfLines: 4,
                    xBase: 0.0,
                    lengthOfLine: 8,
                    isIncludeHeadAndTail: false
                ))
            }

            return path.CGPath
        }()
        subLinesLayer.fillColor = UIColor.clearColor().CGColor
        subLinesLayer.strokeColor = UIColor.blackColor().CGColor
        subLinesLayer.lineWidth = 1
        view.layer.addSublayer(subLinesLayer)
        subLinesLayer.frame.origin = CGPoint.zero
    }

    private func _innerLinesPathAtXAxisFromMin(min: CGFloat,
        toMax max: CGFloat,
        numberOfLines: Int,
        yBase: CGFloat,
        lengthOfLine: CGFloat,
        isIncludeHeadAndTail: Bool = false,
        didAddLine: ((pathFrom: CGPoint, pathTo: CGPoint, path: UIBezierPath) -> ())? = nil
    ) -> UIBezierPath  {
        let length = abs(max - min)
        let interval = length/(numberOfLines.cgFloatValue + (isIncludeHeadAndTail ? -1.0 : 1.0))

        let start = min + (isIncludeHeadAndTail ? 0.0 : interval)

        let path = UIBezierPath()
        for i in 0..<numberOfLines {
            let from = CGPoint(x: start + interval*i.cgFloatValue, y: yBase)
            let to = CGPoint(x: start + interval*i.cgFloatValue, y: yBase + lengthOfLine)

            let linePath = UIBezierPath()
            linePath.moveToPoint(from)
            linePath.addLineToPoint(to)

            path.appendPath(linePath)

            didAddLine?(pathFrom: from, pathTo: to, path: path)
        }

        return path
    }

    private func _innerLinesPathAtYAxisFromMin(min: CGFloat,
        toMax max: CGFloat,
        numberOfLines: Int,
        xBase: CGFloat,
        lengthOfLine: CGFloat,
        isIncludeHeadAndTail: Bool = false,
        didAddLine: ((pathFrom: CGPoint, pathTo: CGPoint, path: UIBezierPath) -> ())? = nil
    ) -> UIBezierPath  {
        let length = abs(max - min)
        let interval = length/(numberOfLines.cgFloatValue + (isIncludeHeadAndTail ? -1.0 : 1.0))

        let start = min + (isIncludeHeadAndTail ? 0.0 : interval)

        let path = UIBezierPath()
        for i in 0..<numberOfLines {
            let linePath = UIBezierPath()
            let from = CGPoint(x: xBase, y: start + interval*i.cgFloatValue)
            let to = CGPoint(x: xBase + lengthOfLine, y: start + interval*i.cgFloatValue)

            linePath.moveToPoint(from)
            linePath.addLineToPoint(to)

            path.appendPath(linePath)

            didAddLine?(pathFrom: from, pathTo: to, path: path)
        }

        return path
    }

    private func _addCoordinateMarkLabelsToView(view: UIView,
        textStartValue: CGFloat,
        textAlignmen: NSTextAlignment = .Center,
        positions: [CGPoint],
        offset: CGPoint = CGPoint.zero,
        useCommonFrameSize: Bool = false
    ) {
        var maxSize = CGSize.zero
        var labels = [UILabel]()

        positions.enumerate().forEach {
            (index, position) -> () in
            let label = self._addAndGetLabelWithText("\(Int(textStartValue) + index*10)",
                center: position + offset,
                alignment: textAlignmen,
                toView: view
            )

            maxSize = CGSize(
                width: max(label.frame.width, maxSize.width),
                height: max(label.frame.height, maxSize.height)
            )

            labels.append(label)
        }

        if useCommonFrameSize {
            labels.forEach { label in label.frame.size = maxSize }
        }
    }
    
    private func _addAndGetLabelWithText(text: String,
        center: CGPoint,
        alignment: NSTextAlignment = .Center,
        toView view: UIView
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.sizeToFit()

        view.addSubview(label)
        label.center = center
        label.textAlignment = alignment

        return label
    }
}