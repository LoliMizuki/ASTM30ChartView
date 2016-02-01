//
//  ASTM30RfRgViewController.m
//  ASTM30View-ObjC
//
//  Created by lolimizuki on 2016/2/1.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import "ASTM30RfRgViewController.h"
#import "ASTM30CoordinateSpace.h"
#import "ASTM30PointsInfo.h"
#import "MZ.h"

@interface ASTM30RfRgViewController ()
@end

@interface ASTM30RfRgViewController (GraphicComponents)
- (void)_setAndAddCoordinateViewToView:(UIView *)view;
- (void)_setGrayLayersToView:(UIView *)view;
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
@end



@implementation ASTM30RfRgViewController {
    UIView* _Nullable _coordinateView;

    CAShapeLayer* _Nullable _pointsLayer;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    self.coordinateSpace = [[ASTM30CoordinateSpace alloc] initWithXMin:50 yMin:60 xMax:100 yMax:140];
    self.points = [NSMutableArray array];

    return self;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self refresh];
}

- (void)refresh {
    [self _setAndAddCoordinateViewToView:self.view];
    [self _setGrayLayersToView:_coordinateView];
    [self _setBoardLinesToView:_coordinateView];
    [self _setCoordinateGridLinesAndLabelsToView:_coordinateView];
    [self _setAndAddPointLayerToView:_coordinateView];
    [self _setPointViewsToView:_coordinateView];
}


# pragma mark - Private

- (void)dealloc {
    [_coordinateView removeFromSuperview];
    [_pointsLayer removeFromSuperlayer];
}

@end

@implementation ASTM30RfRgViewController (GraphicComponents)

- (void)_setAndAddCoordinateViewToView:(UIView *)view {
    [_coordinateView removeFromSuperview];

    mz_var(frame, CGRectMake(0, 0, view.frame.size.width*0.8, view.frame.size.height*0.8));
    mz_var(coordinateView, [[UIView alloc] initWithFrame:frame]);

    [view addSubview:coordinateView];
    coordinateView.center = view.center;

    _coordinateView = coordinateView;
}

- (void)_setGrayLayersToView:(UIView *)view {
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

    mz_var(lightGrayLayer, [CAShapeLayer layer]);
    lightGrayLayer.path = doubleTriangelPathWithSize(view.frame.size).CGPath;
    lightGrayLayer.strokeColor = [UIColor clearColor].CGColor;
    lightGrayLayer.fillColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1.0].CGColor;
    [view.layer addSublayer:lightGrayLayer];

    mz_var(darkGrayLayer, [CAShapeLayer layer]);
    darkGrayLayer.path = doubleTriangelPathWithSize(CGSizeMake(view.frame.size.width*0.8, view.frame.size.height)).CGPath;
    darkGrayLayer.strokeColor = [UIColor clearColor].CGColor;
    darkGrayLayer.fillColor = [UIColor colorWithRed:0.745 green:0.745 blue:0.745 alpha:1.0].CGColor;
    [view.layer addSublayer:darkGrayLayer];
}

- (void)_setBoardLinesToView:(UIView *)view {
    mz_var(layer, [CAShapeLayer layer]);
    layer.frame = CGRectSetSize(layer.frame, view.frame.size);
    layer.path = [UIBezierPath bezierPathWithRect:CGRectFromSize(view.frame.size)].CGPath;

    layer.lineWidth = 2.0;
    layer.strokeColor = [UIColor blackColor].CGColor;
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
    [_pointsLayer removeFromSuperlayer];

    mz_var(layer, [CAShapeLayer layer]);
    layer.frame = CGRectSetSize(layer.frame, view.frame.size);
    layer.fillColor = [UIColor colorWithRed:0.129 green:0.286 blue:0.486 alpha:1.0].CGColor;

    [view.layer addSublayer:layer];

    _pointsLayer = layer;
}

- (void)_setPointViewsToView:(UIView *)view {
    CGPoint (^realPointPositionFromTm30Point)(ASTM30Point*) = ^(ASTM30Point* point) {
        CGFloat xOffset = point.value.x - self.coordinateSpace.xMin;
        CGFloat yOffset = point.value.y - self.coordinateSpace.yMin;

        CGFloat realX = (view.frame.size.width/self.coordinateSpace.xLength)*xOffset;
        CGFloat realY = (view.frame.size.height/self.coordinateSpace.yLength)*yOffset;

        return CGPointMake(realX, realY);
    };

    mz_var(pointViews, [NSMutableArray<UIView *> array]);
    [self.points forEachWithAction: ^(ASTM30Point* point) {
        UIView* pointView = [self _addAndGetPointViewToView:view at: realPointPositionFromTm30Point(point)];
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
    mainLineslayer.strokeColor = [UIColor blackColor].CGColor;
    mainLineslayer.lineWidth = 2.0;

    [view.layer addSublayer:mainLineslayer];
    mainLineslayer.frame = CGRectSetOrigin(mainLineslayer.frame, CGPointZero);
    
    [self _addCoordinateNumberLabelsToView:view
                            textStartValue:self.coordinateSpace.xMin
                                 positions:labelPositionsForXAxis
                                    offset:CGPointMake(0, 10)];

    [self _addCoordinateNumberLabelsToView:view
                            textStartValue:self.coordinateSpace.yMin
                              textAlignmen:NSTextAlignmentRight
                                 positions:[labelPositionsForYAxis reversedArray]
                                    offset:CGPointMake(-20, 0)
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
    subLinesLayer.strokeColor = [UIColor blackColor].CGColor;
    subLinesLayer.lineWidth = 1.0;

    [view.layer addSublayer:subLinesLayer];
    subLinesLayer.frame = CGRectSetOrigin(subLinesLayer.frame, CGPointZero);
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
            label.frame = CGRectSetSize(label.frame, maxSize);
        }];
    }
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
    [label sizeToFit];

    [view addSubview:label];
    label.center = center;
    label.textAlignment = alignment;
    
    return label;
}

- (UIView *)_addAndGetPointViewToView:(UIView *)view at:(CGPoint)center {
    mz_var(pointPath, [UIBezierPath bezierPathWithArcCenter:CGPointZero
                                                     radius:2.0*[UIScreen mainScreen].scale
                                                 startAngle:0.0
                                                   endAngle:M_PI*2.0
                                                  clockwise:true]);

    mz_var(pointLayer, [CAShapeLayer layer]);
    pointLayer.path = pointPath.CGPath;
    pointLayer.fillColor = [UIColor colorWithRed:0.129 green:0.286 blue:0.486 alpha:1.0].CGColor;

    mz_var(pointView, [[UIView alloc] init]);
    pointView.frame = CGRectSetSize(pointView.frame, CGSizeMake(10, 10));
    [pointView.layer addSublayer:pointLayer];
    pointLayer.position = CGPointMake(5, 5);

    [view addSubview:pointView];
    pointView.center = center;
    
    return pointView;
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

@end
