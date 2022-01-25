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
- (void)sendMsg:(NSString *)msg {
    [MediaAudioEngineManager.shared.audioEngine sendCommand:msg roomID:@"123" result:^(int errorCode) {
        NSLog(@"send result:%d", errorCode);
    }];
}

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
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:command.UTF8String length:command.length] options:NSJSONReadingMutableContainers error:nil];
    NSInteger cmd = [dic[@"cmd"] integerValue];
    HSAudioMsgBaseModel *msgModel = nil;
    switch (cmd) {
        case CMD_PUBLIC_MSG_NTF:{
            msgModel = [HSAudioMsgTextModel mj_objectWithKeyValues:command];
        }
            break;
        case CMD_PUBLIC_SEND_GIFT_NTF:{
            msgModel = [HSAudioMsgGiftModel mj_objectWithKeyValues:command];
        }
            break;
        case CMD_UP_MIC_NTF:{
            msgModel = [HSAudioMsgMicModel mj_objectWithKeyValues:command];
        }
            break;
        case CMD_DOWN_MIC_NTF:{
            msgModel = [HSAudioMsgMicModel mj_objectWithKeyValues:command];
        }
            break;
        default:{
            HSAudioMsgTextModel *textModel = HSAudioMsgTextModel.new;
            textModel.content = @"无法显示该消息，请升级最新版本";
            msgModel = textModel;
        }
            break;
    }
}
@end
