//
//  ViewController.m
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import "ViewController.h"
#import "ASTM30CoordinateSpace.h"
#import "ASTM30PointsInfo.h"
#import "ASTM30GraphicViewController.h"
#import "MZ.h"

@interface ViewController ()
@end

@interface ViewController (IB)
- (IBAction)didTouchUpInsideMaskButton:(UIButton *)button;
@end



@implementation ViewController {
    ASTM30GraphicViewController* _tm30ViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor grayColor];
    [self __testSetting];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    _tm30ViewController = (ASTM30GraphicViewController *)segue.destinationViewController;
}

# pragma mark - Test

- (void)__testSetting {
    [self __addTestData];
}

- (void)__addTestData {
    _tm30ViewController.coordinateSpace = [[ASTM30CoordinateSpace alloc] initWithXMin:-400
                                                                                 yMin:-400
                                                                                 xMax:400
                                                                                 yMax:400];
    _tm30ViewController.testSourceName = @"TestSource";
    _tm30ViewController.referenceName = @"Reference";

    NSArray* referencePoints = @[[NSValue valueWithCGPoint:CGPointMake(-360, 0)],
                                 [NSValue valueWithCGPoint:CGPointMake(-180, 180)],
                                 [NSValue valueWithCGPoint:CGPointMake(0, 360)],
                                 [NSValue valueWithCGPoint:CGPointMake(180, 180)],
                                 [NSValue valueWithCGPoint:CGPointMake(90, 90)],
                                 [NSValue valueWithCGPoint:CGPointMake(360, 0)],
                                 [NSValue valueWithCGPoint:CGPointMake(180, -180)],
                                 [NSValue valueWithCGPoint:CGPointMake(0, -360)],
                                 [NSValue valueWithCGPoint:CGPointMake(-180, -180)]];

    mz_gen_var(keys, [NSMutableArray array]);
    for (int i = 0; i < referencePoints.count; i++) {
        [keys addObject:[NSString stringWithFormat:@"A%d", i]];
    }

    mz_gen_var(infoForReference, [[ASTM30PointsInfo alloc] initWithName:@"Reference"]);
    infoForReference.color = [UIColor blackColor];
    infoForReference.colorInMasked = [UIColor whiteColor];
    infoForReference.lineWidth = 4;
    infoForReference.points = ^{
        NSMutableArray* points = [NSMutableArray array];

        for (int i = 0; i < keys.count; i++) {
            [points addObject:[[ASTM30Point alloc] initWithKey:keys[i] value:[referencePoints[i] CGPointValue]]];
        }

        return points;
    }();
    [_tm30ViewController addPointsInfo:infoForReference];

    mz_gen_var(infoForTestSource, [[ASTM30PointsInfo alloc] initWithName:@"TestSource"]);
    infoForTestSource.color = [UIColor redColor];
    infoForTestSource.colorInMasked = [UIColor clearColor];
    infoForTestSource.lineWidth = 4;
    infoForTestSource.points = ^{
        NSMutableArray* points = [NSMutableArray array];

        for (int i = 0; i < keys.count; i++) {
            CGFloat x = [referencePoints[i] CGPointValue].x + [MZMath randomFloatWithMin:-30 max:30];
            CGFloat y = [referencePoints[i] CGPointValue].y + [MZMath randomFloatWithMin:-30 max:30];

            [points addObject:[[ASTM30Point alloc] initWithKey:keys[i] value:CGPointMake(x, y)]];
        }

        return points;
    }();
    [_tm30ViewController addPointsInfo:infoForTestSource];
}

@end

@implementation ViewController (IB)

- (IBAction)didTouchUpInsideMaskButton:(UIButton *)sender {
    ASTM30GraphicType type =
        (_tm30ViewController.graphicType == ASTM30GraphicType_ColorVector)?
        ASTM30GraphicType_ColorDistortion :
        ASTM30GraphicType_ColorVector;

    [_tm30ViewController setGraphicType:type];
}

@end