//
// Created by kaniel on 2022/6/1.
// Copyright (c) 2022 Sud.Tech (https://sud.tech). All rights reserved.
//

#import "GuessRoomViewController.h"
#import "GuessMineView.h"
#import "SwitchAutoGuessPopView.h"
#import "GuessSelectPopView.h"
#import "GuessResultPopView.h"

@interface GuessRoomViewController ()
/// 猜我赢挂件视图
@property(nonatomic, strong) GuessMineView *guessMineView;
/// 导航自动竞猜导航视图
@property(nonatomic, strong) BaseView *autoGuessNavView;
@property(nonatomic, strong) UIImageView *autoNavImageView;
@property(nonatomic, strong) UILabel *autoTitleLabel;
/// 围观者导航视图
@property(nonatomic, strong) BaseView *normalGuessNavView;
@property(nonatomic, strong) MarqueeLabel *normalGuessNavLabel;
/// 开启了自动竞猜
@property(nonatomic, assign) BOOL openAutoBet;
@property(nonatomic, assign) NSInteger betCoin;
@end

@implementation GuessRoomViewController {

}

- (Class)serviceClass {
    return GuessService.class;
}


- (void)dtAddViews {
    [super dtAddViews];
    [self.sceneView addSubview:self.guessMineView];
    [self.naviView addSubview:self.autoGuessNavView];
    [self.naviView addSubview:self.normalGuessNavView];

    [self.autoGuessNavView addSubview:self.autoNavImageView];
    [self.autoGuessNavView addSubview:self.autoTitleLabel];

    [self.normalGuessNavView addSubview:self.normalGuessNavLabel];

}

- (void)dtLayoutViews {
    [super dtLayoutViews];

    CGFloat bottom = kAppSafeBottom + 51;
    [self.guessMineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(@(-18));
        make.width.equalTo(@80);
        make.height.equalTo(@90);
        make.bottom.equalTo(@(-bottom));
    }];
    [self.autoGuessNavView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.naviView.roomModeView);
        make.height.equalTo(@20);
        make.width.equalTo(@0);
        make.trailing.equalTo(self.naviView.roomModeView.mas_leading).offset(-10);
        make.leading.greaterThanOrEqualTo(self.naviView.onlineImageView.mas_trailing).offset(10);
    }];
    [self.autoNavImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(@-1);
        make.width.height.equalTo(@18);
        make.centerY.equalTo(self.autoGuessNavView);
    }];
    [self.autoTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@7);
        make.trailing.equalTo(self.autoNavImageView.mas_leading);
        make.width.height.greaterThanOrEqualTo(@0);
        make.centerY.equalTo(self.autoGuessNavView);
    }];
    [self.normalGuessNavView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.naviView.roomModeView);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@0);
        make.trailing.equalTo(self.naviView.roomModeView.mas_leading).offset(-10);
        make.leading.greaterThanOrEqualTo(self.naviView.onlineImageView.mas_trailing).offset(10);
    }];
    [self.normalGuessNavLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@8);
        make.trailing.equalTo(@-8);
        make.width.greaterThanOrEqualTo(@0);
        make.height.equalTo(self.normalGuessNavView);
    }];

}

- (void)dtConfigUI {
    [super dtConfigUI];
    self.autoTitleLabel.text = @"自动竞猜";
    self.normalGuessNavLabel.text = @"猜输赢";
    [self reqData];
}

- (void)dtUpdateUI {
    [super dtUpdateUI];

    [self.guessMineView updateBetCoin:self.betCoin];
}

- (void)dtConfigEvents {
    [super dtConfigEvents];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.guessMineView addGestureRecognizer:tap];

    UITapGestureRecognizer *tapAuto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAuto:)];
    [self.autoGuessNavView addGestureRecognizer:tapAuto];

    UITapGestureRecognizer *tapNormal = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapNormal:)];
    [self.normalGuessNavView addGestureRecognizer:tapNormal];

}

- (void)reqData {
    WeakSelf
    NSArray *playerUserIdList = @[AppService.shared.loginUserID ? AppService.shared.loginUserID : @""];
    NSString *roomId = kGuessService.currentRoomVC.roomID;
    [GuessService reqGuessPlayerList:playerUserIdList roomId:roomId finished:^(RespGuessPlayerListModel *model) {
        weakSelf.betCoin = model.betCoin;
        [weakSelf dtUpdateUI];
    }];
}

/// 游戏玩家加入游戏状态变化
- (void)playerIsInGameStateChanged:(NSString *)userId {
    if (![AppService.shared.loginUserID isEqualToString:userId]) {
        return;
    }

    BOOL isInGame = self.sudFSMMGDecorator.isInGame;
    if (!isInGame) {
        // 当前用户没有加入游戏
        [self showNaviAutoStateView:NO];
        self.guessMineView.hidden = YES;
        self.normalGuessNavView.hidden = NO;
        return;
    }
    // 当前用户加入了游戏
    
    // 如果未开启自动竞猜，展示挂件
    if (!self.openAutoBet) {
        self.guessMineView.hidden = NO;
    }
    self.normalGuessNavView.hidden = YES;
}

/// 我的猜输赢挂件响应
- (void)onTap:(id)tap {

    if (self.sudFSMMGDecorator.gameStateType == GameStateTypePlaying) {
        [ToastUtil show:@"游戏进行中，暂不可开启竞猜"];
        return;
    }
    WeakSelf
    SwitchAutoGuessPopView *v = [[SwitchAutoGuessPopView alloc] init];
    v.betCoin = self.betCoin;
    [v dtUpdateUI];
    v.onCloseBlock = ^{
        [DTSheetView close];
    };
    v.onOpenBlock = ^{
        if (UserService.shared.currentUserCoin < self.betCoin) {
            [ToastUtil show:@"余额不足"];
            return;
        }
        // 开启的时候自动扣费
        [GuessService reqBet:2 coin:self.betCoin userList:@[AppService.shared.loginUserID] finished:^{
            [DTSheetView close];
            DDLogDebug(@"开启自动扣费：投注成功");
            weakSelf.openAutoBet = YES;
            [weakSelf showNaviAutoStateView:YES];
            // 自己押注消息
            AudioUserModel *userModel = AudioUserModel.new;
            userModel.userID = AppService.shared.login.loginUserInfo.userID;
            userModel.name = AppService.shared.login.loginUserInfo.name;
            userModel.icon = AppService.shared.login.loginUserInfo.icon;
            userModel.sex = AppService.shared.login.loginUserInfo.sex;
            [kGuessService sendBetNotifyMsg:weakSelf.roomID betUsers:@[userModel]];
        }            failure:nil];

    };
    [DTSheetView show:v onCloseCallback:^{

    }];
}

/// 自动竞猜状态开关响应
- (void)onTapAuto:(id)tap {

    if (self.sudFSMMGDecorator.gameStateType == GameStateTypePlaying) {
        [ToastUtil show:@"游戏进行中，暂不可关闭竞猜"];
        return;
    }
    WeakSelf
    [DTAlertView showTextAlert:@"是否关闭每轮自动猜自己赢?" sureText:@"确认关闭" cancelText:@"返回" onSureCallback:^{
        weakSelf.openAutoBet = NO;
        [weakSelf showNaviAutoStateView:NO];
    }          onCloseCallback:^{
        [DTAlertView close];
    }];

}

/// 普通用户猜输赢开关响应
- (void)onTapNormal:(id)tap {
    GuessSelectPopView *v = [[GuessSelectPopView alloc] init];
    v.mj_h = kScreenHeight * 0.77;
    [DTSheetView show:v onCloseCallback:^{

    }];
}

/// 展示自动竞猜状态视图
/// @param show  show
- (void)showNaviAutoStateView:(BOOL)show {
    if (show) {
        self.autoGuessNavView.hidden = NO;
        self.guessMineView.hidden = YES;
        [self.autoGuessNavView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.naviView.roomModeView);
            make.height.equalTo(@20);
            make.width.greaterThanOrEqualTo(@0);
            make.trailing.equalTo(self.naviView.roomModeView.mas_leading).offset(-10);
            make.leading.greaterThanOrEqualTo(self.naviView.onlineImageView.mas_trailing).offset(10);
        }];
    } else {
        self.autoGuessNavView.hidden = YES;
        self.guessMineView.hidden = NO;
        [self.autoGuessNavView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.naviView.roomModeView);
            make.height.equalTo(@20);
            make.width.greaterThanOrEqualTo(@0);
            make.trailing.equalTo(self.naviView.roomModeView.mas_leading).offset(-10);
            make.leading.greaterThanOrEqualTo(self.naviView.onlineImageView.mas_trailing).offset(10);
        }];
    }
}

/// 展示结果弹窗
- (void)showResultAlertView:(NSArray<GuessPlayerModel *> *)playerList winCoin:(NSInteger)winCoin {
    GuessResultPopView *v = [[GuessResultPopView alloc] init];
    v.dataList = playerList;

    BOOL isSupport = NO;
    for (int i = 0; i < playerList.count; ++i) {
        if (playerList[i].support) {
            isSupport = YES;
            break;
        }
    }
    if (playerList.count > 0 && playerList[0].support) {
        v.resultStateType = GuessResultPopViewTypeWin;
    } else if (isSupport) {
        v.resultStateType = GuessResultPopViewTypeLose;
    } else {
        v.resultStateType = GuessResultPopViewTypeNotBet;
    }
    [v dtUpdateUI];
    v.backgroundColor = UIColor.clearColor;
    [DTAlertView show:v rootView:nil clickToClose:YES showDefaultBackground:NO onCloseCallback:^{

    }];
}

/// 请求结果玩家列表
/// @param results results
- (void)reqResultPlayerListData:(NSArray<MGCommonGameSettleResults *> *)results {
    WeakSelf

    NSMutableArray *playerUserIdList = [[NSMutableArray alloc] init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < results.count; ++i) {
        MGCommonGameSettleResults *m = results[i];
        if (m.uid) {
            [playerUserIdList addObject:m.uid];
            dic[m.uid] = m;
        }
    }
    NSString *roomId = kGuessService.currentRoomVC.roomID;
    [GuessService reqGuessPlayerList:playerUserIdList roomId:roomId finished:^(RespGuessPlayerListModel *model) {
        weakSelf.betCoin = model.betCoin;
        NSArray *arr = model.playerList;

        for (int i = 0; i < arr.count; ++i) {
            GuessPlayerModel *m = arr[i];
            MGCommonGameSettleResults *resultModel = dic[[NSString stringWithFormat:@"%@", @(m.userId)]];
            if (resultModel) {
                m.rank = resultModel.rank;
                m.award = resultModel.award;
                m.score = resultModel.score;
            }
        }
        arr = [arr sortedArrayUsingComparator:^NSComparisonResult(GuessPlayerModel *_Nonnull obj1, GuessPlayerModel *_Nonnull obj2) {
            return obj1.rank > obj2.rank;
        }];
        [weakSelf showResultAlertView:arr winCoin:model.winCoin];
    }];
}

/// 处理业务指令
- (void)handleBusyCommand:(NSInteger)cmd command:(NSString *)command {
    WeakSelf
    switch (cmd) {
        case CMD_ROOM_QUIZ_BET: {
            // 押注公屏
            RoomCmdGuessBetNotifyModel *model = [RoomCmdGuessBetNotifyModel fromJSON:command];
            [weakSelf showBetScreenMsg:model];
        }
            break;
        default:
            break;
    }
}

- (void)showBetScreenMsg:(RoomCmdGuessBetNotifyModel *)model {

    NSArray <AudioUserModel *> *arrUsers = model.recUser;
    for (int i = 0; i < arrUsers.count; ++i) {
        AudioUserModel *user = arrUsers[i];
        NSString *content = @"";
        if ([user.userID isEqualToString:model.sendUser.userID]) {
            content = [NSString stringWithFormat:@"%@ 胸有成竹，猜自己一定能赢", model.sendUser.name];
        } else {
            content = [NSString stringWithFormat:@"%@ 为 %@ 打call，猜TA赢", model.sendUser.name, user.name];
        }
        [self addBetPublicMsgContent:content];
    }
}

- (void)addBetPublicMsgContent:(NSString *)content {
    if (content.length == 0) {
        return;
    }
    NSMutableAttributedString *attrMsg = [[NSMutableAttributedString alloc] initWithString:content];
    if (attrMsg.length > 0) {
        attrMsg.yy_lineSpacing = 6;
        attrMsg.yy_font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        attrMsg.yy_color = [UIColor dt_colorWithHexString:@"#ffffff" alpha:1];
        AudioMsgSystemModel *msgModel = [AudioMsgSystemModel makeMsgWithAttr:attrMsg];
        /// 公屏添加消息
        [self addMsg:msgModel isShowOnScreen:YES];
    }
}

#pragma mark game events

/// 获取游戏Config  【需要实现】
- (NSString *)onGetGameCfg {

    GameSettle *gameSettle = [[GameSettle alloc] init];
    gameSettle.hide = YES;

    LobbyPlayers *l = [[LobbyPlayers alloc] init];
    l.hide = true;

    GameUi *ui = [[GameUi alloc] init];
    ui.gameSettle = gameSettle;
    ui.lobby_players = l;

    GameCfgModel *m = [GameCfgModel defaultCfgModel];
    m.ui = ui;

    return [m mj_JSONString];
}

/// 游戏: 开始游戏按钮点击状态   MG_COMMON_SELF_CLICK_START_BTN
- (void)onGameMGCommonSelfClickStartBtn {
    // 通过游戏透传业务竞猜场景ID到业务服务端
    NSDictionary *dic = @{@"sceneId": @(self.configModel.enterRoomModel.sceneType)};
    [self.sudFSTAPPDecorator notifyAppComonSelfPlaying:true reportGameInfoExtras:dic.mj_JSONString];
    WeakSelf
    /// 开启了自动扣费
    if (self.openAutoBet) {
        [GuessService reqBet:2 coin:self.betCoin userList:@[AppService.shared.loginUserID] finished:^{
            [DTSheetView close];
            DDLogDebug(@"开启自动扣费：投注成功");
            // 自己押注消息
            AudioUserModel *userModel = AudioUserModel.new;
            userModel.userID = AppService.shared.login.loginUserInfo.userID;
            userModel.name = AppService.shared.login.loginUserInfo.name;
            userModel.icon = AppService.shared.login.loginUserInfo.icon;
            userModel.sex = AppService.shared.login.loginUserInfo.sex;
            [kGuessService sendBetNotifyMsg:weakSelf.roomID betUsers:@[userModel]];
        }            failure:^(NSError *error) {
            weakSelf.openAutoBet = NO;
            [weakSelf showNaviAutoStateView:NO];
        }];
    }
}

/// 游戏: 游戏结算状态     MG_COMMON_GAME_SETTLE
- (void)onGameMGCommonGameSettle:(nonnull id <ISudFSMStateHandle>)handle model:(MGCommonGameSettleModel *)model {

    // 展示游戏结果
    [self reqResultPlayerListData:model.results];

    [handle success:[self.sudFSMMGDecorator handleMGSuccess]];
}

#pragma mark lazy

- (GuessMineView *)guessMineView {
    if (!_guessMineView) {
        _guessMineView = [[GuessMineView alloc] init];
        _guessMineView.hidden = YES;
    }
    return _guessMineView;
}

- (BaseView *)autoGuessNavView {
    if (!_autoGuessNavView) {
        _autoGuessNavView = [[BaseView alloc] init];
        _autoGuessNavView.backgroundColor = HEX_COLOR(@"#35C543");
        _autoGuessNavView.hidden = YES;
        [_autoGuessNavView dt_cornerRadius:10];
    }
    return _autoGuessNavView;
}

- (UIImageView *)autoNavImageView {
    if (!_autoNavImageView) {
        _autoNavImageView = [[UIImageView alloc] init];
        _autoNavImageView.contentMode = UIViewContentModeScaleAspectFill;
        _autoNavImageView.clipsToBounds = YES;
        _autoNavImageView.image = [UIImage imageNamed:@"guess_auto_state"];
    }
    return _autoNavImageView;
}

- (UILabel *)autoTitleLabel {
    if (!_autoTitleLabel) {
        _autoTitleLabel = [[UILabel alloc] init];
        _autoTitleLabel.font = UIFONT_BOLD(12);
        _autoTitleLabel.textColor = HEX_COLOR(@"#FFFFFF");
        _autoTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _autoTitleLabel;
}

- (BaseView *)normalGuessNavView {
    if (!_normalGuessNavView) {
        _normalGuessNavView = [[BaseView alloc] init];
        [_normalGuessNavView dtAddGradientLayer:@[@0, @1] colors:@[(id) HEX_COLOR(@"#FCE58B").CGColor, (id) HEX_COLOR(@"#FFA81C").CGColor] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5) cornerRadius:0];
    }
    return _normalGuessNavView;
}

- (MarqueeLabel *)normalGuessNavLabel {
    if (!_normalGuessNavLabel) {
        _normalGuessNavLabel = [[MarqueeLabel alloc] init];
        _normalGuessNavLabel.text = NSString.dt_room_start_pk;
        _normalGuessNavLabel.textColor = UIColor.whiteColor;
        _normalGuessNavLabel.font = UIFONT_MEDIUM(12);
        _normalGuessNavLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _normalGuessNavLabel;
}
@end
