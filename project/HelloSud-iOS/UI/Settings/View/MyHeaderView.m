//
// Created by kaniel on 2022/7/26.
// Copyright (c) 2022 Sud.Tech (https://sud.tech). All rights reserved.
//

#import "MyHeaderView.h"
#import "UserDetailView.h"
#import "MyBindWalletView.h"
#import "MyNFTView.h"

@interface MyHeaderView () <UITextFieldDelegate>
@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *userIdLabel;
@property (nonatomic, strong) UIImageView *nftView;
@property (nonatomic, strong)MyBindWalletView *bindView;
@property (nonatomic, strong)MyNFTView *myNFTView;

@end

@implementation MyHeaderView

- (void)dtConfigUI {
    self.backgroundColor = UIColor.whiteColor;
}

- (void)dtAddViews {
    [self addSubview:self.headerView];
    [self addSubview:self.userNameLabel];
    [self addSubview:self.userIdLabel];
    [self addSubview:self.nftView];
}

- (void)dtLayoutViews {
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(7);
        make.leading.mas_equalTo(16);
        make.size.mas_equalTo(CGSizeMake(56, 56));
    }];
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.headerView.mas_trailing).offset(10);
        make.top.mas_equalTo(self.headerView.mas_top).offset(3);
        make.size.mas_greaterThanOrEqualTo(CGSizeZero);
    }];
    [self.userIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.headerView.mas_trailing).offset(10);
        make.top.mas_equalTo(self.userNameLabel.mas_bottom).offset(6);
        make.size.mas_greaterThanOrEqualTo(CGSizeZero);
    }];
    [self.nftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(10);
        make.leading.equalTo(@0);
        make.trailing.equalTo(@0);
        make.height.greaterThanOrEqualTo(@0);
        make.bottom.equalTo(@-24);
    }];

}

- (void)dtUpdateUI {
    AccountUserModel *userInfo = AppService.shared.login.loginUserInfo;
    self.userNameLabel.text = userInfo.name;
    self.userIdLabel.text = [NSString stringWithFormat:@"%@ %@", NSString.dt_home_user_id, userInfo.userID];
    if (userInfo.icon.length > 0) {
        [self.headerView sd_setImageWithURL:[NSURL URLWithString:userInfo.icon]];
    }

    BOOL isBindWallet = YES;// AppService.shared.login.walletAddress.length > 0;
    if (isBindWallet) {
        // 绑定过了钱包
        if (_bindView) {
            [_bindView removeFromSuperview];
            _bindView = nil;
        }
        if (!_myNFTView) {
            [self.nftView addSubview:self.myNFTView];
        }
        [self.myNFTView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.bottom.equalTo(@0);
        }];
    } else {
        // 未绑定钱包
        if (_myNFTView) {
            [_myNFTView removeFromSuperview];
            _myNFTView = nil;
        }
        if (!_bindView) {
            [self.nftView addSubview:self.bindView];
        }
        [self.bindView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.bottom.equalTo(@0);
        }];
    }
}

- (void)dtConfigEvents {
    [super dtConfigEvents];
    self.headerView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapHead:)];
    [self.headerView addGestureRecognizer:tap];
}

- (void)onTapHead:(id)tap {
    /// 展示用户金币信息
    UserDetailView *v = [[UserDetailView alloc] init];
    [DTAlertView show:v rootView:AppUtil.currentWindow clickToClose:YES showDefaultBackground:YES onCloseCallback:^{

    }];
}

- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] init];
        _headerView.clipsToBounds = true;
        _headerView.layer.cornerRadius = 56/2;
    }
    return _headerView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.text = @"";
        _userNameLabel.numberOfLines = 1;
        _userNameLabel.textColor = [UIColor dt_colorWithHexString:@"#13141A" alpha:1];
        _userNameLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    }
    return _userNameLabel;
}

- (UILabel *)userIdLabel {
    if (!_userIdLabel) {
        _userIdLabel = [[UILabel alloc] init];
        _userIdLabel.numberOfLines = 1;
        _userIdLabel.textColor = [UIColor dt_colorWithHexString:@"#13141A" alpha:1];
        _userIdLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    }
    return _userIdLabel;
}

- (UIImageView *)nftView {
    if (!_nftView) {
        _nftView = [[UIImageView alloc] init];
        _nftView.image = [UIImage imageNamed:@"nft_bg"];
        _nftView.userInteractionEnabled = YES;
    }
    return _nftView;
}

- (MyBindWalletView *)bindView {
    if (!_bindView) {
        _bindView = [[MyBindWalletView alloc] init];
    }
    return _bindView;
}

- (MyNFTView *)myNFTView {
    if (!_myNFTView) {
        _myNFTView = [[MyNFTView alloc] init];
    }
    return _myNFTView;
}

@end
