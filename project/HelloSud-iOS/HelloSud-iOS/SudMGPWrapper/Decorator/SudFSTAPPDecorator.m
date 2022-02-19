//
//  SudFSTAPPManager.m
//  HelloSud-iOS
//
//  Created by Mary on 2022/1/19.
//

#import "SudFSTAPPDecorator.h"

@implementation SudFSTAPPDecorator

- (void)setISudFSTAPP:(id<ISudFSTAPP>)iSudFSTAPP {
    self.iSudFSTAPP = iSudFSTAPP;
}
/// 加入,退出游戏
/// @param isIn true 加入游戏，false 退出游戏
/// @param seatIndex 加入的游戏位(座位号) 默认传seatIndex = -1 随机加入，seatIndex 从0开始，不可大于座位数
/// @param isSeatRandom 默认为ture, 带有游戏位(座位号)的时候，如果游戏位(座位号)已经被占用，是否随机分配一个空位坐下 isSeatRandom=true 随机分配空位坐下，isSeatRandom=false 不随机分配
/// @param teamId 不支持分队的游戏：数值填1；支持分队的游戏：数值填1或2（两支队伍）
- (void)notifyComonSelfIn:(BOOL)isIn seatIndex:(int)seatIndex isSeatRandom:(BOOL)isSeatRandom teamId:(int)teamId {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(isIn), @"isIn", @(seatIndex), @"seatIndex", @(isSeatRandom), @"isSeatRandom", @(1), @"teamId", nil];
    [self notifyStateChange:APP_COMMON_SELF_IN dataJson:dic.mj_JSONString];
}

/// 是否设置为准备状态
/// @param isReady  true 准备，false 取消准备
- (void)notifyComonSetReady:(BOOL)isReady {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(isReady), @"isReady", nil];
    [self notifyStateChange:APP_COMMON_SELF_READY dataJson:dic.mj_JSONString];
}

/// 游戏中状态设置
/// @param isPlaying   true 开始游戏，false 结束游戏
- (void)notifyComonSelfPlaying:(BOOL)isPlaying reportGameInfoExtras:(NSString *)reportGameInfoExtras {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(isPlaying), @"isPlaying", reportGameInfoExtras, @"reportGameInfoExtras", nil];
    [self notifyStateChange:APP_COMMON_SELF_PLAYING dataJson:dic.mj_JSONString];
}

/// 设置用户为队长
/// @param userId   必填，指定队长uid
- (void)notifyComonSetCaptainStateWithUserId:(NSString *)userId {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:userId, @"curCaptainUID", nil];
    [self notifyStateChange:APP_COMMON_SELF_CAPTAIN dataJson:dic.mj_JSONString];
}

/// 踢出用户
/// @param userId   被踢用户uid
- (void)notifyComonKickStateWithUserId:(NSString *)userId {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:userId, @"kickedUID", nil];
    [self notifyStateChange:APP_COMMON_SELF_KICK dataJson:dic.mj_JSONString];
}

/// 结束游戏
- (void)notifyComonSetEnd {
    [self notifyStateChange:APP_COMMON_SELF_END dataJson:[AppUtil dictionaryToJson:@{}]];
}

/// 麦克风状态
/// @param isOn   true 开麦，false 闭麦
/// @param isDisabled   true 被禁麦，false 未被禁麦
- (void)notifyComonMicrophoneState:(BOOL)isOn isDisabled:(BOOL)isDisabled {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(isOn), @"isOn", @(isDisabled), @"isDisabled", nil];
    [self notifyStateChange:APP_COMMON_SELF_MICROPHONE dataJson:dic.mj_JSONString];
}

/// 文字命中状态
/// @param isHit true 命中，false 未命中
/// @param keyWord 单个关键词， 兼容老版本
/// @param text 返回转写文本
/// @param wordType text:文本包含匹配; number:数字等于匹配
/// @param keyWordList 命中关键词，可以包含多个关键词
/// @param numberList 在number模式下才有，返回转写的多个数字
- (void)notifyComonDrawTextHit:(BOOL)isHit keyWord:(NSString *)keyWord text:(NSString *)text wordType:(NSString *)wordType keyWordList:(NSArray<NSString *> *)keyWordList numberList:(NSArray<NSNumber *> *)numberList {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(isHit), @"isHit", keyWord, @"keyWord", text, @"text", wordType, @"wordType", keyWordList, @"keyWordList", numberList, @"numberList", nil];
    [self notifyStateChange:APP_COMMON_SELF_TEXT_HIT dataJson:dic.mj_JSONString];
}

/// 文字命中状态
/// @param isHit true 命中，false 未命中
/// @param keyWord 单个关键词， 兼容老版本
/// @param text 返回转写文本
- (void)notifyComonDrawTextHit:(BOOL)isHit keyWord:(NSString *)keyWord text:(NSString *)text {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(isHit), @"isHit", keyWord, @"keyWord", text, @"text", nil];
    [self notifyStateChange:APP_COMMON_SELF_TEXT_HIT dataJson:dic.mj_JSONString];
}

/// 打开或关闭背景音乐
/// @param isOpen  true 打开背景音乐，false 关闭背景音乐
- (void)notifyComonOpenBgMusic:(BOOL)isOpen {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(isOpen), @"isOpen", nil];
    [self notifyStateChange:APP_COMMON_OPEN_BG_MUSIC dataJson:dic.mj_JSONString];
}

/// 打开或关闭音效
/// @param isOpen  true 打开音效，false 关闭音效
- (void)notifyComonOpenSound:(BOOL)isOpen {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(isOpen), @"isOpen", nil];
    [self notifyStateChange:APP_COMMON_OPEN_SOUND dataJson:dic.mj_JSONString];
}

/// 打开或关闭游戏中的振动效果
/// @param isOpen  true 打开振动效果，false 关闭振动效果
- (void)notifyComonOpenVibrate:(BOOL)isOpen {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(isOpen), @"isOpen", nil];
    [self notifyStateChange:APP_COMMON_OPEN_BRATE dataJson:dic.mj_JSONString];
}

/// 设置游戏的音量大小
/// @param volume  音量大小 0 到 100
- (void)notifyComonOpenSoundVolume:(int)volume {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(volume), @"volume", nil];
    [self notifyStateChange:APP_COMMON_SOUND_VOLUME dataJson:dic.mj_JSONString];
}


#pragma mark =======APP->游戏状态处理=======
/// 状态通知（app to mg）
/// @param state 状态名称
/// @param dataJson 需传递的json
- (void)notifyStateChange:(NSString *) state dataJson:(NSString*) dataJson {
    [self.iSudFSTAPP notifyStateChange:state dataJson:dataJson listener:^(int retCode, const NSString *retMsg, const NSString *dataJson) {
        NSLog(@"ISudFSMMG:notifyStateChange:retCode=%@ retMsg=%@ dataJson=%@", @(retCode), retMsg, dataJson);
    }];
}


- (void)destroyMG {
    [self.iSudFSTAPP destroyMG];
}

- (UIView *)getGameView {
    return [self.iSudFSTAPP getGameView];
}

/// 更新code
/// @param code 新的code
- (void)updateCode:(NSString *) code {
    [self.iSudFSTAPP updateCode:code listener:^(int retCode, const NSString *retMsg, const NSString *dataJson) {
        NSLog(@"ISudFSMMG:updateGameCode retCode=%@ retMsg=%@ dataJson=%@", @(retCode), retMsg, dataJson);
    }];
}

/// 传输音频数据： 传入的音频数据必须是：PCM格式，采样率：16000， 采样位数：16， 声道数： MONO
- (void)pushAudio:(NSData *)data {
    /// 必须要在主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.iSudFSTAPP pushAudio:data];
    });
}
@end
