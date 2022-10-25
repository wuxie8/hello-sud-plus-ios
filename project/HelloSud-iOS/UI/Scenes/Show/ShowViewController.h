//
//  ShowViewController.h
//  HelloSud-iOS
//
//  Created by kaniel on 2022/2/9.
//

#import "AudioRoomViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// 秀场场景
@interface ShowViewController : BaseSceneViewController
@property(nonatomic, strong, readonly) UIView *videoView;
- (void)resetVideoView;
@end

NS_ASSUME_NONNULL_END
