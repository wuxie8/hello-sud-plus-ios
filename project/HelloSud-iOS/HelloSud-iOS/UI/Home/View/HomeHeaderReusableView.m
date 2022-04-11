//
//  HomeHeaderReusableView.m
//  HelloSud-iOS
//
//  Created by Mary on 2022/1/24.
//

#import "HomeHeaderReusableView.h"
#import "TicketChooseLevelView.h"

@interface HomeHeaderReusableView ()
@property (nonatomic, strong) BaseView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *previewView;
//@property (nonatomic, strong) UIView *itemContainerView;
@property (nonatomic, assign) CGFloat itemW;
@property (nonatomic, assign) CGFloat itemH;
@property (nonatomic, strong) UILabel *tipLabel;
/// 创建房间
@property (nonatomic, strong) UIButton *createBtn;
@property (nonatomic, strong) UIView *borderView;
@end

@implementation HomeHeaderReusableView

- (void)setHeaderGameList:(NSArray<HSGameItem *> *)headerGameList {
    _headerGameList = headerGameList;
}

- (void)setSceneModel:(HSSceneModel *)sceneModel {
    _sceneModel = sceneModel;
    
    self.titleLabel.text = sceneModel.sceneName;
    [self.previewView sd_setImageWithURL:[NSURL URLWithString:sceneModel.sceneImage]];
    [self.createBtn setTitleColor:sceneModel.isGameWait ? HEX_COLOR_A(@"#1A1A1A", 0.2) : HEX_COLOR(@"#1A1A1A") forState:UIControlStateNormal];
}

- (void)hsConfigUI {
    self.backgroundColor = [UIColor dt_colorWithHexString:@"#F5F6FB" alpha:1];
    self.itemW = (kScreenWidth - 32) / 4;
    self.itemH = 125 + 12;
}

- (void)tapInputEvent:(UITapGestureRecognizer *)gesture {
    [IQKeyboardManager.sharedManager resignFirstResponder];
    NSInteger tag = [gesture view].tag;
    HSGameItem *m = self.headerGameList[tag];
    if (m.isGameWait) {
        // 假数据
        return;
    }
    
//    [AudioRoomService.shared reqMatchRoom:m.gameId sceneType:self.sceneModel.sceneId];
}

- (void)onBtnClick:(UIButton *)sender {
    // 创建房间
    if (self.sceneModel.isGameWait) {
        return;
    }
    /// 门票场景
    if (self.sceneModel.sceneId == SceneTypeTicket) {
        TicketChooseLevelView *node = TicketChooseLevelView.new;
        [DTSheetView show:node rootView:AppUtil.currentWindow hiddenBackCover:false onCloseCallback:^{}];
        node.onGameLevelCallBack = ^(NSInteger gameLevel) {
            [AudioRoomService.shared reqCreateRoom:self.sceneModel.sceneId gameLevel: gameLevel];
        };
    } else {
        [AudioRoomService.shared reqCreateRoom:self.sceneModel.sceneId gameLevel: -1];
    }
}

- (void)hsAddViews {
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.previewView];
//    [self.contentView addSubview:self.tipLabel];
    [self.contentView addSubview:self.borderView];
    [self.borderView addSubview:self.createBtn];
}

- (void)hsLayoutViews {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.size.mas_greaterThanOrEqualTo(0);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15);
        make.trailing.mas_equalTo(-15);
        make.top.mas_equalTo(16);
        make.height.mas_equalTo(33);
        make.width.mas_greaterThanOrEqualTo(0);
    }];
    [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.leading.mas_equalTo(13);
        make.trailing.mas_equalTo(-13);
        make.height.mas_equalTo(80);
        make.bottom.mas_equalTo(-10);
    }];
    [self.borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.previewView);
        make.trailing.equalTo(self.previewView).offset(-12);
        make.width.mas_equalTo(118);
        make.height.mas_equalTo(44);
    }];
    [self.createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(4, 4, 4, 4));
    }];
    CGFloat w = (kScreenWidth - 32) / 2;
//    [self.itemContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_equalTo(self.mas_centerX);
//        make.top.mas_equalTo(36);
//        make.width.mas_equalTo(w);
//        make.bottom.mas_equalTo(0);
//    }];
//    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.mas_equalTo(self.itemContainerView);
//        make.size.mas_greaterThanOrEqualTo(CGSizeZero);
//    }];
}

- (BaseView *)contentView {
    if (!_contentView) {
        _contentView = [[BaseView alloc] init];
        _contentView.backgroundColor = UIColor.whiteColor;
        [_contentView setPartRoundCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadius:8];
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"";
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = [UIColor dt_colorWithHexString:@"#000000" alpha:1];
        _titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
    }
    return _titleLabel;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = NSString.dt_home_coming_soon;
        _tipLabel.numberOfLines = 1;
        _tipLabel.textColor = [UIColor dt_colorWithHexString:@"#666666" alpha:1];
        _tipLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
    }
    return _tipLabel;
}

- (UIImageView *)previewView {
    if (!_previewView) {
        _previewView = [[UIImageView alloc] init];
        _previewView.image = [UIImage imageNamed:@"home_preview_0"];
        _previewView.clipsToBounds = YES;
        [_previewView dt_cornerRadius:8];
    }
    return _previewView;
}

- (UIView *)borderView {
    if (!_borderView) {
        _borderView = [[UIView alloc] init];
        _borderView.backgroundColor = HEX_COLOR_A(@"#FFFFFF", 0.31);
        _borderView.layer.cornerRadius = 22;
    }
    return _borderView;
}

- (UIButton *)createBtn {
    if (!_createBtn) {
        _createBtn = UIButton.new;
        [_createBtn setTitle:NSString.dt_home_create_room forState:UIControlStateNormal];
        _createBtn.backgroundColor = HEX_COLOR(@"#FFFFFF");
        _createBtn.titleLabel.font = UIFONT_BOLD(17);
        _createBtn.layer.cornerRadius = 18;
        [_createBtn addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createBtn;
}

@end
