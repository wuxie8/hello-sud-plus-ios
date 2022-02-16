//
//  AudioRoomViewController+IM.m
//  HelloSud-iOS
//
//  Created by kaniel on 2022/1/24.
//

#import "AudioRoomViewController+IM.h"

@implementation AudioRoomViewController(IM)

/// 发送消息
/// @param msg 消息体
/// @param isAddToShow 是否公屏展示
- (void)sendMsg:(AudioMsgBaseModel *)msg isAddToShow:(BOOL)isAddToShow {
    NSString *command = [[NSString alloc]initWithData:[msg mj_JSONData] encoding:NSUTF8StringEncoding];
    NSLog(@"send content:%@", command);
    [HSAudioEngineManager.shared.audioEngine sendCommand:command roomID:self.roomID result:^(int errorCode) {
        NSLog(@"send result:%d", errorCode);
    }];
    [self addMsg:msg isShowOnScreen:isAddToShow];
    /// Game - 发送文本命中
    if ([msg isKindOfClass:AudioMsgTextModel.class]) {
        AudioMsgTextModel *m = (AudioMsgTextModel *)msg;
        [self gameKeyWordHiting: m.content];
    } else if ([msg isKindOfClass:AudioMsgMicModel.class]) {
        AudioMsgMicModel *m = (AudioMsgMicModel *)msg;
        if (m.cmd == CMD_UP_MIC_NTF) {
            [self gameUpMic];
        } else if (m.cmd == CMD_DOWN_MIC_NTF) {
            [self gameDownMic];
        }
    }
}

/// 发送进房消息
- (void)sendEnterRoomMsg {
    self.isEnteredRoom = YES;
    AudioMsgSystemModel *msg = [AudioMsgSystemModel makeMsg:[NSString stringWithFormat:@"%@ 进入了房间", AppManager.shared.loginUserInfo.name]];
    [msg configBaseInfoWithCmd:CMD_ENTER_ROOM_NTF];
    [self sendMsg:msg isAddToShow:YES];
}

/// 接收引擎回调回来消息响应
- (void)onIMRecvCustomCommand:(NSString *)command fromUser:(MediaUser *)fromUser roomID:(NSString *)roomID {
    NSLog(@"recv command:\nroom:%@\nuserID:%@\nnickname:%@,content:%@", roomID, fromUser.userID,fromUser.nickname, command);
    [self handleCommand:command user:fromUser.userID roomID:roomID];
}


/// 处理收到房间信令
/// @param command 指令内容
/// @param userID 发送者
/// @param roomID 房间号
- (void)handleCommand:(NSString *)command user:(NSString *)userID roomID:(NSString *)roomID {
    if (command.length == 0) {
        NSLog(@"recv content is empty.");
        return;
    }
    NSData *data = [command dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"parse json err:%@", error.debugDescription);
        return;
    }
    NSInteger cmd = [dic[@"cmd"] integerValue];
    AudioMsgBaseModel *msgModel = nil;
    BOOL isShowOnScreen = YES;
    switch (cmd) {
        case CMD_PUBLIC_MSG_NTF:{
            // 公屏消息
            AudioMsgTextModel *msgTextModel = [AudioMsgTextModel decodeModel:command];
            msgModel = msgTextModel;
        }
            break;
        case CMD_PUBLIC_SEND_GIFT_NTF:{
            // 礼物消息
            msgModel = [AudioMsgGiftModel decodeModel:command];
        }
            break;
        case CMD_UP_MIC_NTF:{
            // 上麦消息
            msgModel = [AudioMsgMicModel decodeModel:command];
            isShowOnScreen = NO;
        }
            break;
        case CMD_DOWN_MIC_NTF:{
            // 下麦消息
            msgModel = [AudioMsgMicModel decodeModel:command];
            isShowOnScreen = NO;
        }
            break;
        case CMD_GAME_CHANGE: {
            // 游戏切换
            ExChangeGameMsgModel *m = [ExChangeGameMsgModel decodeModel:command];
            [self handleGameChange:m.gameID];
        }
            break;
            
        case CMD_ENTER_ROOM_NTF: {
            // 进入房间
            AudioMsgSystemModel *m = [AudioMsgSystemModel decodeModel:command];
            [m updateContent:[NSString stringWithFormat:@"%@ 进入了房间", m.sendUser.name]];
            msgModel = m;
        }
            break;
        default:
        {
            // 无法解析消息
            AudioMsgTextModel *textModel = AudioMsgTextModel.new;
            textModel.content = [NSString stringWithFormat:@"无法显示该消息，请升级最新版本,cmd:%ld", cmd];
            msgModel = textModel;
        }
            break;
    }
    if (msgModel) {
        [self addMsg:msgModel isShowOnScreen:isShowOnScreen];
    }
}


#pragma mark - 业务处理
/// 上麦
- (void)gameUpMic {
    if (self.roomType == HSAudio) {
        return;
    }
    if (self.gameInfoModel.gameState == 0 && !self.gameInfoModel.isInGame) {
        /// 上麦，就是加入游戏
        [self.fsm2MGManager sendComonSelfIn:YES seatIndex:-1 isSeatRandom:true teamId:1];
    }
}

/// 下麦
- (void)gameDownMic {
    if (self.roomType == HSAudio) {
        return;
    }
    if (self.gameInfoModel.isReady) {
        /// 如果已经准备先退出准备状态
        [self.fsm2MGManager sendComonSetReady:false];
    }
    /// 下麦，就是退出游戏
    [self.fsm2MGManager sendComonSelfIn:NO seatIndex:-1 isSeatRandom:true teamId:1];
}

/// 你画我猜命中
- (void)gameKeyWordHiting:(NSString *)content {
    if (self.roomType == HSAudio) {
        return;
    }
    if (self.gameInfoModel.keyWordHiting == YES && [content isEqualToString:self.gameInfoModel.drawKeyWord]) {
        /// 关键词命中
        [self.fsm2MGManager sendComonDrawTextHit:true keyWord:self.gameInfoModel.drawKeyWord text:self.gameInfoModel.drawKeyWord];
    }
}

@end
