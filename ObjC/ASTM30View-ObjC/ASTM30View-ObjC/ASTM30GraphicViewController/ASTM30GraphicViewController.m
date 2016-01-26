//
//  ASTM30GraphicViewController.m
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import "ASTM30GraphicViewController.h"
#import "ASTM30CoordinateSpace.h"
#import "ASTM30PointsInfo.h"
#import "MZLogs.h"
#import "MZCodeMiracle.h"
#import "MZMapReduces.h"

@interface ASTM30GraphicViewController (PresentViewsAndLayers)
- (void)_setAndAddGraphicBackgroundViewToView:(UIView *)view;
- (void)_setAndAddGridLayerToView:(UIView *)view;
- (void)_setAndAddPointsLayersViewToView:(UIView *)view;
- (void)_setAndAddReferenceToTestSourceArrowsLayerToView:(UIView *)view;
- (CAShapeLayer *)_shapeLayerWithPointsInfo:(ASTM30PointsInfo *)pointsInfo;
// mask 預定地
- (UIBezierPath *)_arrowPathFromPoint:(CGPoint)from toPoint:(CGPoint)to;
@end

@interface ASTM30GraphicViewController (Supports)
- (CGPoint)_pointFrom:(CGPoint)point inCoordinateSpace:(ASTM30CoordinateSpace*)coordinateSpace;

@end



@implementation ASTM30GraphicViewController {
    NSMutableDictionary<ASTM30PointsInfo*, CAShapeLayer*>* _pointsInfoToLayersDict;

    UIView* _pointsLinesLayerView;

    CAShapeLayer* _sourceToReferenceArrowsLayer;

    UIImageView* _graphicBackgroundView;

    CAShapeLayer* _graphicBackgroundGridLayer;

    UIImageView* _graphicBackgroundForFadeView;

    CAShapeLayer* _graphicBackgroundMaskLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initSetting];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self refresh];
}

- (void)addPointsInfo:(ASTM30PointsInfo * _Nonnull)info {
    [_pointsInfoToLayersDict[info] removeFromSuperlayer];
    [_pointsInfoToLayersDict removeObjectForKey:info];

    _pointsInfoToLayersDict[(id)info] = [CAShapeLayer layer]; // TODO: why id?
}

- (ASTM30PointsInfo * _Nullable)poinsInfoWithName:(NSString * _Nonnull)name {
    for (ASTM30PointsInfo* info in _pointsInfoToLayersDict.allKeys) {
        if ([info.name isEqualToString:name]) return info;
    }

    return nil;
}

- (void)removePointsInfoWithName:(NSString * _Nonnull)name {
    mz_guard_let_return(targetKey, [self poinsInfoWithName:name]);

    [_pointsInfoToLayersDict removeObjectForKey:targetKey];
}

- (void)removeAllPointsInfo {
    for (CAShapeLayer* layer in _pointsInfoToLayersDict.allValues) {
        [layer removeFromSuperlayer];
    }

    [_pointsInfoToLayersDict removeAllObjects];
}


- (void)refresh {
    [self _setAndAddGraphicBackgroundViewToView:self.view];
    [self _setAndAddGridLayerToView:_graphicBackgroundView];
    [self _setAndAddPointsLayersViewToView:self.view];
//    _setAndAddAllPoinsInfoLayersToView(_pointsLinesLayerView!)
//    _setGraphicBackgroundMaskWithPointsInfoName(testSourceName)
//    [self _setAndAddReferenceToTestSourceArrowsLayerToView:_pointsLinesLayerView];
}


# pragma mark - Private

- (void)_initSetting {
    _pointsInfoToLayersDict = [NSMutableDictionary dictionary];
    _sourceToReferenceArrowsLayer = nil;
    _graphicBackgroundView = nil;
    _graphicBackgroundGridLayer = nil;
    _graphicBackgroundForFadeView = nil;
    _graphicBackgroundMaskLayer = nil;
}

- (void)_setGraphicBackgroundWithMaskEnable:(bool)maskEnable {
    mz_guard_let_return(backgroundView, _graphicBackgroundView);
    mz_guard_let_return(backgroundMaskLayer, _graphicBackgroundMaskLayer);

    backgroundView.layer.mask = (maskEnable)? backgroundMaskLayer : nil;

    [_pointsInfoToLayersDict enumerateKeysAndObjectsUsingBlock:
        ^(ASTM30PointsInfo * _Nonnull info, CAShapeLayer * _Nonnull shapeLayer, BOOL * _Nonnull stop) {
            UIColor* nextColorValue = (maskEnable)? info.colorInMasked : info.color;
            shapeLayer.strokeColor = nextColorValue.CGColor;
    }];

    _graphicBackgroundForFadeView.hidden = maskEnable;
}

@end



@implementation ASTM30GraphicViewController (PresentViewsAndLayers)

- (void)_setAndAddGraphicBackgroundViewToView:(UIView *)view {
    [_graphicBackgroundView removeFromSuperview];
    [_graphicBackgroundForFadeView removeFromSuperview];

    UIImageView *(^newGraphicView)(void) = ^{
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ColorVectorBackground"]];
        imageView.frame = view.frame;
        imageView.contentMode = UIViewContentModeScaleToFill;
        
        return imageView;
    };

    _graphicBackgroundView = newGraphicView();
    _graphicBackgroundForFadeView = newGraphicView();

    [self.view addSubview:_graphicBackgroundForFadeView];
    [self.view addSubview:_graphicBackgroundView];
}

- (void)_setAndAddGridLayerToView:(UIView *)view {
    [_graphicBackgroundGridLayer removeFromSuperlayer];

    CGFloat numberOfGrid = 5;

    CGPoint interval = CGPointMake(view.frame.size.width/numberOfGrid,
                                   view.frame.size.height/numberOfGrid);

    UIBezierPath* path = [UIBezierPath bezierPath];

    for (int i = 1; i <numberOfGrid; i++) {
        UIBezierPath* linePath = [UIBezierPath bezierPath];

        [linePath moveToPoint:CGPointMake(0, i*interval.y)];
        [linePath addLineToPoint:CGPointMake(view.frame.size.width, i*interval.y)];

        [linePath moveToPoint:CGPointMake(i*interval.x, 0)];
        [linePath addLineToPoint:CGPointMake(i*interval.x, view.frame.size.height)];

        [path appendPath:linePath];
    }

    CAShapeLayer* gridLayer = [CAShapeLayer layer];
    gridLayer.frame = view.frame;
    gridLayer.path = path.CGPath;

    gridLayer.lineWidth = 2;
    gridLayer.strokeColor = [UIColor grayColor].CGColor;

    [view.layer addSublayer:gridLayer];

    _graphicBackgroundGridLayer = gridLayer;
}

- (void)_setAndAddPointsLayersViewToView:(UIView *)view {
    [_pointsLinesLayerView removeFromSuperview];

    mz_gen_var(pointsView, [[UIView alloc] initWithFrame:view.frame]);

    [view addSubview:pointsView];

    _pointsLinesLayerView = pointsView;
}

- (void)_setAndAddAllPoinsInfoLayersToView:(UIView *)view {
    for (CAShapeLayer* layer in _pointsInfoToLayersDict.allValues) {
        [layer removeFromSuperlayer];
    }

    mz_gen_var(allInfos, _pointsInfoToLayersDict.allKeys);

    [_pointsInfoToLayersDict removeAllObjects];

    for (ASTM30PointsInfo* info in allInfos) {
//        mz_gen_var(shapeLayer, [self _shapeLayerWithPointsInfo:info]);
//        _pointsInfoToLayersDict[info] = shapeLayer;
//        [self.view.layer.addSublayer:shapeLayer];
    }
}


- (void)_setAndAddReferenceToTestSourceArrowsLayerToView:(UIView *)view {
    [_sourceToReferenceArrowsLayer removeFromSuperlayer];

    mz_guard_let_return(testSourceName, self.testSourceName);
    mz_guard_let_return(referenceName, self.referenceName);

    mz_guard_let_return(toInfo, [self poinsInfoWithName:self.testSourceName]);
    mz_guard_let_return(fromInfo, [self poinsInfoWithName:self.referenceName]);

    mz_gen_var(path, [UIBezierPath bezierPath]);

    for (ASTM30Point* fromPoint in fromInfo.points) {
        mz_gen_var(toPoint, [toInfo pointWithKey:fromPoint.key]);
        MZAssert(toPoint != nil, <#desc, ...#>)

        MZAssertIfNilWithMessage(toPoint, @"Can not found point with key: %@", fromPoint.key);

        mz_gen_var(modifiedFromPoint, [self _pointFrom:fromPoint.value inCoordinateSpace:self.coordinateSpace]);
        mz_gen_var(modifiedToPoint, [self _pointFrom:toPoint.value inCoordinateSpace:self.coordinateSpace]);

        [path appendPath:[self _arrowPathFromPoint:modifiedFromPoint toPoint:modifiedToPoint]];
    }

    mz_gen_var(layer, [CAShapeLayer layer]);
    layer.frame = view.frame;
    layer.path = path.CGPath;
    layer.strokeColor = [UIColor greenColor].CGColor;
    layer.lineWidth = 1;
    layer.lineCap = @"round";
    layer.lineJoin = @"bevel";
    [view.layer addSublayer:layer];

    _sourceToReferenceArrowsLayer = layer;
}


- (CAShapeLayer *)_shapeLayerWithPointsInfo:(ASTM30PointsInfo *)pointsInfo {
    NSArray* points =
        [MZMapReduces mapWithArray:pointsInfo.points
                              func:^(ASTM30Point* p) {
                                  CGPoint cgP = [self _pointFrom:p.value
                                               inCoordinateSpace:self.coordinateSpace];

                                  return [NSValue valueWithCGPoint:cgP];
                              }];


    mz_gen_var(path, [UIBezierPath bezierPath]);
    [path moveToPoint:[points[0] CGPointValue]];
    for (int i = 1; i < points.count; i++) {
        [path addLineToPoint:[points[i] CGPointValue]];
    }

    if (pointsInfo.closePath) { [path closePath]; }

    mz_gen_var(layer, [CAShapeLayer layer]);
    layer.path = path.CGPath;
    layer.lineWidth = pointsInfo.lineWidth;
    layer.strokeColor = pointsInfo.color.CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;

    NSDictionary* actions = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"strokeColor"];
    layer.actions = actions;

    return layer;
}

//- (UIBezierPath *)_arrowPathFromPoint:(CGPoint)from toPoint:(CGPoint)to {
//    let lengthOfFromTo = MZ.Maths.distance(p1: from, p2: to)
//    let degreesOfFromTo = MZ.Degrees.degressFromP1(from, toP2: to)
//    let maxWingsLength = 10.cgFloatValue
//    let wingsIntervalDegrees = 30.mzFloatValue
//
//    let path = UIBezierPath()
//    let zeroLeft = CGPoint(x: -lengthOfFromTo/2, y: 0)
//    let zeroRight = CGPoint(x: lengthOfFromTo/2, y: 0)
//
//    path.moveToPoint(zeroLeft)
//    path.addLineToPoint(zeroRight)
//
//    let wingsLength = min(maxWingsLength, lengthOfFromTo/3)
//    let wingPoint1 = MZ.Maths.unitVectorFromDegrees(180-wingsIntervalDegrees)*wingsLength
//    let wingPoint2 = MZ.Maths.unitVectorFromDegrees(180+wingsIntervalDegrees)*wingsLength
//
//    path.moveToPoint(zeroRight)
//    path.addLineToPoint(zeroRight + wingPoint1)
//    path.moveToPoint(zeroRight)
//    path.addLineToPoint(zeroRight + wingPoint2)
//
//    let centerOfFromTo = CGPoint(x: (to.x + from.x)/2, y: (to.y + from.y)/2)
//    let rotationAngle = MZ.Degrees.radiansFromDegrees(degreesOfFromTo).cgFloatValue
//    path.applyTransform(CGAffineTransformMakeRotation(rotationAngle))
//    path.applyTransform(CGAffineTransformMakeTranslation(centerOfFromTo.x, centerOfFromTo.y))
//
//    return path
//}

@end


@implementation ASTM30GraphicViewController (Supports)

- (CGPoint)_pointFrom:(CGPoint)point inCoordinateSpace:(ASTM30CoordinateSpace*)coordinateSpace {
    mz_gen_var(size, self.view.frame.size);

    mz_gen_var(realX, size.width*((point.x - coordinateSpace.xMin)/coordinateSpace.xLength));
    mz_gen_var(realY, size.height - size.height*((point.y - coordinateSpace.yMin)/coordinateSpace.yLength));

    return CGPointMake(realX, realY);
}

@end