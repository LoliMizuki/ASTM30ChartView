//
//  PointsInfoToLayersDictionary.h
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/27.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//
//  Internal support class for ASTM30ColorVectorViewController
//  - Act as NSDictionary<ASTM30PointsInfo*, CAShapeLayer*>


#import <UIKit/UIKit.h>

@class ASTM30PointsInfo;
@class CAShapeLayer;
@class MZPair;

NS_ASSUME_NONNULL_BEGIN

@interface PointsInfoToLayersDictionary : NSObject

@property (nonatomic, readonly) NSArray<ASTM30PointsInfo *>* allKeys;
@property (nonatomic, readonly) NSArray<CAShapeLayer *>* allValues;

- (CAShapeLayer *)objectForKeyedSubscript:(ASTM30PointsInfo *)info;
- (void)setObject:(CAShapeLayer *)layer forKeyedSubscript:(ASTM30PointsInfo *)info;
- (void)removeObjectForKey:(ASTM30PointsInfo *)info;
- (void)removeAllObjects;
- (NSArray<MZPair *> *)filterWithFunc:(BOOL (^)(ASTM30PointsInfo* info, CAShapeLayer* layer))func;
- (void)forEachWithAction:(void (^)(ASTM30PointsInfo* info, CAShapeLayer* layer))action;

@end

NS_ASSUME_NONNULL_END