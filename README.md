# PanoramaGLDemo
Integration PanoramaGL into your projects

### 前言
> 在我做一个商城类App的时候，遇到一个需求，就是需要把安装师傅的项目效果图360°全景展示出来，以前也从来没有接触过，一开始也并没有具体的实现思路，后来同事给我推荐了一个基于OpenGL支持球,立方体，圆柱的库，这是一个很老的库了，但是效果却还不错，最后工程也集成和使用了这个库，顺便也介绍几种其他的实现方式，以便以后做项目查阅。
### 一、[PanoramaGL](https://github.com/shaojiankui/PanoramaGL)
上面这个库的链接是GitHub上一个大神**skyfox**维护的，他在原有基础之上对一些问题进行了修复，这个库没有使用ARC，集成的时候相对麻烦一点，因为库的作者没有对库进行维护，在有些效果上，性能开销还是挺大的,下面开始介绍集成与使用吧。
- **集成**，将PanoramaGL文件夹拖入工程，并在**Build Phases Compile Source**库文件.m中添加`-fno-objc-arc`（注意：每个库文件.m都要添加，不然运行会报错）,如下图所示：
![屏幕快照 2018-01-03 下午12.05.42.png](https://user-gold-cdn.xitu.io/2018/1/3/160bb40a13681376?w=269&h=291&f=png&s=26514)
![屏幕快照 2018-01-03 下午12.08.58.png](https://user-gold-cdn.xitu.io/2018/1/3/160bb40a150cfe09?w=790&h=802&f=png&s=170371)
- **具体使用**：PanoramaGL的demo主要提供了六种效果展示，有六张图片拼接，也有直接使用一张全景图片，我项目里使用的是**Sphere**这种效果，图片支持大小是**2048x1024**。在构建**PLImage**的时候，我不得不吐槽下自己，因为demo都是通过图片路径得到PLImage，于是我就想到用**AFN**封装一个图片下载方法，下载图片后，获取图片保存在本地路径，来构建PLImage。之后**SDWebImage**了解和使用的比较多，发现SDWebImage可以直接下载图片并缓存，好了，不多说了，直接上代码吧。
```
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
```
```
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
```
到这里全景图效果都已经实现了，在项目中运用的也只有这么多，如果还有更多需求，可以查看相关头文件提供的方法吧。具体详情请看GitHub：[PanoramaGLDemo](https://github.com/wenmobo/PanoramaGLDemo),下面也帖出运行效果图吧：
![Untitled.gif](https://user-gold-cdn.xitu.io/2018/1/3/160bb40a14471d85?w=352&h=712&f=gif&s=1889162)


##### 问题解决
1、[解决点击 PLHotspot 不响应 didClickHotspot 代理方法的问题](http://www.skyfox.org/ios-panoramagl-360-arm64-hotspot.html)
### 二、[JAPanoView](https://github.com/smartapps-fr/JAPanoView)
JAPanoView是一个UIView子类,从立方全景图像创建显示360 - 180度全景，交互式平移和缩放。可以添加任何UIView JAPanoView热点。具体使用查看GitHub说明。
### 三、[Panorama](https://github.com/robbykraft/Panorama)
360°球形全景视图，基于**OpenGL**实现，具体使用查看GitHub上的Demo。
### 四、[three.js](https://github.com/mrdoob/three.js)
JavaScript 3D library。
### 五、自己实现
GLKit.framework 与OpenGLES实现，这个需要对OpenGL比较精通才能实现吧。
### 结语
> 全景图在一般的项目中也用不到，自己写篇文章做下记录，这篇文章主要对我在项目中实现全景图代码做了记录，其他方法只是为了拓展和了解，希望能对你能有所帮助。
### 参考文章
1、[iOS全景](http://www.cnblogs.com/mawenqiangios/p/5884373.html)
2、[PanoramaGL在IOS的使用](http://blog.csdn.net/ralbatr/article/details/21719437)
3、[iOS PanoramaGL（全景展示）用法](http://blog.csdn.net/jiayani/article/details/37501997)
