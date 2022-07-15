//
//  AppService.m
//  HelloSud-iOS
//
//  Created by kaniel on 2022/1/25.
//

#import "AppService.h"
#import "ZegoAudioEngineImpl.h"

/// 用户登录确认key
#define kKeyLoginAgreement @"key_login_agreement"

/// 当前选中RTC类型缓存key
#define kKeyCurrentRTCType @"key_current_rtc_type"
/// 配置信息缓存key
#define kKeyConfigModel @"key_config_model"
/// 配置信息缓存appId
#define kAppIdInfoModel @"key_appId_model"
/// 游戏环境
#define kKeyGameEnvType @"kKeyGameEnvType"

NSString *const kRtcTypeZego = @"zego";
NSString *const kRtcTypeAgora = @"agora";
NSString *const kRtcTypeRongCloud = @"rongCloud";
NSString *const kRtcTypeCommEase = @"commsEase";
NSString *const kRtcTypeVolcEngine = @"volcEngine";
NSString *const kRtcTypeAlibabaCloud = @"alibabaCloud";
NSString *const kRtcTypeTencentCloud = @"tencentCloud";


@interface AppService ()
@property(nonatomic, strong) NSArray <NSString *> *randomNameArr;

@end

@implementation AppService
+ (instancetype)shared {
    static AppService *g_manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        g_manager = AppService.new;
    });
    return g_manager;
}

- (LoginService *)login {
    if (!_login) {
        _login = [[LoginService alloc] init];
    }
    return _login;
}

- (void)prepare {
    [self.login prepare];
    [self config];
}

- (NSString *)loginUserID {
    return self.login.loginUserInfo.userID;
}

- (void)config {

    _isAgreement = [NSUserDefaults.standardUserDefaults boolForKey:kKeyLoginAgreement];
    id temp = [NSUserDefaults.standardUserDefaults objectForKey:kKeyGameEnvType];
    if (!temp){
        _gameEnvType = 4;// 默认dev
    } else {
        _gameEnvType = [temp integerValue];
    }

    NSString *cacheRTCType = [NSUserDefaults.standardUserDefaults stringForKey:kKeyCurrentRTCType];
    NSString *configStr = [NSUserDefaults.standardUserDefaults stringForKey:kKeyConfigModel];
    if (configStr) {
        _configModel = [ConfigModel mj_objectWithKeyValues:configStr];
    }
    NSString *appIdInfoStr = [NSUserDefaults.standardUserDefaults stringForKey:kAppIdInfoModel];
    if (appIdInfoStr) {
        _currentAppIdModel = [AppIDInfoModel mj_objectWithKeyValues:appIdInfoStr];
    }

    [self switchRtcType:cacheRTCType];
    [SettingsService reqAppIdListWithSuccess:^(NSArray<AppIDInfoModel *> *_Nonnull appIdList) {
        [self updateAppIdList:appIdList];
    }                                   fail:nil];
}

- (void)setConfigModel:(ConfigModel *)configModel {
    _configModel = configModel;
    [NSUserDefaults.standardUserDefaults setObject:[configModel mj_JSONString] forKey:kKeyConfigModel];
    [NSUserDefaults.standardUserDefaults synchronize];
    NSString *rtcType = self.rtcType;
    if (self.rtcType.length == 0 || !AudioEngineFactory.shared.audioEngine) {
        [self switchRtcType:rtcType];
    }
}

- (void)setRtcType:(NSString *)rtcType {
    _rtcType = rtcType;
    [NSUserDefaults.standardUserDefaults setObject:rtcType forKey:kKeyCurrentRTCType];
    [NSUserDefaults.standardUserDefaults synchronize];
}


/// 保存是否同意协议
- (void)saveAgreement {
    _isAgreement = true;
    [NSUserDefaults.standardUserDefaults setBool:true forKey:kKeyLoginAgreement];
    [NSUserDefaults.standardUserDefaults synchronize];
}

/// 随机名字
- (NSString *)randomUserName {
    int num = arc4random() % 100;
    return self.randomNameArr[num];
}

/// 设置请求header
- (void)setupNetWorkHeader {
    NSString *token = AppService.shared.login.token;
    if (AppService.shared.login.token) {
        [HSHttpService setupHeader:@{@"Authorization": token}];
        // 图片拉取鉴权
        SDWebImageDownloader *downloader = (SDWebImageDownloader *) [SDWebImageManager sharedManager].imageLoader;
        [downloader setValue:token forHTTPHeaderField:@"Authorization"];
    } else {
        DDLogError(@"设置APP请求头token为空");
    }
    NSString *locale = [SettingsService getCurLanguageLocale];
    NSString *clientChannel = @"appstore";
    NSString *clientVersion = [NSString stringWithFormat:@"%@", DeviceUtil.getAppVersion];
    NSString *buildNumber = DeviceUtil.getAppBuildCode;
    NSString *deviceId = DeviceUtil.getIdfv;
    NSString *systemType = @"iOS";
    NSString *systemVersion = DeviceUtil.getSystemVersion;
    NSString *clientTimestamp = [NSString stringWithFormat:@"%ld", (NSInteger) [NSDate date].timeIntervalSince1970];
    NSString *rtcType = AppService.shared.rtcType ? AppService.shared.rtcType : @"";
    NSArray *arr = @[
            locale,
            clientChannel,
            clientVersion,
            buildNumber,
            deviceId,
            systemType,
            systemVersion,
            clientTimestamp,
            rtcType
    ];
    NSString *sudMeta = [arr componentsJoinedByString:@","];
    [HSHttpService setupHeader:@{@"Sud-Meta": sudMeta}];
    DDLogInfo(@"Sud-Meta:%@", sudMeta);
}

- (void)setDefLanguage {

}

/// 登录成功请求配置信息
- (void)reqConfigData {
    WeakSelf
    [HSHttpService postRequestWithURL:kBASEURL(@"base/config/v1") param:nil respClass:ConfigModel.class showErrorToast:YES success:^(BaseRespModel *resp) {
        weakSelf.configModel = (ConfigModel *) resp;
    }                         failure:nil];
}

- (void)reqAppUpdate:(RespModelBlock)success fail:(nullable ErrorStringBlock)fail {
    [HSHttpService postRequestWithURL:kBASEURL(@"check-upgrade/v1") param:nil respClass:RespVersionUpdateInfoModel.class showErrorToast:YES success:^(BaseRespModel *resp) {
        success(resp);
    }                         failure:^(NSError *error) {
        if (fail) {
            fail(error.dt_errMsg);
        }
    }];
}

- (NSArray<NSString *> *)randomNameArr {
    if (!_randomNameArr) {
        _randomNameArr = @[@"哈利", @"祺祥", @"沐辰", @"阿米莉亚", @"齐默尔曼", @"陌北", @"旺仔", @"半夏", @"朝雨", @"卫斯理", @"阿道夫", @"长青", @"安小六", @"小凡", @"炎月", @"醉风", @"斯科特", @"布卢默", @"宛岩", @"平萱", @"凝雁", @"怀亚特", @"格伦巴特", @"尔白", @"南露", @"爱丽丝", @"埃尔维斯", @"奥利维亚", @"妙竹", @"雲思衣", @"少女大佬", @"兔兔别跑", @"夏纱", @"嘉慕", @"阿拉贝拉", @"星剑", @"罗德斯", @"渡满归", @"星浅", @"问水", @"星奕晨", @"丹尼尔", @"白止扇", @"暖暖", @"埃迪", @"杰里米", @"玛德琳", @"波佩", @"卡诺", @"泡芙", @"帕特里克", @"梅雷迪斯", @"公孙昕", @"青弘", @"潘豆豆", @"小番秀二", @"大一宇", @"米奇", @"戴夫", @"伯特", @"米洛布雷", @"阿德莱德", @"吉宝", @"伊娃", @"路易斯", @"希拉姆", @"杰西", @"贝特西", @"利奥波德", @"丽塔", @"拉姆斯登", @"伯纳德", @"理查德", @"奥尔德里奇", @"劳里", @"奥兰多", @"埃尔罗伊", @"栗和顺", @"朱雀佳行", @"理德拉", @"凡勃伦", @"科波菲尔", @"玉谷大三", @"大木元司", @"钮阳冰", @"盖勤", @"紫心", @"弘慕慕", @"怀星驰", @"泉宏胜", @"闻人星海", @"Watt", @"Kevin", @"Toby", @"瓦利斯", @"苏珊娜", @"罗密欧", @"福克纳", @"多萝西", @"贝尔", @"卡门", @"安德烈", @"朱丽叶", @"吉姆"];
    }
    return _randomNameArr;
}

/// 刷新token
- (void)refreshToken {
    if (AppService.shared.login.isLogin) {
    }
}

/// 切换RTC厂商
/// @param rtcType 对应rtc厂商类型
- (void)switchRtcType:(NSString *)rtcType {
    NSString *changedRtcType = [self switchAudioEngine:rtcType];
    if (changedRtcType) {
        self.rtcType = changedRtcType;
    }
    [self setupNetWorkHeader];
}

- (BOOL)isSameRtc:(HSConfigContent *)rtcConfig rtcType:(NSString *)rtcType {
    if (rtcConfig) {
        return [rtcConfig isSameRtc:rtcType];
    }
    return NO;
}

/// 更新应用列表
/// @param appIdList 应用列表
- (void)updateAppIdList:(NSArray<AppIDInfoModel *> *)appIdList {
    self.appIdList = appIdList;
    if (!self.currentAppIdModel && appIdList.count > 0) {
        [self cacheAppIdInfoModel:appIdList[0]];
    }
}

- (void)cacheAppIdInfoModel:(AppIDInfoModel *)model {
    self.currentAppIdModel = model;
    [NSUserDefaults.standardUserDefaults setObject:model.mj_JSONString forKey:kAppIdInfoModel];
}

/// 游戏环境名称
/// @return
- (NSString *)gameEnvTypeName:(GameEnvType)envType {
//    1 pro 2 sim 3 fat 4 dev
    NSString *name = @"pro";
    switch (envType) {
        case GameEnvTypeSim:
            name = @"sim";
            break;
        case GameEnvTypeFat:
            name = @"fat";
            break;
        case GameEnvTypeDev:
            name = @"dev";
            break;
        default:
            name = @"pro";
            break;
    }
    return name;
}

/// 切换RTC语音SDK
/// @param rtcType 厂商类型
- (NSString *)switchAudioEngine:(NSString *)rtcType {

    HSConfigContent *rtcConfig = nil;
    DDLogInfo(@"切换RTC厂商:%@", rtcType);
    [AudioEngineFactory.shared.audioEngine destroy];

    rtcType = self.configModel.zegoCfg.rtcType;
    [AudioEngineFactory.shared createEngine:ZegoAudioEngineImpl.class];
    rtcConfig = self.configModel.zegoCfg;
    DDLogInfo(@"默认RTC厂商：%@", rtcType);

    /// 初始化引擎SDK
    NSString *appID = rtcConfig.appId;
    NSString *appKey = rtcConfig.appKey;
    if (appID.length > 0 || appKey.length > 0) {
        AudioConfigModel *model = [[AudioConfigModel alloc] init];
        model.appId = appID;
        model.appKey = appKey;
        self.rtcConfigModel = model;
        return rtcType;
    }
    return rtcType;
}

/// 通过gameID获取游戏总人数
/// @param gameID 游戏ID
- (NSInteger)getTotalGameCountWithGameID:(NSInteger)gameID {
    NSInteger count = 0;
    for (HSGameItem *item in self.gameList) {
        if (gameID == item.gameId) {
            if (item.gameModeList.count > 0) {
                count = [[item.gameModeList[0].count lastObject] integerValue];
            }
            break;
        }
    }
    return count;
}

/// 获取RTC厂商名称
/// @param rtcType rtc类型
- (NSString *)getRTCTypeName:(NSString *)rtcType {
    if ([rtcType dt_isInsensitiveEqualToString:kRtcTypeZego]) {
        return NSString.dt_settings_zego;
    } else if ([rtcType dt_isInsensitiveEqualToString:kRtcTypeAgora]) {
        return NSString.dt_settings_agora;
    } else if ([rtcType dt_isInsensitiveEqualToString:kRtcTypeRongCloud]) {
        return NSString.dt_settings_rong_cloud;
    } else if ([rtcType dt_isInsensitiveEqualToString:kRtcTypeCommEase]) {
        return NSString.dt_settings_net_ease;
    } else if ([rtcType dt_isInsensitiveEqualToString:kRtcTypeVolcEngine]) {
        return NSString.dt_settings_volcano;
    } else if ([rtcType dt_isInsensitiveEqualToString:kRtcTypeAlibabaCloud]) {
        return NSString.dt_settings_alicloud;
    } else if ([rtcType dt_isInsensitiveEqualToString:kRtcTypeTencentCloud]) {
        return NSString.dt_settings_tencent;
    }
    return @"";
}


/// 更新游戏类型
/// @param envType
- (void)updateGameEnvType:(GameEnvType)envType {
    self.gameEnvType = envType;
    [NSUserDefaults.standardUserDefaults setInteger:envType forKey:kKeyGameEnvType];
    [NSUserDefaults.standardUserDefaults synchronize];
}
@end


