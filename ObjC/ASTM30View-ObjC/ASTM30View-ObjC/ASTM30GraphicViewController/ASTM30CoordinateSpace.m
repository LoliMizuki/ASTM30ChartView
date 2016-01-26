//
//  ASTM30CoordinateSpace.m
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import "ASTM30CoordinateSpace.h"

@implementation ASTM30CoordinateSpace

@synthesize xMin;
@synthesize yMin;
@synthesize xMax;
@synthesize yMax;
@synthesize xLength;
@synthesize yLength;

- (instancetype)initWithXMin:(CGFloat)aXMin yMin:(CGFloat)aYMin xMax:(CGFloat)aXMax yMax:(CGFloat)aYMax {
    self = [super init];
    if (self == nil) return nil;

    self.xMin = aXMin;
    self.yMin = aYMin;
    self.xMax = aXMax;
    self.yMax = aYMax;

    return self;
}

- (CGFloat)xLength { return fabs(xMax - xMin); }

- (CGFloat)yLength { return fabs(yMax - yMin); }

- (NSString *)description {
    return [NSString stringWithFormat:@"x: [%0.2f, %0.2f], y: [%0.2f, %0.2f]", xMin, xMax, yMin, yMax];
}

@end
