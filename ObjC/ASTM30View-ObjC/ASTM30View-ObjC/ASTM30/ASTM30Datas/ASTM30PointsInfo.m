//
//  ASTM30PointsInfo.m
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import "ASTM30PointsInfo.h"
#import "MZ.h"

@implementation ASTM30Point

@synthesize key;
@synthesize value;

- (instancetype)initWithKey:(NSString *)aKey value:(CGPoint)aValue {
    self = [super init];

    self.key = aKey;
    self.value = (!CGPointIsNaN(aValue))? aValue : CGPointInvalid;

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

- (instancetype)initWithName:(NSString *)aName {
    self = [super init];

    self.name = aName;

    self.lineWidth = 2.0;
    self.color = [UIColor blackColor];
    self.colorInMasked = nil;
    self.points = [NSArray array];
    self.closePath = true;

    return self;
}

- (nullable ASTM30Point *)pointWithKey:(NSString *)key {
    for (ASTM30Point* point in points) {
        if ([point.key isEqualToString:key]) {
            return point;
        }
    }

    return nil;
}

@end
