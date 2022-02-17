//
//  AudioRoomViewController.m
//  HelloSud-iOS
//
//  Created by Mary on 2022/1/21.
//

#import "AudioRoomViewController.h"
#import "AudioRoomViewController+IM.h"
#import "AudioRoomViewController+Game.h"

/// View
#import "RoomNaviView.h"
#import "RoomOperatorView.h"
#import "RoomMsgBgView.h"
#import "RoomMsgTableView.h"
#import "AudioMicContentView.h"
#import "RoomInputView.h"
#import "GameMicContentView.h"
#import "AudioMicroView.h"
#import "MicOperateView.h"
#import "RoomGiftPannelView.h"

@interface AudioRoomViewController () <BDAlphaPlayerMetalViewDelegate>
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) RoomNaviView *naviView;
@property (nonatomic, strong) RoomOperatorView *operatorView;
@property (nonatomic, strong) RoomMsgBgView *msgBgView;
@property (nonatomic, strong) RoomMsgTableView *msgTableView;
@property (nonatomic, strong) AudioMicContentView *audioMicContentView;
@property (nonatomic, strong) GameMicContentView *gameMicContentView;
@property (nonatomic, strong) RoomInputView *inputView;
/// 主播视图列表
@property (nonatomic, strong) NSArray <AudioMicroView *> *arrAnchorView;

@end

@implementation AudioRoomViewController

- (BOOL)dtIsHidenNavigationBar {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AudioRoomManager.shared.currentRoomVC = self;
    [self loginRoom];
//    [self sendEnterRoomMsg];
    if (self.gameId > 0) {
        self.gameInfoModel.currentPlayerUserId = AppManager.shared.loginUserInfo.userID;
        [self loginGame];
    }
    [self dtUpdateUI];
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

- (void)dtAddViews {
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.gameView];
    [self.view addSubview:self.naviView];
    [self.view addSubview:self.operatorView];
    [self.view addSubview:self.audioMicContentView];
    [self.view addSubview:self.gameMicContentView];
    [self.view addSubview:self.msgBgView];
    [self.msgBgView addSubview:self.msgTableView];
    [self.view addSubview:self.inputView];
}

- (void)dtLayoutViews {
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self.naviView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.mas_equalTo(kStatusBarHeight);
        make.height.mas_equalTo(44);
    }];
    [self.operatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(-kAppSafeBottom);
        make.height.mas_equalTo(44);
    }];
    [self.audioMicContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.naviView.mas_bottom).offset(20);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    [self.gameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.gameMicContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.naviView.mas_bottom).offset(20);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(55);
    }];
    [self.msgBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.audioMicContentView.mas_bottom);
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.operatorView.mas_top).offset(0);
    }];
    [self.msgTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.msgBgView);
    }];
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(80);
    }];
}

- (void)dtConfigEvents {
    WeakSelf
    self.operatorView.giftTapBlock = ^(UIButton *sender) {
        [DTSheetView show:[[RoomGiftPannelView alloc] init] rootView:AppUtil.currentWindow onCloseCallback:^{
            [weakSelf.operatorView resetAllSelectedUser];
        }];
    };
    self.operatorView.inputTapBlock = ^(UITapGestureRecognizer *gesture) {
        [weakSelf.inputView hsBecomeFirstResponder];
    };
    self.operatorView.voiceTapBlock = ^(UIButton *sender) {
        // 上麦点击
        [weakSelf handleTapVoice];
    };
    self.inputView.inputMsgBlock = ^(NSString * _Nonnull msg) {
        // 发送公屏消息
        RoomCmdChatTextModel *m = [RoomCmdChatTextModel makeMsg:msg];
        [weakSelf sendMsg:m isAddToShow:YES];
    };
    if (self.roomType == HSAudioMic) {
        self.audioMicContentView.updateMicArrCallBack = ^(NSArray<AudioMicroView *> * _Nonnull micArr) {
            weakSelf.arrAnchorView = micArr;
        };
    } else if (self.roomType == HSGameMic) {
        self.gameMicContentView.updateMicArrCallBack = ^(NSArray<AudioMicroView *> * _Nonnull micArr) {
            weakSelf.arrAnchorView = micArr;
        };
    }
    self.audioMicContentView.onTapCallback = ^(AudioRoomMicModel * _Nonnull micModel) {
        /// 麦位点击回调
        [weakSelf handleMicTap:micModel];
    };
    self.gameMicContentView.onTapCallback = ^(AudioRoomMicModel * _Nonnull micModel) {
        /// 麦位点击回调
        [weakSelf handleMicTap:micModel];
    };
    self.naviView.closeTapBlock = ^(UIButton *sender) {
        [DTAlertView showTextAlert:@"确认离开当前房间吗" sureText:@"确定" cancelText:@"取消" onSureCallback:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                // 如果在麦位上，则下麦
                if (AudioRoomManager.shared.micIndex >= 0) {
                    [AudioRoomManager.shared reqSwitchMic:weakSelf.roomID.integerValue micIndex:(int)AudioRoomManager.shared.micIndex handleType:1 success:^{
                        [weakSelf handleExitRoom];
                    } fail:^(NSError *error) {
                        [weakSelf handleExitRoom];
                    }];
                } else {
                    [weakSelf handleExitRoom];
                }
            });
        } onCloseCallback:^{
        }];
    };
    self.naviView.changeRoomTapBlock = ^(UITapGestureRecognizer *gesture) {
        SwitchRoomModeView *modeView = [[SwitchRoomModeView alloc] init];
        [modeView reloadData:weakSelf.roomType == HSAudio];
        [DTSheetView show:modeView rootView:AppUtil.currentWindow onCloseCallback:^{
        }];
        modeView.onTapGameCallBack = ^(HSGameItem * _Nonnull m) {
            [DTSheetView close];
            if (weakSelf.gameInfoModel.gameState == 2) {
                [ToastUtil show:@"正在游戏中, 无法切换游戏"];
                return;
            }
            [weakSelf handleChangeRoomMode:m];
        };
    };
}

- (void)dtUpdateUI {
    [self.naviView dtUpdateUI];
}

/// 退出房间
- (void)handleExitRoom {
    [AudioRoomManager.shared reqExitRoom:self.roomID.longLongValue];
    [self logoutRoom];
    [AppUtil.currentViewController.navigationController popViewControllerAnimated:true];
}

/// 处理切换房间
/// @param m m description
- (void)handleChangeRoomMode:(HSGameItem *)m {
    WeakSelf
    [AudioRoomManager.shared reqSwitchGame:self.roomID.integerValue gameId:m.gameId success:^{
        
        RoomCmdChangeGameModel *msg = nil;
        if (m.isAudioRoom) {
            weakSelf.roomType = HSAudio;
            msg = [RoomCmdChangeGameModel makeMsg:0];
        } else if(m.gameId > 0) {
            msg = [RoomCmdChangeGameModel makeMsg:m.gameId];
            [weakSelf handleGameChange:m.gameId];
        }
        // 发送游戏切换给其它用户
        if (msg) {
            [weakSelf sendMsg:msg isAddToShow:false];
        }
    } fail:^(NSError *error) {
        NSLog(@"reqSwitchGame error:%@", error.debugDescription);
    }];
    
}

/// 处理麦位点击
/// @param micModel micModel description
- (void)handleMicTap:(AudioRoomMicModel *)micModel {
    if (micModel.user == nil) {
        /// 无人，上麦
        [AudioRoomManager.shared reqSwitchMic:self.roomID.integerValue micIndex:(int)micModel.micIndex handleType:0 success:nil fail:nil];
        return;
    } else if ([AppManager.shared.loginUserInfo isMeByUserID:micModel.user.userID]) {
        // 是自己或者房主
        MicOperateView *v = MicOperateView.new;
        v.downMicCallback = ^(UIButton *sender) {
            // 下麦
            [AudioRoomManager.shared reqSwitchMic:self.roomID.integerValue micIndex:(int)micModel.micIndex handleType:1 success:nil fail:nil];
            [DTSheetView close];
        };
        v.cancelCallback = ^(UIButton *sender) {
            [DTSheetView close];
        };
        [DTSheetView show:v rootView:self.view onCloseCallback:^{
                    
        }];
    }
}

- (void)handleTapVoice {
    switch (self.operatorView.voiceBtnState) {
        case VoiceBtnStateTypeNormal:{
            // 请求上麦
            NSArray *o_arr = self.dicMicModel.allValues;
            /// 重新排序
            NSArray *arr = [o_arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                AudioRoomMicModel *model1 = obj1;
                AudioRoomMicModel *model2 = obj2;
                if (model1.micIndex > model2.micIndex){
                    return NSOrderedDescending;
                } else if (model1.micIndex < model2.micIndex){
                    return NSOrderedAscending;
                } else {
                    return NSOrderedAscending;
                }
            }];
            
            AudioRoomMicModel *emptyModel = nil;
            for (AudioRoomMicModel *m in arr) {
                if (m.user == nil) {
                    emptyModel = m;
                    break;
                }
            }
            if (emptyModel == nil) {
                [ToastUtil show:@"没有空麦位"];
                return;
            }
            self.operatorView.voiceBtnState = VoiceBtnStateTypeWaitOpen;
            [self handleMicTap:emptyModel];
        }
            break;
        case VoiceBtnStateTypeWaitOpen:{
            
            // 开启声音
            [DeviceUtil checkMicAuth:^(BOOL isAuth) {
                if (isAuth) {
                    self.operatorView.voiceBtnState = VoiceBtnStateTypeOnVoice;
                    [self startPublish:[NSString stringWithFormat:@"%u", arc4random()]];
                } else {
                    // 提示开启权限
                    [DTAlertView showTextAlert:@"无法访问麦克风，请到“设置-隐私“中开启麦克风访问权限" sureText:@"去开启" cancelText:@"暂时不用" onSureCallback:^{
                        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        if (url && [[UIApplication sharedApplication]canOpenURL:url]) {
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    } onCloseCallback:nil];
                }
            }];
        }
            break;
        case VoiceBtnStateTypeOnVoice:
            // 关闭声音
            self.operatorView.voiceBtnState = VoiceBtnStateTypeWaitOpen;
            [self stopPublish];
            break;
            
        default:
            break;
    }
    
}

/// 展示公屏消息
/// @param msg 消息体
/// @param isShowOnScreen 是否展示公屏
- (void)addMsg:(RoomBaseCMDModel *)msg isShowOnScreen:(BOOL)isShowOnScreen {
    if (isShowOnScreen) {    
        [self.msgTableView addMsg:msg];
    }
    if ([msg isKindOfClass:RoomCmdUpMicModel.class]) {
        [self handleMicChanged:(RoomCmdUpMicModel *)msg];
    } else if ([msg isKindOfClass:RoomCmdSendGiftModel.class]) {
        [self handleGiftEffect:(RoomCmdSendGiftModel *)msg];
    }
}

/// 处理麦位变化
/// @param model model description
- (void)handleMicChanged:(RoomCmdUpMicModel *)model {
    // 通知麦位变化
    [[NSNotificationCenter defaultCenter]postNotificationName:NTF_MIC_CHANGED object:nil userInfo:@{@"msgModel": model}];
}

/// 处理礼物动效
/// @param model model description
- (void)handleGiftEffect:(RoomCmdSendGiftModel *)model {
    GiftModel *giftModel = [GiftManager.shared giftByID:model.giftID];
    if (!giftModel) {
        NSLog(@"No exist the gift info:%ld", model.giftID);
        return;
    }
    if ([giftModel.animateType isEqualToString:@"svga"]) {
        DTSVGAPlayerView *v = DTSVGAPlayerView.new;
        NSURL *url = [NSURL fileURLWithPath: giftModel.animateURL];
        [v setURL:url];
        [self.view addSubview:v];
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.height.equalTo(self.view.mas_width);
            make.center.equalTo(self.view);
        }];
        __weak UIView *weakV = v;
        [v play:1 didFinished:^{
            [weakV removeFromSuperview];
        }];
    } else if ([giftModel.animateType isEqualToString:@"lottie"]) {
        NSURL *url = [NSURL fileURLWithPath: giftModel.animateURL];
        
        LOTAnimationView *v = [[LOTAnimationView alloc] initWithContentsOfURL:url];
        [self.view addSubview:v];
        
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.height.equalTo(self.view.mas_width);
            make.center.equalTo(self.view);
        }];
        __weak UIView *weakV = v;
        [v playWithCompletion:^(BOOL animationFinished) {
            [weakV removeFromSuperview];
        }];
    } else if ([giftModel.animateType isEqualToString:@"webp"]) {
//        [[SDWebImageDownloader sharedDownloader] setValue:@"image/webp,image/*,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
//        SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
//        [[SDImageCodersManager sharedManager] addCoder:webPCoder];
        
        NSData *webpData = [NSData dataWithContentsOfFile:giftModel.animateURL];
        UIImage *wimage = [[SDImageWebPCoder sharedCoder] decodedImageWithData:webpData options:nil];
        
        UIImageView *v = [[UIImageView alloc] initWithImage:wimage];
        [self.view addSubview:v];
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.height.equalTo(self.view.mas_width);
            make.center.equalTo(self.view);
        }];
        __weak UIView *weakV = v;
        dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
        dispatch_after(timer, dispatch_get_main_queue(), ^(void){
            [weakV removeFromSuperview];
        });
    } else if ([giftModel.animateType isEqualToString:@"mp4"]) {
        BDAlphaPlayerMetalView *v = [[BDAlphaPlayerMetalView alloc] initWithDelegate: self];
        [self.view addSubview:v];
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
        BDAlphaPlayerMetalConfiguration *configuration = [BDAlphaPlayerMetalConfiguration defaultConfiguration];
        configuration.directory = giftModel.animateURL;
        configuration.renderSuperViewFrame = self.view.frame;
        configuration.orientation = BDAlphaPlayerOrientationPortrait;

        [v playWithMetalConfiguration:configuration];
    }
}

/// 同步麦位列表
- (void)reqMicList {
    WeakSelf
    [AudioRoomManager.shared reqMicList:self.roomID.integerValue success:^(NSArray<HSRoomMicList *> * _Nonnull micList) {
        [weakSelf handleMicList:micList];
    } fail:^(NSError *error) {
    }];
}

- (void)handleMicList:(NSArray<HSRoomMicList *> *)micList {
    NSMutableArray<NSNumber *> *arrUserID = NSMutableArray.new;
    for (HSRoomMicList *m in micList) {
        [arrUserID addObject:[NSNumber numberWithInteger:m.userId]];
    }
    // 缓存用户信息
    [UserManager.shared asyncCacheUserInfo:arrUserID finished:^{
        for (HSRoomMicList *m in micList) {
            NSString *key = [NSString stringWithFormat:@"%ld",m.micIndex];
            AudioRoomMicModel *micModel = self.dicMicModel[key];
            HSUserInfoModel *userInfo = [UserManager.shared getCacheUserInfo:m.userId];
            if (micModel) {
                if (!micModel.user) {
                    micModel.user = AudioUserModel.new;
                }
                micModel.user.roleType = m.roleType;
                micModel.user.userID = [NSString stringWithFormat:@"%ld", m.userId];
                if (userInfo) {
                    micModel.user.name = userInfo.nickname;
                    micModel.user.icon = userInfo.avatar;
                    micModel.user.sex = [userInfo.gender isEqualToString:@"male"] ? 1 : 2;
                }
            }
        }
        [NSNotificationCenter.defaultCenter postNotificationName:NTF_MIC_CHANGED object:nil];
    }];

}

#pragma mark setter
- (void)setRoomType:(RoomType)roomType {
    _roomType = roomType;
    if (self.roomType == HSAudioMic) {
        /// 销毁游戏
        [self logoutGame];
        [self.gameMicContentView setHidden:true];
        [self.audioMicContentView setHidden:false];
        self.gameView.hidden = YES;
        [self.msgBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.audioMicContentView.mas_bottom);
            make.left.right.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.operatorView.mas_top).offset(-20);
            make.height.mas_greaterThanOrEqualTo(0);
        }];
        [self.dicMicModel removeAllObjects];
        for (AudioMicroView *v in self.audioMicContentView.micArr) {
            NSString *key = [NSString stringWithFormat:@"%ld", v.model.micIndex];
            self.dicMicModel[key] = v.model;
            v.micType = HSAudioMic;
        }
        GameManager.shared.captainUserId = @"";
        GameManager.shared.gameId = 0;
    } else if (self.roomType == HSGameMic) {
        self.gameView.hidden = NO;
        [self.gameMicContentView setHidden:false];
        [self.audioMicContentView setHidden:true];
        [self.msgBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.operatorView.mas_top);
            make.height.mas_equalTo(106);
        }];
        [self.dicMicModel removeAllObjects];
        for (AudioMicroView *v in self.gameMicContentView.micArr) {
            NSString *key = [NSString stringWithFormat:@"%ld", v.model.micIndex];
            self.dicMicModel[key] = v.model;
            v.micType = HSGameMic;
        }
    }
    [self reqMicList];
}

#pragma mark lazy

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.image = [UIImage imageNamed:@"room_bg"];
    }
    return _bgImageView;
}

- (RoomNaviView *)naviView {
    if (!_naviView) {
        _naviView = [[RoomNaviView alloc] init];
    }
    return _naviView;
}

- (RoomOperatorView *)operatorView {
    if (!_operatorView) {
        _operatorView = [[RoomOperatorView alloc] init];
    }
    return _operatorView;
}

- (RoomMsgBgView *)msgBgView {
    if (!_msgBgView) {
        _msgBgView = [[RoomMsgBgView alloc] init];
    }
    return _msgBgView;
}

- (RoomMsgTableView *)msgTableView {
    if (!_msgTableView) {
        _msgTableView = [[RoomMsgTableView alloc] init];
    }
    return _msgTableView;
}

- (AudioMicContentView *)audioMicContentView {
    if (!_audioMicContentView) {
        _audioMicContentView = [[AudioMicContentView alloc] init];
    }
    return _audioMicContentView;
}

- (RoomInputView *)inputView {
    if (!_inputView) {
        _inputView = [[RoomInputView alloc] init];
    }
    return _inputView;
}

- (GameMicContentView *)gameMicContentView {
    if (!_gameMicContentView) {
        _gameMicContentView = [[GameMicContentView alloc] init];
    }
    return _gameMicContentView;
}

- (UIView *)gameView {
    if (_gameView == nil) {
        _gameView = UIView.new;
    }
    return _gameView;
}

- (NSMutableDictionary *)dicMicModel {
    if (_dicMicModel == nil) {
        _dicMicModel = NSMutableDictionary.new;
    }
    return _dicMicModel;
}

- (RoomGameInfoModel *)gameInfoModel {
    if (_gameInfoModel == nil) {
        _gameInfoModel = RoomGameInfoModel.new;
        _gameInfoModel.language = @"zh-CN";
    }
    return _gameInfoModel;
}

- (void)setIsEnteredRoom:(BOOL)isEnteredRoom {
    [self.fsm2MGManager sendComonSelfIn:_isEnteredRoom seatIndex:-1 isSeatRandom:true teamId:1];
}

- (void)setRoomName:(NSString *)roomName {
    _roomName = roomName;
    self.naviView.roomNameLabel.text = roomName;
}

- (void)setGameId:(NSInteger)gameId {
    _gameId = gameId;
    GameManager.shared.gameId = gameId;
}

- (void)dealloc {
    [self logoutGame];
}

#pragma mark - BDAlphaPlayerMetalViewDelegate
- (void)metalView:(nonnull BDAlphaPlayerMetalView *)metalView didFinishPlayingWithError:(nonnull NSError *)error {
    [metalView removeFromSuperview];
}

@end
