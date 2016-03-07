//
//  ASTM30RfRgViewController.h
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/2/1.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASTM30CoordinateSpace;
@class ASTM30Point;

NS_ASSUME_NONNULL_BEGIN

@interface ASTM30RfRgViewController : UIViewController

// General
@property (readwrite, strong, nonatomic) ASTM30CoordinateSpace* coordinateSpace;
@property (readwrite, strong, nonatomic) NSMutableArray<ASTM30Point*>* points;
@property (readwrite, strong, nonatomic) UIColor* backgroundColor;

// Points
@property (readwrite, nonatomic) CGFloat pointSize;
@property (readwrite, strong, nonatomic) UIColor* pointColor;
@property (readwrite, strong, nonatomic) UIColor* pointColorForFocused;
@property (readwrite, strong, nonatomic) UIColor* pointStrokeColorForFocused;
@property (readwrite, strong, nonatomic) UIColor* pointColorForNonfocused;
@property (readwrite, strong, nonatomic) UIColor* pointStrokeColorForNonfocused;

// Grid, Labels
@property (readwrite, strong, nonatomic) UIColor* gridLineColor;
@property (readwrite, strong, nonatomic) UIColor* coordinateLabelTextColor;
@property (readwrite, nonatomic) CGPoint coordinateViewOffset;
@property (readwrite, nonatomic) CGFloat coordinateLabelTextSize;
@property (readwrite, nonatomic) CGPoint coordinateXLabelOffset;
@property (readwrite, nonatomic) CGPoint coordinateYLabelOffset;

- (void)refresh;
- (void)setFocusPointWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
