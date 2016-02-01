//
//  ASTM30RfRgViewController.h
//  ASTM30View-ObjC
//
//  Created by lolimizuki on 2016/2/1.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASTM30CoordinateSpace;
@class ASTM30Point;

NS_ASSUME_NONNULL_BEGIN

@interface ASTM30RfRgViewController : UIViewController

@property (nonatomic, readwrite, strong) ASTM30CoordinateSpace* coordinateSpace;
@property (nonatomic, readwrite, strong) NSMutableArray<ASTM30Point*>* points;

- (void)refresh;

@end

NS_ASSUME_NONNULL_END
