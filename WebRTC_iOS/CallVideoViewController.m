//
//  CallVideoViewController.m
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/9.
//

#import "CallVideoViewController.h"
#import "WebRTCManager.h"

@interface CallVideoViewController ()
@property(nonatomic, strong) id localRenderer;
@property(nonatomic, strong) id remoteRenderer;
@property(nonatomic, strong) UIButton *rotateCameraButton;
@property(nonatomic, assign) AVCaptureDevicePosition postion;
@property(nonatomic, assign) BOOL audioEnabled;
@end

@implementation CallVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.postion = AVCaptureDevicePositionFront;
    self.view.backgroundColor = [UIColor whiteColor];
#if defined(__arm64__)
    // Using metal (arm64 only)
    
    RTCMTLVideoView *localRenderer = [[RTCMTLVideoView  alloc]initWithFrame:CGRectMake(10, CGRectGetHeight(self.view.frame)-100 - 64, CGRectGetWidth(self.view.frame)/2-40, 100)];
    RTCMTLVideoView *remoteRenderer = [[RTCMTLVideoView alloc]initWithFrame:self.view.frame];
    localRenderer.videoContentMode = UIViewContentModeScaleAspectFill;
    remoteRenderer.videoContentMode = UIViewContentModeScaleAspectFill;
    _localRenderer = localRenderer;
    _remoteRenderer = remoteRenderer;
#else
    // Using OpenGLES for the rest
    RTCEAGLVideoView *remoteRenderer = [[RTCEAGLVideoView alloc]initWithFrame:self.view.frame];
    
    RTCEAGLVideoView *localRenderer =  [[RTCEAGLVideoView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-110, CGRectGetWidth(self.view.frame)/2-40, 100)];
    
    _remoteRenderer = remoteRenderer;
    _localRenderer =localRenderer;
   
#endif
    [self.view addSubview:self.remoteRenderer];
    [self.view addSubview:self.localRenderer];
    [[WebRTCManager shareInstance] startCaptureLocalVideoPosition:AVCaptureDevicePositionFront];
    UIBarButtonItem *item1 =  [[UIBarButtonItem alloc]initWithTitle:@"📷" style:UIBarButtonItemStylePlain target:self action:@selector(rotateCameraBtnFun)];
    UIBarButtonItem *item2 =  [[UIBarButtonItem alloc]initWithTitle:@"🔇" style:UIBarButtonItemStylePlain target:self action:@selector(audioEnabledClick)];
    UIBarButtonItem *item3 =  [[UIBarButtonItem alloc]initWithTitle:@"🔊" style:UIBarButtonItemStylePlain target:self action:@selector(audioEnabledClick)];
    
    UIBarButtonItem *item4 =  [[UIBarButtonItem alloc]initWithTitle:@"👂" style:UIBarButtonItemStylePlain target:self action:@selector(setAudioSession)];
    
    
    UIBarButtonItem *item5 =  [[UIBarButtonItem alloc]initWithTitle:@"外放" style:UIBarButtonItemStylePlain target:self action:@selector(setAudioWaiFangSession)];
    
    
    self.navigationItem.rightBarButtonItems = @[item1,item2,item3,item4, item5];
  
    // Do any additional setup after loading the view.
}
-(void)rotateCameraBtnFun{
    if (self.postion == AVCaptureDevicePositionFront) {
        self.postion = AVCaptureDevicePositionBack;
    }else{
        self.postion = AVCaptureDevicePositionFront;
    }
    [[WebRTCManager shareInstance]rotateCamera:self.postion];
}
-(void)audioEnabledClick{
    self.audioEnabled = !self.audioEnabled;
    [[WebRTCManager shareInstance]setAllAudioEnabled:self.audioEnabled];
}
-(void)setAudioSession{
    [[WebRTCManager shareInstance]setAudioSession];
}
-(void)setAudioWaiFangSession{
    [[WebRTCManager shareInstance]setAudioWaiFangSession];
}
-(void)dealloc {
    NSLog(@" CallVideoViewController delloc");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
