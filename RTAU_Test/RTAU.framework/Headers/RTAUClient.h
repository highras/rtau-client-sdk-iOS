//
//  RTAUClient.h
//  RTAU
//
//  Created by zsl on 2019/12/11.
//  Copyright © 2019 FunPlus. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <RTAU/RTAUProtocol.h>
#import <RTAU/RTAUCallBackDefinition.h>
#import <RTAU/RTAUClientConfig.h>
#import <VideoToolbox/VideoToolbox.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RTAUClientConnectStatus){
    
    RTAUClientConnectStatusConnectClosed = 0,
    RTAUClientConnectStatusConnecting = 1,
    RTAUClientConnectStatusConnected = 2,
    
};

typedef void (^RTAULoginSuccessCallBack)(void);
typedef void (^RTAULoginFailCallBack)(FPNError * _Nullable error);

typedef void (^RTAUAnswerSuccessCallBack)(void);
typedef void (^RTAUAnswerFailCallBack)(FPNError * _Nullable error);



@interface RTAUClient : NSObject


/// 初始化
/// - Parameters:
///   - endpoint: endpoint
///   - projectId: 项目ID
///   - delegate: delegate
+ (nullable instancetype)clientWithEndpoint:(nonnull NSString * )endpoint
                                  projectId:(int64_t)projectId
                                   delegate:(id <RTAUProtocol>)delegate;


/// 登录
/// - Parameters:
///   - token: 登录token
///   - ts: 生成token对应的时间（毫秒）
///   - loginSuccess: 成功回调
///   - loginFail: 失败回调
- (void)loginWithToken:(nonnull NSString *)token
                    ts:(int64_t)ts
               success:(RTAULoginSuccessCallBack)loginSuccess
           connectFail:(RTAULoginFailCallBack)loginFail;


@property (nonatomic,readonly,strong)NSString * sdkVersion;//1.0.0
@property (nonatomic,readonly,assign)RTAUClientConnectStatus currentConnectStatus;
@property (nonatomic,assign,nullable)id <RTAUProtocol> delegate;
@property (nonatomic,readonly,assign)int64_t projectId;


/// 注册streamId
/// - Parameters:
///   - streamId: 审核流id,尽量保证唯一
///   - attrs: 为用户附加筛选用字段，最多可传5个
///   - audioLang: 音频语言(如果为视频 可为nil)具体支持的语言请参考https://docs.ilivedata.com/audiocheck/techdoc/language/
///   - audioStrategyId: 音频审核策略ID(传nil为默认策略)
///   - imageStrategyId: 图片审核策略ID(传nil为默认策略)
///   - callbackUrl: 指定的回调地址，不传使用项目配置的回调地址
///   - successCallback: 成功回调
///   - failCallback: 失败回调
-(void)startAuditWithStreamId:(NSString * _Nonnull)streamId
                        attrs:(NSArray <NSString*> * _Nonnull)attrs
                    audioLang:(NSString * _Nullable)audioLang
              audioStrategyId:(NSString * _Nullable)audioStrategyId
              imageStrategyId:(NSString * _Nullable)imageStrategyId
                  callbackUrl:(NSString * _Nullable)callbackUrl
                      success:(void(^)(void))successCallback
                         fail:(RTAUAnswerFailCallBack)failCallback;



/// 发送语音片段 (音频数据为PCM数据，16000Hz，16bit，单声道)
/// - Parameters:
///   - streamId: 审核流id(streamId与前面startAudit中的streamId对应)
///   - pcmData: 语音数据
///   - ts: 音频帧发送时间戳(毫秒)
-(void)sendAudioDataWithStreamId:(NSString * _Nonnull)streamId
                         pcmData:(NSData * _Nonnull)pcmData
                              ts:(int64_t)ts;
                         


/// 发送视频审核图像
/// - Parameters:
///   - streamId: 审核流id(streamId与前面startAudit中的streamId对应)
///   - image: 视频帧图像
///   - ts: 发送时间戳(毫秒)
-(void)sendImageDataWithStreamId:(NSString * _Nonnull)streamId
                           image:(UIImage * _Nonnull)image
                              ts:(int64_t)ts;



/// 停止审核
/// - Parameters:
///   - streamId: 审核的流id(streamId与前面startAudit中的streamId对应)
///   - successCallback: 成功回调
///   - failCallback: 失败回调
-(void)endAuditWithStreamId:(NSString * _Nonnull)streamId
                    success:(RTAUAnswerSuccessCallBack)successCallback
                       fail:(RTAUAnswerFailCallBack)failCallback;



//使用结束时调用 下次使用需要先登录
- (BOOL)closeConnect;



- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end


NS_ASSUME_NONNULL_END
