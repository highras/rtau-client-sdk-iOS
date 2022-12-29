//
//  RTMProtocol.h
//  Rtm
//
//  Created by zsl on 2019/12/16.
//  Copyright © 2019 FunPlus. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class RTAUClient,RTAUAnswer,FPNError,RTAUMessage;
@protocol RTAUProtocol <NSObject>


@optional
//重连只有在登录成功过1次后才会有效
//重连将要开始  根据返回值是否进行重连
-(BOOL)rtauReloginWillStart:(RTAUClient *)client reloginCount:(int)reloginCount;
//重连结果
-(void)rtauReloginCompleted:(RTAUClient *)client reloginCount:(int)reloginCount reloginResult:(BOOL)reloginResult error:(FPNError*)error;
//关闭连接  
-(void)rtauConnectClose:(RTAUClient *)client;


@end

NS_ASSUME_NONNULL_END

