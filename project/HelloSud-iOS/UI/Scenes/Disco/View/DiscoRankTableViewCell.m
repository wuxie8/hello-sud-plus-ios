//
//  DiscoRankTableViewCell.m
//  HelloSud-iOS
//
//  Created by kaniel on 2022/6/30.
//  Copyright © 2022 Sud.Tech (https://sud.tech). All rights reserved.
//

#import "DiscoRankTableViewCell.h"
@interface DiscoRankTableViewCell()
@property(nonatomic, strong) UILabel *rankLabel;
@property(nonatomic, strong) UIImageView *rankImageView;
@property(nonatomic, strong) UIImageView *headImageView;
@property(nonatomic, strong) YYLabel *nameLabel;
@property(nonatomic, strong) YYLabel *winLabel;
@end

@implementation DiscoRankTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dtAddViews {
    [super dtAddViews];
    [self.contentView addSubview:self.rankLabel];
    [self.contentView addSubview:self.rankImageView];
    [self.contentView addSubview:self.headImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.winLabel];
}

- (void)dtLayoutViews {
    [super dtLayoutViews];

    [self.rankLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.greaterThanOrEqualTo(@0);
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(@21);
    }];
    [self.rankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@23);
        make.height.equalTo(@19);
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(@16);
    }];
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@36);
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(@57);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.greaterThanOrEqualTo(@0);
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.headImageView.mas_trailing).offset(8);
    }];
    [self.winLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.greaterThanOrEqualTo(@0);
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(@-16);
    }];
}

- (void)dtConfigUI {
    [super dtConfigUI];
    self.backgroundColor = UIColor.whiteColor;
}

- (void)dtUpdateUI {
    [super dtUpdateUI];
    if (![self.model isKindOfClass:DiscoContributionModel.class]) {
        return;
    }
    DiscoContributionModel *m = (DiscoContributionModel *)self.model;

    if (m.rank < 3) {
        self.rankImageView.hidden = NO;
        self.rankLabel.hidden = YES;
        self.rankImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"disco_rank_%@", @(m.rank + 1)]];
    } else {
        self.rankImageView.hidden = YES;
        self.rankLabel.hidden = NO;
        self.rankLabel.text = [NSString stringWithFormat:@"%@", @(m.rank + 1)];
    }
    if (m.fromUser.icon) {
        [self.headImageView sd_setImageWithURL:[[NSURL alloc] initWithString:m.fromUser.icon]];
    }
    [self updateWinCount:m.count];
    [self updateName:m.fromUser.name];
}

- (void)updateWinCount:(NSInteger)count {
    

    NSDictionary *dic = @{NSFontAttributeName: UIFONT_MEDIUM(16), NSForegroundColorAttributeName: HEX_COLOR(@"#000000")};
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", @(count)]
                                                                             attributes:dic];
    attr.yy_alignment = NSTextAlignmentRight;
    self.winLabel.attributedText = attr;
}

- (void)updateName:(NSString *)name {
    
    NSDictionary *dic = @{NSFontAttributeName: UIFONT_MEDIUM(16), NSForegroundColorAttributeName: HEX_COLOR(@"#000000")};
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", name]
                                                                             attributes:dic];
    attr.yy_alignment = NSTextAlignmentLeft;
    self.nameLabel.attributedText = attr;
}

- (YYLabel *)winLabel {
    if (!_winLabel) {
        _winLabel = [[YYLabel alloc] init];
        _winLabel.numberOfLines = 0;
        _winLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _winLabel;
}

- (YYLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[YYLabel alloc] init];
        _nameLabel.numberOfLines = 0;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel *)rankLabel {
    if (!_rankLabel) {
        _rankLabel = [[UILabel alloc] init];
        _rankLabel.font = UIFONT_MEDIUM(20);
        _rankLabel.textColor = HEX_COLOR_A(@"#000000", 0.6);
        _rankLabel.text = @"0";
        _rankLabel.textAlignment = NSTextAlignmentRight;
    }
    return _rankLabel;
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.clipsToBounds = YES;
        [_headImageView dt_cornerRadius:18];
    }
    return _headImageView;
}

- (UIImageView *)rankImageView {
    if (!_rankImageView) {
        _rankImageView = [[UIImageView alloc] init];
    }
    return _rankImageView;
}

@end
