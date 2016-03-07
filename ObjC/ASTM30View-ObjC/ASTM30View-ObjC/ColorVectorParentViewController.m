//
//  ColorVectorParentViewController.m
//  ASTM30View-ObjC
//
//  Created by Inaba Mizuki on 2016/1/26.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import "ColorVectorParentViewController.h"
#import "ASTM30CoordinateSpace.h"
#import "ASTM30PointsInfo.h"
#import "ASTM30ColorVectorViewController.h"
#import "Utilities.h"
#import "MZ.h"

@interface ColorVectorParentViewController ()
@property (readwrite, strong, nonatomic) ASTM30ColorVectorViewController* _tm30ViewController;
@end

@interface ColorVectorParentViewController (IB)
- (IBAction)triggerMask:(id)sender;
- (IBAction)takeSnapshot:(id)sender;
@end

@interface ColorVectorParentViewController (TestData)
- (NSArray<NSValue *> *)__referencePoints;
- (NSArray<NSValue *> *)__testSourcePoints;
@end



@implementation ColorVectorParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor grayColor];
    [self __testSetting];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    self._tm30ViewController = (ASTM30ColorVectorViewController *)segue.destinationViewController;
}

# pragma mark - Test

- (void)__testSetting {
    [self __addTestData];
}

- (void)__addTestData {
    self._tm30ViewController.testSourceName = @"TestSource";
    self._tm30ViewController.referenceName = @"Reference";

    mz_var(infoForReference, [[ASTM30PointsInfo alloc] initWithName:@"Reference"]);
    infoForReference.color = [UIColor blackColor];
    infoForReference.colorInMasked = [UIColor whiteColor];
    infoForReference.lineWidth = 4;
    infoForReference.points = ^{
        NSArray<NSValue*>* rawPoints = [self __referencePoints];
        NSMutableArray* points = [NSMutableArray array];

        for (int i = 0; i < rawPoints.count; i++) {
            NSString* key = [NSString stringWithFormat:@"A%d", i];
            [points addObject:[[ASTM30Point alloc] initWithKey:key
                                                         value:[rawPoints[i] CGPointValue]]];
        }

        return points;
    }();
    [self._tm30ViewController addPointsInfo:infoForReference];

    mz_var(infoForTestSource, [[ASTM30PointsInfo alloc] initWithName:@"TestSource"]);
    infoForTestSource.color = [UIColor redColor];
    infoForTestSource.colorInMasked = [UIColor clearColor];
    infoForTestSource.lineWidth = 4;
    infoForTestSource.points = ^{
        NSArray<NSValue*>* rawPoints = [self __testSourcePoints];
        NSMutableArray* points = [NSMutableArray array];

        for (int i = 0; i < rawPoints.count; i++) {
            NSString* key = [NSString stringWithFormat:@"A%d", i];
            [points addObject:[[ASTM30Point alloc] initWithKey:key
                                                         value:[rawPoints[i] CGPointValue]]];
        }

        return points;
    }();
    [self._tm30ViewController addPointsInfo:infoForTestSource];
}

@end

@implementation ColorVectorParentViewController (IB)

- (IBAction)triggerMask:(id)sender {
    ASTM30GraphicType type = (self._tm30ViewController.graphicType == ASTM30GraphicType_ColorVector)?
        ASTM30GraphicType_ColorDistortion :
        ASTM30GraphicType_ColorVector;

    [self._tm30ViewController setGraphicType:type];
}

- (IBAction)takeSnapshot:(id)sender {
    mz_var(snapshotImage, [Utilities imageWithView:self._tm30ViewController.view]);

    mz_var(imageData, UIImagePNGRepresentation(snapshotImage));

    mz_var(docPath, NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject);
    NSString* path = [NSString stringWithFormat:@"%@/%@.png", docPath, @"niya1"];

    BOOL success = [[NSFileManager defaultManager] createFileAtPath:path
                                                           contents:imageData
                                                         attributes:nil];
    MZLogMessageBool(@"Success", success);
    MZLog(@"Save to: %@", path);
}

@end

@implementation ColorVectorParentViewController (TestData)

- (NSArray<NSValue *> *)__referencePoints {
    return @[[NSValue valueWithCGPoint:CGPointMake(0.979482, 0.201533)],
             [NSValue valueWithCGPoint:CGPointMake(0.804753, 0.593609)],
             [NSValue valueWithCGPoint:CGPointMake(0.565791, 0.824548)],
             [NSValue valueWithCGPoint:CGPointMake(0.18508, 0.982723)],
             [NSValue valueWithCGPoint:CGPointMake(-0.0885433, 0.996072)],
             [NSValue valueWithCGPoint:CGPointMake(-0.516068, 0.856548)],
             [NSValue valueWithCGPoint:CGPointMake(-0.841959, 0.539542)],
             [NSValue valueWithCGPoint:CGPointMake(-0.993123, 0.117075)],
             [NSValue valueWithCGPoint:CGPointMake(-0.987714, -0.156275)],
             [NSValue valueWithCGPoint:CGPointMake(-0.849281, -0.527942)],
             [NSValue valueWithCGPoint:CGPointMake(-0.592092, -0.805871)],
             [NSValue valueWithCGPoint:CGPointMake(-0.184827, -0.982771)],
             [NSValue valueWithCGPoint:CGPointMake(0.112917, -0.993604)],
             [NSValue valueWithCGPoint:CGPointMake(0.597958, -0.801528)],
             [NSValue valueWithCGPoint:CGPointMake(0.827279, -0.561791)],
             [NSValue valueWithCGPoint:CGPointMake(0.983755, -0.179517)]];
}

- (NSArray<NSValue *> *)__testSourcePoints {
    return @[[NSValue valueWithCGPoint:CGPointMake(0.830428, 0.152285)],
             [NSValue valueWithCGPoint:CGPointMake(0.665421, 0.600832)],
             [NSValue valueWithCGPoint:CGPointMake(0.390513, 0.869416)],
             [NSValue valueWithCGPoint:CGPointMake(0.0299235, 1.03496)],
             [NSValue valueWithCGPoint:CGPointMake(-0.184857, 1.03375)],
             [NSValue valueWithCGPoint:CGPointMake(-0.521905,  0.903854)],
             [NSValue valueWithCGPoint:CGPointMake(-0.78017, 0.570425)],
             [NSValue valueWithCGPoint:CGPointMake(-0.87806, 0.12918)],
             [NSValue valueWithCGPoint:CGPointMake(-0.81089, -0.222912)],
             [NSValue valueWithCGPoint:CGPointMake(-0.631358, -0.654632)],
             [NSValue valueWithCGPoint:CGPointMake(-0.386599, -0.931485)],
             [NSValue valueWithCGPoint:CGPointMake(-0.0546757, -1.06064)],
             [NSValue valueWithCGPoint:CGPointMake(0.170136, -1.10126)],
             [NSValue valueWithCGPoint:CGPointMake(0.610058, -0.96514)],
             [NSValue valueWithCGPoint:CGPointMake(0.742329, -0.761882)],
             [NSValue valueWithCGPoint:CGPointMake(0.903637, -0.259266)]];
}

@end