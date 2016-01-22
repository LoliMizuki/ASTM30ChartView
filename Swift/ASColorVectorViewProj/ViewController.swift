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
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        _tm30ViewController = segue.destinationViewController as! ASTM30ColorVectorViewController
    }


    // MARK: Private

    private var _tm30ViewController: ASTM30ColorVectorViewController! = nil
}


// MARK: IBActons

extension ViewController {

    @IBAction func didTouchUpInsideMaskButton(button: UIButton) {
        _tm30ViewController.clipBackgroundWithPointsInfoName("Hello")
    }
}
