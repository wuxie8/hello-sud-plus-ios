//
//  HSSettingViewController.m
//  HelloSud-iOS
//
//  Created by kaniel on 2022/1/20.
//

#import "QuickStartViewController.h"
#import "../Model/HSSettingModel.h"
#import "ChangeRTCViewController.h"
#import "../View/MyHeaderView.h"
#import "../View/BindWalletStateView.h"
#import "CNAuthViewController.h"
#import "../View/MyCNWalletSwitchPopView.h"
#import "../View/CNWalletSelectPopView.h"
#import "../View/CNWalletDeletePopView.h"
#import "../View/ForeignWalletSelectPopView.h"
#import "../View/WalletDeletePopView.h"

// TODO: 申请APP ID
#define SUDNFT_APP_ID          @"1486637108889305089"
// TODO: 申请APP KEY
#define SUDNFT_APP_KEY         @"wVC9gUtJNIDzAqOjIVdIHqU3MY6zF6SR"
// TODO: APP 配置universal link 有则填，无暂可为空
#define APP_UNIVERSAL_LINK  @"https://links.sud.tech"

@interface QuickStartViewController () <ISudNFTListenerBindWallet>

/// 页面数据
@property(nonatomic, strong) NSArray <NSArray <HSSettingModel *> *> *arrData;
@property(nonatomic, strong) MyHeaderView *myHeaderView;
@property(nonatomic, strong) NSArray<SudNFTWalletInfoModel *> *walletList;
@property(nonatomic, strong) UIView *contactUsView;
@property(nonatomic, weak) BindWalletStateView *bindWalletStateView;
/// 等待绑定钱包信息
@property(nonatomic, strong) SudNFTWalletInfoModel *waitBindWalletInfo;
/// 是否已经初始化
@property(nonatomic, assign) BOOL isNFTInited;
/// 是否初始化失败
@property(nonatomic, assign) BOOL isNFTInitedError;

@end

@implementation QuickStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 配置顶部tableview不留出状态栏
    if (@available(iOS 11.0, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self configData];
    [self configSudNFT];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isNFTInited) {
        [self checkWalletInfo];
    } else if (self.isNFTInitedError) {
        [self configSudNFT];
    }
}

- (void)configSudNFT {
    BOOL isTestEnv = NO;
#if DEBUG
//    [ISudNFTD e:2];
    isTestEnv = YES;
#endif
    NSString *sudNFTSDKVersoin = [SudNFT getVersion];
    NSLog(@"sudNFTSDKVersoin:%@", sudNFTSDKVersoin);

    SudInitNFTParamModel *paramModel = SudInitNFTParamModel.new;
    paramModel.appId = SUDNFT_APP_ID;
    paramModel.appKey = SUDNFT_APP_KEY;
    paramModel.universalLink = APP_UNIVERSAL_LINK;
    paramModel.isTestEnv = isTestEnv;
    paramModel.userId = HsNFTPreferences.shared.userId;
    WeakSelf
    [SudNFT initNFT:paramModel
           listener:^(NSInteger errCode, NSString *_Nullable errMsg) {
               if (errCode != 0) {
                   DDLogError(@"initNFT: errCode:%@, errMsg:%@", @(errCode), errMsg);
                   // SDK初始失败，重试或者提示错误
                   weakSelf.isNFTInitedError = YES;
                   return;
               }
               weakSelf.isNFTInited = YES;
               DDLogError(@"onSudNFTInitStateChanged init success");
               [weakSelf checkWalletInfo];
           }];
}

- (BOOL)dtIsHiddenNavigationBar {
    return YES;
}

/// 配置页面数据
- (void)configData {


}

- (void)checkWalletInfo {

    BOOL bindWallet = HsNFTPreferences.shared.isBindWallet;
    if (!bindWallet) {
        [self.myHeaderView removeTipView];
        // 未绑定钱包
        if (self.walletList.count > 0) {
            [self.myHeaderView updateSupportWallet:self.walletList];
            [self reloadHeadView];
            return;
        }
        [SudNFT getWalletList:^(NSInteger errCode, NSString *errMsg, SudNFTGetWalletListModel *getWalletListModel) {
            if (errCode != 0) {
                NSString *msg = [HsNFTPreferences.shared nftErrorMsg:errCode errorMsg:errMsg];
                [ToastUtil show:msg];
                return;
            }
            self.walletList = getWalletListModel.walletList;
            HsNFTPreferences.shared.walletList = self.walletList;
            [self.myHeaderView updateSupportWallet:getWalletListModel.walletList];
            [self reloadHeadView];
        }];
        return;
    }
    // 拉取NFT列表
    if (HsNFTPreferences.shared.isBindForeignWallet) {
        [self getNFTList];
    } else if (HsNFTPreferences.shared.isBindCNWallet) {
        [self getCNCollectionList];
    }
    // 更新链网数据
    if (self.walletList.count == 0) {
        [SudNFT getWalletList:^(NSInteger errCode, NSString *errMsg, SudNFTGetWalletListModel *getWalletListModel) {
            if (errCode != 0) {
                NSString *msg = [HsNFTPreferences.shared nftErrorMsg:errCode errorMsg:errMsg];
                [ToastUtil show:msg];
                return;
            }
            self.walletList = getWalletListModel.walletList;
            HsNFTPreferences.shared.walletList = self.walletList;
            [self updateWalletEtherChains];
            [self.myHeaderView updateSupportWallet:getWalletListModel.walletList];
        }];
    } else {
        [self updateWalletEtherChains];
    }
    [self.myHeaderView showTipIfNeed];
}

/// 获取NFT列表
- (void)getNFTList {
    SudNFTGetNFTListParamModel *paramModel = SudNFTGetNFTListParamModel.new;
    paramModel.walletToken = HsNFTPreferences.shared.currentWalletToken;
    paramModel.walletAddress = HsNFTPreferences.shared.currentWalletAddress;
    paramModel.chainType = HsNFTPreferences.shared.selectedEthereumChainType;
    paramModel.pageKey = nil;
    [SudNFT getNFTList:paramModel listener:^(NSInteger errCode, NSString *errMsg, SudNFTGetNFTListModel *nftListModel) {
        if (errCode != 0) {
            NSString *msg = [HsNFTPreferences.shared nftErrorMsg:errCode errorMsg:errMsg];
            [ToastUtil show:msg];
            [HsNFTPreferences.shared handleFilterNftError:errCode errMsg:errMsg];
            [self.myHeaderView updateNFTList:nil];
            return;
        }
        HsNFTPreferences.shared.nftListPageKey = nftListModel.pageKey;
        [self.myHeaderView updateNFTList:nftListModel];
        [self reloadHeadView];
    }];
}

/// 获取国内收藏品
- (void)getCNCollectionList {
    SudNFTGetCnNFTListParamModel *paramModel = SudNFTGetCnNFTListParamModel.new;
    paramModel.pageSize = 20;
    paramModel.pageNumber = 0;
    paramModel.walletType = HsNFTPreferences.shared.currentWalletType;
    paramModel.walletToken = [HsNFTPreferences.shared getBindUserTokenByWalletType:paramModel.walletType];
    [SudNFT getCnNFTList:paramModel listener:^(NSInteger errCode, NSString *errMsg, SudNFTGetCnNFTListModel *resp) {
        if (errCode != 0) {
            NSString *msg = [HsNFTPreferences.shared nftErrorMsg:errCode errorMsg:errMsg];
            [ToastUtil show:msg];
            [HsNFTPreferences.shared handleFilterNftError:errCode errMsg:errMsg];
            [self.myHeaderView updateCardList:nil];
            return;
        }
        [self.myHeaderView updateCardList:resp];
        [self reloadHeadView];
    }];
}

/// 更新钱包链网类型
- (void)updateWalletEtherChains {
    for (SudNFTWalletInfoModel *m in self.walletList) {
        if (m.type == HsNFTPreferences.shared.currentWalletType) {
            [self.myHeaderView updateEthereumList:m.chainList];
            break;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_NFT_WALLET_LIST_UPDATE_NTF object:nil userInfo:nil];
    [self reloadHeadView];
}

- (void)reloadHeadView {


}

- (void)dtAddViews {
    [super dtAddViews];
    self.view.backgroundColor = HEX_COLOR(@"#F5F6FB");
    [self.view addSubview:self.myHeaderView];

}

- (void)dtLayoutViews {
    [super dtLayoutViews];
    [self.myHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.equalTo(@16);
        make.trailing.equalTo(@-16);
    }];


    [self reloadHeadView];
}

- (void)dtConfigEvents {
    [super dtConfigEvents];
    WeakSelf
    self.myHeaderView.clickWalletBlock = ^(SudNFTWalletInfoModel *m) {

        if (m.zoneType == 1) {
            [weakSelf handleCNWalletClick:m selectView:nil];
            return;
        }
        [weakSelf handleWalletClick:m selectView:nil];

    };
    self.myHeaderView.deleteWalletBlock = ^{
        if (HsNFTPreferences.shared.bindZoneType == 1) {
            // 绑定的是国内
            CNWalletSelectPopView *v = CNWalletSelectPopView.new;
            __weak typeof(v) weakV = v;
            v.selectedWalletBlock = ^(SudNFTWalletInfoModel *walletInfoModel) {
                [weakSelf handleCNWalletClick:walletInfoModel selectView:weakV];
            };
            [DTSheetView show:v onCloseCallback:nil];
            [DTSheetView addPanGesture];
            NSMutableArray *cnWalletList = NSMutableArray.new;
            for (SudNFTWalletInfoModel *m in weakSelf.walletList) {
                if (m.zoneType == 1) {
                    [cnWalletList addObject:m];
                }
            }
            [v updateDataList:cnWalletList];
            return;
        }
        // 海外
        ForeignWalletSelectPopView *v = ForeignWalletSelectPopView.new;
        __weak ForeignWalletSelectPopView * weakV = v;
        v.selectedWalletBlock = ^(SudNFTWalletInfoModel *walletInfoModel) {
            [weakSelf handleWalletClick:walletInfoModel selectView:weakV];
        };
        [DTSheetView show:v onCloseCallback:nil];
        [DTSheetView addPanGesture];
        NSMutableArray *walletList = NSMutableArray.new;
        for (SudNFTWalletInfoModel *m in weakSelf.walletList) {
            if (m.zoneType == 0) {
                [walletList addObject:m];
            }
        }
        [v updateDataList:walletList];
    };

    [[NSNotificationCenter defaultCenter] addObserverForName:MY_ETHEREUM_CHAINS_SELECT_CHANGED_NTF object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
        [weakSelf checkWalletInfo];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MY_NFT_WEAR_CHANGE_NTF object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
        [weakSelf.myHeaderView dtUpdateUI];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MY_NFT_WALLET_TYPE_CHANGE_NTF object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
        [weakSelf checkWalletInfo];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:WALLET_BIND_TOKEN_EXPIRED_NTF object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
        [weakSelf onSudNFTBindWalletTokenExpired];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:NFT_REFRESH_NFT object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
        id temp = note.userInfo[@"nft"];
        id cardTemp = note.userInfo[@"card"];
        if (temp && [temp isKindOfClass:[SudNFTGetNFTListModel class]]) {
            SudNFTGetNFTListModel *nft = (SudNFTGetNFTListModel *) temp;
            [self.myHeaderView updateNFTList:nft];
            [self reloadHeadView];
        } else if (cardTemp && [cardTemp isKindOfClass:[SudNFTGetCnNFTListModel class]]) {
            SudNFTGetCnNFTListModel *card = (SudNFTGetCnNFTListModel *) cardTemp;
            [self.myHeaderView updateCardList:card];
            [self reloadHeadView];
        }
    }];

}

/// 处理国内钱包选择
- (void)handleCNWalletClick:(SudNFTWalletInfoModel *)walletInfoModel selectView:(CNWalletSelectPopView *)selectView {

    WeakSelf
    BOOL isBind = [HsNFTPreferences.shared getBindUserTokenByWalletType:walletInfoModel.type].length > 0;
    // 未绑定
    if (!isBind) {
        [DTSheetView close];
        // 国内钱包授权
        CNAuthViewController *vc = CNAuthViewController.new;
        vc.bindSuccessBlock = ^{
            [weakSelf.myHeaderView dtUpdateUI];
            [weakSelf reloadHeadView];
            [weakSelf checkWalletInfo];

            [[NSNotificationCenter defaultCenter] postNotificationName:MY_NFT_BIND_WALLET_CHANGE_NTF object:nil userInfo:nil];
        };
        vc.walletInfoModel = walletInfoModel;
        [AppUtil.currentViewController.navigationController pushViewController:vc animated:YES];
        return;
    }
    // 已绑定，解除绑定

    CNWalletDeletePopView *v = CNWalletDeletePopView.new;
    v.walletInfoModel = walletInfoModel;
    [v dtUpdateUI];
    UIView *coverView = UIView.new;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCover:)];
    [coverView addGestureRecognizer:tap];
    coverView.backgroundColor = HEX_COLOR_A(@"#000000", 0.4);
    [AppUtil.currentWindow addSubview:coverView];
    [coverView addSubview:v];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(@0);
    }];
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(@0);
        make.height.greaterThanOrEqualTo(@0);
    }];
    __weak typeof(coverView) weakCoverView = coverView;
    v.cancelBlock = ^{
        [weakCoverView removeFromSuperview];
    };
    v.sureBlock = ^{

        [weakCoverView removeFromSuperview];
        
        if ([HsNFTPreferences.shared isCurrentWearFromWalletType:walletInfoModel.type]) {
            [weakSelf removeWearData];
        }

        SudNFTUnBindCnWalletParamModel *paramModel = SudNFTUnBindCnWalletParamModel.new;
        paramModel.walletType = walletInfoModel.type;
        paramModel.userId = HsNFTPreferences.shared.userId;
        paramModel.phone = [HsNFTPreferences.shared getBindUserPhoneByWalletType:paramModel.walletType];
        [SudNFT unbindCnWallet:paramModel listener:^(NSInteger errCode, NSString *_Nullable errMsg) {
            DDLogDebug(@"unbind user errcode:%@, msg:%@", @(errCode), errMsg);
        }];
        [weakSelf removeWalletData:walletInfoModel.type];
        [selectView closeIfNoBindAccount];
    };
}

/// 处理国外钱包选择
- (void)handleWalletClick:(SudNFTWalletInfoModel *)walletInfoModel selectView:(ForeignWalletSelectPopView *)selectView {

    WeakSelf
    BOOL isBind = [HsNFTPreferences.shared isBindWalletWithType:walletInfoModel.type];
    // 未绑定
    if (!isBind) {
        [DTSheetView close];
        self.waitBindWalletInfo = walletInfoModel;
        // 海外 绑定三方钱包
        BindWalletStateView *bindWalletStateView = [[BindWalletStateView alloc] init];
        [DTAlertView show:bindWalletStateView rootView:nil clickToClose:NO showDefaultBackground:YES onCloseCallback:^{

        }];

        weakSelf.bindWalletStateView = bindWalletStateView;
        SudNFTBindWalletParamModel *paramModel = SudNFTBindWalletParamModel.new;
        paramModel.walletType = walletInfoModel.type;
        DDLogDebug(@"bindWallet:%@", @(paramModel.walletType));
        [SudNFT bindWallet:paramModel listener:self];
        return;
    }
    // 已绑定，解除绑定
    WalletDeletePopView *v = WalletDeletePopView.new;
    v.walletInfoModel = walletInfoModel;
    [v dtUpdateUI];
    UIView *coverView = UIView.new;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCover:)];
    [coverView addGestureRecognizer:tap];
    coverView.backgroundColor = HEX_COLOR_A(@"#000000", 0.4);
    [AppUtil.currentWindow addSubview:coverView];
    [coverView addSubview:v];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(@0);
    }];
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(@0);
        make.height.greaterThanOrEqualTo(@0);
    }];
    __weak typeof(coverView) weakCoverView = coverView;
    v.cancelBlock = ^{
        [weakCoverView removeFromSuperview];
    };
    v.sureBlock = ^{
        if ([HsNFTPreferences.shared isCurrentWearFromWalletType:walletInfoModel.type]) {
            [weakSelf removeWearData];
        }

        SudNFTUnbindWalletParamModel *paramModel = SudNFTUnbindWalletParamModel.new;
        paramModel.walletType = walletInfoModel.type;
        paramModel.userId = HsNFTPreferences.shared.userId;
        paramModel.walletAddress = [HsNFTPreferences.shared getBindWalletAddressByWalletType:walletInfoModel.type];
        [SudNFT unbindWallet:paramModel listener:^(NSInteger errCode, NSString *_Nullable errMsg) {
            DDLogDebug(@"unbind user errcode:%@, msg:%@", @(errCode), errMsg);
        }];

        [weakSelf removeWalletData:walletInfoModel.type];
        [weakCoverView removeFromSuperview];
        [selectView closeIfNoBindAccount];
    };
}

/// 移除穿戴数据
- (void)removeWearData {
    
    [HsNFTPreferences.shared useNFT:@"" tokenId:@"" detailsToken:nil add:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_NFT_WEAR_CHANGE_NTF object:nil userInfo:nil];
}

/// 移除当前钱包数据
- (void)removeWalletData:(NSInteger)walletType {
    BOOL isRemoveCurrentWalletType = HsNFTPreferences.shared.currentWalletType == walletType;
    [HsNFTPreferences.shared clearBindInfoWithWalletType:walletType];
    /// 不是移除当前钱包则清空绑定信息后退出即可，不需要切换钱包
    if (!isRemoveCurrentWalletType) {
        return;
    }
    // 重新选择一个新钱包
    NSInteger zoneType = HsNFTPreferences.shared.bindZoneType;
    BOOL isExistNextBindWalletType = NO;
    for (int i = 0; i < self.walletList.count; ++i) {
        SudNFTWalletInfoModel *m = self.walletList[i];
        if (m.zoneType == zoneType) {
            if ([HsNFTPreferences.shared isBindWalletWithType:m.type]) {
                HsNFTPreferences.shared.currentWalletType = m.type;
                if (m.chainList.count > 0) {
                    HsNFTPreferences.shared.selectedEthereumChainType = m.chainList[0].type;
                }
                isExistNextBindWalletType = YES;
                break;
            }
        }
    }
    if (!isExistNextBindWalletType) {
        HsNFTPreferences.shared.bindZoneType = -1;
        HsNFTPreferences.shared.currentWalletType = -1;
    }
    [self.myHeaderView dtUpdateUI];
    [self reloadHeadView];
    [self checkWalletInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_NFT_BIND_WALLET_CHANGE_NTF object:nil userInfo:nil];
}

- (void)onTapCover:(UITapGestureRecognizer *)tap {
    [tap.view removeFromSuperview];
}

- (void)showBindErrorAlert:(NSString *)msg {
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", @"连接失败"]];
    attrTitle.yy_lineSpacing = 16;
    attrTitle.yy_font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    attrTitle.yy_color = [UIColor dt_colorWithHexString:@"#1A1A1A" alpha:1];
    attrTitle.yy_alignment = NSTextAlignmentCenter;

    NSMutableAttributedString *attrStr_0 = [[NSMutableAttributedString alloc] initWithString:msg];
    attrStr_0.yy_lineSpacing = 6;
    attrStr_0.yy_font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    attrStr_0.yy_color = [UIColor dt_colorWithHexString:@"#1A1A1A" alpha:1];
    attrStr_0.yy_alignment = NSTextAlignmentCenter;
    [attrTitle appendAttributedString:attrStr_0];
    [DTAlertView showAttrTextAlert:attrTitle sureText:@"确定" cancelText:nil rootView:nil onSureCallback:^{
        [DTAlertView close];
    }              onCloseCallback:nil];
    return;
}

#pragma makr lazy

- (MyHeaderView *)myHeaderView {
    if (!_myHeaderView) {
        _myHeaderView = [[MyHeaderView alloc] init];
        _myHeaderView.backgroundColor = HEX_COLOR(@"#F5F6FB");
    }
    return _myHeaderView;
}

#pragma mark ISudNFTListener

/// 绑定钱包token过期，需要重新验证绑定
- (void)onSudNFTBindWalletTokenExpired {
    DDLogWarn(@"onSudNFTBindWalletTokenExpired");
    NSInteger walletType = HsNFTPreferences.shared.currentWalletType;
    [HsNFTPreferences.shared clearBindInfoWithWalletType:walletType];
    HsNFTPreferences.shared.bindZoneType = -1;
    [self.myHeaderView dtUpdateUI];
    [self reloadHeadView];
    [self checkWalletInfo];
    [self.navigationController popViewControllerAnimated:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:MY_NFT_WEAR_CHANGE_NTF object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_NFT_BIND_WALLET_CHANGE_NTF object:nil userInfo:nil];
}

/// 绑定钱包成功回调
/// @param walletInfoModel 成功回调
- (void)onSuccess:(SudNFTBindWalletModel *_Nullable)walletInfoModel {

    DDLogInfo(@"onSuccess:%@", walletInfoModel.walletAddress);
    // 绑定钱包成功
    HsNFTPreferences.shared.bindZoneType = self.waitBindWalletInfo.zoneType;
    HsNFTPreferences.shared.currentWalletType = self.waitBindWalletInfo.type;
    if (self.waitBindWalletInfo.chainList[0]) {
        HsNFTPreferences.shared.selectedEthereumChainType = self.waitBindWalletInfo.chainList[0].type;
    }
    [HsNFTPreferences.shared saveWalletToken:walletInfoModel walletType:self.waitBindWalletInfo.type walletAddress:walletInfoModel.walletAddress];
    [self.myHeaderView dtUpdateUI];
    [self reloadHeadView];
    [self checkWalletInfo];

    [[NSNotificationCenter defaultCenter] postNotificationName:MY_NFT_BIND_WALLET_CHANGE_NTF object:nil userInfo:nil];
    [self.myHeaderView showTipIfNeed];
    self.waitBindWalletInfo = nil;
}

/// 绑定钱包
- (void)onFailure:(NSInteger)errCode errMsg:(NSString *_Nullable)errMsg {
    NSString *msg = [NSString stringWithFormat:@"%@(%@)", errMsg, @(errCode)];
    DDLogError(@"bind wallet err:%@", msg);
    if (!self.waitBindWalletInfo) {
        return;
    }
    [DTAlertView close];
    if (errCode != 0) {
        
        [self showBindErrorAlert:msg];
        return;
    }
}

/// 钱包绑定事件通知，可以使用此状态做交互状态展示
/// @param stage 1: 连接；2：签名
/// @param event 1：连接开始；2 成功连接钱包；3：签名开始；4:签名结束
- (void)onBindStageEvent:(NSInteger)stage event:(NSInteger)event {
    DDLogDebug(@"onBindStageEvent:%@, event:%@", @(stage), @(event));
    [self.bindWalletStateView updateStage:stage event:event];
}

/// 绑定步骤顺序列表
/// @param stageList 对应状态事件列表，如：["1", "2"]
- (void)onBindStageList:(NSArray <NSNumber *> *_Nullable)stageList {

}

@end
