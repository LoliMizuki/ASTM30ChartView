//
//  ASTM30CoordinateSpace.m
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import "ASTM30CoordinateSpace.h"

@implementation ASTM30CoordinateSpace

@synthesize xLength;
@synthesize yLength;

- (instancetype)initWithXMin:(CGFloat)aXMin yMin:(CGFloat)aYMin xMax:(CGFloat)aXMax yMax:(CGFloat)aYMax {
    self = [super init];

    self.xMin = aXMin;
    self.yMin = aYMin;
    self.xMax = aXMax;
    self.yMax = aYMax;

    return self;
}

- (CGFloat)xLength { return fabs(self.xMax - self.xMin); }

- (CGFloat)yLength { return fabs(self.yMax - self.yMin); }

- (NSString *)description {
    return [NSString stringWithFormat:@"x: [%0.2f, %0.2f], y: [%0.2f, %0.2f]",
            self.xMin,
            self.xMax,
            self.yMin,
            self.yMax];
}

@end
