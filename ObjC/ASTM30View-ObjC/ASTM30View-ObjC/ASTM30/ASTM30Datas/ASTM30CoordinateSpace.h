//
//  ASTM30CoordinateSpace.h
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASTM30CoordinateSpace : NSObject

@property (readwrite, nonatomic) CGFloat xMin;
@property (readwrite, nonatomic) CGFloat yMin;
@property (readwrite, nonatomic) CGFloat xMax;
@property (readwrite, nonatomic) CGFloat yMax;

@property (readonly, nonatomic) CGFloat xLength;
@property (readonly, nonatomic) CGFloat yLength;

- (instancetype)initWithXMin:(CGFloat)xMin yMin:(CGFloat)yMin xMax:(CGFloat)xMax yMax:(CGFloat)yMax;

@end

NS_ASSUME_NONNULL_END
