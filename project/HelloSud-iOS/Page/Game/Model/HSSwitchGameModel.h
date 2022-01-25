//
//  HSSwitchGameModel.h
//  HelloSud-iOS
//
//  Created by Mary on 2022/1/25.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 切换房间游戏
@interface HSSwitchGameModel : BaseModel
@property (nonatomic, assign) NSInteger              retCode;
@property (nonatomic, copy) NSString              * retMsg;

@end

NS_ASSUME_NONNULL_END
