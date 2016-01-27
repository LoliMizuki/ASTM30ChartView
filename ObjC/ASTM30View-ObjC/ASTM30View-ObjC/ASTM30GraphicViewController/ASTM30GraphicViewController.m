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
#import "MZ.h"

@interface PointsInfoToLayersDictionary : NSObject
@end

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

- (id)objectForKeyedSubscript:(ASTM30PointsInfo *)info {
    return nil;
}

- (void)setObject:(CAShapeLayer *)layer forKeyedSubscript:(ASTM30PointsInfo *)info {

}

- (void)dealloc {
    [_pointsInfosDict removeAllObjects];
    [_pointsLayersDict removeAllObjects];
}

@end



@interface ASTM30GraphicViewController (PresentViewsAndLayers)
- (void)_setAndAddGraphicBackgroundViewToView:(UIView *)view;
- (void)_setAndAddGridLayerToView:(UIView *)view;
- (void)_setAndAddPointsLayersViewToView:(UIView *)view;
- (void)_setAndAddAllPoinsInfoLayersToView:(UIView *)view;
- (void)_setGraphicBackgroundMaskWithPointsInfoName:(NSString * _Nullable)name;
- (void)_setAndAddReferenceToTestSourceArrowsLayerToView:(UIView *)view;
- (CAShapeLayer *)_shapeLayerWithPointsInfo:(ASTM30PointsInfo *)pointsInfo;
- (CAShapeLayer *)_maskLayerFromLayer:(CAShapeLayer *)layer;
- (UIBezierPath *)_arrowPathFromPoint:(CGPoint)from toPoint:(CGPoint)to;
@end

@interface ASTM30GraphicViewController (ASTM30GraphicTypeSwitchAnimations)
- (void)_animateMaskEnable:(BOOL)maskEnable duration:(NSTimeInterval)duration;
- (void)_animateMaskEnableToGraphicBackground:(BOOL)maskEnable duration:(NSTimeInterval)duration;
- (void)_animateMaskEnableToGraphicBackgroundForFade:(BOOL)maskEnable duration:(NSTimeInterval)duration;
@end

@interface ASTM30GraphicViewController (Supports)
- (CGPoint)_pointFrom:(CGPoint)point inCoordinateSpace:(ASTM30CoordinateSpace*)coordinateSpace;
- (void)_addPointsInfoToDict:(ASTM30PointsInfo *)info;
- (void)_addShaperLayerToDict:(CAShapeLayer *)layer withInfo:(ASTM30PointsInfo *)info;
- (ASTM30PointsInfo * _Nullable)_getPointsInfoWithName:(NSString *)name;
- (CAShapeLayer * _Nullable)_getShapeLayerInDictWithPointsInfo:(ASTM30PointsInfo *)info;
@end



@implementation ASTM30GraphicViewController {
    NSMutableDictionary<NSString*, ASTM30PointsInfo*>* _pointsInfosDict;
    NSMutableDictionary<NSString*, CAShapeLayer*>* _pointsLayersDict;

    UIView* _pointsLinesLayerView;

    CAShapeLayer* _sourceToReferenceArrowsLayer;

    UIImageView* _graphicBackgroundView;

    CAShapeLayer* _graphicBackgroundGridLayer;

    UIImageView* _graphicBackgroundForFadeView;

    CAShapeLayer* _graphicBackgroundMaskLayer;
}

@synthesize graphicType;

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
    [[self _getShapeLayerInDictWithPointsInfo:info] removeFromSuperlayer];
    if (_pointsLayersDict[info.name] != nil ) [_pointsLayersDict removeObjectForKey:info.name];

    [self _addPointsInfoToDict:info];
}

- (ASTM30PointsInfo * _Nullable)poinsInfoWithName:(NSString * _Nonnull)name {
    for (NSString* infoName in _pointsLayersDict.allKeys) {
        if ([infoName isEqualToString:name]) {
            return [self _getPointsInfoWithName:infoName];
        }
    }

    return nil;
}

- (void)removePointsInfoWithName:(NSString * _Nonnull)name {
    [_pointsInfosDict removeObjectForKey:name];
    [_pointsLayersDict removeObjectForKey:name];
}

- (void)removeAllPointsInfo {
    for (CAShapeLayer* layer in _pointsLayersDict.allValues) {
        [layer removeFromSuperlayer];
    }

    [_pointsLayersDict removeAllObjects];
}

- (void)setGraphicType:(ASTM30GraphicType)type animated:(bool)animated duration:(CFTimeInterval)duration {
    graphicType = type;
    bool enableMask = graphicType == ASTM30GraphicType_ColorDistortion;

    if (animated) {
        [self _animateMaskEnable:enableMask duration: duration];
    } else {
        [self _setGraphicBackgroundWithMaskEnable:enableMask];
    }
}

- (void)setGraphicType:(ASTM30GraphicType)type {
    [self setGraphicType:type animated:true duration:0.25];
}

- (void)refresh {
    [self _setAndAddGraphicBackgroundViewToView:self.view];
    [self _setAndAddGridLayerToView:_graphicBackgroundView];
    [self _setAndAddPointsLayersViewToView:self.view];
    [self _setAndAddAllPoinsInfoLayersToView:_pointsLinesLayerView];
    [self _setGraphicBackgroundMaskWithPointsInfoName:self.testSourceName];
//    [self _setAndAddReferenceToTestSourceArrowsLayerToView:_pointsLinesLayerView];
}


# pragma mark - Private

- (void)_initSetting {
    _pointsInfosDict = [NSMutableDictionary dictionary];
    _pointsLayersDict = [NSMutableDictionary dictionary];
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

    [_pointsInfosDict.allKeys forEachWithAction:^(NSString* name) {
        mz_gen_var(info, [self _getPointsInfoWithName:name]);
        mz_gen_var(shapeLayer, [self _getShapeLayerInDictWithPointsInfo:info]);

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
    for (CAShapeLayer* layer in _pointsLayersDict.allValues) {
        [layer removeFromSuperlayer];
    }
    [_pointsLayersDict removeAllObjects];

    for (ASTM30PointsInfo* info in _pointsInfosDict.allValues) {
        mz_gen_var(shapeLayer, [self _shapeLayerWithPointsInfo:info]);
        [self _addShaperLayerToDict:shapeLayer withInfo:info];
        [view.layer addSublayer:shapeLayer];
    }
}

- (void)_setGraphicBackgroundMaskWithPointsInfoName:(NSString * _Nullable)name {
    if (name == nil) return;
    mz_guard_let_return(graphicBackgroundView, _graphicBackgroundView);

     NSArray* pointsInfoKeyValue = [_pointsLayersDict filterWithFunc: ^BOOL(NSString* infoName, CAShapeLayer* _) {
         return [infoName isEqualToString:name];
     }].firstObject;

    MZAssert(pointsInfoKeyValue != nil, @"pointsInfo not found with name: \(name)");

    CAShapeLayer* layer = ((MZPair *)pointsInfoKeyValue).second;
    MZAssertIfNilWithMessage(layer, @"layer not found");

    graphicBackgroundView.layer.mask = nil;

    _graphicBackgroundMaskLayer = [self _maskLayerFromLayer:layer];

    self.testSourceName = name;
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
    NSArray* points = [pointsInfo.points mapWithFunc:^(ASTM30Point* point) {
        CGPoint realPoint = [self _pointFrom:point.value
                           inCoordinateSpace:self.coordinateSpace];

        return [NSValue valueWithCGPoint:realPoint];
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

- (CAShapeLayer *)_maskLayerFromLayer:(CAShapeLayer *)layer {
    mz_gen_var(maskLayer, [[CAShapeLayer alloc] initWithLayer:layer]);
    maskLayer.frame = self.view.frame;
    maskLayer.path = layer.path;

    return maskLayer;
}


- (UIBezierPath *)_arrowPathFromPoint:(CGPoint)from toPoint:(CGPoint)to {
    return nil;
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
}

@end

@implementation ASTM30GraphicViewController (ASTM30GraphicTypeSwitchAnimations)

- (void)_animateMaskEnable:(BOOL)maskEnable duration:(NSTimeInterval)duration {
    [self _animateMaskEnableToGraphicBackground:maskEnable duration:duration];
    [self _animateMaskEnableToGraphicBackgroundForFade:maskEnable duration: duration];
//    _animateFadeMaskEnableToLayer(_graphicBackgroundGridLayer, maskEnable: maskEnable, duration: duration)
//    _animateFadeMaskEnableToLayer(_sourceToReferenceArrowsLayer, maskEnable: maskEnable, duration: duration)
//    _animateMaskEnableToPointsLinesLayer(maskEnable, duration: duration)
}

- (void)_animateMaskEnableToGraphicBackground:(BOOL)maskEnable duration:(NSTimeInterval)duration {
    mz_guard_let_return(view, _graphicBackgroundView);
    mz_guard_let_return(maskLayer, _graphicBackgroundMaskLayer);

    if (view.layer.mask == nil) {
        view.layer.mask = maskLayer;
    }

    CGFloat maxScale = 5.0;
    CGFloat minScale = 1.0;

    mz_gen_var(scale, [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"]);
    scale.duration = duration;
    scale.keyTimes = @[@0.0, @1.0];
    scale.values = @[[NSNumber numberWithFloat:((maskEnable)? maxScale : minScale)],
                     [NSNumber numberWithFloat:((maskEnable)? minScale : maxScale)]];
    scale.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    scale.fillMode = kCAFillModeForwards;
    scale.removedOnCompletion = false;

    [maskLayer removeAllAnimations];
    [maskLayer addAnimation:scale forKey: @"scale"];
}

- (void)_animateMaskEnableToGraphicBackgroundForFade:(BOOL)maskEnable duration:(NSTimeInterval)duration {
    mz_guard_let_return(view, _graphicBackgroundForFadeView);

    view.alpha = (maskEnable)? 1.0 : 0.0;

    [UIView animateWithDuration:duration
                     animations:^{ view.alpha = (maskEnable)? 0.0 : 1.0; }
                     completion:^(BOOL _) { [self _setGraphicBackgroundWithMaskEnable:maskEnable]; }];
}

@end

@implementation ASTM30GraphicViewController (Supports)

- (CGPoint)_pointFrom:(CGPoint)point inCoordinateSpace:(ASTM30CoordinateSpace*)coordinateSpace {
    mz_gen_var(size, self.view.frame.size);

    mz_gen_var(realX, size.width*((point.x - coordinateSpace.xMin)/coordinateSpace.xLength));
    mz_gen_var(realY, size.height - size.height*((point.y - coordinateSpace.yMin)/coordinateSpace.yLength));

    return CGPointMake(realX, realY);
}

- (void)_addPointsInfoToDict:(ASTM30PointsInfo *)info {
    _pointsInfosDict[info.name] = info;
}

- (void)_addShaperLayerToDict:(CAShapeLayer *)layer withInfo:(ASTM30PointsInfo *)info {
    _pointsInfosDict[info.name] = info;
    _pointsLayersDict[info.name] = layer;
}

- (ASTM30PointsInfo * _Nullable)_getPointsInfoWithName:(NSString *)name {
    return _pointsInfosDict[name];
}

- (CAShapeLayer * _Nullable)_getShapeLayerInDictWithPointsInfo:(ASTM30PointsInfo *)info {
    return _pointsLayersDict[info.name];
}

@end