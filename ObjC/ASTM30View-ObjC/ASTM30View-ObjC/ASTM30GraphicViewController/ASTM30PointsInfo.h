//
//  ASTM30PointsInfo.h
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ASTM30Point : NSObject

@property (nonatomic, nonnull, readwrite, strong) NSString* key;
@property (nonatomic, readwrite) CGPoint value;

- (instancetype _Nonnull)initWithKey:(NSString * _Nonnull)key value:(CGPoint)value;

@end



@interface ASTM30PointsInfo : NSObject

@property (nonatomic, nonnull, readwrite, strong) NSString* name;
@property (nonatomic, readwrite) CGFloat lineWidth;
@property (nonatomic, nonnull, readwrite, strong) UIColor* color;
@property (nonatomic, nonnull, readwrite, strong) UIColor* colorInMasked;
@property (nonatomic, nonnull, readwrite, strong) NSArray<ASTM30Point *>* points;
@property (nonatomic, readwrite) BOOL closePath;

- (instancetype _Nonnull)initWithName:(NSString * _Nonnull)name;

- (ASTM30Point * _Nullable)pointWithKey:(NSString * _Nonnull)key;

@end
