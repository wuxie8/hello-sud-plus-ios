//
//  TicketService.h
//  HelloSud-iOS
//
//  Created by Mary on 2022/3/29.
//  Copyright © 2022 Sud.Tech (https://sud.tech). All rights reserved.
//

#import "AudioRoomService.h"

NS_ASSUME_NONNULL_BEGIN
/// 门票加入弹窗key
#define kKeyTicketJoinPop @"key_ticket_join_pop"

@interface TicketService : AudioRoomService
typedef NS_ENUM(NSInteger, TicketLevelType) {
    TicketLevelTypePrimary = 1,
    TicketLevelTypeMedia,
    TicketLevelTypeSenior
};
/// 门票场景等级类型
@property (nonatomic, assign) TicketLevelType ticketLevelType;

#pragma mark - NSUserDefaults
- (void)savePopTicketJoin:(BOOL)isShow;
- (BOOL)getPopTicketJoin;

@end

NS_ASSUME_NONNULL_END
