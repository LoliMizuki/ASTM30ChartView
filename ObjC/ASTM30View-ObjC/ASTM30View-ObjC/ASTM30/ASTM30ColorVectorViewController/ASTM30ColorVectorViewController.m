//
//  ASTM30ColorVectorViewController.m
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import "ASTM30ColorVectorViewController.h"
#import "ASTM30ColorVectorViewController+PointsInfoToLayersDictionary.h"
#import "ASTM30CoordinateSpace.h"
#import "ASTM30PointsInfo.h"
#import "MZ.h"

@interface ASTM30ColorVectorViewController()
@property (nonatomic, strong, readwrite) PointsInfoToLayersDictionary* _pointsInfoToLayersDict;
@property (nonatomic, strong, readwrite) UIView* _pointsLinesLayerView;
@property (nonatomic, strong, readwrite) CAShapeLayer* _sourceToReferenceArrowsLayer;
@property (nonatomic, strong, readwrite) UIImageView* _graphicBackgroundView;
@property (nonatomic, strong, readwrite) CAShapeLayer* _graphicBackgroundGridLayer;
@property (nonatomic, strong, readwrite) UIImageView* _graphicBackgroundForFadeView;
@property (nonatomic, strong, readwrite) CAShapeLayer* _graphicBackgroundMaskLayer;
@end

@interface ASTM30ColorVectorViewController (PresentViewsAndLayers)
- (void)_setAndAddGraphicBackgroundViewToView:(UIView *)view;
- (void)_setAndAddGridLayerToView:(UIView *)view;
- (void)_setAndAddPointsLayersViewToView:(UIView *)view;
- (void)_setAndAddAllPoinsInfoLayersToView:(UIView *)view;
- (void)_setGraphicBackgroundMaskWithPointsInfoName:(nullable NSString *)name;
- (void)_setAndAddReferenceToTestSourceArrowsLayerToView:(UIView *)view;
- (CAShapeLayer *)_shapeLayerWithPointsInfo:(ASTM30PointsInfo *)pointsInfo;
- (CAShapeLayer *)_maskLayerFromLayer:(CAShapeLayer *)layer;
- (UIBezierPath *)_arrowPathFromPoint:(CGPoint)from toPoint:(CGPoint)to;
@end

@interface ASTM30ColorVectorViewController (ASTM30GraphicTypeSwitchAnimations)
- (void)_animateMaskEnable:(BOOL)maskEnable duration:(NSTimeInterval)duration;
- (void)_animateMaskEnableToGraphicBackground:(BOOL)maskEnable duration:(NSTimeInterval)duration;
- (void)_animateMaskEnableToGraphicBackgroundForFade:(BOOL)maskEnable duration:(NSTimeInterval)duration;
- (void)_animateFadeMaskEnableToLayer:(CAShapeLayer *)aLayer maskEnable:(BOOL)maskEnable duration:(NSTimeInterval)duration;
- (void)_animateMaskEnableToPointsLinesLayer:(BOOL)maskEnable duration:(NSTimeInterval)duration;
@end

@interface ASTM30ColorVectorViewController (Supports)
- (CGPoint)_pointFrom:(CGPoint)point inCoordinateSpace:(ASTM30CoordinateSpace*)coordinateSpace;
@end


# pragma mark - Implementation

@implementation ASTM30ColorVectorViewController

@synthesize graphicType;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    self._pointsInfoToLayersDict = [[PointsInfoToLayersDictionary alloc] init];
    self._sourceToReferenceArrowsLayer = nil;
    self._graphicBackgroundView = nil;
    self._graphicBackgroundGridLayer = nil;
    self._graphicBackgroundForFadeView = nil;
    self._graphicBackgroundMaskLayer = nil;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self refresh];
}

- (void)addPointsInfo:(ASTM30PointsInfo * _Nonnull)info {
    [self._pointsInfoToLayersDict[info] removeFromSuperlayer];
    [self._pointsInfoToLayersDict removeObjectForKey:info];

    self._pointsInfoToLayersDict[info] = [CAShapeLayer layer];
}

- (nullable ASTM30PointsInfo *)poinsInfoWithName:(NSString *)name {
    for (ASTM30PointsInfo* info in self._pointsInfoToLayersDict.allKeys) {
        if ([info.name isEqualToString:name]) {
            return info;
        }
    }

    return nil;
}

- (void)removePointsInfoWithName:(NSString * _Nonnull)name {
    mz_guard_let_return(info, [self poinsInfoWithName:name]);
    [self._pointsInfoToLayersDict removeObjectForKey:info];
}

- (void)removeAllPointsInfo {
    for (CAShapeLayer* layer in self._pointsInfoToLayersDict.allValues) {
        [layer removeFromSuperlayer];
    }

    [self._pointsInfoToLayersDict removeAllObjects];
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
    [self _setAndAddGridLayerToView:self._graphicBackgroundView];
    [self _setAndAddPointsLayersViewToView:self.view];
    [self _setAndAddAllPoinsInfoLayersToView:self._pointsLinesLayerView];
    [self _setGraphicBackgroundMaskWithPointsInfoName:self.testSourceName];
    [self _setAndAddReferenceToTestSourceArrowsLayerToView:self._pointsLinesLayerView];
}


# pragma mark - Private

- (void)dealloc {
    [self._pointsInfoToLayersDict.allValues forEachWithAction:^(CAShapeLayer* layer) {
        [layer removeFromSuperlayer];
    }];
    [self._pointsInfoToLayersDict removeAllObjects];
    [self._pointsLinesLayerView removeFromSuperview];
    [self._sourceToReferenceArrowsLayer removeFromSuperlayer];
    [self._graphicBackgroundView removeFromSuperview];
    [self._graphicBackgroundGridLayer removeFromSuperlayer];
    [self._graphicBackgroundForFadeView removeFromSuperview];
    [self._graphicBackgroundMaskLayer removeFromSuperlayer];
}

- (void)_setGraphicBackgroundWithMaskEnable:(bool)maskEnable {
    mz_guard_let_return(backgroundView, self._graphicBackgroundView);
    mz_guard_let_return(backgroundMaskLayer, self._graphicBackgroundMaskLayer);

    backgroundView.layer.mask = (maskEnable)? backgroundMaskLayer : nil;

    [self._pointsInfoToLayersDict forEachWithAction:^(ASTM30PointsInfo* info, CAShapeLayer* shapeLayer) {
        UIColor* nextColorValue = (maskEnable)? info.colorInMasked : info.color;
        shapeLayer.strokeColor = nextColorValue.CGColor;
    }];

    self._graphicBackgroundForFadeView.hidden = maskEnable;
}

@end

@implementation ASTM30ColorVectorViewController (PresentViewsAndLayers)

- (void)_setAndAddGraphicBackgroundViewToView:(UIView *)view {
    [self._graphicBackgroundView removeFromSuperview];
    [self._graphicBackgroundForFadeView removeFromSuperview];

    UIImageView *(^newGraphicView)(void) = ^{
        UIImage* bgImage = [UIImage imageNamed:@"ColorVectorBackground"];
        MZAssertIfNilWithMessage(bgImage, @"Can not load image \"ColorVectorBackground\"");

        UIImageView* imageView = [[UIImageView alloc] initWithImage:bgImage];
        imageView.frame = view.frame;
        imageView.contentMode = UIViewContentModeScaleToFill;

        return imageView;
    };

    self._graphicBackgroundView = newGraphicView();
    self._graphicBackgroundForFadeView = newGraphicView();

    [self.view addSubview:self._graphicBackgroundForFadeView];
    [self.view addSubview:self._graphicBackgroundView];
}

- (void)_setAndAddGridLayerToView:(UIView *)view {
    [self._graphicBackgroundGridLayer removeFromSuperlayer];

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

    self._graphicBackgroundGridLayer = gridLayer;
}

- (void)_setAndAddPointsLayersViewToView:(UIView *)view {
    [self._pointsLinesLayerView removeFromSuperview];

    mz_var(pointsView, [[UIView alloc] initWithFrame:view.frame]);

    [view addSubview:pointsView];

    self._pointsLinesLayerView = pointsView;
}

- (void)_setAndAddAllPoinsInfoLayersToView:(UIView *)view {
    [self._pointsInfoToLayersDict.allValues forEachWithAction:^(CAShapeLayer* layer) {
        [layer removeFromSuperlayer];
    }];

    mz_var(allInfos, self._pointsInfoToLayersDict.allKeys);
    [self._pointsInfoToLayersDict removeAllObjects];

    [allInfos forEachWithAction:^(ASTM30PointsInfo* info) {
        mz_var(shapeLayer, [self _shapeLayerWithPointsInfo:info]);
        self._pointsInfoToLayersDict[info] = shapeLayer;
        [view.layer addSublayer:shapeLayer];
    }];
}

- (void)_setGraphicBackgroundMaskWithPointsInfoName:(nullable NSString *)name {
    if (name == nil) return;
    mz_guard_let_return(graphicBackgroundView, self._graphicBackgroundView);

    MZPair* pointsInfoKeyValue = [self._pointsInfoToLayersDict filterWithFunc:^(ASTM30PointsInfo* info, CAShapeLayer* layer) {
        return [info.name isEqualToString:name];
    }].firstObject;

    MZAssert(pointsInfoKeyValue != nil, @"pointsInfo not found with name: %@", name);

    CAShapeLayer* layer = ((MZPair *)pointsInfoKeyValue).second;
    MZAssertIfNilWithMessage(layer, @"layer not found");

    graphicBackgroundView.layer.mask = nil;

    self._graphicBackgroundMaskLayer = [self _maskLayerFromLayer:layer];

    self.testSourceName = name;
}

- (void)_setAndAddReferenceToTestSourceArrowsLayerToView:(UIView *)view {
    [self._sourceToReferenceArrowsLayer removeFromSuperlayer];

    mz_guard_let_return(testSourceName, self.testSourceName);
    mz_guard_let_return(referenceName, self.referenceName);

    mz_guard_let_return(toInfo, [self poinsInfoWithName:self.testSourceName]);
    mz_guard_let_return(fromInfo, [self poinsInfoWithName:self.referenceName]);

    mz_var(path, [UIBezierPath bezierPath]);

    for (ASTM30Point* fromPoint in fromInfo.points) {
        mz_var(toPoint, [toInfo pointWithKey:fromPoint.key]);

        MZAssertIfNilWithMessage(toPoint, @"Can not found point with key: %@", fromPoint.key);

        mz_var(modifiedFromPoint, [self _pointFrom:fromPoint.value inCoordinateSpace:self.coordinateSpace]);
        mz_var(modifiedToPoint, [self _pointFrom:toPoint.value inCoordinateSpace:self.coordinateSpace]);

        [path appendPath:[self _arrowPathFromPoint:modifiedFromPoint toPoint:modifiedToPoint]];
    }

    mz_var(layer, [CAShapeLayer layer]);
    layer.frame = view.frame;
    layer.path = path.CGPath;
    layer.strokeColor = [UIColor greenColor].CGColor;
    layer.lineWidth = 1;
    layer.lineCap = @"round";
    layer.lineJoin = @"bevel";
    [view.layer addSublayer:layer];

    self._sourceToReferenceArrowsLayer = layer;
}


- (CAShapeLayer *)_shapeLayerWithPointsInfo:(ASTM30PointsInfo *)pointsInfo {
    NSArray* points = [pointsInfo.points mapWithFunc:^(ASTM30Point* point) {
        CGPoint realPoint = [self _pointFrom:point.value
                           inCoordinateSpace:self.coordinateSpace];

        return [NSValue valueWithCGPoint:realPoint];
    }];

    mz_var(path, [UIBezierPath bezierPath]);
    [path moveToPoint:[points[0] CGPointValue]];
    for (int i = 1; i < points.count; i++) {
        [path addLineToPoint:[points[i] CGPointValue]];
    }

    if (pointsInfo.closePath) { [path closePath]; }

    mz_var(layer, [CAShapeLayer layer]);
    layer.path = path.CGPath;
    layer.lineWidth = pointsInfo.lineWidth;
    layer.strokeColor = pointsInfo.color.CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;

    NSDictionary* actions = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"strokeColor"];
    layer.actions = actions;

    return layer;
}

- (CAShapeLayer *)_maskLayerFromLayer:(CAShapeLayer *)layer {
    mz_var(maskLayer, [[CAShapeLayer alloc] initWithLayer:layer]);
    maskLayer.frame = self.view.frame;
    maskLayer.path = layer.path;

    return maskLayer;
}


- (UIBezierPath *)_arrowPathFromPoint:(CGPoint)from toPoint:(CGPoint)to {
    mz_var(lengthOfFromTo, [MZMath distanceFromP1:from toPoint2:to]);
    mz_var(degreesOfFromTo, [MZMath degreesFromP1:from toP2:to]);

    CGFloat maxWingsLength = 10.0;
    CGFloat wingsIntervalDegrees = 30.0;

    mz_var(path, [UIBezierPath bezierPath]);
    mz_var(zeroLeft, CGPointMake(-lengthOfFromTo/2, 0));
    mz_var(zeroRight, CGPointMake(lengthOfFromTo/2, 0));

    [path moveToPoint:zeroLeft];
    [path addLineToPoint:zeroRight];

    CGFloat wingsLength = fmin(maxWingsLength, lengthOfFromTo/3);

    mz_var(wingPoint1,
           CGPointMul([MZMath unitVectorFromDegrees:(180.0 - wingsIntervalDegrees)],
                      wingsLength));
    mz_var(wingPoint2,
           CGPointMul([MZMath unitVectorFromDegrees:(180.0 + wingsIntervalDegrees)],
                      wingsLength));

    [path moveToPoint:zeroRight];
    [path addLineToPoint:CGPointAdd(zeroRight, wingPoint1)];
    [path moveToPoint:zeroRight];
    [path addLineToPoint:CGPointAdd(zeroRight, wingPoint2)];

    mz_var(centerOfFromTo, CGPointMake((to.x + from.x)/2, (to.y + from.y)/2));
    mz_var(rotationAngle, [MZMath radiansFromDegrees:degreesOfFromTo]);

    [path applyTransform:CGAffineTransformMakeRotation(rotationAngle)];
    [path applyTransform:CGAffineTransformMakeTranslation(centerOfFromTo.x, centerOfFromTo.y)];

    return path;
}

@end

@implementation ASTM30ColorVectorViewController (ASTM30GraphicTypeSwitchAnimations)

- (void)_animateMaskEnable:(BOOL)maskEnable duration:(NSTimeInterval)duration {
    [self _animateMaskEnableToGraphicBackground:maskEnable duration:duration];
    [self _animateMaskEnableToGraphicBackgroundForFade:maskEnable duration: duration];
    [self _animateFadeMaskEnableToLayer:self._graphicBackgroundGridLayer maskEnable:maskEnable duration:duration];
    [self _animateFadeMaskEnableToLayer:self._sourceToReferenceArrowsLayer maskEnable:maskEnable duration:duration];
    [self _animateMaskEnableToPointsLinesLayer:maskEnable duration:duration];
}

- (void)_animateMaskEnableToGraphicBackground:(BOOL)maskEnable duration:(NSTimeInterval)duration {
    mz_guard_let_return(view, self._graphicBackgroundView);
    mz_guard_let_return(maskLayer, self._graphicBackgroundMaskLayer);

    if (view.layer.mask == nil) {
        view.layer.mask = maskLayer;
    }

    CGFloat maxScale = 5.0;
    CGFloat minScale = 1.0;

    mz_var(scale, [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"]);
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
    mz_guard_let_return(view, self._graphicBackgroundForFadeView);

    view.alpha = (maskEnable)? 1.0 : 0.0;

    [UIView animateWithDuration:duration
                     animations:^{ view.alpha = (maskEnable)? 0.0 : 1.0; }
                     completion:^(BOOL _) { [self _setGraphicBackgroundWithMaskEnable:maskEnable]; }];
}

- (void)_animateFadeMaskEnableToLayer:(CAShapeLayer *)aLayer maskEnable:(BOOL)maskEnable duration:(NSTimeInterval)duration {
    mz_guard_let_return(layer, aLayer);

    mz_var(fade, [CABasicAnimation animationWithKeyPath:@"opacity"]);

    fade.fromValue = (maskEnable)? @1.0 : @0.0;
    fade.toValue = (maskEnable)? @0.0 : @1.0;
    fade.duration = duration;
    fade.fillMode = kCAFillModeForwards;
    fade.removedOnCompletion = false;

    [layer removeAllAnimations];
    [layer addAnimation:fade forKey: @"fade"];
}

- (void)_animateMaskEnableToPointsLinesLayer:(BOOL)maskEnable duration:(NSTimeInterval)duration {
    [self._pointsInfoToLayersDict forEachWithAction:^(ASTM30PointsInfo *info, CAShapeLayer *shapeLayer) {
        UIColor* nextColorValue = (maskEnable)? info.colorInMasked : info.color;

        mz_guard_let_return(nextColor, nextColorValue);

        mz_var(color, [CABasicAnimation animationWithKeyPath:@"strokeColor"]);

        color.fromValue = (id)shapeLayer.strokeColor;
        color.toValue = (id)nextColor.CGColor;
        color.duration = duration;

        [shapeLayer addAnimation:color forKey: @"color"];
    }];
}

@end

@implementation ASTM30ColorVectorViewController (Supports)

- (CGPoint)_pointFrom:(CGPoint)point inCoordinateSpace:(ASTM30CoordinateSpace*)coordinateSpace {
    mz_var(size, self.view.frame.size);
    
    mz_var(realX, size.width*((point.x - coordinateSpace.xMin)/coordinateSpace.xLength));
    mz_var(realY, size.height - size.height*((point.y - coordinateSpace.yMin)/coordinateSpace.yLength));
    
    return CGPointMake(realX, realY);
}

@end