//
//  TicketChooseViewController.m
//  HelloSud-iOS
//
//  Created by Mary on 2022/3/22.
//  Copyright © 2022 Sud.Tech (https://sud.tech). All rights reserved.
//

#import "TicketChooseViewController.h"
#import "TicketChooseItemView.h"
#import "TocketChooseModel.h"
#import "DTRollTableView.h"
#import "TicketJoinPopView.h"
#import "TicketService.h"

@interface TicketChooseViewController ()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) DTRollTableView *noticeView;
@end

@implementation TicketChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (BOOL)dtIsHiddenNavigationBar {
    return true;
}

- (void)dtAddViews {
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.noticeView];
    [self setupContentItems];
    
    self.noticeView.dataArray = [AppService.shared.ticket getTicketRewardAttributedStrArr];
    [self.noticeView reloadData];
}

- (void)dtLayoutViews {
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kAppSafeTop + 10);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_greaterThanOrEqualTo(CGSizeZero);
    }];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kAppSafeTop);
        make.left.mas_equalTo(6);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.noticeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(19);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(300, 30));
    }];
}

- (void)setupContentItems {
    NSArray <NSString *>*rewardArr = @[@"10", @"50", @"90"];
    for (int i = 0; i < 3; i++) {
        TicketChooseItemView *item = TicketChooseItemView.new;
        TocketChooseModel *model = TocketChooseModel.new;
        model.bgImgStr = [NSString stringWithFormat:@"tickets_item_%d_bg", i];
        model.goldImgStr = [NSString stringWithFormat:@"tickets_item_%d_gold", i];
        model.btnImgStr = [NSString stringWithFormat:@"tickets_item_%d_btn", i];
        model.rewardStr = [NSString stringWithFormat:@"赢%@倍奖励", rewardArr[i]];
        model.isHiddenHot = i == 0;
        item.model = model;
        item.tag = 1000 + i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickItemsEvent:)];
        [item addGestureRecognizer:tap];
        [self.view addSubview:item];
        [item mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(kStatusBarHeight + 44 + 85 + i * 187);
            make.left.mas_equalTo(14);
            make.right.mas_equalTo(-14);
            make.height.mas_equalTo(154);
        }];
    }
}

- (void)clickItemsEvent:(UITapGestureRecognizer *)tap {
    NSInteger tag = tap.view.tag - 1000 + 1;
    [AudioRoomService.shared reqMatchRoom:self.gameId sceneType:self.sceneId gameLevel:tag];
}

- (void)backEvent {
    [self.navigationController popViewControllerAnimated:true];
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tickets_bg"]];
    }
    return _bgImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = UILabel.new;
        _titleLabel.text = @"狼人杀";
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.font = UIFONT_MEDIUM(18);
    }
    return _titleLabel;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = UIButton.new;
        [_backBtn setImage:[UIImage imageNamed:@"tickets_navi_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (DTRollTableView *)noticeView {
    if (!_noticeView) {
        _noticeView = DTRollTableView.new;
    }
    return _noticeView;
}

@end
