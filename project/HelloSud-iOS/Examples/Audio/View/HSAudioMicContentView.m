//
//  HSAudioMicContentView.m
//  HelloSud-iOS
//
//  Created by Mary on 2022/1/21.
//

#import "HSAudioMicContentView.h"
#import "HSAudioMicroView.h"

@interface HSAudioMicContentView ()
@property (nonatomic, strong) HSAudioMicroView *ownerMicView;
@property (nonatomic, strong) UIView *containerView;

@end

@implementation HSAudioMicContentView

- (void)hsConfigUI {
    WeakSelf
    for (UIView * v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    self.ownerMicView.micType = HSAudioMic;
    self.ownerMicView.onTapCallback = ^(HSAudioRoomMicModel * _Nonnull micModel) {
        if (weakSelf.onTapCallback) weakSelf.onTapCallback(micModel);
    };
    HSAudioRoomMicModel *m = HSAudioRoomMicModel.new;
    m.micIndex = 0;
    self.ownerMicView.model = m;
    [self.micArr addObject:self.ownerMicView];
    for (int i = 1; i < 9; i++) {
        HSAudioMicroView *micNode = [[HSAudioMicroView alloc] init];
        micNode.headWidth = 54;
        micNode.micType = HSAudioMic;
        micNode.onTapCallback = ^(HSAudioRoomMicModel * _Nonnull micModel) {
            if (weakSelf.onTapCallback) weakSelf.onTapCallback(micModel);
        };
        HSAudioRoomMicModel *m = HSAudioRoomMicModel.new;
        m.micIndex = i;
        micNode.model = m;
        [self.containerView addSubview:micNode];
        [self.micArr addObject:micNode];
    }
    CGFloat interitemSpac = (kScreenWidth - 44 - (54 * 4)) / 4;
    [self.containerView.subviews hs_mas_distributeSudokuViewsWithFixedItemWidth:54 fixedItemHeight:110
                                                fixedLineSpacing:0 fixedInteritemSpacing:interitemSpac
                                                       warpCount:4
                                                      topSpacing:0
                                                   bottomSpacing:0 leadSpacing:22 tailSpacing:22];
    if (self.updateMicArrCallBack) {
        self.updateMicArrCallBack(self.micArr);
    }
}

- (void)hsAddViews {
    [self addSubview:self.ownerMicView];
    [self addSubview:self.containerView];
}

- (void)hsLayoutViews {
    self.ownerMicView.headWidth = 72;
    [self.ownerMicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(72, 118));
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.ownerMicView.mas_bottom);
        make.left.right.equalTo(self);
        make.size.mas_greaterThanOrEqualTo(CGSizeZero);
        make.bottom.mas_equalTo(0);
    }];
}

- (HSAudioMicroView *)ownerMicView {
    if (!_ownerMicView) {
        _ownerMicView = [[HSAudioMicroView alloc] init];
    }
    return _ownerMicView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}

- (NSMutableArray *)micArr {
    if (_micArr == nil) {
        _micArr = NSMutableArray.new;
    }
    return _micArr;
}

@end
