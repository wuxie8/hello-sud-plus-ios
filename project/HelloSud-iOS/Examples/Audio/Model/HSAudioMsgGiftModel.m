//
//  HSAudioMsgGiftModel.m
//  HelloSud-iOS
//
//  Created by kaniel on 2022/1/24.
//

#import "HSAudioMsgGiftModel.h"

@interface HSAudioMsgGiftModel(){
    NSAttributedString *_attrContent;
}

@end

@implementation HSAudioMsgGiftModel
- (NSString *)cellName {
    return @"HSRoomGiftTableViewCell";
}

- (NSAttributedString *)attrContent {
    return _attrContent;
}

/// 构建消息
/// @param giftID giftID description
/// @param giftCount giftCount description
/// @param toUser toUser description
+ (instancetype)makeMsgWithGiftID:(NSInteger)giftID giftCount:(NSInteger)giftCount toUser:(HSAudioUserModel *)toUser {
    HSAudioMsgGiftModel *m = HSAudioMsgGiftModel.new;
    [m configBaseInfoWithCmd:CMD_PUBLIC_SEND_GIFT_NTF];
    m.giftID = giftID;
    m.giftCount = giftCount;
    m.toUser = toUser;
    return m;
}

- (CGFloat)caculateHeight {
    CGFloat h = [super caculateHeight];
    CGFloat yMargin = 3;
    h += yMargin * 2;
    NSMutableAttributedString *attrSendName = [[NSMutableAttributedString alloc] initWithString:@"大眼萌嘟宝"];
    attrSendName.yy_lineSpacing = 6;
    attrSendName.yy_font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    attrSendName.yy_color = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    
    NSMutableAttributedString *attrSend = [[NSMutableAttributedString alloc] initWithString:@"送给"];
    attrSend.yy_lineSpacing = 6;
    attrSend.yy_font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    attrSend.yy_color = [UIColor colorWithHexString:@"#AAAAAA" alpha:1];
    
    NSMutableAttributedString *attrGetName = [[NSMutableAttributedString alloc] initWithString:@"零乳糖软妹   小仓鼠"];
    attrGetName.yy_lineSpacing = 6;
    attrGetName.yy_font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    attrGetName.yy_color = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    
    UIImage *iconImage = [UIImage imageNamed:@"room_ope_gift"];
    NSMutableAttributedString *attrGift = [NSAttributedString yy_attachmentStringWithContent:iconImage contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(16, 16) alignToFont:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular] alignment:YYTextVerticalAlignmentCenter];
    
    NSMutableAttributedString *attrGiftCount = [[NSMutableAttributedString alloc] initWithString:@"x1"];
    attrGiftCount.yy_lineSpacing = 6;
    attrGiftCount.yy_font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    attrGiftCount.yy_color = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    
    [attrSendName appendAttributedString:attrSend];
    [attrSendName appendAttributedString:attrGetName];
    [attrSendName appendAttributedString:attrGift];
    [attrSendName appendAttributedString:attrGiftCount];
    _attrContent = attrSendName;
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(MAX_CELL_CONTENT_WIDTH - 8, CGFLOAT_MAX) text:attrSendName];
    if (layout) {
        h += layout.textBoundingSize.height;
    }
    return h;
}
@end
