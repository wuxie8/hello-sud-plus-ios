//
// Created by kaniel on 2022/10/10.
// Copyright (c) 2022 Sud.Tech (https://sud.tech). All rights reserved.
//

#import "OneOneVideoContentView.h"
#import "SuspendRoomView.h"
#import "OneOneAudioMicroView.h"

@interface OneOneVideoContentView ()
@property(nonatomic, strong) UIButton *suspendBtn;
@property(nonatomic, strong) UIButton *hangupBtn;
@property(nonatomic, strong) UIButton *micBtn;
@property(nonatomic, strong) UIButton *gameBtn;
@property(nonatomic, strong) UILabel *timeLabel;

@property(nonatomic, strong) UIView *micContentView;

@property(nonatomic, strong) OneOneAudioMicroView *leftMicView;
@property(nonatomic, strong) OneOneAudioMicroView *rightMicView;
@property(nonatomic, strong) UIImageView *bgImageView;
@property(nonatomic, strong) UIImageView *otherHeaderImageView;
@property(nonatomic, strong) UILabel *otherNameLabel;
@property(nonatomic, strong) UIImageView *bottomCoverImageView;

@property(nonatomic, strong) UIView *addRobotView;
@property(nonatomic, strong) UIView *myVideoView;
@property(nonatomic, strong) UIView *otherVideoView;
/// 语音按钮状态类型
@property(nonatomic, assign) OneOneVideoMicType micStateType;
@property(nonatomic, assign) BOOL isGameState;
@property(nonatomic, strong) AudioRoomMicModel *otherMicModel;
@end

@implementation OneOneVideoContentView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *v = [super hitTest:point withEvent:event];
    // 穿透
    if (v == self) {
        return nil;
    }
    return v;
}

- (void)dtAddViews {
    [super dtAddViews];
    [self addSubview:self.bgImageView];
    [self addSubview:self.otherVideoView];
    [self addSubview:self.otherHeaderImageView];
    [self addSubview:self.otherNameLabel];
    [self addSubview:self.bottomCoverImageView];
    [self addSubview:self.suspendBtn];
    [self addSubview:self.hangupBtn];
    [self addSubview:self.micBtn];
    [self addSubview:self.gameBtn];
    [self addSubview:self.timeLabel];
    [self addSubview:self.micContentView];
    [self.micContentView addSubview:self.leftMicView];
    [self.micContentView addSubview:self.rightMicView];
    self.micContentView.hidden = YES;
    self.leftMicView.model = kAudioRoomService.currentRoomVC.dicMicModel[@"0"];
    self.otherMicModel = kAudioRoomService.currentRoomVC.dicMicModel[@"1"];
    [self addSubview:self.addRobotView];
    [self addSubview:self.myVideoView];
}

- (void)dtLayoutViews {
    [super dtLayoutViews];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.equalTo(@0);
    }];
    [self.otherVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.equalTo(@0);
    }];
    [self.otherHeaderImageView dt_cornerRadius:24];
    [self.otherHeaderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@16);
        make.top.equalTo(self.suspendBtn.mas_bottom).offset(16);
        make.width.height.equalTo(@48);
    }];
    [self.otherNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.otherHeaderImageView.mas_trailing).offset(8);
        make.centerY.equalTo(self.otherHeaderImageView);
        make.width.height.greaterThanOrEqualTo(@0);
    }];
    [self.bottomCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(@0);
        make.height.equalTo(@158);
    }];
    [self.suspendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@32);
        make.top.equalTo(@(kAppSafeTop + 6));
        make.leading.equalTo(@16);
    }];

    [self.gameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@64);
        make.bottom.equalTo(@(-kAppSafeBottom - 16));
        make.centerX.equalTo(self);
    }];
    [self.micBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self.gameBtn);
        make.bottom.equalTo(self.gameBtn);
        make.trailing.equalTo(self.gameBtn.mas_leading).offset(-40);
    }];
    [self.hangupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self.gameBtn);
        make.bottom.equalTo(self.gameBtn);
        make.leading.equalTo(self.gameBtn.mas_trailing).offset(40);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(@0);
        make.height.greaterThanOrEqualTo(@0);
        make.bottom.equalTo(self.gameBtn.mas_top).offset(-17);
    }];

    [self.micContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@130);
        make.leading.equalTo(@58);
        make.trailing.equalTo(@-58);
        make.top.equalTo(self.suspendBtn.mas_bottom).offset(56);
    }];
    [self.leftMicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(@0);
        make.width.equalTo(@80);
        make.height.equalTo(@110);
    }];
    [self.rightMicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.equalTo(@0);
        make.width.equalTo(@80);
        make.height.equalTo(@110);
    }];

    [self.addRobotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.otherHeaderImageView.mas_bottom).offset(18);
        make.width.greaterThanOrEqualTo(@0);
        make.height.equalTo(@32);
        make.leading.equalTo(self.otherHeaderImageView);
    }];
    [self.myVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(@-16);
        make.top.equalTo(self.otherHeaderImageView);
        make.width.equalTo(@80);
        make.height.equalTo(@107);
    }];
}

- (void)dtConfigUI {
    [super dtConfigUI];
    self.timeLabel.text = @"00 : 00";
    self.bgImageView.image = [UIImage imageNamed:@"oneone_video_default_bg"];

}

- (void)dtUpdateUI {
    [super dtUpdateUI];
    if (self.otherMicModel.user) {
        NSString *icon = self.otherMicModel.user.icon;
        if (icon) {
            [self.otherHeaderImageView sd_setImageWithURL:[[NSURL alloc] initWithString:icon] placeholderImage:[UIImage imageNamed:@"oneone_video_head_default"]];
        }
        self.otherNameLabel.text = self.otherMicModel.user.name;
        if (self.otherMicModel.user.isRobot) {
            self.bgImageView.image = [UIImage imageNamed:@"oneone_video_robot_bg"];
        }
        self.addRobotView.hidden = YES;
    } else {
        self.otherHeaderImageView.image = [UIImage imageNamed:@"oneone_video_head_default"];
        self.otherNameLabel.text = @"等待对方加入";
        self.bgImageView.image = [UIImage imageNamed:@"oneone_video_default_bg"];
        self.addRobotView.hidden = NO;
    }
}

- (void)dtConfigEvents {
    [super dtConfigEvents];
    WeakSelf
    [self.hangupBtn addTarget:self action:@selector(onHangupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.gameBtn addTarget:self action:@selector(onGameBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.micBtn addTarget:self action:@selector(onMicBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *robotViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAddRobotViewTap:)];
    [self.addRobotView addGestureRecognizer:robotViewTap];
    self.leftMicView.micUserChangedBlock = ^(AudioRoomMicModel *micModel) {
        [weakSelf updateAddRobotViewPos];
    };
    self.rightMicView.micUserChangedBlock = ^(AudioRoomMicModel *micModel) {
        [weakSelf updateAddRobotViewPos];
    };
    self.leftMicView.onTapCallback = ^(AudioRoomMicModel *micModel) {
        [weakSelf handleMicClick:micModel];
    };
    self.rightMicView.onTapCallback = ^(AudioRoomMicModel *micModel) {
        [weakSelf handleMicClick:micModel];
    };

    [[NSNotificationCenter defaultCenter] addObserverForName:NTF_MIC_CHANGED object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *_Nonnull note) {
        RoomCmdUpMicModel *msgModel = note.userInfo[@"msgModel"];
        if ([msgModel isKindOfClass:RoomCmdUpMicModel.class]) {

            BOOL isSameMicUser = weakSelf.otherMicModel.user != nil && [msgModel.sendUser.userID isEqualToString:weakSelf.otherMicModel.user.userID];
            // 操作麦位与当前符合
            if (msgModel.micIndex == weakSelf.otherMicModel.micIndex) {
                DDLogDebug(@"NTF_MIC_CHANGED msg info:%@", [msgModel mj_JSONString]);
                if (msgModel.cmd == CMD_DOWN_MIC_NOTIFY) {
                    // 下麦,清空用户信息
                    if (isSameMicUser) {
                        weakSelf.otherMicModel.user = nil;
                    }
                } else {
                    weakSelf.otherMicModel.user = msgModel.sendUser;
                    weakSelf.otherMicModel.user.roleType = msgModel.roleType;
                    weakSelf.otherMicModel.streamID = msgModel.streamID;
                }
            } else if (isSameMicUser) {
                DDLogDebug(@"NTF_MIC_CHANGED msg info:%@", [msgModel mj_JSONString]);
                // 当前用户ID与切换用户ID一致，则清除掉
                weakSelf.otherMicModel.user = nil;
            }
            [weakSelf dtUpdateUI];
        } else {
            [weakSelf dtUpdateUI];
        }
    }];
}

- (void)handleMicClick:(AudioRoomMicModel *)micModel {
    if (micModel.user == nil) {
        /// 无人，上麦
        [kAudioRoomService reqSwitchMic:kAudioRoomService.currentRoomVC.roomID.integerValue micIndex:(int) micModel.micIndex handleType:0 proxyUser:nil success:nil fail:nil];
        return;
    }
}

- (void)updateAddRobotViewPos {
//    if (self.leftMicView.model.user && self.rightMicView.model.user) {
//        self.addRobotView.hidden = YES;
//        return;
//    }
//    if (self.rightMicView.model.user == nil) {
//        self.addRobotView.hidden = NO;
//
//    } else if (self.leftMicView.model.user == nil) {
//        self.addRobotView.hidden = NO;
//
//    }
}


- (void)onAddRobotViewTap:(id)tap {
    if (self.addRobotBlock) self.addRobotBlock();
}

- (void)onHangupBtnClick:(id)sender {
    if (self.hangupBlock) self.hangupBlock();
}

- (void)onGameBtnClick:(id)sender {
    if (self.selecteGameBlock) self.selecteGameBlock();
}

- (void)onMicBtnClick:(id)sender {
    self.micBtn.selected = !self.micBtn.selected;
    if (self.micStateChangedBlock) self.micStateChangedBlock(self.micBtn.selected ? OneOneVideoMicTypeOpen : OneOneVideoMicTypeClose);
}

- (void)onSpeakerBtnClick:(id)sender {

}

- (void)onRightUserHeadBtnClick:(id)sender {
    [self changeUIState:YES];
}

- (void)onLeftUserHeadBtnClick:(id)sender {
    [self changeUIState:NO];
}

/// 切换UI状态
/// @param isGameState 是否处于游戏中
- (void)changeUIState:(BOOL)isGameState {
    if (self.isGameState == isGameState) {
        return;
    }
    self.isGameState = isGameState;
    if (isGameState) {
        // 游戏状态UI
        [UIView animateWithDuration:0.25 animations:^{
            CGAffineTransform transScale = CGAffineTransformMakeScale(0.75, 0.75);
            CGFloat y = self.micContentView.mj_y - self.suspendBtn.mj_y + self.micContentView.mj_h * (1 - 0.75) / 2;
            CGAffineTransform transMove = CGAffineTransformMakeTranslation(0, -y);
            CGAffineTransform transGroup = CGAffineTransformConcat(transScale, transMove);
            self.micContentView.transform = transGroup;
            self.bottomCoverImageView.alpha = 1;
        }];

        [self.gameBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@32);
            make.bottom.equalTo(@(-kAppSafeBottom - 4));
            make.trailing.equalTo(@-17);
        }];
        [self.micBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(self.gameBtn);
            make.bottom.equalTo(self.gameBtn);
            make.leading.equalTo(@16);
        }];

        self.timeLabel.hidden = YES;
        self.gameBtn.backgroundColor = HEX_COLOR_A(@"#000000", 0.4);
        self.micBtn.backgroundColor = HEX_COLOR_A(@"#000000", 0.4);
        [self.gameBtn dt_cornerRadius:16];
        [self.micBtn dt_cornerRadius:16];

        [self.gameBtn setImage:[UIImage imageNamed:@"oneone_game_game"] forState:UIControlStateNormal];
        [self.micBtn setImage:[UIImage imageNamed:@"oneone_game_mic_close"] forState:UIControlStateNormal];
        [self.micBtn setImage:[UIImage imageNamed:@"room_voice_open_mic"] forState:UIControlStateSelected];

    } else {
        self.bottomCoverImageView.alpha = 0;
        self.timeLabel.hidden = NO;
        self.gameBtn.backgroundColor = nil;
        self.micBtn.backgroundColor = nil;

        [self.gameBtn dt_cornerRadius:0];
        [self.micBtn dt_cornerRadius:0];

        [self.gameBtn setImage:[UIImage imageNamed:@"oneone_game"] forState:UIControlStateNormal];
        [self.micBtn setImage:[UIImage imageNamed:@"oneone_mic_close"] forState:UIControlStateNormal];
        [self.micBtn setImage:[UIImage imageNamed:@"oneone_mic_open"] forState:UIControlStateSelected];

        [UIView animateWithDuration:0.25 animations:^{
            self.micContentView.transform = CGAffineTransformIdentity;
        }];
        [self.gameBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@64);
            make.bottom.equalTo(@(-kAppSafeBottom - 16));
            make.centerX.equalTo(self);
        }];
        [self.micBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(self.gameBtn);
            make.bottom.equalTo(self.gameBtn);
            make.trailing.equalTo(self.gameBtn.mas_leading).offset(-40);
        }];

    }
}

- (void)updateDuration:(NSInteger)duration {
    NSInteger minute = duration / 60;
    NSInteger second = duration - minute * 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld : %02ld", minute, second];
}

- (void)changeMicState:(OneOneVideoMicType)stateType {
    self.micStateType = stateType;
    self.micBtn.selected = stateType == OneOneVideoMicTypeOpen;
}


- (UIView *)micContentView {
    if (!_micContentView) {
        _micContentView = UIView.new;
    }
    return _micContentView;
}

- (UIButton *)suspendBtn {
    if (!_suspendBtn) {
        _suspendBtn = UIButton.new;
        [_suspendBtn setImage:[UIImage imageNamed:@"oneone_suspend"] forState:UIControlStateNormal];
    }
    return _suspendBtn;
}

- (UIButton *)hangupBtn {
    if (!_hangupBtn) {
        _hangupBtn = UIButton.new;
        [_hangupBtn setImage:[UIImage imageNamed:@"oneone_video_hangup"] forState:UIControlStateNormal];
    }
    return _hangupBtn;
}

- (UIButton *)micBtn {
    if (!_micBtn) {
        _micBtn = UIButton.new;
        [_micBtn setImage:[UIImage imageNamed:@"oneone_mic_close"] forState:UIControlStateNormal];
        [_micBtn setImage:[UIImage imageNamed:@"oneone_mic_open"] forState:UIControlStateSelected];
    }
    return _micBtn;
}

- (UIButton *)gameBtn {
    if (!_gameBtn) {
        _gameBtn = UIButton.new;
        [_gameBtn setImage:[UIImage imageNamed:@"oneone_game"] forState:UIControlStateNormal];
    }
    return _gameBtn;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = UILabel.new;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = UIFONT_SEMI_BOLD(24);
        _timeLabel.textColor = HEX_COLOR(@"#ffffff");
    }
    return _timeLabel;
}

- (UILabel *)otherNameLabel {
    if (!_otherNameLabel) {
        _otherNameLabel = UILabel.new;
        _otherNameLabel.font = UIFONT_REGULAR(14);
        _otherNameLabel.textColor = HEX_COLOR(@"#ffffff");
    }
    return _otherNameLabel;
}


- (UIView *)addRobotView {
    if (!_addRobotView) {
        _addRobotView = UIView.new;
        _addRobotView.backgroundColor = HEX_COLOR_A(@"#000000", 0.6);
        [_addRobotView dt_cornerRadius:4];
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"oneone_add_robot"]];
        UILabel *titleLabel = UILabel.new;
        titleLabel.font = UIFONT_MEDIUM(14);
        titleLabel.textColor = HEX_COLOR(@"#ffffff");
        titleLabel.text = @"添加机器人";
        [_addRobotView addSubview:iconImageView];
        [_addRobotView addSubview:titleLabel];
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@6);
            make.width.height.equalTo(@24);
            make.centerY.equalTo(_addRobotView);
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(iconImageView.mas_trailing).offset(8);
            make.width.height.greaterThanOrEqualTo(@0);
            make.centerY.equalTo(_addRobotView);
            make.trailing.equalTo(@-8);
        }];
    }
    return _addRobotView;
}

- (UIView *)myVideoView {
    if (!_myVideoView) {
        _myVideoView = UIView.new;
    }
    return _myVideoView;
}

- (UIView *)otherVideoView {
    if (!_otherVideoView) {
        _otherVideoView = UIView.new;
    }
    return _otherVideoView;
}

- (OneOneAudioMicroView *)leftMicView {
    if (!_leftMicView) {
        _leftMicView = OneOneAudioMicroView.new;
        _leftMicView.headWidth = 80;
    }
    return _leftMicView;
}

- (OneOneAudioMicroView *)rightMicView {
    if (!_rightMicView) {
        _rightMicView = OneOneAudioMicroView.new;
        _rightMicView.headWidth = 80;
    }
    return _rightMicView;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = UIImageView.new;
    }
    return _bgImageView;
}

- (UIImageView *)otherHeaderImageView {
    if (!_otherHeaderImageView) {
        _otherHeaderImageView = UIImageView.new;
        _otherHeaderImageView.image = [UIImage imageNamed:@"oneone_video_head_default"];
    }
    return _otherHeaderImageView;
}

- (UIImageView *)bottomCoverImageView {
    if (!_bottomCoverImageView) {
        _bottomCoverImageView = UIImageView.new;
        _bottomCoverImageView.image = [UIImage imageNamed:@"oneone_game_bottom_cover"];
        _bottomCoverImageView.alpha = 0;
    }
    return _bottomCoverImageView;
}

@end
