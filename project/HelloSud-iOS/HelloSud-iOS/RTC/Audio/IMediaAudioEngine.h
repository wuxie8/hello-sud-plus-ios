//
//  MediaAudioEngine.h
//  HelloSud-iOS
//
//  Created by Mary on 2022/1/18.
//

#import <Foundation/Foundation.h>
#import "MediaAudioEventListener.h"

NS_ASSUME_NONNULL_BEGIN

/// 多媒体语音引擎接口，多引擎实现以下接口
@protocol IMediaAudioEngine <NSObject>
@required

/// 设置事件处理器
/// @param listener 事件处理实例
- (void)setEventListener:(id<MediaAudioEventListener>)listener;

/// 配置引擎SDK
/// @param appID APPID
/// @param appKey APP秘钥
- (void)config:(NSString *)appID appKey:(NSString *)appKey;

/// 销毁
- (void)destroy;

/// 登录房间
/// @param roomID 房间ID
/// @param user 用户
/// @param config 配置
- (void)loginRoom:(NSString *)roomID user:(MediaUser *)user config:(nullable MediaRoomConfig *)config;

/// 退出房间
- (void)logoutRoom;

/// 开启推流
/// @param streamID 流ID
- (void)startPublish:(NSString *)streamID;

/// 停止推流
- (void)stopPublishStream;

/// 是否处于推流状态
- (BOOL)isPublishing;

/// 播放流
/// @param streamID 流ID
- (void)startPlayingStream:(NSString *)streamID;

/// 停止播放流
/// @param streamID 流ID
- (void)stopPlayingStream:(NSString *)streamID;

/// 静音麦克风
/// @param isMute 是否静音 YES静音 NO开启声音
- (void)muteMicrophone:(BOOL)isMute;

/// 发送指令
/// @param command 指令内容
/// @param roomID 房间ID
- (void)sendCommand:(NSString *)command roomID:(NSString *)roomID result:(void(^)(int))result;

/// 开始原始音频采集
- (void)startCapture;

/// 结束原始音频采集
- (void)stopCapture;
@end

NS_ASSUME_NONNULL_END
