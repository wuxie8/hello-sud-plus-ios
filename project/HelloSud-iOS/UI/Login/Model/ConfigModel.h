//
//  ConfigModel.h
//  HelloSud-iOS
//
//  Created by Mary on 2022/1/26.
//

#import "BaseRespModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface HSConfigContent : BaseModel
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *appKey;
/// rtc厂商类型
@property (nonatomic, strong) NSString *rtcType;
/// 厂商描述
@property (nonatomic, strong) NSString *desc;

- (BOOL)isSameRtc:(NSString *)rtcType;
@end

/// 配置
@interface ConfigModel : BaseRespModel
@property (nonatomic, strong) HSConfigContent *zegoCfg;
@property (nonatomic, strong) HSConfigContent *agoraCfg;
@property (nonatomic, strong) HSConfigContent *tencentCloudCfg;
@property (nonatomic, strong) HSConfigContent *rongCloudCfg;
@property (nonatomic, strong) HSConfigContent *commsEaseCfg;
@property (nonatomic, strong) HSConfigContent *alibabaCloudCfg;
@property (nonatomic, strong) HSConfigContent *volcEngineCfg;
@property (nonatomic, strong) HSConfigContent *sudCfg;
@property (nonatomic, assign) NSInteger accountStatus;
@end

NS_ASSUME_NONNULL_END
