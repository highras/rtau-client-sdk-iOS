RTAU v1.0.0 使用文档
================================

* [版本支持](#版本支持)
* [集成依赖](#集成依赖)
* [登录](#登录)
* [使用接口](#使用接口)

<a id="版本支持">版本支持</a>
================
* 语言:Objective-C  
* 最低支持 iOS 10 系统



<a id="集成依赖">集成依赖</a>
================
* 在TARGETS->Build Settings->Other Linker Flags （选中ALL视图）中添加-ObjC，字母O和C大写，符号“-”请勿忽略
* 静态库中采用Objective-C++实现，因此需要您保证您工程中至少有一个.mm后缀的源文件(您可以将任意一个.m后缀的文件改名为.mm)
* 添加库libresolv.9.tbd


<a id="登录">登录</a>
================ 
```objc

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
```






<a id="使用接口">使用接口</a>
================
```objc


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
```



