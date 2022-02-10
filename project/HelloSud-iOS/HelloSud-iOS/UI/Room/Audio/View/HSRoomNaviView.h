//
//  HSRoomNaviView.h
//  HelloSud-iOS
//
//  Created by Mary on 2022/1/21.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN
/// 房间导航栏
@interface HSRoomNaviView : BaseView
typedef void(^OnTapGameCallBack)(HSGameList *m);
@property (nonatomic, copy) OnTapGameCallBack onTapGameCallBack;
@property(nonatomic, copy)UIBUTTON_TAP_BLOCK closeTapBlock;
@property (nonatomic, strong) UILabel *roomNameLabel;
@end

NS_ASSUME_NONNULL_END
