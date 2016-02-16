//
//  ASTM30RfRgViewController.h
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/2/1.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASTM30CoordinateSpace;
@class ASTM30Point;

NS_ASSUME_NONNULL_BEGIN

@interface ASTM30RfRgViewController : UIViewController

@property (nonatomic, strong, readwrite) ASTM30CoordinateSpace* coordinateSpace;
@property (nonatomic, strong, readwrite) NSMutableArray<ASTM30Point*>* points;
@property (nonatomic, strong, readwrite) UIColor* backgroundColor;
@property (nonatomic, strong, readwrite) UIColor* pointColor;
@property (nonatomic, strong, readwrite) UIColor* gridLineColor;
@property (nonatomic, strong, readwrite) UIColor* coordinateLabelTextColor;

- (void)refresh;

@end

NS_ASSUME_NONNULL_END
