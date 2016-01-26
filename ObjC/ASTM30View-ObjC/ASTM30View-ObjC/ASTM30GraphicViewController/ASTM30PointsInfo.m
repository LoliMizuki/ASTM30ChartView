//
//  ASTM30PointsInfo.m
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import "ASTM30PointsInfo.h"

@implementation ASTM30Point

@synthesize key;
@synthesize value;

- (instancetype)initWithKey:(NSString *)aKey value:(CGPoint)aValue {
    self = [super init];
    if (self == nil) return self;

    self.key = aKey;
    self.value = aValue;


    return self;
}

@end



@implementation ASTM30PointsInfo

@synthesize name;
@synthesize lineWidth;
@synthesize color;
@synthesize colorInMasked;
@synthesize points;
@synthesize closePath;

- (instancetype _Nonnull)initWithName:(NSString * _Nonnull)aName {
    self = [super init];
    if (self == nil) return self;

    self.name = name;

    return self;
}

- (ASTM30Point * _Nullable)pointWithKey:(NSString * _Nonnull)key {
    for (ASTM30Point* point in points) {
        if ([point.key isEqualToString:key]) {
            return point;
        }
    }

    return nil;
}

@end
