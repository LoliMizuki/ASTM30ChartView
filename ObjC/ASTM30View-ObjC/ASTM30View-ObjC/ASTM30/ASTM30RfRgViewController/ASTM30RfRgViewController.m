//
//  ASTM30RfRgViewController.m
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/2/1.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import "ASTM30RfRgViewController.h"
#import "ASTM30CoordinateSpace.h"
#import "ASTM30PointsInfo.h"
#import "MZ.h"

@interface ASTM30RfRgViewController ()

@property (readonly, nonatomic) CGFloat _defaultTextSize;
@property (readwrite, weak, nonatomic) UIView* _coordinateView;
@property (readwrite, weak, nonatomic) CAShapeLayer* _pointsLayer;
@property (readwrite, weak, nonatomic) ASTM30Point* _focusPoint;
@property (readwrite, weak, nonatomic) UILabel* _xCoordinateDescriptionLabel;
@property (readwrite, weak, nonatomic) UILabel* _yCoordinateDescriptionLabel;
@property (readwrite, strong, nonatomic) NSMutableDictionary<NSString*, UIView*>* _pointToViewDict;

- (void)_init;

@end

@interface ASTM30RfRgViewController (GraphicComponents)

- (void)_setAndAddCoordinateViewToView:(UIView *)view;
- (void)_setColorZoneLayersToView:(UIView *)view;
- (void)_setBoardLinesToView:(UIView *)view;
- (void)_setCoordinateGridLinesAndLabelsToView:(UIView *)view;
- (void)_setAndAddPointLayerToView:(UIView *)view;
- (void)_setPointViewsToView:(UIView *)view;
- (void)_addMainGridLinesAndNumberLabelToView:(UIView *)view
                             numberOfBlockAtX:(NSInteger)numberOfBlockAtX
                             numberOfBlockAtY:(NSInteger)numberOfBlockAtY;
- (void)_addSubGridLinesToLayer:(UIView *)view
               numberOfBlockAtX:(NSInteger)numberOfBlockAtX
               numberOfBlockAtY:(NSInteger)numberOfBlockAtY;
- (UILabel *)_addAndGetLabelWithText:(NSString *)text
                              center:(CGPoint)center
                           alignment:(NSTextAlignment)alignment
                              toView:(UIView *)view;
- (UIView *)_addAndGetPointViewToView:(UIView *)view at:(CGPoint)center;
- (void)_addCoordinateNumberLabelsToView:(UIView *)view
                          textStartValue:(CGFloat)textStartValue
                            textAlignmen:(NSTextAlignment)textAlignmen
                               positions:(NSArray<NSValue *> *)positions
                                  offset:(CGPoint)offset
                      useCommonFrameSize:(BOOL)useCommonFrameSize;
- (void)_addXYCoordinateDescriptionLabelsToView:(UIView *)view;
- (void)_addCoordinateNumberLabelsToView:(UIView *)view
                          textStartValue:(CGFloat)textStartValue
                               positions:(NSArray<NSValue *> *)positions
                                  offset:(CGPoint)offset;
- (UIBezierPath *)_innerLinesPathAtXAxisFromMin:(CGFloat)min
                                          toMax:(CGFloat)max
                                  numberOfLines:(NSInteger)numberOfLines
                                          yBase:(CGFloat)yBase
                                   lengthOfLine:(CGFloat)lengthOfLine
                           isIncludeHeadAndTail:(BOOL)isIncludeHeadAndTail
                                     didAddLine:(void (^)(CGPoint pathFrom, CGPoint pathTo, UIBezierPath* path))didAddLine;
- (UIBezierPath *)_innerLinesPathAtXAxisFromMin:(CGFloat)min
                                          toMax:(CGFloat)max
                                  numberOfLines:(NSInteger)numberOfLines
                                          yBase:(CGFloat)yBase
                                   lengthOfLine:(CGFloat)lengthOfLine
                           isIncludeHeadAndTail:(BOOL)isIncludeHeadAndTail;
- (UIBezierPath *)_innerLinesPathAtYAxisFromMin:(CGFloat)min
                                          toMax:(CGFloat)max
                                  numberOfLines:(NSInteger)numberOfLines
                                          xBase:(CGFloat)xBase
                                   lengthOfLine:(CGFloat)lengthOfLine
                           isIncludeHeadAndTail:(BOOL)isIncludeHeadAndTail
                                     didAddLine:(void (^)(CGPoint pathFrom, CGPoint pathTo, UIBezierPath* path))didAddLine;
- (void)_modifyLayout;
- (CAShapeLayer *)_newShaperLayer;
- (void)_setPointViewForNormal:(UIView *)pointView;
- (void)_setPointViewForFocus:(UIView *)pointView bringToTop:(BOOL)needBringToTop;
- (void)_setPointViewForNonFocus:(UIView *)pointView;

@end



@implementation ASTM30RfRgViewController

@synthesize _defaultTextSize;

- (instancetype)init {
    self = [super init];
    [self _init];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self _init];
    return self;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self refresh];
}

- (void)refresh {
    self.view.backgroundColor = self.backgroundColor;

    [self _setAndAddCoordinateViewToView:self.view];
    [self _setColorZoneLayersToView:self._coordinateView];
    [self _setBoardLinesToView:self._coordinateView];
    [self _setCoordinateGridLinesAndLabelsToView:self._coordinateView];
    [self _setAndAddPointLayerToView:self._coordinateView];
    [self _setPointViewsToView:self._coordinateView];
    [self _addXYCoordinateDescriptionLabelsToView:self.view];
    [self _modifyLayout];
}

- (void)setFocusPointWithKey:(NSString *)key {
    mz_var(focusPointView, self._pointToViewDict[key]);

    if (focusPointView == nil) {
        [self._pointToViewDict.allValues forEachWithAction:^(UIView* pointView) {
            [self _setPointViewForNormal:pointView];
        }];
    } else {
        [self._pointToViewDict.allValues forEachWithAction:^(UIView* pointView) {
            if (pointView == focusPointView) return;
            [self _setPointViewForNonFocus:pointView];
        }];

        [self _setPointViewForFocus:focusPointView bringToTop:true];
    }
}


# pragma mark - Private

- (void)dealloc {
    [self._pointToViewDict removeAllObjects];
    [self._coordinateView removeFromSuperview];
    [self._pointsLayer removeFromSuperlayer];
}

- (void)_init {
    _defaultTextSize = 14;

    self.coordinateSpace = [[ASTM30CoordinateSpace alloc] initWithXMin:50 yMin:60 xMax:100 yMax:140];
    self.points = [NSMutableArray array];
    self.backgroundColor = [UIColor blackColor];
    self.pointSize = 2.0;
    self.pointColor = [UIColor colorWithRed:0.129 green:0.286 blue:0.486 alpha:1.0];
    self.pointColorForFocused = [UIColor colorWithRed:0.1788 green:0.3857 blue:0.7481 alpha:1.0];
    self.pointColorForNonfocused = [UIColor colorWithRed:0.564 green:0.639 blue:0.737 alpha:1.0];
    self.pointStrokeColorForFocused = [UIColor clearColor];
    self.pointStrokeColorForNonfocused = [UIColor clearColor];
    self.gridLineColor = [UIColor blackColor];
    self.coordinateLabelTextColor = [UIColor whiteColor];
    self.coordinateViewOffset = CGPointZero;
    self.coordinateLabelTextSize = 14.0;
    self.coordinateXLabelOffset = CGPointZero;
    self.coordinateYLabelOffset = CGPointZero;
    
    self._pointToViewDict = [NSMutableDictionary<NSString*, UIView*> dictionary];
}

@end

@implementation ASTM30RfRgViewController (GraphicComponents)

- (void)_setAndAddCoordinateViewToView:(UIView *)view {
    [self._coordinateView removeFromSuperview];

    mz_var(frame, CGRectMake(0, 0, view.frame.size.width*0.8, view.frame.size.height*0.8));
    mz_var(coordinateView, [[UIView alloc] initWithFrame:frame]);

    [view addSubview:coordinateView];
    coordinateView.center = CGPointAdd(view.center, self.coordinateViewOffset);
    coordinateView.backgroundColor = [UIColor clearColor];

    self._coordinateView = coordinateView;
}

- (void)_setColorZoneLayersToView:(UIView *)view {
    UIBezierPath* (^doubleTriangelPathWithSize)(CGSize size) = ^(CGSize size) {
        mz_var(startPoint, CGPointMake(view.frame.size.width, view.frame.size.height/2.0));
        mz_var(rect, CGRectMake(startPoint.x - size.width,
                                startPoint.y - size.height/2.0,
                                size.width,
                                size.height));

        mz_var(path, [UIBezierPath bezierPath]);
        [path moveToPoint:startPoint];
        [path addLineToPoint:CGRectGetTopLeft(rect)];
        [path addLineToPoint:CGRectGetTopRight(rect)];
        [path closePath];

        [path moveToPoint:startPoint];
        [path addLineToPoint:CGRectGetBottomLeft(rect)];
        [path addLineToPoint:CGRectGetBottomRight(rect)];
        [path closePath];

        return path;
    };

    mz_var(whilteLayer, [self _newShaperLayer]);
    whilteLayer.path = ^{
        mz_var(path, [UIBezierPath bezierPath]);
        [path moveToPoint:CGPointMake(view.frame.size.width, view.frame.size.height/2)];
        [path addLineToPoint:CGPointMake(0, view.frame.size.height)];
        [path addLineToPoint:CGPointMake(0, 0)];

        return path.CGPath;
    }();
    whilteLayer.strokeColor = [UIColor clearColor].CGColor;
    whilteLayer.fillColor = [UIColor whiteColor].CGColor;
    [view.layer addSublayer:whilteLayer];

    mz_var(lightGrayLayer, [self _newShaperLayer]);
    lightGrayLayer.path = doubleTriangelPathWithSize(view.frame.size).CGPath;
    lightGrayLayer.strokeColor = [UIColor clearColor].CGColor;
    lightGrayLayer.fillColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.0].CGColor;
    [view.layer addSublayer:lightGrayLayer];

    mz_var(darkGrayLayer, [self _newShaperLayer]);
    darkGrayLayer.path = doubleTriangelPathWithSize(CGSizeMake(view.frame.size.width*0.8, view.frame.size.height)).CGPath;
    darkGrayLayer.strokeColor = [UIColor clearColor].CGColor;
    darkGrayLayer.fillColor = [UIColor colorWithRed:0.745 green:0.745 blue:0.745 alpha:1.0].CGColor;
    [view.layer addSublayer:darkGrayLayer];
}

- (void)_setBoardLinesToView:(UIView *)view {
    mz_var(layer, [CAShapeLayer layer]);
    layer.frame = CGRectWithSize(layer.frame, view.frame.size);
    layer.path = [UIBezierPath bezierPathWithRect:CGRectFromSize(view.frame.size)].CGPath;

    layer.lineWidth = 2.0;
    layer.strokeColor = self.gridLineColor.CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;

    [view.layer addSublayer:layer];
}

- (void)_setCoordinateGridLinesAndLabelsToView:(UIView *)view {
    NSInteger numberOfBlockAtX = (self.coordinateSpace.xMax - self.coordinateSpace.xMin)/10.0;
    NSInteger numberOfBlockAtY = (self.coordinateSpace.yMax - self.coordinateSpace.yMin)/10.0;

    [self _addMainGridLinesAndNumberLabelToView:view
                               numberOfBlockAtX:numberOfBlockAtX
                               numberOfBlockAtY:numberOfBlockAtY];

    [self _addSubGridLinesToLayer:view
                 numberOfBlockAtX:numberOfBlockAtX
                 numberOfBlockAtY:numberOfBlockAtY];
}

- (void)_setAndAddPointLayerToView:(UIView *)view {
    [self._pointsLayer removeFromSuperlayer];

    mz_var(layer, [CAShapeLayer layer]);
    layer.frame = CGRectWithSize(layer.frame, view.frame.size);
    layer.fillColor = [UIColor colorWithRed:0.129 green:0.286 blue:0.486 alpha:1.0].CGColor;

    [view.layer addSublayer:layer];

    self._pointsLayer = layer;
}

- (void)_setPointViewsToView:(UIView *)view {
    CGPoint (^realPointPositionFromTm30Point)(ASTM30Point*) = ^(ASTM30Point* point) {
        CGFloat xOffset = point.value.x - self.coordinateSpace.xMin;
        CGFloat yOffset = point.value.y - self.coordinateSpace.yMin;

        CGFloat realX = (view.frame.size.width/self.coordinateSpace.xLength)*xOffset;
        CGFloat realY = view.frame.size.height - (view.frame.size.height/self.coordinateSpace.yLength)*yOffset;

        return CGPointMake(realX, realY);
    };

    mz_var(pointViews, [NSMutableArray<UIView *> array]);
    [self.points forEachWithAction: ^(ASTM30Point* point) {
        UIView* pointView = [self _addAndGetPointViewToView:view at: realPointPositionFromTm30Point(point)];
        MZAssertIfNil(pointView);

        self._pointToViewDict[point.key] = pointView;

        [pointViews addObject: pointView];
    }];

    for (NSInteger index = 0; index < pointViews.count; index++) {
        mz_var(pointView, pointViews[index]);
        pointView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);

        [UIView animateWithDuration:1.5
                              delay:index*0.05
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{ pointView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1); }
                         completion:nil];
    }
}

- (void)_addMainGridLinesAndNumberLabelToView:(UIView *)view
                             numberOfBlockAtX:(NSInteger)numberOfBlockAtX
                             numberOfBlockAtY:(NSInteger)numberOfBlockAtY {
    mz_var(labelPositionsForXAxis, [NSMutableArray<NSValue *> array]);
    mz_var(labelPositionsForYAxis, [NSMutableArray<NSValue *> array]);

    mz_var(mainLineslayer, [CAShapeLayer layer]);
    mainLineslayer.frame = CGRectFromSize(view.frame.size);
    mainLineslayer.path = ^{
        mz_var(path, [UIBezierPath bezierPath]);

        [path appendPath:[self _innerLinesPathAtXAxisFromMin:0
                                                       toMax:view.frame.size.width
                                               numberOfLines:numberOfBlockAtX + 1
                                                       yBase:view.frame.size.height + 4
                                                lengthOfLine:-16
                                        isIncludeHeadAndTail:true
                                                  didAddLine:^(CGPoint from, CGPoint _1, UIBezierPath* _2) {
                                                      [labelPositionsForXAxis addObject:[NSValue valueWithCGPoint:from]];
                                                  }]];

        [path appendPath:[self _innerLinesPathAtYAxisFromMin:0
                                                       toMax:view.frame.size.height
                                               numberOfLines:numberOfBlockAtY + 1
                                                       xBase:-4
                                                lengthOfLine:16
                                        isIncludeHeadAndTail:true
                                                  didAddLine:^(CGPoint from, CGPoint _1, UIBezierPath* _2) {
                                                      [labelPositionsForYAxis addObject:[NSValue valueWithCGPoint:from]];
                                                  }]];

        return path.CGPath;
    }();

    mainLineslayer.fillColor = [UIColor clearColor].CGColor;
    mainLineslayer.strokeColor = self.gridLineColor.CGColor;
    mainLineslayer.lineWidth = 2.0;

    [view.layer addSublayer:mainLineslayer];
    mainLineslayer.frame = CGRectWithOrigin(mainLineslayer.frame, CGPointZero);

    [self _addCoordinateNumberLabelsToView:view
                            textStartValue:self.coordinateSpace.xMin
                                 positions:labelPositionsForXAxis
                                    offset:CGPointAdd(CGPointMake(0, 6), self.coordinateXLabelOffset)];

    [self _addCoordinateNumberLabelsToView:view
                            textStartValue:self.coordinateSpace.yMin
                              textAlignmen:NSTextAlignmentRight
                                 positions:[labelPositionsForYAxis reversedArray]
                                    offset:CGPointAdd(CGPointMake(-16, 0), self.coordinateYLabelOffset)
                        useCommonFrameSize:true];
}

- (void)_addSubGridLinesToLayer:(UIView *)view
               numberOfBlockAtX:(NSInteger)numberOfBlockAtX
               numberOfBlockAtY:(NSInteger)numberOfBlockAtY {
    mz_var(subLinesLayer, [CAShapeLayer layer]);
    subLinesLayer.frame = view.frame;
    subLinesLayer.path = ^{
        mz_var(path, [UIBezierPath bezierPath]);

        CGFloat xInterval = view.frame.size.width/numberOfBlockAtX;
        for (int i = 0; i < numberOfBlockAtX; i++) {
            [path appendPath:[self _innerLinesPathAtXAxisFromMin:xInterval*i
                                                           toMax:xInterval*(i + 1)
                                                   numberOfLines:4
                                                           yBase:view.frame.size.height
                                                    lengthOfLine:-8
                                            isIncludeHeadAndTail:false]];
        }

        CGFloat yInterval = view.frame.size.height/numberOfBlockAtY;
        for (int i = 0; i < numberOfBlockAtY; i++) {
            [path appendPath:[self _innerLinesPathAtYAxisFromMin:yInterval*i
                                                           toMax:yInterval*(i + 1)
                                                   numberOfLines:4
                                                           xBase:0.0
                                                    lengthOfLine:8
                                            isIncludeHeadAndTail:false]];
        }

        return path.CGPath;
    }();
    subLinesLayer.fillColor = [UIColor clearColor].CGColor;
    subLinesLayer.strokeColor = self.gridLineColor.CGColor;
    subLinesLayer.lineWidth = 1.0;

    [view.layer addSublayer:subLinesLayer];
    subLinesLayer.frame = CGRectWithOrigin(subLinesLayer.frame, CGPointZero);
}

- (void)_addCoordinateNumberLabelsToView:(UIView *)view
                          textStartValue:(CGFloat)textStartValue
                            textAlignmen:(NSTextAlignment)textAlignmen
                               positions:(NSArray<NSValue *> *)positions
                                  offset:(CGPoint)offset
                      useCommonFrameSize:(BOOL)useCommonFrameSize {
    CGSize maxSize = CGSizeZero;
    mz_var(labels, [NSMutableArray<UILabel*> array]);

    for (int index = 0; index < positions.count; index++) {
        mz_var(position, [positions[index] CGPointValue]);

        UILabel* label = [self _addAndGetLabelWithText:[NSString stringWithFormat:@"%d", (int)(textStartValue + index*10)]
                                                center:CGPointAdd(position, offset)
                                             alignment:textAlignmen
                                                toView:view];

        maxSize = CGSizeMake(fmax(label.frame.size.width, maxSize.width),
                             fmax(label.frame.size.height, maxSize.height));

        [labels addObject:label];
    }

    if (useCommonFrameSize) {
        [labels forEachWithAction:^(UILabel* label) {
            label.frame = CGRectWithSize(label.frame, maxSize);
        }];
    }
}

- (void)_addXYCoordinateDescriptionLabelsToView:(UIView *)view {
    [self._xCoordinateDescriptionLabel removeFromSuperview];
    [self._yCoordinateDescriptionLabel removeFromSuperview];

    UILabel* (^descLabel)(NSString*) = ^(NSString* title){
        mz_var(label, [[UILabel alloc] init]);
        mz_var(fontSize, label.font.pointSize*self.coordinateLabelTextSize/self._defaultTextSize);

        mz_var(fontDescriptor, [label.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold]);
        label.font = [UIFont fontWithDescriptor:fontDescriptor
                                           size:fontSize];
        label.text = title;
        [label sizeToFit];
        label.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];

        [view addSubview:label];

        return label;
    };

    mz_var(viewFrame, view.frame);

    mz_var(xLabel, descLabel(@"Fidelity Index, Rf"));
    xLabel.center = CGPointMake(viewFrame.size.width/2,
                                viewFrame.size.height - xLabel.frame.size.height/2);

    mz_var(yLabel, descLabel(@"Gamut Index, Rg"));
    yLabel.center = CGPointMake(0,
                                viewFrame.size.height/2);
    yLabel.transform = CGAffineTransformRotate(yLabel.transform, -M_PI_2);

    self._xCoordinateDescriptionLabel = xLabel;
    self._yCoordinateDescriptionLabel = yLabel;
}

- (void)_modifyLayout {
    if (self._coordinateView == nil) return;
    if (self._xCoordinateDescriptionLabel == nil) return;
    if (self._yCoordinateDescriptionLabel == nil) return;

    self._coordinateView.center = CGPointAdd(self._coordinateView.center, CGPointMake(8, -8));

    mz_var(coordinateViewCenter, self._coordinateView.center);
    mz_var(coordinateViewFrame, self._coordinateView.frame);

    mz_var(xLabelFrame, self._xCoordinateDescriptionLabel.frame);
    mz_var(xLabelCenter, CGPointAdd(coordinateViewCenter,
                                    CGPointMake(0,
                                                coordinateViewFrame.size.height/2 +
                                                xLabelFrame.size.height/2 +
                                                self.coordinateLabelTextSize +
                                                2)));   // 主觀修正 :D
    self._xCoordinateDescriptionLabel.center = xLabelCenter;

    mz_var(yLabelFrame, self._yCoordinateDescriptionLabel.frame);
    mz_var(yLabelCenter, CGPointAdd(coordinateViewCenter,
                                    CGPointMake(-(coordinateViewFrame.size.width/2 +
                                                  yLabelFrame.size.width/2 +
                                                  self.coordinateLabelTextSize*2 + // modify for 3 digits
                                                  4), // 主觀修正 :D
                                                0)));
    self._yCoordinateDescriptionLabel.center = yLabelCenter;
}

- (void)_addCoordinateNumberLabelsToView:(UIView *)view
                          textStartValue:(CGFloat)textStartValue
                               positions:(NSArray<NSValue *> *)positions
                                  offset:(CGPoint)offset {
    [self _addCoordinateNumberLabelsToView:view
                            textStartValue:textStartValue
                              textAlignmen:NSTextAlignmentCenter
                                 positions:positions
                                    offset:offset
                        useCommonFrameSize:false];
}

- (UILabel *)_addAndGetLabelWithText:(NSString *)text
                              center:(CGPoint)center
                           alignment:(NSTextAlignment)alignment
                              toView:(UIView *)view {
    mz_var(label, [[UILabel alloc] init]);
    label.text = text;
    label.font = [UIFont fontWithName:label.font.fontName size:self.coordinateLabelTextSize];
    label.textColor = self.coordinateLabelTextColor;
    [label sizeToFit];

    [view addSubview:label];
    label.center = center;
    label.textAlignment = alignment;

    return label;
}

- (UIView *)_addAndGetPointViewToView:(UIView *)view at:(CGPoint)center {
    mz_var(pointPath, [UIBezierPath bezierPathWithArcCenter:CGPointZero
                                                     radius:self.pointSize*[UIScreen mainScreen].scale
                                                 startAngle:0.0
                                                   endAngle:M_PI*2.0
                                                  clockwise:true]);

    mz_var(pointLayer, [CAShapeLayer layer]);
    pointLayer.path = pointPath.CGPath;
    pointLayer.fillColor = self.pointColor.CGColor;

    mz_var(pointView, [[UIView alloc] init]);
    pointView.frame = CGRectWithSize(pointView.frame, CGSizeMake(10, 10));
    [pointView.layer addSublayer:pointLayer];
    pointLayer.position = CGPointMake(5, 5);

    [view addSubview:pointView];
    pointView.center = center;

    return pointView;
}

- (CAShapeLayer *)_pointShapeLayerFromView:(UIView *)pointView {
    return (CAShapeLayer*) pointView.layer.sublayers.firstObject;
}

- (UIBezierPath *)_innerLinesPathAtXAxisFromMin:(CGFloat)min
                                          toMax:(CGFloat)max
                                  numberOfLines:(NSInteger)numberOfLines
                                          yBase:(CGFloat)yBase
                                   lengthOfLine:(CGFloat)lengthOfLine
                           isIncludeHeadAndTail:(BOOL)isIncludeHeadAndTail
                                     didAddLine:(void (^)(CGPoint pathFrom, CGPoint pathTo, UIBezierPath* path))didAddLine {
    mz_var(length, fabs(max - min));
    mz_var(interval, length/(numberOfLines + ((isIncludeHeadAndTail)? -1.0 : 1.0)));

    mz_var(start, min + ((isIncludeHeadAndTail)? 0.0 : interval));

    mz_var(path, [UIBezierPath bezierPath]);

    for (int i = 0; i < numberOfLines; i++) {
        mz_var(from, CGPointMake(start + interval*i, yBase));
        mz_var(to, CGPointMake(start + interval*i, yBase + lengthOfLine));

        mz_var(linePath, [UIBezierPath bezierPath]);
        [linePath moveToPoint:from];
        [linePath addLineToPoint:to];

        [path appendPath:linePath];

        mz_block_exec(didAddLine, from, to, path);
    }

    return path;
}

- (UIBezierPath *)_innerLinesPathAtXAxisFromMin:(CGFloat)min
                                          toMax:(CGFloat)max
                                  numberOfLines:(NSInteger)numberOfLines
                                          yBase:(CGFloat)yBase
                                   lengthOfLine:(CGFloat)lengthOfLine
                           isIncludeHeadAndTail:(BOOL)isIncludeHeadAndTail {
    return [self _innerLinesPathAtXAxisFromMin:min
                                         toMax:max
                                 numberOfLines:numberOfLines
                                         yBase:yBase
                                  lengthOfLine:lengthOfLine
                          isIncludeHeadAndTail:isIncludeHeadAndTail
                                    didAddLine:nil];
}

- (UIBezierPath *)_innerLinesPathAtYAxisFromMin:(CGFloat)min
                                          toMax:(CGFloat)max
                                  numberOfLines:(NSInteger)numberOfLines
                                          xBase:(CGFloat)xBase
                                   lengthOfLine:(CGFloat)lengthOfLine
                           isIncludeHeadAndTail:(BOOL)isIncludeHeadAndTail
                                     didAddLine:(void (^)(CGPoint pathFrom, CGPoint pathTo, UIBezierPath* path))didAddLine {

    mz_var(length, fabs(max - min));
    mz_var(interval, length/(numberOfLines + ((isIncludeHeadAndTail)? -1.0 : 1.0)));

    mz_var(start, min + ((isIncludeHeadAndTail)? 0.0 : interval));

    mz_var(path, [UIBezierPath bezierPath]);

    for (int i = 0; i < numberOfLines; i++) {
        mz_var(from, CGPointMake(xBase, start + interval*i));
        mz_var(to, CGPointMake(xBase + lengthOfLine, start + interval*i));

        mz_var(linePath, [UIBezierPath bezierPath]);
        [linePath moveToPoint:from];
        [linePath addLineToPoint:to];

        [path appendPath:linePath];

        mz_block_exec(didAddLine, from, to, path);
    }

    return path;
}

- (UIBezierPath *)_innerLinesPathAtYAxisFromMin:(CGFloat)min
                                          toMax:(CGFloat)max
                                  numberOfLines:(NSInteger)numberOfLines
                                          xBase:(CGFloat)xBase
                                   lengthOfLine:(CGFloat)lengthOfLine
                           isIncludeHeadAndTail:(BOOL)isIncludeHeadAndTail {
    return [self _innerLinesPathAtYAxisFromMin:min
                                         toMax:max
                                 numberOfLines:numberOfLines
                                         xBase:xBase
                                  lengthOfLine:lengthOfLine
                          isIncludeHeadAndTail:isIncludeHeadAndTail
                                    didAddLine:nil];
}

- (CAShapeLayer *)_newShaperLayer {
    mz_var(layer, [CAShapeLayer layer]);
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    layer.shouldRasterize = true;
    
    return layer;
}

- (void)_setPointViewForNormal:(UIView *)pointView {
    mz_var(pointLayer, [self _pointShapeLayerFromView:pointView]);
    MZAssertIfNil(pointLayer);

    pointLayer.fillColor = self.pointColor.CGColor;
    pointLayer.strokeColor = [UIColor clearColor].CGColor;
    pointLayer.transform = CATransform3DIdentity;
}

- (void)_setPointViewForFocus:(UIView *)pointView bringToTop:(BOOL)needBringToTop {
    mz_var(pointLayer, [self _pointShapeLayerFromView:pointView]);
    MZAssertIfNil(pointLayer);

    mz_var(scale, 1.05);

    pointLayer.fillColor = self.pointColorForFocused.CGColor;
    pointLayer.strokeColor = self.pointStrokeColorForFocused.CGColor;
    pointLayer.transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.0);

    if (needBringToTop) {
        mz_var(superview, pointView.superview);
        [pointView removeFromSuperview];
        [superview addSubview:pointView];
    }
}

- (void)_setPointViewForNonFocus:(UIView *)pointView {
    mz_var(pointLayer, [self _pointShapeLayerFromView:pointView]);
    MZAssertIfNil(pointLayer);

    mz_var(scale, 0.4);

    pointLayer.fillColor = self.pointColorForNonfocused.CGColor;
    pointLayer.strokeColor = self.pointStrokeColorForNonfocused.CGColor;
    pointLayer.transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.0);
}

@end
