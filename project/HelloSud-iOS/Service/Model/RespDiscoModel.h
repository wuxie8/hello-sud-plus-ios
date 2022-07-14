//
//  RespDiscoModel.h
//  HelloSud-iOS
//
//  Created by kaniel_mac on 2022/7/7.
//  Copyright © 2022 Sud.Tech (https://sud.tech). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiscoMenuModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 蹦迪贡献榜数据
@interface DiscoContributionModel : BaseModel
@property (nonatomic, strong)AudioUserModel *fromUser;
@property (nonatomic, assign)NSInteger count;
@property (nonatomic, assign)NSInteger rank;
@end

// CMD_ROOM_DISCO_INFO_RESP
@interface RespDiscoInfoModel : RoomBaseCMDModel
@property(nonatomic, strong) NSArray<DiscoMenuModel *> *dancingMenu;
@property(nonatomic, strong) NSArray<DiscoContributionModel *> *contribution;
@property(nonatomic, assign) BOOL isEnd;
@end

// CMD_ROOM_DISCO_BECOME_DJ
@interface RespDiscoBecomeDJModel : RoomBaseCMDModel
@property (nonatomic, strong)NSString * userID;
@end

/// 机器人信息model
@interface RotbotInfoModel : BaseModel
@property (nonatomic, assign)int64_t userId;
@property (nonatomic, strong)NSString * avatar;
@property (nonatomic, strong)NSString * name;
/// male female
@property (nonatomic, strong)NSString * gender;
@end
/// 拉取机器人列表数据模型
@interface RespDiscoRobotListModel : BaseRespModel
@property (nonatomic, strong)NSArray<RotbotInfoModel *> * robotList;
@end

NS_ASSUME_NONNULL_END
