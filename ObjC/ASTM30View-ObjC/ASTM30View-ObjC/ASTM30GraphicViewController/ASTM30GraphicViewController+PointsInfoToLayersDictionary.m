//
//  PointsInfoToLayersDictionary.m
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/27.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import "ASTM30GraphicViewController+PointsInfoToLayersDictionary.h"
#import "ASTM30GraphicViewController.h"
#import "ASTM30PointsInfo.h"
#import "MZ.h"

@implementation PointsInfoToLayersDictionary {
    NSMutableDictionary<NSString*, ASTM30PointsInfo*>* _pointsInfosDict;
    NSMutableDictionary<NSString*, CAShapeLayer*>* _pointsLayersDict;
}

- (instancetype)init {
    self = [super init];

    _pointsInfosDict = [NSMutableDictionary dictionary];
    _pointsLayersDict = [NSMutableDictionary dictionary];

    return self;
}

- (NSArray<ASTM30PointsInfo *> *)allKeys {
    return _pointsInfosDict.allValues;
}

- (NSArray<CAShapeLayer *> *)allValues {
    return _pointsLayersDict.allValues;
}

- (CAShapeLayer *)objectForKeyedSubscript:(ASTM30PointsInfo *)info {
    return _pointsLayersDict[info.name];
}

- (void)setObject:(CAShapeLayer *)layer forKeyedSubscript:(ASTM30PointsInfo *)info {
    _pointsInfosDict[info.name] = info;
    _pointsLayersDict[info.name] = layer;
}

- (void)removeObjectForKey:(ASTM30PointsInfo *)info {
    [_pointsInfosDict removeObjectForKey:info.name];
    [_pointsLayersDict removeObjectForKey:info.name];
}

- (void)removeAllObjects {
    [_pointsInfosDict removeAllObjects];
    [_pointsLayersDict removeAllObjects];
}

- (NSArray<MZPair *> *)filterWithFunc:(bool (^)(ASTM30PointsInfo* info, CAShapeLayer* layer))func {
    mz_var(result, [NSMutableArray array]);
    mz_var(allNames, _pointsInfosDict.allKeys);

    for (NSString* name in allNames) {
        mz_var(info, _pointsInfosDict[name]);
        mz_var(layer, _pointsLayersDict[name]);

        if (func(info, layer)) {
            [result addObject:[[MZPair alloc] initWithFirst:info second:layer]];
        }
    }

    return result;
}

- (void)forEachWithAction:(void (^)(ASTM30PointsInfo* info, CAShapeLayer* layer))action {
    for (NSString * name in _pointsInfosDict.allKeys) {
        mz_var(info, _pointsInfosDict[name]);
        mz_var(layer, _pointsLayersDict[name]);

        action(info, layer);
    }
}


# pragma mark - Private

- (void)dealloc {
    [self removeAllObjects];
}

@end
