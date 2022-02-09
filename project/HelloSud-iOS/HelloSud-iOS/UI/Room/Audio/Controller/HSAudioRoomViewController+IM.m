//
//  HSAudioRoomViewController+IM.m
//  HelloSud-iOS
//
//  Created by kaniel on 2022/1/24.
//

#import "HSAudioRoomViewController+IM.h"

@implementation HSAudioRoomViewController(IM)

/// 发送消息
/// @param msg 消息体
/// @param isAddToShow 是否公屏展示
- (void)sendMsg:(HSAudioMsgBaseModel *)msg isAddToShow:(BOOL)isAddToShow {
    NSString *command = [[NSString alloc]initWithData:[msg mj_JSONData] encoding:NSUTF8StringEncoding];
    NSLog(@"send content:%@", command);
    [MediaAudioEngineManager.shared.audioEngine sendCommand:command roomID:self.roomID result:^(int errorCode) {
        NSLog(@"send result:%d", errorCode);
    }];
    if (isAddToShow) {
        [self addMsg:msg];
    }
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
    HSAudioMsgBaseModel *msgModel = nil;
    switch (cmd) {
        case CMD_PUBLIC_MSG_NTF:{
            // 公屏消息
            HSAudioMsgTextModel *msgTextModel = [HSAudioMsgTextModel mj_objectWithKeyValues:command];
            msgModel = msgTextModel;
            
            /// Game
            [self gameKeyWordHiting: msgTextModel.content];
        }
            break;
        case CMD_PUBLIC_SEND_GIFT_NTF:{
            // 礼物消息
            msgModel = [HSAudioMsgGiftModel mj_objectWithKeyValues:command];
        }
            break;
        case CMD_UP_MIC_NTF:{
            // 上麦消息
            msgModel = [HSAudioMsgMicModel mj_objectWithKeyValues:command];
            
            /// Game
            [self gameUpMic];
        }
            break;
        case CMD_DOWN_MIC_NTF:{
            // 下麦消息
            msgModel = [HSAudioMsgMicModel mj_objectWithKeyValues:command];
            
            /// Game
            [self gameDownMic];
        }
            break;
        case CMD_GAME_CHANGE: {
            // 游戏切换
            NSInteger gameID = [dic[@"gameID"] integerValue];
            [self handleGameChange:gameID];
        }
            break;
        default:
//        {
//            // 无法解析消息
//            HSAudioMsgTextModel *textModel = HSAudioMsgTextModel.new;
//            textModel.content = @"无法显示该消息，请升级最新版本";
//            msgModel = textModel;
//        }
            break;
    }
    if (msgModel) {
        [self addMsg:msgModel];
    }
}


#pragma mark - 业务处理
/// 上麦
- (void)gameUpMic {
    if (self.roomType == HSAudio) {
        return;
    }
    /// 上麦，就是加入游戏
    [self.fsm2MGManager sendComonSelfIn:YES seatIndex:-1 isSeatRandom:true teamId:1];
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

/// 处理切换游戏
/// @param gameID 新的游戏ID
- (void)handleGameChange:(NSInteger)gameID {
    if (gameID == 0) {
        // 切换语音房间
        self.gameId = 0;
        self.roomType = HSAudio;
        return;
    }
    self.gameId = gameID;
    self.gameInfoModel.currentPlayerUserId = HSAppManager.shared.loginUserInfo.userID;
    [self loginGame];
    self.roomType = HSGame;
}

@end
