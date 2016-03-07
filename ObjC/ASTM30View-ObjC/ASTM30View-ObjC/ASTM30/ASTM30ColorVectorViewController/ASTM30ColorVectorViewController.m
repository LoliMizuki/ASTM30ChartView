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

@property (readwrite, strong, nonatomic) PointsInfoToLayersDictionary* _pointsInfoToLayersDict;
@property (readwrite, strong, nonatomic) UIView* _pointsLinesLayerView;
@property (readwrite, strong, nonatomic) CAShapeLayer* _sourceToReferenceArrowsLayer;
@property (readwrite, strong, nonatomic) UIImageView* _graphicBackgroundView;
@property (readwrite, strong, nonatomic) CAShapeLayer* _graphicBackgroundGridLayer;
@property (readwrite, strong, nonatomic) UIImageView* _graphicBackgroundForFadeView;
@property (readwrite, strong, nonatomic) CAShapeLayer* _graphicBackgroundMaskLayer;
@property (readwrite, strong, nonatomic) UIImage* _backgroundImageForNormal;
@property (readwrite, strong, nonatomic) UIImage* _backgroundImageForMasked;
@property (readwrite, weak, nonatomic) UILabel* _rfRgLabel;
@property (readwrite, weak, nonatomic) UILabel* _testSourceDescLabel;
@property (readwrite, weak, nonatomic) UILabel* _referenceDescLabel;

// Irreversible action: if set to true once, view no long switch it's graphic type
@property (readwrite, nonatomic) BOOL _forceToColorDistortion;

- (void)_init;

@end

@interface ASTM30ColorVectorViewController (PresentViewsAndLayers)

- (void)_setAndAddGraphicBackgroundViewToView:(UIView *)view;
- (void)_setAndAddGridLayerToView:(UIView *)view;
- (void)_setAndAddPointsLayersViewToView:(UIView *)view;
- (void)_setAndAddAllPoinsInfoLayersToView:(UIView *)view;
- (void)_setGraphicBackgroundMaskWithPointsInfoName:(nullable NSString *)name;
- (void)_setAndAddReferenceToTestSourceArrowsLayerToView:(UIView *)view;
- (void)_setAndAddRfRgLabelToView:(UIView *)view;
- (void)_setAndAddDescLabelsToView:(UIView *)view;
- (CAShapeLayer *)_shapeLayerWithPointsInfo:(ASTM30PointsInfo *)pointsInfo;
- (CAShapeLayer *)_maskLayerFromLayer:(CAShapeLayer *)layer;
- (UIBezierPath *)_arrowPathFromPoint:(CGPoint)from toPoint:(CGPoint)to;

- (void)_forceToGraphicTypeColorDistortionIfNeed;

@end

@interface ASTM30ColorVectorViewController (ASTM30GraphicTypeSwitchAnimations)
- (void)_animateMaskEnable:(BOOL)maskEnable duration:(NSTimeInterval)duration;
- (void)_animateMaskEnableToGraphicBackground:(BOOL)maskEnable duration:(NSTimeInterval)duration;
- (void)_animateMaskEnableToGraphicBackgroundForFade:(BOOL)maskEnable duration:(NSTimeInterval)duration;
- (void)_animateFadeMaskEnableToLayer:(CAShapeLayer *)aLayer maskEnable:(BOOL)maskEnable duration:(NSTimeInterval)duration;
- (void)_animateMaskEnableToPointsLinesLayer:(BOOL)maskEnable duration:(NSTimeInterval)duration;
- (void)_animateMaskEnableToDescriptionLables:(BOOL)maskEnable duration:(NSTimeInterval)duration;
@end

@interface ASTM30ColorVectorViewController (Supports)
- (CGPoint)_pointFrom:(CGPoint)point inCoordinateSpace:(ASTM30CoordinateSpace*)coordinateSpace;
@end


# pragma mark - Implementation

@implementation ASTM30ColorVectorViewController

@synthesize graphicType;

- (instancetype)init {
    self = [super init];
    [self _init];
    return self;
}

- (instancetype)initWithAlwaysColorDistortionType {
    MZLog(@"WARNIG: View will no long to change graphic tpye \\>///</");

    self = [super init];
    self._forceToColorDistortion = true;
    [self _init];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self _init];
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
    [self _setAndAddRfRgLabelToView:self.view];
    [self _setAndAddDescLabelsToView:self.view];

    
    [self _forceToGraphicTypeColorDistortionIfNeed];
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
    [self._rfRgLabel removeFromSuperview];
    [self._testSourceDescLabel removeFromSuperview];
    [self._referenceDescLabel removeFromSuperview];
}

- (void)_init {
    mz_var(coordinate, 1.4);
    self.coordinateSpace = [[ASTM30CoordinateSpace alloc] initWithXMin:-coordinate
                                                                  yMin:-coordinate
                                                                  xMax:coordinate
                                                                  yMax:coordinate];

    self._pointsInfoToLayersDict = [[PointsInfoToLayersDictionary alloc] init];
    self._sourceToReferenceArrowsLayer = nil;
    self._graphicBackgroundView = nil;
    self._graphicBackgroundGridLayer = nil;
    self._graphicBackgroundForFadeView = nil;
    self._graphicBackgroundMaskLayer = nil;
    self._rfRgLabel = nil;
    self._testSourceDescLabel = nil;
    self._referenceDescLabel = nil;

    self._backgroundImageForNormal = [UIImage imageNamed:@"ColorVectorBackground"];
    MZAssertIfNil(self._backgroundImageForNormal);
    self._backgroundImageForMasked = [UIImage imageNamed:@"ColorVectorMaskedBackground"];
    MZAssertIfNil(self._backgroundImageForMasked);

    self.rf = NAN;
    self.rg = NAN;
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
        UIImage* bgImage = self._backgroundImageForNormal;

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

    CGFloat numberOfXGrid = 6;
    CGFloat numberOfYGrid = 6;

    CGPoint interval = CGPointMake(view.frame.size.width/numberOfXGrid,
                                   view.frame.size.height/numberOfYGrid);

    UIBezierPath* path = [UIBezierPath bezierPath];

    for (int i = 1; i <numberOfXGrid; i++) {
        UIBezierPath* linePath = [UIBezierPath bezierPath];

        [linePath moveToPoint:CGPointMake(i*interval.x, 0)];
        [linePath addLineToPoint:CGPointMake(i*interval.x, view.frame.size.height)];

        [path appendPath:linePath];
    }

    for (int i = 0; i < numberOfYGrid; i++) {
        UIBezierPath* linePath = [UIBezierPath bezierPath];

        [linePath moveToPoint:CGPointMake(0, i*interval.y)];
        [linePath addLineToPoint:CGPointMake(view.frame.size.width, i*interval.y)];

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

- (void)_setAndAddRfRgLabelToView:(UIView *)view {
    [self._rfRgLabel removeFromSuperview];

    if ((isnan(self.rf) || isnan(self.rg))) return;

    mz_var(label, [[UILabel alloc] init]);

    label.text = [NSString stringWithFormat:@"Rf = %0.0f\nRg = %0.0f", self.rf, self.rg];
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    label.numberOfLines = 2;

    [self.view addSubview:label];
    [label sizeToFit];

    mz_var(labelFrame, label.frame);
    mz_var(viewTopRight, CGRectGetTopRight(self.view.frame));

    label.center = CGPointMake(viewTopRight.x - (labelFrame.size.width/2) + 4,
                               labelFrame.size.height/2 + 2);
    [label setTextAlignment:NSTextAlignmentRight];

    label.transform = CGAffineTransformMakeScale(0.8, 0.8);

    self._rfRgLabel = label;
}

- (void)_setAndAddDescLabelsToView:(UIView *)view {
    [self._testSourceDescLabel removeFromSuperview];
    [self._referenceDescLabel removeFromSuperview];

    mz_guard_let_return(testPointsInfo, [self poinsInfoWithName:self.testSourceName]);
    mz_guard_let_return(referencePointsInfo, [self poinsInfoWithName:self.referenceName]);

    UILabel* (^descLabel)(NSString*, UIColor*) = ^(NSString* title, UIColor* color) {
        mz_var(label, [[UILabel alloc] init]);
        label.font = [UIFont fontWithName:label.font.fontName size:label.font.pointSize*0.8];
        label.text = title;
        label.textColor = color;
        [label sizeToFit];

        mz_var(frame, label.frame);

        mz_var(lineLayer, [CAShapeLayer layer]);
        lineLayer.path = ^{
            mz_var(yPos, frame.origin.y + frame.size.height/2);
            mz_var(length, 20);

            mz_var(from, CGPointMake(-2, yPos));
            mz_var(to, CGPointMake(-length, yPos));

            mz_var(path, [UIBezierPath bezierPath]);

            [path moveToPoint:from];
            [path addLineToPoint:to];

            return path.CGPath;
        }();
        lineLayer.strokeColor = label.textColor.CGColor;
        lineLayer.lineWidth = lineLayer.lineWidth*1.2;
        [label.layer addSublayer:lineLayer];

        return label;
    };

    mz_var(testDescLabel, descLabel(@"Test Source", testPointsInfo.color));
    mz_var(referenceLabel, descLabel(@"Reference", referencePointsInfo.color));

    [view addSubview:testDescLabel];
    [view addSubview:referenceLabel];

    // move to buttom-left
    mz_var(maxFrameWidth, MAX(testDescLabel.frame.size.width, referenceLabel.frame.size.width));
    mz_var(maxFrameHeigth, MAX(testDescLabel.frame.size.height, referenceLabel.frame.size.height));

    mz_var(bottomRight, CGRectGetTopRight(view.frame));
    mz_var(firstLabelTopLeft, CGPointAdd(bottomRight, CGPointMake(-maxFrameWidth, -maxFrameHeigth*2)));

    testDescLabel.frame = CGRectOffset(testDescLabel.frame, firstLabelTopLeft.x, firstLabelTopLeft.y);
    referenceLabel.frame = CGRectOffset(referenceLabel.frame, firstLabelTopLeft.x, firstLabelTopLeft.y + maxFrameHeigth);

    // offset from buttom-left
    mz_var(offset, CGPointMake(-4, -4));
    testDescLabel.center = CGPointAdd(testDescLabel.center, offset);
    referenceLabel.center = CGPointAdd(referenceLabel.center, offset);

    self._testSourceDescLabel = testDescLabel;
    self._referenceDescLabel = referenceLabel;
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

- (void)_forceToGraphicTypeColorDistortionIfNeed {
    if (!self._forceToColorDistortion) return;

    mz_guard_let_return(graphicBackgroundView, self._graphicBackgroundView);
    mz_guard_let_return(graphicBackgroundForFadeView, self._graphicBackgroundForFadeView);
    mz_guard_let_return(graphicBackgroundMaskLayer, self._graphicBackgroundMaskLayer);

    graphicBackgroundView.layer.mask = graphicBackgroundMaskLayer;
    graphicBackgroundView.image = self._backgroundImageForMasked;
    graphicBackgroundForFadeView.alpha = 0;

    self._testSourceDescLabel.hidden = true;

    mz_var(testInfo, [self poinsInfoWithName:self.testSourceName]);
    mz_var(referenceInfo, [self poinsInfoWithName:self.referenceName]);

    self._pointsInfoToLayersDict[testInfo].strokeColor = testInfo.colorInMasked.CGColor;
    self._pointsInfoToLayersDict[referenceInfo].strokeColor = referenceInfo.colorInMasked.CGColor;

    self._testSourceDescLabel.textColor = [self poinsInfoWithName:self.testSourceName].colorInMasked;
    self._referenceDescLabel.textColor = [self poinsInfoWithName:self.referenceName].colorInMasked;
    CAShapeLayer* lineLayer = (CAShapeLayer*)self._referenceDescLabel.layer.sublayers.firstObject;
    lineLayer.strokeColor = self._referenceDescLabel.textColor.CGColor;

    self._sourceToReferenceArrowsLayer.hidden = true;
    self._graphicBackgroundGridLayer.hidden = true;
}

@end

@implementation ASTM30ColorVectorViewController (ASTM30GraphicTypeSwitchAnimations)

- (void)_animateMaskEnable:(BOOL)maskEnable duration:(NSTimeInterval)duration {
    [self _animateMaskEnableToGraphicBackground:maskEnable duration:duration];
    [self _animateMaskEnableToGraphicBackgroundForFade:maskEnable duration: duration];
    [self _animateFadeMaskEnableToLayer:self._graphicBackgroundGridLayer maskEnable:maskEnable duration:duration];
    [self _animateFadeMaskEnableToLayer:self._sourceToReferenceArrowsLayer maskEnable:maskEnable duration:duration];
    [self _animateMaskEnableToPointsLinesLayer:maskEnable duration:duration];
    [self _animateMaskEnableToDescriptionLables:maskEnable duration:duration];
}

- (void)_animateMaskEnableToGraphicBackground:(BOOL)maskEnable duration:(NSTimeInterval)duration {
    mz_guard_let_return(view, self._graphicBackgroundView);
    mz_guard_let_return(maskLayer, self._graphicBackgroundMaskLayer);

    if (view.layer.mask == nil) {
        view.layer.mask = maskLayer;
    }

    view.image = (maskEnable)? self._backgroundImageForMasked : self._backgroundImageForNormal;

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
    [self._pointsInfoToLayersDict forEachWithAction:^(ASTM30PointsInfo* info, CAShapeLayer* shapeLayer) {
        UIColor* nextColorValue = (maskEnable)? info.colorInMasked : info.color;

        mz_guard_let_return(nextColor, nextColorValue);

        mz_var(color, [CABasicAnimation animationWithKeyPath:@"strokeColor"]);

        color.fromValue = (id)shapeLayer.strokeColor;
        color.toValue = (id)nextColor.CGColor;
        color.duration = duration;

        [shapeLayer addAnimation:color forKey: @"color"];
    }];
}

- (void)_animateMaskEnableToDescriptionLables:(BOOL)maskEnable duration:(NSTimeInterval)duration {
    mz_guard_let_return(testPointsInfo, [self poinsInfoWithName:self.testSourceName]);
    mz_guard_let_return(referencePointsInfo, [self poinsInfoWithName:self.referenceName]);

    void (^updateColor)(UILabel*, ASTM30PointsInfo*) = ^(UILabel* label, ASTM30PointsInfo* info) {
        label.textColor = (maskEnable)? info.colorInMasked : info.color;
        CAShapeLayer* lineLayer = (CAShapeLayer*)label.layer.sublayers.firstObject;
        lineLayer.strokeColor = label.textColor.CGColor;
    };

    updateColor(self._testSourceDescLabel, testPointsInfo);
    updateColor(self._referenceDescLabel, referencePointsInfo);
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