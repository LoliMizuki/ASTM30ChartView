//
//  ASTM30PointsInfo.h
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASTM30Point : NSObject

@property (nonatomic, readwrite, strong) NSString* key;
@property (nonatomic, readwrite) CGPoint value;

- (instancetype)initWithKey:(NSString *)key value:(CGPoint)value;

@end



@interface ASTM30PointsInfo : NSObject

@property (nonatomic, readwrite, strong) NSString* name;
@property (nonatomic, readwrite) CGFloat lineWidth;
@property (nonatomic, readwrite, strong) UIColor* color;
@property (nonatomic, nullable, readwrite, strong) UIColor* colorInMasked;
@property (nonatomic, readwrite, strong) NSArray<ASTM30Point *>* points;
@property (nonatomic, readwrite) BOOL closePath;

- (instancetype)initWithName:(NSString *)name;

- (nullable ASTM30Point *)pointWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
