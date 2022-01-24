//
//  BaseView.h
//  HelloSud-iOS
//
//  Created by kaniel on 2022/1/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 基础View
@interface BaseView : UIView

/// 增加子view
- (void)hsAddViews;
/// 布局视图
- (void)hsLayoutViews;
/// 配置事件
- (void)hsConfigEvents;
/// 试图初始化
- (void)hsConfigUI;
/// 更新UI
- (void)hsUpdateUI;
/**
 切部分圆角
 
 UIRectCorner有五种
 UIRectCornerTopLeft //上左
 UIRectCornerTopRight //上右
 UIRectCornerBottomLeft // 下左
 UIRectCornerBottomRight // 下右
 UIRectCornerAllCorners // 全部
 
 @param cornerRadius 圆角半径
 */
- (void)setPartRoundCorners:(UIRectCorner)corners cornerRadius:(CGFloat)cornerRadius;
@end

NS_ASSUME_NONNULL_END
