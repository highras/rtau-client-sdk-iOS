//
//  ViewController.m
//  RTAU_Test
//
//  Created by zsl on 2022/12/1.
//

#import <RTAU/RTAU.h>
#import "ViewController.h"
#import "MBProgressHUD.h"

@interface ViewController ()<AgoraVideoFrameDelegate,AgoraRtcEngineDelegate,AgoraAudioFrameDelegate,RTAUProtocol>
@property(nonatomic,strong)RTAUClient * client;
@property(nonatomic,strong)AgoraRtcEngineKit * kit;
@property(nonatomic,strong)AgoraRtcEngineConfig * config;

@property(nonatomic,strong)NSString * agora_appId;
@property(nonatomic,strong)NSString * agora_Token;
@property(nonatomic,strong)NSString * agora_RoomId;

@property(nonatomic,strong)RTAUClient * rtauClient;
@property(nonatomic,strong)NSString * streamId;
@property(nonatomic,strong)NSString * imgStreamId;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //demo演示为声网采集 需要更换对应的appid 和 roomId token
    self.agora_appId = @"17f7cfe0a67f475f803d32a99ddbcef1";
    self.agora_Token = @"007eJxTYGAV+bM2MU2Fn0WSYdGrG48cUy5n+n9dsCNZKGPPP1eV0lMKDGap5kaWqZYmloZpKSZGqSmJlqkWKakpRiZm5hamximpzC5rkxsCGRkiivcwMEIhiM/MYGhoyMAAAM87HUo=";
    self.agora_RoomId = @"111";
    
    
    self.config = [[AgoraRtcEngineConfig alloc] init];
    self.config.appId = self.agora_appId;
    self.config.areaCode = AgoraAreaCodeTypeGlobal;
    self.config.channelProfile = AgoraChannelProfileLiveBroadcasting;
   
    
    self.kit = [AgoraRtcEngineKit sharedEngineWithConfig:self.config delegate:self];
    [self.kit setClientRole:AgoraClientRoleBroadcaster];
    
    
    NSLog(@"设置结果1  %d",[self.kit setRecordingAudioFrameParametersWithSampleRate:16000 channel:1 mode:AgoraAudioRawFrameOperationModeReadWrite samplesPerCall:320]);
    NSLog(@"设置结果2  %d",[self.kit setMixedAudioFrameParametersWithSampleRate:16000 channel:1 samplesPerCall:320]);
    NSLog(@"设置结果3  %d",[self.kit setPlaybackAudioFrameParametersWithSampleRate:16000 channel:1 mode:AgoraAudioRawFrameOperationModeReadWrite samplesPerCall:320]);
    
    [self.kit setAudioFrameDelegate:self];
    [self.kit setDefaultAudioRouteToSpeakerphone:YES];
    [self.kit enableAudio];
    
    
    [self.kit setVideoFrameDelegate:self];
    AgoraVideoEncoderConfiguration * videoEncoderConfiguration = [[AgoraVideoEncoderConfiguration alloc] initWithSize:CGSizeMake(200, 150)
                                               frameRate:AgoraVideoFrameRateFps15
                                                 bitrate:AgoraVideoBitrateStandard
                                         orientationMode:AgoraVideoOutputOrientationModeFixedPortrait
                                              mirrorMode:AgoraVideoMirrorModeAuto];
    [self.kit setVideoEncoderConfiguration:videoEncoderConfiguration];
    [self.kit enableVideo];


    AgoraRtcVideoCanvas * videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = 0;
    // the view to be binded

    UIView * myView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 200, 150)];
    myView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:myView];
    videoCanvas.view = myView;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    [self.kit setupLocalVideo:videoCanvas];
    [self.kit startPreview];
    
   
    UIButton * login = [UIButton buttonWithType:UIButtonTypeSystem];
    [login setTitle:@"1登录" forState:UIControlStateNormal];
    login.frame = CGRectMake(50, 300, 120, 60);
    login.backgroundColor = [UIColor orangeColor];
    [login addTarget:self action:@selector(_loginClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:login];
    
    UIButton * streamId = [UIButton buttonWithType:UIButtonTypeSystem];
    [streamId setTitle:@"2设置streamId(pcm)" forState:UIControlStateNormal];
    streamId.titleLabel.font = [UIFont systemFontOfSize:11];
    streamId.frame = CGRectMake(180, 300, 120, 60);
    streamId.backgroundColor = [UIColor orangeColor];
    [streamId addTarget:self action:@selector(_streamIdClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:streamId];
    
    UIButton * joinRoom = [UIButton buttonWithType:UIButtonTypeSystem];
    [joinRoom setTitle:@"3加入声网房间(pcm)" forState:UIControlStateNormal];
    joinRoom.titleLabel.font = [UIFont systemFontOfSize:11];
    joinRoom.frame = CGRectMake(50, 400, 120, 60);
    joinRoom.backgroundColor = [UIColor orangeColor];
    [joinRoom addTarget:self action:@selector(_joinRoomClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:joinRoom];
    
    UIButton * imgStreamIdBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [imgStreamIdBtn setTitle:@"4设置streamId(image)" forState:UIControlStateNormal];
    imgStreamIdBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    imgStreamIdBtn.frame = CGRectMake(180, 400, 120, 60);
    imgStreamIdBtn.backgroundColor = [UIColor orangeColor];
    [imgStreamIdBtn addTarget:self action:@selector(_imgStreamId) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imgStreamIdBtn];
    
    UIButton * endPcm = [UIButton buttonWithType:UIButtonTypeSystem];
    [endPcm setTitle:@"5end" forState:UIControlStateNormal];
    endPcm.frame = CGRectMake(50, 500, 120, 60);
    endPcm.backgroundColor = [UIColor orangeColor];
    [endPcm addTarget:self action:@selector(_endPcmClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:endPcm];
        
}
-(void)_loginClick{
    [self showLoadHud];
    NSDictionary * tokenDic = [TokenTest getToken:@"cXdlcnR5" pid:@"92000001"];
    //@{@"ts":time,@"token":base64Result};
    NSLog(@"join success %@",tokenDic);
    [self.rtauClient loginWithToken:[tokenDic objectForKey:@"token"]
                                 ts:[[tokenDic objectForKey:@"ts"] longLongValue]
                            success:^{
        [self showHudMessage:@"登录成功" hideTime:1];
        NSLog(@"rtau login success");
        
        
    } connectFail:^(FPNError * _Nullable error) {
        
        NSLog(@"rtau login fail %@",error);
        
    }];
}
-(void)_streamIdClick{
    
    
    if (self.streamId == nil) {
        [self showLoadHud];
        self.streamId = [NSString stringWithFormat:@"%@",[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
        [self.rtauClient startAuditWithStreamId:self.streamId
                                          attrs:@[]
                                      audioLang:@"zh-CN"
                                audioStrategyId:nil
                                imageStrategyId:nil
                                    callbackUrl:nil
                                        success:^{
            [self showHudMessage:@"获取成功" hideTime:1];
            NSLog(@"_startAuditWithStreamId success %@",self.streamId);
            
        } fail:^(FPNError * _Nullable error) {
            
            [self showHudMessage:error.ex hideTime:1];
            
        }];
        
    }else{
        
        [self showHudMessage:@"streamId不为空" hideTime:1];
        
    }
    
}
-(void)_imgStreamId{
    
    if (self.imgStreamId == nil) {
        [self showLoadHud];
        self.imgStreamId = [NSString stringWithFormat:@"%@",[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
        [self.rtauClient startAuditWithStreamId:self.imgStreamId
                                          attrs:@[]
                                      audioLang:@"zh-CN"
                                audioStrategyId:nil
                                imageStrategyId:nil
                                    callbackUrl:nil
                                        success:^{
            [self showHudMessage:@"获取成功" hideTime:1];
            NSLog(@"_startAuditWithStreamId success %@",self.imgStreamId);
            
        } fail:^(FPNError * _Nullable error) {
            
            [self showHudMessage:error.ex hideTime:1];
            
        }];
        
    }else{
        
        [self showHudMessage:@"imgStreamId 不为空" hideTime:1];
        
    }
}
-(void)_endPcmClick{
    
    [self showLoadHud];
    if (self.streamId != nil) {
        [self.rtauClient endAuditWithStreamId:self.streamId success:^{
            [self showHudMessage:@"结束streamId" hideTime:1];
            NSLog(@"end success");

        } fail:^(FPNError * _Nullable error) {
            [self showHudMessage:error.ex hideTime:1];
        }];
    }else{
        [self showHudMessage:@"streamId is nil" hideTime:1];
    }
    
    if (self.imgStreamId != nil) {
        [self.rtauClient endAuditWithStreamId:self.imgStreamId success:^{
            [self showHudMessage:@"结束imgStreamId" hideTime:1];
            NSLog(@"end success");

        } fail:^(FPNError * _Nullable error) {
            [self showHudMessage:error.ex hideTime:1];
        }];
    }else{
        [self showHudMessage:@"imgStreamId is nil" hideTime:1];
    }
    
    
}
-(void)_joinRoomClick{
    
    [self showLoadHud];
    AgoraRtcChannelMediaOptions * option = [AgoraRtcChannelMediaOptions new];
    option.publishCameraTrack = [AgoraRtcBoolOptional of:YES];
//    option.publishMicrophoneTrack = [AgoraRtcBoolOptional of:YES];
    option.clientRoleType = [AgoraRtcIntOptional of:AgoraClientRoleBroadcaster];
    
    
    int result = [self.kit joinChannelByToken:self.agora_Token
                                    channelId:self.agora_RoomId
                                          uid:0
                                 mediaOptions:option
                                  joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        
        
    }];
    
    
    if (result == 0) {
        [self showHudMessage:@"加入成功" hideTime:1];
    }
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}
-(BOOL)onRecordAudioFrame:(AgoraAudioFrame *)frame channelId:(NSString *)channelId{
    
//    NSLog(@"pcm %lu",(unsigned long)[NSData dataWithBytes:frame.buffer length:frame.samplesPerChannel * frame.channels * frame.bytesPerSample].length);
    if (self.streamId != nil) {
        int64_t ts = [[NSDate date] timeIntervalSince1970] * 1000;
        NSData * pcmData = [NSData dataWithBytes:frame.buffer length:frame.samplesPerChannel * frame.channels * frame.bytesPerSample];
        [_rtauClient sendAudioDataWithStreamId:self.streamId pcmData:pcmData ts:ts];
    }
    
    
    return YES;
}


- (BOOL)onMixedAudioFrame:(AgoraAudioFrame * _Nonnull)frame channelId:(NSString * _Nonnull)channelId {
   
    return YES;
}


- (BOOL)onPlaybackAudioFrame:(AgoraAudioFrame * _Nonnull)frame channelId:(NSString * _Nonnull)channelId {
   
    return YES;
}


- (BOOL)onPlaybackAudioFrameBeforeMixing:(AgoraAudioFrame * _Nonnull)frame channelId:(NSString * _Nonnull)channelId uid:(NSUInteger)uid {
    
    return YES;
}
- (AgoraAudioFramePosition)getObservedAudioFramePosition NS_SWIFT_NAME(getObservedAudioFramePosition()){
    
    return AgoraAudioFramePositionRecord;
    
}

- (UIImage *)pixelBufferToImage: (CVPixelBufferRef)pixelBuffer {
    size_t width = CVPixelBufferGetHeight(pixelBuffer);
    size_t height = CVPixelBufferGetWidth(pixelBuffer);
    
    CIImage *coreImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:coreImage
                                                   fromRect:CGRectMake(0, 0, height, width)];
    
    UIImage *finalImage = [[UIImage alloc] initWithCGImage:videoImage
                                                     scale:1.0
                                               orientation:UIImageOrientationUp];
    //    CVPixelBufferRelease(pixelBuffer);
    CGImageRelease(videoImage);
    return finalImage;
}
-(BOOL)onCaptureVideoFrame:(AgoraOutputVideoFrame *)videoFrame{
    
//    NSLog(@"yuv %@",videoFrame.pixelBuffer);
    
    if (self.imgStreamId != nil) {
        
        UIImage * image = [self pixelBufferToImage:videoFrame.pixelBuffer];
        int64_t ts = [[NSDate date] timeIntervalSince1970] * 1000;
        [_rtauClient sendImageDataWithStreamId:self.imgStreamId image:image ts:ts];
    }

    
    return YES;
    
}

-(RTAUClient*)rtauClient{
    if (_rtauClient == nil) {
        
        _rtauClient = [RTAUClient clientWithEndpoint:@"161.189.171.91:15001" projectId:92000001 delegate:self];
    }
    return _rtauClient;;
}

//delegate 可不实现 为自动重连
-(BOOL)rtauReloginWillStart:(RTAUClient *)client reloginCount:(int)reloginCount{
 
    NSLog(@"rtauReloginWillStart");
    return YES;
}
//重连结果
-(void)rtauReloginCompleted:(RTAUClient *)client reloginCount:(int)reloginCount reloginResult:(BOOL)reloginResult error:(FPNError*)error{
    NSLog(@"rtauReloginCompleted %d",reloginResult);
}
//关闭连接
-(void)rtauConnectClose:(RTAUClient *)client{
    NSLog(@"rtauConnectClose");
}


- (void)showHudMessage:(NSString*)message hideTime:(int)hideTime{
   
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = message;
        hud.label.textColor = [UIColor whiteColor];
        hud.label.numberOfLines = 0;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:hideTime];
        
    });
    
}
-(void)showLoadHud{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.removeFromSuperViewOnHide = true;
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        hud.contentColor = [UIColor whiteColor];
        hud.label.textColor = [UIColor whiteColor];
        
    });
    
}
@end
