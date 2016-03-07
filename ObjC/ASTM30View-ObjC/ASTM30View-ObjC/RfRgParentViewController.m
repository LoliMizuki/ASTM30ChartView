//
//  RfRgParentViewController.m
//  ASTM30View-ObjC
//
//  Created by lolimizuki on 2016/2/2.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

#import "RfRgParentViewController.h"
#import "ASTM30RfRgViewController.h"
#import "ASTM30CoordinateSpace.h"
#import "ASTM30PointsInfo.h"
#import "Utilities.h"
#import "MZ.h"

@interface RfRgParentViewController ()
@property (readwrite, strong, nonatomic) ASTM30RfRgViewController* _graphicViewController;
@end

@interface RfRgParentViewController (IB)
- (IBAction)takeSnapshot:(id)sender;
@end

@interface RfRgParentViewController (Test)
- (void)__testSetting;
- (NSArray<ASTM30Point *> *)__testPointsWithNumber:(NSInteger)number;
@end



@implementation RfRgParentViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    [self __testSetting];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self._graphicViewController = segue.destinationViewController;
}

@end

@implementation RfRgParentViewController (IB)

- (IBAction)takeSnapshot:(id)sender {
    mz_var(snapshotImage, [Utilities imageWithView:self._graphicViewController.view]);

    mz_var(imageData, UIImagePNGRepresentation(snapshotImage));

    mz_var(docPath, NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject);
    NSString* path = [NSString stringWithFormat:@"%@/%@.png", docPath, @"niya2"];

    BOOL success = [[NSFileManager defaultManager] createFileAtPath:path
                                                           contents:imageData
                                                         attributes:nil];
    MZLogMessageBool(@"Success", success);
    MZLog(@"Save to: %@", path);
}


@end

@implementation RfRgParentViewController (Test)

- (void)__testSetting {
    mz_var(graphicViewController, self._graphicViewController);
    graphicViewController.coordinateSpace = [[ASTM30CoordinateSpace alloc] initWithXMin:50
                                                                                   yMin:60
                                                                                   xMax:100
                                                                                   yMax:140];
    graphicViewController.points = [[self __testPointsWithNumber:50] mutableCopy];

    mz_var(onePoint, [[ASTM30Point alloc] initWithKey:@"a" value:CGPointMake(70, 130)]);
    graphicViewController.points = [@[onePoint] mutableCopy];
}

- (NSArray<ASTM30Point *> *)__testPointsWithNumber:(NSInteger)number {
    mz_var(graphicViewController, self._graphicViewController);
    if (graphicViewController == nil) return nil;

    mz_var(coordinateSpace, graphicViewController.coordinateSpace);

    mz_var(testPoints, [NSMutableArray<ASTM30Point *> array]);


    for (int i = 0; i < number; i++) {
        mz_var(point, CGPointMake([MZMath randomFloatWithMin:coordinateSpace.xMin max:coordinateSpace.xMax],
                                  [MZMath randomFloatWithMin:coordinateSpace.yMin max:coordinateSpace.yMax]));

        ASTM30Point* tm30Point = [[ASTM30Point alloc] initWithKey:@"a" value:point];

        [testPoints addObject:tm30Point];
    }
    
    return testPoints;
}

@end


