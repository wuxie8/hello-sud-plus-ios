//
//  RoomGiftPannelView.m
//  HelloSud-iOS
//
//  Created by Mary on 2022/1/21.
//

#import "RoomGiftPannelView.h"
#import "GiftUserCollectionViewCell.h"
#import "RoomGiftContentView.h"
#import "../../Base/VC/BaseSceneViewController+IM.h"
#import "GiftRocketEnterView.h"

@interface RoomGiftPannelView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) GiftRocketEnterView *rocketEnterView;
@property(nonatomic, strong) UIView *topView;
@property(nonatomic, strong) UILabel *sendToLabel;
@property(nonatomic, strong) YYLabel *coinLabel;
@property(nonatomic, strong) UIButton *checkAllBtn;
@property(nonatomic, strong) UIButton *sendBtn;
@property(nonatomic, strong) UIView *sendView;
@property(nonatomic, strong) UIView *lineView;
@property(nonatomic, strong) RoomGiftContentView *giftContentView;
@property(nonatomic, strong) DTBlurEffectView *blurView;
/// 选择用户
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray<AudioRoomMicModel *> *userDataList;
@property(nonatomic, assign) BOOL isFirstSelected;

/// 选中用户状态缓存
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *selectedCacheMap;
@end

@implementation RoomGiftPannelView

- (void)dtConfigUI {
    [super dtConfigUI];
    [self reqCoinData];
    [self setPartRoundCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadius:12];
}

- (void)dtAddViews {
    [self addSubview:self.blurView];
    [self addSubview:self.rocketEnterView];
    [self addSubview:self.topView];
    [self.topView addSubview:self.sendToLabel];
    [self.topView addSubview:self.checkAllBtn];
    [self.topView addSubview:self.lineView];
    [self.topView addSubview:self.collectionView];
    [self addSubview:self.giftContentView];
    [self addSubview:self.coinLabel];
    [self addSubview:self.sendView];
}

- (void)dtLayoutViews {
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView);
        make.leading.trailing.bottom.equalTo(@0);
    }];
    [self.rocketEnterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(0);
    }];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.equalTo(self.rocketEnterView.mas_bottom);
        make.height.mas_equalTo(0);
    }];
    [self.sendToLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.top.mas_equalTo(28);
        make.size.mas_greaterThanOrEqualTo(CGSizeZero);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.sendToLabel.mas_trailing).offset(10);
        make.top.mas_equalTo(self.topView);
        make.height.mas_equalTo(72);
        make.width.mas_greaterThanOrEqualTo(0);
        make.trailing.mas_equalTo(self.checkAllBtn.mas_leading).offset(-16);
    }];
    [self.checkAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-16);
        make.top.mas_equalTo(25);
        make.height.mas_equalTo(22);
        make.width.mas_greaterThanOrEqualTo(42);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.collectionView.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    [self.giftContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.topView.mas_bottom).offset(10);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    [self.sendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.giftContentView.mas_bottom).offset(24);
        make.trailing.mas_equalTo(-16);
        make.size.mas_equalTo(CGSizeMake(56 + 56, 32));
        make.bottom.mas_equalTo(-kAppSafeBottom - 8);
    }];
    [self.coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(@24);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@0);
        make.centerY.equalTo(self.sendView);
    }];
}

- (void)dtConfigEvents {
    [super dtConfigEvents];
    WeakSelf
    [[NSNotificationCenter defaultCenter] addObserverForName:NTF_MIC_CHANGED object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *_Nonnull note) {
        [weakSelf dtUpdateUI];
    }];

    self.giftContentView.didSelectedCallback = ^(GiftModel *giftModel) {
        if (giftModel.giftID == 9) {
            // 定制火箭
            if (!weakSelf.showRocket) {
                return;
            }
            [weakSelf.rocketEnterView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(80);
            }];
            [weakSelf dtRemoveRoundCorners];
        } else {
            [weakSelf.rocketEnterView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            [weakSelf setPartRoundCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadius:12];
        }

    };
    self.rocketEnterView.enterRocketBlock = ^{
        [DTSheetView close];
        if (weakSelf.enterRocketBlock) {
            weakSelf.enterRocketBlock();
        }
    };
}

/// 过滤麦位
/// @param micModel
/// @return
- (BOOL)skipMicModel:(AudioRoomMicModel *)micModel {
    // 弹幕场景，送礼列表中只展示房主
    if (kAudioRoomService.currentRoomVC.enterModel.sceneType == SceneTypeDanmaku && micModel.user.roleType != 1) {
        return YES;
    }
    return NO;
}

- (void)dtUpdateUI {
    NSArray *arrModel = kAudioRoomService.currentRoomVC.dicMicModel.allValues;
    NSMutableArray<AudioRoomMicModel *> *userList = NSMutableArray.new;
    NSMutableDictionary *tempSelectedCacheMap = NSMutableDictionary.new;
    for (AudioRoomMicModel *m in arrModel) {
        if (m.user != nil) {

            if ([self skipMicModel:m]) {
                continue;
            }

            [userList addObject:m];
            m.isSelected = NO;
            if (self.selectedCacheMap[m.user.userID]) {
                m.isSelected = YES;
                tempSelectedCacheMap[m.user.userID] = @(YES);
            }
        }
    }
    NSArray *sortArr = [userList sortedArrayUsingComparator:^NSComparisonResult(AudioRoomMicModel *_Nonnull obj1, AudioRoomMicModel *_Nonnull obj2) {
        return obj1.micIndex > obj2.micIndex;
    }];
    [self.userDataList setArray:sortArr];
    [self.selectedCacheMap setDictionary:tempSelectedCacheMap];


    if (self.userDataList.count > 0) {
        // 没有选中时，首次默认选中第一个
        if (self.selectedCacheMap.count == 0 && !self.isFirstSelected) {
            self.userDataList[0].isSelected = YES;
            self.isFirstSelected = YES;
            self.selectedCacheMap[self.userDataList[0].user.userID] = @(YES);
        }
        [self.topView setHidden:false];
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(72);
        }];
        AudioRoomMicModel *m = self.userDataList[0];
    } else {
        [self.topView setHidden:true];
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    [self.collectionView reloadData];
    [self updateAllSelectedState];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTF_SEND_GIFT_USER_CHANGED object:nil];
}

/// 加载场景礼物
/// @param gameId gameId
/// @param sceneId sceneId
- (void)loadSceneGift:(int64_t)gameId sceneId:(NSInteger)sceneId isAppend:(BOOL)isAppend {
    WeakSelf
    [GiftService reqGiftListWithGameId:gameId sceneId:sceneId finished:^(NSArray<GiftModel *> *modelList) {
        weakSelf.giftContentView.appendSceneGift = isAppend;
        weakSelf.giftContentView.sceneGiftList = modelList;
    }                          failure:nil];
}

- (void)setShowRocket:(BOOL)showRocket {
    _showRocket = showRocket;
    self.giftContentView.showRocket = showRocket;
    [self.giftContentView dtUpdateUI];
}


- (void)updateCoin:(NSInteger)coin {
    NSMutableAttributedString *full = [[NSMutableAttributedString alloc] init];
    full.yy_alignment = NSTextAlignmentCenter;


    UIImage *iconImage = [UIImage imageNamed:@"guess_award_coin"];
    NSMutableAttributedString *attrIcon = [NSAttributedString yy_attachmentStringWithContent:iconImage contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(14, 14) alignToFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular] alignment:YYTextVerticalAlignmentCenter];
    attrIcon.yy_firstLineHeadIndent = 8;
    [full appendAttributedString:attrIcon];

    NSNumber *number = @(coin);
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;
    formatter.positiveFormat = @"###,###";
    NSString *amountString = [formatter stringFromNumber:number];
    NSMutableAttributedString *attrAwardValue = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@  ", amountString]];
    attrAwardValue.yy_font = UIFONT_MEDIUM(14);
    attrAwardValue.yy_color = HEX_COLOR(@"#F6A209");
    [full appendAttributedString:attrAwardValue];

    self.coinLabel.attributedText = full;
}

- (void)reqCoinData {
    WeakSelf
    [UserService.shared reqUserCoinDetail:^(int64_t i) {
        [weakSelf updateCoin:i];
    }                                fail:^(NSString *errStr) {
        [ToastUtil show:errStr];
    }];
}

- (void)onBtnSend:(UIButton *)sender {

    NSMutableArray<AudioUserModel *> *arrWaitForSend = NSMutableArray.new;
    for (AudioRoomMicModel *m in self.userDataList) {
        if (m.isSelected && m.user != nil) {
            [arrWaitForSend addObject:m.user];
        }
    }
    if (arrWaitForSend.count == 0) {
        [ToastUtil show:NSString.dt_select_person];
        return;
    }
    if (!self.giftContentView.didSelectedGift) {
        [ToastUtil show:NSString.dt_select_gift];
        return;
    }
    GiftModel *giftModel = self.giftContentView.didSelectedGift;
    if (giftModel.giftID == kRocketGiftID) {
        NSMutableArray<AudioRoomMicModel *> *toMicList = NSMutableArray.new;
        for (AudioRoomMicModel *m in self.userDataList) {
            if (m.isSelected && m.user != nil) {
                [toMicList addObject:m];
            }
        }
        [self handleRocketGift:giftModel toMicList:toMicList];
    } else {
        for (AudioUserModel *user in arrWaitForSend) {

            AudioUserModel *toUser = user;
            RoomCmdSendGiftModel *giftMsg = [RoomCmdSendGiftModel makeMsgWithGiftID:giftModel.giftID giftCount:1 toUser:toUser];
            giftMsg.type = giftModel.type;
            giftMsg.giftUrl = giftModel.giftURL;
            giftMsg.animationUrl = giftModel.animateURL;
            giftMsg.giftName = giftModel.giftName;

            [kAudioRoomService.currentRoomVC sendMsg:giftMsg isAddToShow:YES finished:nil];
        }
    }
}

/// 处理火箭特殊礼物
/// @param giftModel
/// @param userList
- (void)handleRocketGift:(GiftModel *)giftModel toMicList:(NSArray<AudioRoomMicModel *> *)toMicList {
    [DTSheetView close];
    [kAudioRoomService.currentRoomVC handleRocketGift:giftModel toMicList:toMicList];
}

- (void)onCheckAllSelect:(UIButton *)sender {
    [self.checkAllBtn setSelected:!self.checkAllBtn.isSelected];

    for (AudioRoomMicModel *m in self.userDataList) {
        m.isSelected = self.checkAllBtn.isSelected ? true : false;
        if (m.user) {
            if (m.isSelected) {
                self.selectedCacheMap[m.user.userID] = @(YES);
            } else {
                [self.selectedCacheMap removeObjectForKey:m.user.userID];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NTF_SEND_GIFT_USER_CHANGED object:nil userInfo:@{@"micModel": m}];
    }
    [self.collectionView reloadData];
}


/// 更新全选状态
- (void)updateAllSelectedState {
    BOOL isAllSelected = YES;
    for (AudioRoomMicModel *m in self.userDataList) {
        if (!m.isSelected) {
            isAllSelected = NO;
            break;
        }
    }
    self.checkAllBtn.selected = isAllSelected;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.userDataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GiftUserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GiftUserCollectionViewCell" forIndexPath:indexPath];
    cell.model = self.userDataList[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.userDataList[indexPath.row].isSelected = !self.userDataList[indexPath.row].isSelected;
    [self.collectionView reloadData];
    AudioRoomMicModel *m = self.userDataList[indexPath.row];
    if (m.user && m.user.userID) {
        if (m.isSelected) {
            self.selectedCacheMap[m.user.userID] = @(YES);
        } else {
            [self.selectedCacheMap removeObjectForKey:m.user.userID];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NTF_SEND_GIFT_USER_CHANGED object:nil userInfo:@{@"micModel": m}];
    [self updateAllSelectedState];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.userDataList[indexPath.row].isSelected = !self.userDataList[indexPath.row].isSelected;
    [self.collectionView reloadData];
    AudioRoomMicModel *m = self.userDataList[indexPath.row];
    if (m.user && m.user.userID) {
        if (!m.isSelected) {
            [self.selectedCacheMap removeObjectForKey:m.user.userID];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NTF_SEND_GIFT_USER_CHANGED object:nil userInfo:@{@"micModel": m}];
    [self updateAllSelectedState];
}


#pragma mark - 懒加载

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(32, 72);
        flowLayout.minimumLineSpacing = 8;
        flowLayout.minimumInteritemSpacing = 10;
//        flowLayout.sectionInset = UIEdgeInsetsMake(20, 16, 16, 20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[GiftUserCollectionViewCell class] forCellWithReuseIdentifier:@"GiftUserCollectionViewCell"];
    }
    return _collectionView;
}

- (NSMutableArray *)userDataList {
    if (!_userDataList) {
        _userDataList = [NSMutableArray array];
    }
    return _userDataList;
}

- (NSMutableDictionary *)selectedCacheMap {
    if (!_selectedCacheMap) {
        _selectedCacheMap = NSMutableDictionary.new;
    }
    return _selectedCacheMap;
}

- (GiftRocketEnterView *)rocketEnterView {
    if (!_rocketEnterView) {
        _rocketEnterView = GiftRocketEnterView.new;
    }
    return _rocketEnterView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
    }
    return _topView;
}

- (YYLabel *)coinLabel {
    if (!_coinLabel) {
        _coinLabel = [[YYLabel alloc] init];
    }
    return _coinLabel;
}

- (UILabel *)sendToLabel {
    if (!_sendToLabel) {
        _sendToLabel = [[UILabel alloc] init];
        _sendToLabel.text = NSString.dt_send;
        _sendToLabel.textColor = [UIColor dt_colorWithHexString:@"#FFFFFF" alpha:1];
        _sendToLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    }
    return _sendToLabel;
}

- (UIButton *)checkAllBtn {
    if (!_checkAllBtn) {
        _checkAllBtn = [[UIButton alloc] init];
        [_checkAllBtn setTitle:NSString.dt_common_select_all forState:UIControlStateNormal];
        [_checkAllBtn setTitle:NSString.dt_common_cancel forState:UIControlStateSelected];
        [_checkAllBtn setTitleColor:[UIColor dt_colorWithHexString:@"#000000" alpha:1] forState:UIControlStateNormal];
        _checkAllBtn.titleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
        _checkAllBtn.backgroundColor = [UIColor dt_colorWithHexString:@"#FFFFFF" alpha:1];
        [_checkAllBtn addTarget:self action:@selector(onCheckAllSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkAllBtn;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [[UIButton alloc] init];
        [_sendBtn setTitle:NSString.dt_send_gift forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor dt_colorWithHexString:@"#000000" alpha:1] forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _sendBtn.backgroundColor = [UIColor dt_colorWithHexString:@"#FFFFFF" alpha:1];
        [_sendBtn addTarget:self action:@selector(onBtnSend:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (UIView *)sendView {
    if (!_sendView) {
        _sendView = [[UIView alloc] init];
        _sendView.backgroundColor = [UIColor blackColor];
        _sendView.layer.borderWidth = 1;
        _sendView.layer.borderColor = [UIColor dt_colorWithHexString:@"#FFFFFF" alpha:1].CGColor;
        _sendView.layer.masksToBounds = true;

        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.text = @"x1";
        numLabel.textColor = [UIColor dt_colorWithHexString:@"#FFFFFF" alpha:1];
        numLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];

        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"room_gift_send_num"]];
        [_sendView addSubview:numLabel];
        [_sendView addSubview:iconView];
        [_sendView addSubview:self.sendBtn];

        [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(15);
            make.centerY.mas_equalTo(_sendView);
            make.size.mas_greaterThanOrEqualTo(CGSizeZero);
        }];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(numLabel.mas_trailing).offset(5);
            make.centerY.mas_equalTo(_sendView);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
        [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(54);
            make.top.trailing.bottom.mas_equalTo(_sendView);
            make.width.mas_equalTo(56);
        }];
    }
    return _sendView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor dt_colorWithHexString:@"#FFFFFF" alpha:0.1];
    }
    return _lineView;
}

- (RoomGiftContentView *)giftContentView {
    if (!_giftContentView) {
        _giftContentView = [[RoomGiftContentView alloc] init];
    }
    return _giftContentView;
}

- (DTBlurEffectView *)blurView {
    if (_blurView == nil) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurView = [[DTBlurEffectView alloc] initWithEffect:effect];
        _blurView.blurLevel = 0.35;
        _blurView.backgroundColor = HEX_COLOR_A(@"#000000", 0.7);
    }
    return _blurView;
}

@end
