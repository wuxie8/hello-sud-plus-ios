//
//  HomeViewController.m
//  HelloSud-iOS
//
//  Created by Mary on 2022/1/24.
//

#import "MyNFTDetailViewController.h"

@interface MyNFTDetailViewController ()
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) SDAnimatedImageView *iconImageView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *contractAddressLabel;
@property(nonatomic, strong) UILabel *tokenIDLabel;
@property(nonatomic, strong) UILabel *tokenStandLabel;
@property(nonatomic, strong) UIButton *copyBtn;
@property(nonatomic, strong) BaseView *topView;
@property(nonatomic, strong) BaseView *bottomView;
@property(nonatomic, strong) UIButton *wearBtn;
@property(nonatomic, strong) UIButton *backBtn;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UILabel *moreLabel;
@property(nonatomic, assign) BOOL showMore;

@end

@implementation MyNFTDetailViewController
- (BOOL)dtIsHiddenNavigationBar {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dtConfigUI {
    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)dtConfigEvents {
    WeakSelf
    [_backBtn addTarget:self action:@selector(dtNavigationBackClick) forControlEvents:UIControlEventTouchUpInside];
    [_wearBtn addTarget:self action:@selector(onWearBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *addrTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAddrTap:)];
    [self.contractAddressLabel addGestureRecognizer:addrTap];
    UITapGestureRecognizer *tokenTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTokenTap:)];
    [self.tokenIDLabel addGestureRecognizer:tokenTap];
    UITapGestureRecognizer *moreTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMoreTap:)];
    [self.moreLabel addGestureRecognizer:moreTap];
}

- (void)onMoreTap:(id)sender {
    self.showMore = !self.showMore;
    [self dtUpdateUI];
}

- (void)onWearBtnClick:(UIButton *)sender {
    BOOL isWear = self.wearBtn.selected ? NO : YES;
    if (isWear) {
        [self handleWear:sender];
    } else {
        [self handleRemoveWear:sender];
    }
}

/// 处理穿戴
- (void)handleWear:(UIButton *)sender {
    BOOL isCN = HsNFTPreferences.shared.isBindCNWallet;
    if (isCN) {
        [self wearCard:sender];
    } else {
        [self wearNFT:sender];
    }
}

/// 处理移除穿戴
- (void)handleRemoveWear:(UIButton *)sender {
    BOOL isCN = HsNFTPreferences.shared.isBindCNWallet;
    NSString *contractAddress = @"";
    NSString *tokenId = @"";
    if (isCN) {
        contractAddress = self.cellModel.cardModel.cardHash;
        tokenId = self.cellModel.cardModel.chainAddr;
    } else {
        contractAddress = self.cellModel.nftModel.contractAddress;
        tokenId = self.cellModel.nftModel.tokenId;
    }
    // 解绑
    NSString *detailsToken = [HsNFTPreferences.shared detailsTokenWithContractAddress:contractAddress tokenId:tokenId];
    [self handleWearDetailToken:detailsToken isCN:isCN];
}

/// 穿戴NFT
- (void)wearNFT:(UIButton *)sender {
    WeakSelf
    DDLogDebug(@"wearNFT");
    sender.enabled = NO;

    SudNFTCredentialsTokenParamModel *paramModel = SudNFTCredentialsTokenParamModel.new;
    paramModel.walletToken = HsNFTPreferences.shared.currentWalletToken;
    paramModel.contractAddress = self.cellModel.nftModel.contractAddress;
    paramModel.tokenId = self.cellModel.nftModel.tokenId;
    paramModel.chainType = HsNFTPreferences.shared.selectedEthereumChainType;
    paramModel.extension = self.cellModel.nftModel.extension;
    [SudNFT genNFTCredentialsToken:paramModel listener:^(NSInteger errCode, NSString *errMsg, SudNFTGenNFTCredentialsTokenModel *generateDetailTokenModel) {
        if (errCode != 0) {
            NSString *msg = [HsNFTPreferences.shared nftErrorMsg:errCode errorMsg:errMsg];
            [ToastUtil show:msg];
            sender.enabled = YES;
            [HsNFTPreferences.shared handleFilterNftError:errCode errMsg:errMsg];
            return;
        }
        [weakSelf handleWearDetailToken:generateDetailTokenModel.detailsToken isCN:NO];
    }];
}

/// 穿戴藏品
- (void)wearCard:(UIButton *)sender {
    WeakSelf
    DDLogDebug(@"wearCard");
    sender.enabled = NO;
    SudNFTCnCredentialsTokenParamModel *paramModel = SudNFTCnCredentialsTokenParamModel.new;
    paramModel.walletType = HsNFTPreferences.shared.currentWalletType;
    paramModel.walletToken = [HsNFTPreferences.shared getBindUserTokenByWalletType:paramModel.walletType];
    paramModel.cardId = self.cellModel.cardModel.cardId;
    [SudNFT genCnNFTCredentialsToken:paramModel listener:^(NSInteger errCode, NSString *errMsg, SudNFTCnCredentialsTokenModel *resp) {
        if (errCode != 0) {
            NSString *msg = [HsNFTPreferences.shared nftErrorMsg:errCode errorMsg:errMsg];
            [ToastUtil show:msg];
            sender.enabled = YES;
            [HsNFTPreferences.shared handleFilterNftError:errCode errMsg:errMsg];
            return;
        }
        [weakSelf handleWearDetailToken:resp.detailsToken isCN:YES];
    }];

}

- (void)onAddrTap:(id)sender {
    NSString *contractAddress = @"";
    if (HsNFTPreferences.shared.isBindCNWallet) {
        contractAddress = self.cellModel.cardModel.cardHash;
    } else if (HsNFTPreferences.shared.isBindForeignWallet) {
        contractAddress = self.cellModel.nftModel.contractAddress;
    }
    [AppUtil copyToPasteProcess:contractAddress toast:@"复制成功"];
}

- (void)onTokenTap:(id)sender {
    NSString *tokenId = @"";
    if (HsNFTPreferences.shared.isBindCNWallet) {
        tokenId = self.cellModel.cardModel.chainAddr;
    } else if (HsNFTPreferences.shared.isBindForeignWallet) {
        tokenId = self.cellModel.nftModel.tokenId;
    }
    [AppUtil copyToPasteProcess:tokenId toast:@"复制成功"];
}

//- (void)onCopyBtnClick:(id)sender {
//    [AppUtil copyToPasteProcess:self.cellModel.nftModel.contractAddress toast:@"地址已复制"];
//}

/// 上报后台
/// @param nftDetailToken nftDetailToken
- (void)handleWearDetailToken:(NSString *)nftDetailToken isCN:(BOOL)isCN {
    NSString *tip = [NSString stringWithFormat:@"穿戴token：\n%@", nftDetailToken];
    [ToastUtil show:tip];
}

- (void)updateWearBtn {
    BOOL isUsed = NO;
    if (HsNFTPreferences.shared.isBindForeignWallet) {
        isUsed = [HsNFTPreferences.shared isNFTAlreadyUsed:self.cellModel.nftModel.contractAddress tokenId:self.cellModel.nftModel.tokenId];
    } else if (HsNFTPreferences.shared.isBindCNWallet) {
        isUsed = [HsNFTPreferences.shared isNFTAlreadyUsed:self.cellModel.cardModel.cardHash tokenId:self.cellModel.cardModel.chainAddr];
    }
    if (isUsed) {
        _wearBtn.selected = YES;
        _wearBtn.layer.borderWidth = 1;
        _wearBtn.layer.borderColor = UIColor.blackColor.CGColor;
        _wearBtn.backgroundColor = UIColor.whiteColor;
    } else {
        _wearBtn.selected = NO;
        _wearBtn.layer.borderWidth = 0;
        _wearBtn.layer.borderColor = nil;
        _wearBtn.backgroundColor = UIColor.blackColor;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)dtAddViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.topView];
    [self.topView addSubview:self.nameLabel];
    [self.topView addSubview:self.descLabel];
    [self.topView addSubview:self.moreLabel];
    [self.topView addSubview:self.contractAddressLabel];
    [self.topView addSubview:self.tokenIDLabel];
    [self.topView addSubview:self.tokenStandLabel];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.wearBtn];
    [self.view addSubview:self.backBtn];
}

- (void)dtLayoutViews {

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.width.equalTo(self.scrollView);
        make.height.greaterThanOrEqualTo(@0);
    }];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.height.equalTo(@(kScreenWidth));
    }];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.mas_bottom).offset(-30);
        make.leading.equalTo(@0);
        make.trailing.mas_equalTo(0);
        make.bottom.equalTo(@0);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.height.equalTo(@22);
        make.top.equalTo(@30);
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.height.greaterThanOrEqualTo(@0);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(18);
    }];
    [self.moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.width.height.greaterThanOrEqualTo(@0);
        make.top.equalTo(self.descLabel.mas_bottom).offset(2);
    }];
    [self.contractAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.trailing.equalTo(@-118);
        make.height.greaterThanOrEqualTo(@0);
        make.top.equalTo(self.moreLabel.mas_bottom).offset(14);
    }];
    [self.tokenIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.width.equalTo(self.contractAddressLabel);
        make.height.greaterThanOrEqualTo(@0);
        make.top.equalTo(self.contractAddressLabel.mas_bottom).offset(14);
    }];
    [self.tokenStandLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.trailing.equalTo(@-16);
        make.height.greaterThanOrEqualTo(@0);
        make.top.equalTo(self.tokenIDLabel.mas_bottom).offset(14);
        make.bottom.equalTo(@-20);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.trailing.equalTo(@0);
        make.height.equalTo(@102);
        make.bottom.equalTo(@0);
    }];
    [self.wearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.trailing.equalTo(@-16);
        make.height.equalTo(@44);
        make.top.equalTo(self.bottomView).offset(12);
    }];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.top.mas_equalTo(50);
        make.width.height.equalTo(@(32));
    }];
}

- (void)dtUpdateUI {
    [super dtUpdateUI];
    self.view.backgroundColor = UIColor.whiteColor;
    if (!self.cellModel) {
        return;
    }
    WeakSelf
    BOOL isCNBind = HsNFTPreferences.shared.isBindCNWallet;
    NSString *contractTitle = @"Contract Address\n";
    NSString *tokenIDTitle = @"Token ID\n";
    NSString *coverURL = nil;
    NSString *contractAddress = @"";
    NSString *tokenId = @"";
    NSString *tokenType = @"";
    NSString *name = @"";
    NSString *descTitle = @"Description\n";
    NSString *desc = @"";
    if (isCNBind) {
        contractTitle = @"地址\n";
        tokenIDTitle = @"令牌ID\n";
        descTitle = @"作品描述\n";
        contractAddress = self.cellModel.cardModel.cardHash;
        tokenId = self.cellModel.cardModel.chainAddr;
        coverURL = self.cellModel.cardModel.coverUrl;
        name = self.cellModel.cardModel.name;
        desc = self.cellModel.cardModel.desc;
    } else {
        SudNFTInfoModel *nftModel = self.cellModel.nftModel;
        contractAddress = nftModel.contractAddress;
        tokenId = nftModel.tokenId;
        tokenType = nftModel.tokenType;
        coverURL = nftModel.coverURL;
        name = nftModel.name;
        desc = nftModel.desc;
    }
    self.nameLabel.text = name;
    NSAttributedString *attrDesc = [self generate:descTitle subtitle:desc subColor:HEX_COLOR(@"#8A8A8E") tailImageName:nil];
    self.descLabel.attributedText = attrDesc;
    self.contractAddressLabel.attributedText = [self generate:contractTitle subtitle:contractAddress subColor:HEX_COLOR(@"#8A8A8E") tailImageName:@"nft_detail_copy"];
    self.tokenIDLabel.attributedText = [self generate:tokenIDTitle subtitle:tokenId subColor:HEX_COLOR(@"#8A8A8E") tailImageName:@"nft_detail_copy"];
    self.tokenStandLabel.attributedText = [self generate:@"Token Standard\n" subtitle:tokenType subColor:HEX_COLOR(@"#8A8A8E") tailImageName:nil];
    self.tokenStandLabel.hidden = tokenType.length == 0;
    
    self.descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.contractAddressLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.tokenIDLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    if (coverURL) {

        SDWebImageContext *context = nil;
        NSURL *url = [[NSURL alloc] initWithString:coverURL];
        if ([url.pathExtension caseInsensitiveCompare:@"svg"] == NSOrderedSame) {
            context = @{SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(kScreenWidth, kScreenWidth))};
        }
        [self showLoadAnimate];
        [self.iconImageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageRetryFailed context:context progress:nil completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
            if (error == nil) {
                weakSelf.wearBtn.hidden = NO;
                [weakSelf closeLoadAnimate];
            }
        }];
    } else {
        self.iconImageView.image = [UIImage imageNamed:@"default_nft_icon"];
    }
    [self updateWearBtn];
    /// 测算高度
    self.descLabel.numberOfLines = 4;
    CGSize size = [self.descLabel sizeThatFits:CGSizeMake(kScreenWidth - 32, 100000)];
    CGRect descRect = [attrDesc boundingRectWithSize:CGSizeMake(kScreenWidth - 32, 100000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat limitHeight = size.height;
    if (descRect.size.height > limitHeight) {
        self.moreLabel.hidden = NO;
        if (!self.showMore) {
            self.descLabel.numberOfLines = 4;
        } else {
            self.descLabel.numberOfLines = 0;
        }
        [self.moreLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.width.height.greaterThanOrEqualTo(@0);
            make.top.equalTo(self.descLabel.mas_bottom).offset(2);
        }];
        [self updateMoreLabel:self.showMore];
    } else {
        self.moreLabel.hidden = YES;
        self.descLabel.numberOfLines = 0;
        [self.moreLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.width.height.equalTo(@0);
            make.top.equalTo(self.descLabel.mas_bottom);
        }];
    }
    [self.scrollView layoutIfNeeded];
    CGFloat height = self.contentView.bounds.size.height;
    self.scrollView.contentSize = CGSizeMake(kScreenWidth, height);
}

- (void)updateMoreLabel:(BOOL)showMore {

    BOOL isCNBind = HsNFTPreferences.shared.isBindCNWallet;
    self.showMore = showMore;
    NSString *title = showMore ? @"see less " : @"see more ";
    if (isCNBind) {
        title = showMore ? @"收起 " : @"展开 ";
    }
    NSString *imageName = showMore ? @"nft_desc_up" : @"nft_desc_down";

    NSMutableAttributedString *fullAttr = [[NSMutableAttributedString alloc] initWithString:title];
    fullAttr.yy_font = UIFONT_REGULAR(14);
    fullAttr.yy_color = HEX_COLOR(@"#000000");
    if (imageName) {
        NSAttributedString *iconAttr = [NSAttributedString dt_attrWithImage:[UIImage imageNamed:imageName] size:CGSizeMake(12, 12) offsetY:-2];
        [fullAttr appendAttributedString:iconAttr];
    }
    self.moreLabel.attributedText = fullAttr;
}

- (void)showLoadAnimate {

    [self closeLoadAnimate];
    CGColorRef whiteBegin = HEX_COLOR_A(@"#000000", 0.05).CGColor;
    CGColorRef whiteEnd = HEX_COLOR_A(@"#000000", 0.1).CGColor;
    CGFloat duration = 0.6;
    CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    anim1.duration = duration;
    anim1.fromValue = (__bridge id) whiteBegin;
    anim1.toValue = (__bridge id) whiteEnd;

    CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    anim2.beginTime = duration;
    anim2.duration = duration;
    anim2.fromValue = (__bridge id) whiteEnd;
    anim2.toValue = (__bridge id) whiteBegin;

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = duration * 2;
    group.animations = @[anim1, anim2];
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.repeatCount = 10000000;

    [self.iconImageView.layer addAnimation:group forKey:@"animate_background"];
}

- (void)closeLoadAnimate {
    [self.iconImageView.layer removeAllAnimations];
}

- (NSAttributedString *)generate:(NSString *)title subtitle:(NSString *)subtitle subColor:(UIColor *)subColor tailImageName:(NSString *)imageName {
    NSMutableAttributedString *fullAttr = [[NSMutableAttributedString alloc] initWithString:title];
    fullAttr.yy_font = UIFONT_REGULAR(14);
    fullAttr.yy_color = HEX_COLOR(@"#000000");
    fullAttr.yy_lineSpacing = 5;

    subtitle = subtitle ? subtitle : @"";
    subtitle = [NSString stringWithFormat:@"%@ ", subtitle];
    NSMutableAttributedString *subtitleAttr = [[NSMutableAttributedString alloc] initWithString:subtitle];
    subtitleAttr.yy_font = UIFONT_REGULAR(14);
    subtitleAttr.yy_color = subColor;
    subtitleAttr.yy_lineSpacing = 5;
    [fullAttr appendAttributedString:subtitleAttr];
    if (imageName) {
        NSAttributedString *iconAttr = [NSAttributedString dt_attrWithImage:[UIImage imageNamed:imageName] size:CGSizeMake(16, 17) offsetY:-3];
        [fullAttr appendAttributedString:iconAttr];
    }
    return fullAttr;
}

#pragma mark - requst Data

- (void)requestData {
    WeakSelf

}

#pragma mark - 懒加载

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = UIColor.whiteColor;
        _scrollView.bounces = YES;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = UIColor.whiteColor;
        _contentView.clipsToBounds = YES;
    }
    return _contentView;
}

- (SDAnimatedImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[SDAnimatedImageView alloc] init];
        _iconImageView.shouldCustomLoopCount = YES;
        _iconImageView.animationRepeatCount = NSIntegerMax;
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.clipsToBounds = YES;
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = @"";
        _nameLabel.textColor = HEX_COLOR(@"#1A1A1A");
        _nameLabel.font = UIFONT_MEDIUM(16);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel *)contractAddressLabel {
    if (!_contractAddressLabel) {
        _contractAddressLabel = [[UILabel alloc] init];
        _contractAddressLabel.text = @"";
        _contractAddressLabel.textColor = HEX_COLOR(@"#0053FF");
        _contractAddressLabel.font = UIFONT_BOLD(16);
        _contractAddressLabel.textAlignment = NSTextAlignmentLeft;
        _contractAddressLabel.numberOfLines = 2;
        _contractAddressLabel.userInteractionEnabled = YES;
    }
    return _contractAddressLabel;
}

- (UILabel *)tokenIDLabel {
    if (!_tokenIDLabel) {
        _tokenIDLabel = [[UILabel alloc] init];
        _tokenIDLabel.text = @"";
        _tokenIDLabel.textColor = UIColor.blackColor;

        _tokenIDLabel.font = UIFONT_BOLD(16);
        _tokenIDLabel.textAlignment = NSTextAlignmentLeft;
        _tokenIDLabel.numberOfLines = 2;
        _tokenIDLabel.userInteractionEnabled = YES;
    }
    return _tokenIDLabel;
}

- (UILabel *)tokenStandLabel {
    if (!_tokenStandLabel) {
        _tokenStandLabel = [[UILabel alloc] init];
        _tokenStandLabel.text = @"";
        _tokenStandLabel.textColor = UIColor.blackColor;
        _tokenStandLabel.font = UIFONT_BOLD(16);
        _tokenStandLabel.textAlignment = NSTextAlignmentLeft;
        _tokenStandLabel.numberOfLines = 0;
    }
    return _tokenStandLabel;
}

- (UIButton *)copyBtn {
    if (!_copyBtn) {
        _copyBtn = [[UIButton alloc] init];
        [_copyBtn setTitle:@"复制" forState:UIControlStateNormal];
        [_copyBtn setTitleColor:HEX_COLOR(@"#0053FF") forState:UIControlStateNormal];
        _copyBtn.titleLabel.font = UIFONT_BOLD(16);
    }
    return _copyBtn;
}

- (UIButton *)wearBtn {
    if (!_wearBtn) {
        _wearBtn = [[UIButton alloc] init];
        [_wearBtn setTitle:@"穿戴" forState:UIControlStateNormal];
        [_wearBtn setTitleColor:HEX_COLOR(@"#ffffff") forState:UIControlStateNormal];
        [_wearBtn setTitle:@"取消穿戴" forState:UIControlStateSelected];
        [_wearBtn setTitleColor:HEX_COLOR(@"#000000") forState:UIControlStateSelected];
        _wearBtn.titleLabel.font = UIFONT_BOLD(14);
        _wearBtn.hidden = YES;
    }
    return _wearBtn;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"my_white_back"] forState:UIControlStateNormal];
        [_backBtn setTintColor:UIColor.whiteColor];
    }
    return _backBtn;
}

- (BaseView *)topView {
    if (!_topView) {
        _topView = [[BaseView alloc] init];
        BaseView *radiusView = [[BaseView alloc] init];
        radiusView.backgroundColor = UIColor.whiteColor;
        [radiusView setPartRoundCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadius:20];
        [_topView addSubview:radiusView];
        [radiusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.bottom.equalTo(@0);
        }];

        _topView.layer.shadowColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.1000].CGColor;
        _topView.layer.shadowOffset = CGSizeMake(0, -3);
        _topView.layer.shadowOpacity = 1;
        _topView.layer.shadowRadius = 12;

    }
    return _topView;
}

- (BaseView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[BaseView alloc] init];
        _bottomView.layer.shadowColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.0800].CGColor;
        _bottomView.layer.shadowOffset = CGSizeMake(0, 0);
        _bottomView.layer.shadowOpacity = 1;
        _bottomView.layer.shadowRadius = 10;
        _bottomView.backgroundColor = UIColor.whiteColor;
    }
    return _bottomView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.text = @"";
        _descLabel.textColor = HEX_COLOR(@"#0053FF");
        _descLabel.font = UIFONT_BOLD(16);
        _descLabel.textAlignment = NSTextAlignmentLeft;
        _descLabel.numberOfLines = 0;
        _descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _descLabel.userInteractionEnabled = YES;
    }
    return _descLabel;
}

- (UILabel *)moreLabel {
    if (!_moreLabel) {
        _moreLabel = [[UILabel alloc] init];
        _moreLabel.userInteractionEnabled = YES;
    }
    return _moreLabel;
}
@end
