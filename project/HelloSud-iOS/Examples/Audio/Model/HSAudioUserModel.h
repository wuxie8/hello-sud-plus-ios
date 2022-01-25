//
//  HSAudioUserModel.h
//  HelloSud-iOS
//
//  Created by kaniel on 2022/1/24.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 用户信息model
@interface HSAudioUserModel : BaseModel
/// 用户ID
@property(nonatomic, copy)NSString *userID;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *icon;
@property(nonatomic, assign)NSInteger sex;
+ (instancetype)makeUserWithUserID:(NSString *)userID name:(NSString *)name icon:(NSString *)icon sex:(NSInteger)sex;
@end

NS_ASSUME_NONNULL_END
