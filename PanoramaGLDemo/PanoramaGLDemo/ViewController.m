//
//  ViewController.m
//  PanoramaGLDemo
//
//  Created by Admin on 2018/1/3.
//  Copyright © 2018年 WENBO. All rights reserved.
//

#import "ViewController.h"
#import "PLView.h"
#import "SDWebImageManager.h"
#define kIdMin 1
#define kIdMax 1000

@interface ViewController () <PLViewDelegate>
{
    
    __weak IBOutlet NSLayoutConstraint *topConstraints;
    __weak IBOutlet UISegmentedControl *segmentedControl;
    __weak IBOutlet PLView *plView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    topConstraints.constant = [UIApplication sharedApplication].statusBarFrame.size.height;
    [self setupPLView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark ------ < Private Method > ------
#pragma mark
- (void)setupPLView {
    //JSON loader example (see json.data, json_s2.data and json_cubic.data)
    //[plView load:[PLJSONLoader loaderWithPath:[[NSBundle mainBundle] pathForResource:@"json_cubic" ofType:@"data"]]];
    /**  < 设置代理 >  */
    plView.delegate = self;
    /**  < 设置灵敏度 >  */
    /**  <
     #define kDefaultAccelerometerSensitivity    7.0f
     #define kDefaultAccelerometerInterval        1.0f/60.0f
     #define kAccelerometerSensitivityMinValue    1.0f
     #define kAccelerometerSensitivityMaxValue    10.0f
     #define kAccelerometerMultiplyFactor        100.0f
     >  */
//    plView.accelerometerSensitivity = 10;
//
//    /**  < 加速更新频率 >  */
//    plView.accelerometerInterval = 1 / 45.0;
//    /**  < 加速度 >  */
//    plView.isAccelerometerEnabled = NO;
//    /**  < X轴加速度 >  */
//    plView.isAccelerometerLeftRightEnabled = NO;
//    /**  < Y轴加速度 >  */
//    plView.isAccelerometerUpDownEnabled = NO;
//    /**  < 惯性 >  */
//    plView.isInertiaEnabled = NO;
//    /**  < 三指恢复初始化 >  */
//    plView.isResetEnabled = NO;
    
    /**  < 加载本地 >  */
    [self selectPanorama:0];
    
    /**  < 加载网络全景图 >  */
//    [self loadData];
}

- (void)loadData {
    NSObject<PLIPanorama> *panorama = [PLSphericalPanorama panorama];
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1514970914547&di=2eb3de621ad48c0f9961e99e3176ad65&imgtype=0&src=http%3A%2F%2Fbpic.ooopic.com%2F16%2F00%2F89%2F16008943-6247a25ba16e2cd1e23842d461d60fa5.jpg"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        NSLog(@"%@",imageURL);
        /**  < 1、第一种加载方式 >  */
//        [(PLSphericalPanorama *)panorama setTexture:[PLTexture textureWithImage:[PLImage imageWithBuffer:data]]];
        /**  < 2、第二种加载方式 >  */
        /**  < 是否缓存在磁盘 >  */
        [[SDWebImageManager sharedManager] diskImageExistsForURL:imageURL completion:^(BOOL isInCache) {
            if (isInCache) {
                /**  < 获取缓存key >  */
                NSString *cacheImageKey = [[SDWebImageManager sharedManager]  cacheKeyForURL:imageURL];
                /**  < 获取缓存路径 >  */
                NSString *cacheImagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageKey];
                 [(PLSphericalPanorama *)panorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:cacheImagePath]]];
            }
        }];
        
        //Add a hotspot
        PLTexture *hotspotTexture = [PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"hotspot" ofType:@"png"]]];
        PLHotspot *hotspot = [PLHotspot hotspotWithId:(kIdMin + random() % ((kIdMax + 1) - kIdMin)) texture:hotspotTexture atv:0.0f ath:0.0f width:0.08f height:0.08f];
        [panorama addHotspot:hotspot];
        dispatch_async(dispatch_get_main_queue(), ^{
            [plView setPanorama:panorama];
            /**  < 设置角度 >  */
            PLRotation ro = PLRotationMake(40.0, 0.0, 0.0);
            [plView.camera resetCurrentC:ro Pitch:ro.pitch yaw:ro.yaw];
        });
    }];
}

- (void)selectPanorama:(NSInteger)index
{
    /**  < 改变初始化的位置 >  */
    PLRotation ro = PLRotationMake(0.0, 0.0, 0.0);
    [plView.camera resetCurrentC:ro Pitch:ro.pitch yaw:ro.yaw];
    
    
    NSObject<PLIPanorama> *panorama = nil;
    //尺寸必须符合
    //Spherical2 panorama example (supports up 4096x2048 texture)
    if(index == 0)
    {
        panorama = [PLSpherical2Panorama panorama];
        [(PLSpherical2Panorama *)panorama setImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"pano_sphere2" ofType:@"jpg"]]];
    }
    
    //Spherical panorama example (supports up 2048x1024 texture)
    else if(index == 1)
    {
        panorama = [PLSphericalPanorama panorama];
        [(PLSphericalPanorama *)panorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"mytest" ofType:@"jpg"]]]];
    }
    //尺寸不必须符合，比例符合2;1即可
    else if(index == 5)
    {
        //ifNoPowerOfTwoConvertUpDimension 如果图片不满足2的N次方，YES向上取一个满足的，NO向下取一个满足的
        panorama = [PLSphericalRatioPanorama panorama];
        [(PLSphericalRatioPanorama *)panorama setImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"pano_sphere2" ofType:@"jpg"]] ifNoPowerOfTwoConvertUpDimension:NO];
        
    }
    //Cubic panorama example (supports up 2048x2048 texture per face)
    else if(index == 2)
    {
        PLCubicPanorama *cubicPanorama = [PLCubicPanorama panorama];
        [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"pano_f" ofType:@"jpg"]]] face:PLCubeFaceOrientationFront];
        [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"pano_b" ofType:@"jpg"]]] face:PLCubeFaceOrientationBack];
        [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"pano_l" ofType:@"jpg"]]] face:PLCubeFaceOrientationLeft];
        [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"pano_r" ofType:@"jpg"]]] face:PLCubeFaceOrientationRight];
        [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"pano_u" ofType:@"jpg"]]] face:PLCubeFaceOrientationUp];
        [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"pano_d" ofType:@"jpg"]]] face:PLCubeFaceOrientationDown];
        panorama = cubicPanorama;
    }
    //Car
    else if(index == 4)
    {
        PLCubicPanorama *cubicPanorama = [PLCubicPanorama panorama];
        [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"front" ofType:@"jpg"]]] face:PLCubeFaceOrientationFront];
        [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"back" ofType:@"jpg"]]] face:PLCubeFaceOrientationBack];
        [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"left" ofType:@"jpg"]]] face:PLCubeFaceOrientationLeft];
        [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"right" ofType:@"jpg"]]] face:PLCubeFaceOrientationRight];
        [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"up" ofType:@"jpg"]]] face:PLCubeFaceOrientationUp];
        [cubicPanorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"down" ofType:@"jpg"]]] face:PLCubeFaceOrientationDown];
        panorama = cubicPanorama;
    }
    
    
    
    //Cylindrical panorama example (supports up 1024x1024 texture)
    else if(index == 3)
    {
        panorama = [PLCylindricalPanorama panorama];
        ((PLCylindricalPanorama *)panorama).isHeightCalculated = NO;
        [(PLCylindricalPanorama *)panorama setTexture:[PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"pano_sphere" ofType:@"jpg"]]]];
    }
    //Add a hotspot
    PLTexture *hotspotTexture = [PLTexture textureWithImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"hotspot" ofType:@"png"]]];
    PLHotspot *hotspot = [PLHotspot hotspotWithId:(kIdMin + random() % ((kIdMax + 1) - kIdMin)) texture:hotspotTexture atv:0.0f ath:0.0f width:0.08f height:0.08f];
    [panorama addHotspot:hotspot];
    [plView setPanorama:panorama];
}

#pragma mark ------ < PLViewDelegate > ------
#pragma mark
//Hotspot event
-(void)view:(UIView<PLIView> *)pView didClickHotspot:(PLHotspot *)hotspot screenPoint:(CGPoint)point scene3DPoint:(PLPosition)position
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hotspot" message:[NSString stringWithFormat:@"You select the hotspot with ID %zd", hotspot.identifier] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    //You can load a panorama view
    /*
     PLSpherical2Panorama *panorama = [PLSpherical2Panorama panorama];
     [panorama setImage:[PLImage imageWithPath:[[NSBundle mainBundle] pathForResource:@"pano_sphere2" ofType:@"jpg"]]];
     [pView setPanorama:panorama];
     */
}

#pragma mark ------ < Event Response > ------
#pragma mark
- (IBAction)segmentControlClicked:(UISegmentedControl *)sender {
    [self selectPanorama:segmentedControl.selectedSegmentIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
