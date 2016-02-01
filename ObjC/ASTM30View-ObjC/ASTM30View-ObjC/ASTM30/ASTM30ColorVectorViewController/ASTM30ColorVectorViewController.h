//
//  ASTM30ColorVectorViewController.h
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASTM30CoordinateSpace;
@class ASTM30PointsInfo;


typedef NS_ENUM(NSUInteger, ASTM30GraphicType) {
    ASTM30GraphicType_ColorVector,
    ASTM30GraphicType_ColorDistortion,
};

NS_ASSUME_NONNULL_BEGIN

@interface ASTM30ColorVectorViewController : UIViewController

@property (nonatomic, readwrite, strong) ASTM30CoordinateSpace* coordinateSpace;
@property (nonatomic, readwrite, strong, nullable) NSString* testSourceName;
@property (nonatomic, readwrite, strong, nullable) NSString* referenceName;

@property (nonatomic, readonly) ASTM30GraphicType graphicType;

- (void)addPointsInfo:(ASTM30PointsInfo *)info;
- (nullable ASTM30PointsInfo *)poinsInfoWithName:(NSString *)name;
- (void)removePointsInfoWithName:(NSString *)name;

- (void)setGraphicType:(ASTM30GraphicType)type animated:(bool)animated duration:(CFTimeInterval)duration;
- (void)setGraphicType:(ASTM30GraphicType)type;
- (void)refresh;

@end

NS_ASSUME_NONNULL_END
