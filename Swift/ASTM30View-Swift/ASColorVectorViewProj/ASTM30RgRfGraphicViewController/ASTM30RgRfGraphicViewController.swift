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

    var pointInfos = [ASTM30PointsInfo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        coordinateSpace = ASTM30CoordinateSpace(xMin: 50, yMin: 60, xMax: 100, yMax: 140)
        view.backgroundColor = UIColor(red: 0.502, green: 0.0, blue: 0.251, alpha: 1.0)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        _setAndAddCoordinateViewToView(view)
        _setGrayLayersToView(_coordinateView!)
        _setBoardLinesToView(_coordinateView!)
        _setCoordinateGridToView(_coordinateView!)
    }


    // MARK: Private

    var _coordinateView: UIView? = nil

    private func _setAndAddCoordinateViewToView(view: UIView) {
        _coordinateView?.removeFromSuperview()

        let coordinateView = UIView(frame: view.frame*0.9)
        let offset = CGPoint(
            x: (view.frame.width - coordinateView.frame.width)/2,
            y: -(view.frame.height - coordinateView.frame.height)/2
        )

        coordinateView.backgroundColor = UIColor.blueColor()

        view.addSubview(coordinateView)
        coordinateView.center = view.center + offset

        _coordinateView = coordinateView
    }

    private func _setBoardLinesToView(view: UIView) {
        view.layer.borderColor = UIColor.blackColor().CGColor
        view.layer.borderWidth = 2
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
        grayLayer.fillColor = UIColor(red: 1.0, green: 1.0, blue: 0.4, alpha: 1.0).CGColor
        view.layer.addSublayer(grayLayer)

        let deepGrayLayer = CAShapeLayer()
        deepGrayLayer.path = doubleTriangelPathWithSize(CGSize(width: view.frame.width*0.8, height: view.frame.height)).CGPath
        deepGrayLayer.strokeColor = UIColor.clearColor().CGColor
        deepGrayLayer.fillColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0).CGColor
        view.layer.addSublayer(deepGrayLayer)
    }

    private func _setCoordinateGridToView(view: UIView) {
        let numberOfBlockAtX = 5
        let numberOfBlockAtY = 8

        _addMainGridLinesToView(view,
            numberOfBlockAtX: numberOfBlockAtX,
            numberOfBlockAtY: numberOfBlockAtY
        )

        _addSubGridLinesToLayer(view,
            numberOfBlockAtX: numberOfBlockAtX,
            numberOfBlockAtY: numberOfBlockAtY
        )
    }

    private func _addMainGridLinesToView(view: UIView, numberOfBlockAtX: Int, numberOfBlockAtY: Int) {
        var labelPositionsAtXAxis = [CGPoint]()
        var labelPositionsAtYAxis = [CGPoint]()

        let mainLineslayer = CAShapeLayer()
        mainLineslayer.frame = CGRect(size: view.frame.size)
        mainLineslayer.path = {
            let path = UIBezierPath()

            path.appendPath(_innerLinesPathAtXAxisWithMin(0,
                max: view.frame.width,
                numberOfLines: numberOfBlockAtX + 1,
                yBase: view.frame.height + 10,
                lengthOfLine: -20,
                isIncludeHeadAndTail: true,
                didAddLine: { from, _, _ in labelPositionsAtXAxis.append(from) }
            ))

            path.appendPath(_innerLinesPathAtYAxisWithMin(0,
                max: view.frame.height,
                numberOfLines: numberOfBlockAtY + 1,
                xBase: -10,
                lengthOfLine: 20,
                isIncludeHeadAndTail: true,
                didAddLine: { from, _, _ in labelPositionsAtYAxis.append(from) }
            ))

            return path.CGPath
            }()

        mainLineslayer.fillColor = UIColor.clearColor().CGColor
        mainLineslayer.strokeColor = UIColor.greenColor().CGColor
        mainLineslayer.lineWidth = 2

        view.layer.addSublayer(mainLineslayer)
        mainLineslayer.frame.origin = CGPoint.zero

        var maxSize = CGSize.zero
        var labels = [UILabel]()

        labelPositionsAtXAxis.enumerate().forEach {
            (index, position) -> () in
            let offset = CGPoint(x: 0, y: 10)
            let label = self._addAndGetLabelWithText("\(50 + index*10)", center: position + offset, toView: view)

            maxSize = CGSize(
                width: max(label.frame.width, maxSize.width),
                height: max(label.frame.height, maxSize.height)
            )

            labels.append(label)
        }

        labelPositionsAtYAxis.reverse().enumerate().forEach {
            (index, position) -> () in
            let offset = CGPoint(x: -20, y: 0)
            let label = self._addAndGetLabelWithText("\(60 + index*10)", center: position + offset, alignment: .Right, toView: view)

            maxSize = CGSize(
                width: max(label.frame.width, maxSize.width),
                height: max(label.frame.height, maxSize.height)
            )

            labels.append(label)
        }

        labels.forEach { label in label.frame.size = maxSize }
    }

    private func _addSubGridLinesToLayer(view: UIView, numberOfBlockAtX: Int, numberOfBlockAtY: Int) {
        let subLinesLayer = CAShapeLayer()
        subLinesLayer.frame = view.frame
        subLinesLayer.path = {
            let path = UIBezierPath()

            let xInterval = view.frame.width/numberOfBlockAtX.cgFloatValue
            for i in 0..<numberOfBlockAtX {
                path.appendPath(_innerLinesPathAtXAxisWithMin(xInterval*i.cgFloatValue,
                    max: xInterval*(i + 1).cgFloatValue,
                    numberOfLines: 4,
                    yBase: view.frame.height,
                    lengthOfLine: -8,
                    isIncludeHeadAndTail: false
                ))
            }

            let yInterval = view.frame.height/numberOfBlockAtY.cgFloatValue
            for i in 0..<numberOfBlockAtY {
                path.appendPath(_innerLinesPathAtYAxisWithMin(yInterval*i.cgFloatValue,
                    max: yInterval*(i + 1).cgFloatValue,
                    numberOfLines: 4,
                    xBase: 0.0,
                    lengthOfLine: 8,
                    isIncludeHeadAndTail: false
                ))
            }

            return path.CGPath
        }()
        subLinesLayer.fillColor = UIColor.clearColor().CGColor
        subLinesLayer.strokeColor = UIColor.brownColor().CGColor
        subLinesLayer.lineWidth = 1
        view.layer.addSublayer(subLinesLayer)
        subLinesLayer.frame.origin = CGPoint.zero
    }

    private func _innerLinesPathAtXAxisWithMin(min: CGFloat,
        max: CGFloat,
        numberOfLines: Int,
        yBase: CGFloat,
        lengthOfLine: CGFloat,
        isIncludeHeadAndTail: Bool = false,
        didAddLine: ((from: CGPoint, to: CGPoint, path: UIBezierPath) -> ())? = nil
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

            didAddLine?(from: from, to: to, path: path)
        }

        return path
    }

    private func _innerLinesPathAtYAxisWithMin(min: CGFloat,
        max: CGFloat,
        numberOfLines: Int,
        xBase: CGFloat,
        lengthOfLine: CGFloat,
        isIncludeHeadAndTail: Bool = false,
        didAddLine: ((from: CGPoint, to: CGPoint, path: UIBezierPath) -> ())? = nil
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

            didAddLine?(from: from, to: to, path: path)
        }

        return path
    }

    private func _addAndGetLabelWithText(text: String,
        center: CGPoint,
        alignment: NSTextAlignment = .Center,
        toView view: UIView
    ) -> UILabel {
        let label = UILabel()
        label.text = text

        view.addSubview(label)
        label.frame.size = CGSize(width: 30, height: 20.33)
        label.center = center
        label.textAlignment = alignment

        return label
    }
}