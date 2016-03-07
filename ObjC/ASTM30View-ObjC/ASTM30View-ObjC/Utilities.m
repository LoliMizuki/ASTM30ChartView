//
//  Utilities.m
//  ASTM30View-ObjC
//
//  Created by lolimizuki on 2016/2/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);

    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}


@end
