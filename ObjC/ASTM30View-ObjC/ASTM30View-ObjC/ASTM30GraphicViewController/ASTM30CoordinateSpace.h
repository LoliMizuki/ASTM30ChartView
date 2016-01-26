//
//  ASTM30CoordinateSpace.h
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface ASTM30CoordinateSpace : NSObject

@property (nonatomic, readwrite) CGFloat xMin;
@property (nonatomic, readwrite) CGFloat yMin;
@property (nonatomic, readwrite) CGFloat xMax;
@property (nonatomic, readwrite) CGFloat yMax;

@property (nonatomic, readonly) CGFloat xLength;
@property (nonatomic, readonly) CGFloat yLength;

- (instancetype)initWithXMin:(CGFloat)xMin yMin:(CGFloat)yMin xMax:(CGFloat)xMax yMax:(CGFloat)yMax;

@end
