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
        view.backgroundColor = UIColor.grayColor()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        _setAndAddCoordinateViewToView(view)
        _setBoardLinesToView(_coordinateView!)
        _setCoordinateGridToView(_coordinateView!)
    }


    // MARK: Private

    var _coordinateView: UIView? = nil

    private func _setAndAddCoordinateViewToView(view: UIView) {
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
        view.layer.borderColor = UIColor ( red: 1.0, green: 0.0, blue: 0.0, alpha: 0.395851293103448 ).CGColor
        view.layer.borderWidth = 4
    }

    private func _setCoordinateGridToView(view: UIView) {
        let numberOfBlockAtX = 5
        let numberOfBlockAtY = 8

        let mainLineslayer = CAShapeLayer()
        mainLineslayer.frame = CGRect(size: view.frame.size)
        mainLineslayer.path = {
            let path = UIBezierPath()

            path.appendPath(_innerLinesPathAtXAxisWithMin(0,
                max: view.frame.width,
                numberOfLines: numberOfBlockAtX + 1,
                yBase: view.frame.height + 10,
                lengthOfLine: -20,
                isIncludeHeadAndTail: true
            ))

            path.appendPath(_innerLinesPathAtYAxisWithMin(0,
                max: view.frame.height,
                numberOfLines: numberOfBlockAtY + 1,
                xBase: -10,
                lengthOfLine: 20,
                isIncludeHeadAndTail: true
            ))

            return path.CGPath
        }()

        mainLineslayer.fillColor = UIColor.clearColor().CGColor
        mainLineslayer.strokeColor = UIColor.greenColor().CGColor
        mainLineslayer.lineWidth = 2

        view.layer.addSublayer(mainLineslayer)
        mainLineslayer.frame.origin = CGPoint.zero

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
        isIncludeHeadAndTail: Bool = false
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
        }

        return path
    }

    private func _innerLinesPathAtYAxisWithMin(min: CGFloat,
        max: CGFloat,
        numberOfLines: Int,
        xBase: CGFloat,
        lengthOfLine: CGFloat,
        isIncludeHeadAndTail: Bool = false
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
        }

        return path
    }
}