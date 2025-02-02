//
//  SettingsService.m
//  HelloSud-iOS
//
//  Created by kaniel on 2022/2/17.
//

#import "SettingsService.h"
/// json文件变更的时候改变版本号，重新读取JSON文件，之前本地设置将重复恢复默认值
static NSString *const DTCustotmModelKeyVersion = @"1.3";
#define DTCustotmModelKey [NSString stringWithFormat:@"%@%@", @"DTCustotmModelKey", DTCustotmModelKeyVersion]
@implementation SettingsService

/// APP隐私协议地址
+ (NSURL *)appPrivacyURL {
    NSString *path = [NSBundle.mainBundle pathForResource:@"user_privacy" ofType:@"html" inDirectory:@"Res"];
    return [NSURL fileURLWithPath:path];
}
/// APP用户协议
+ (NSURL *)appProtocolURL {
    NSString *path = [NSBundle.mainBundle pathForResource:@"user_protocol" ofType:@"html" inDirectory:@"Res"];
    return [NSURL fileURLWithPath:path];
}
/// 开源协议
+ (NSURL *)appLicenseURL {
    NSString *path = [NSBundle.mainBundle pathForResource:@"license" ofType:@"html" inDirectory:@"Res"];
    return [NSURL fileURLWithPath:path];
}

/// 默认英文
+ (NSString *)getCurLanguageLocale {
    NSString *language = [SettingsService getCurLanguage];
    if ([language isEqualToString:@""]) {
        return @"en-US";
    }
    return language;
}

/// 不支持的语言
+ (BOOL)isNotSupportLanguage {
    NSString *language = [SettingsService getCurLanguage];
    if ([language isEqualToString:@""]) {
        return true;
    }
    return false;
}

/// 获取当前
+ (NSString *)getCurLanguage {
    NSString *local = NSBundle.currentLanguage;// [NSLocale preferredLanguages].firstObject;
    NSArray <SwitchLangModel *>*dataArray = [self getLanguageArr];
    for (SwitchLangModel *m in dataArray) {
        if (m.language == nil) {
            continue;
        }
        if ([m.language containsString:local]) {
            return m.locale;
        }
    }
    return @"";
}

+ (NSArray <SwitchLangModel *> *)getLanguageArr {
    SwitchLangModel *m_0 = [SwitchLangModel new];
    m_0.title = NSString.dt_follow_system;
    m_0.language = nil;
    m_0.isSelect = YES;
    
    SwitchLangModel *m_1 = [SwitchLangModel new];
    m_1.title = @"简体中文";
    m_1.language = [@"zh-Hans" languageCountryCode];
    m_1.locale = @"zh-CN";
    
    SwitchLangModel *m_2 = [SwitchLangModel new];
    m_2.title = @"繁體中文";
    m_2.language = [@"zh-Hant" languageCountryCode];
    m_2.locale = @"zh-TW";
    
    SwitchLangModel *m_3 = [SwitchLangModel new];
    m_3.title = @"English";
    m_3.language = [@"en" languageCountryCode];
    m_3.locale = @"en-US";
    
    SwitchLangModel *m_4 = [SwitchLangModel new];
    m_4.title = @"لغة عربية";
    m_4.language = [@"ar" languageCountryCode];
    m_4.locale = @"ar-SA";
    
    SwitchLangModel *m_5 = [SwitchLangModel new];
    m_5.title = @"Bahasa Indonesia";
    m_5.language = [@"id" languageCountryCode];
    m_5.locale = @"id-ID";
    
    SwitchLangModel *m_6 = [SwitchLangModel new];
    m_6.title = @"Bahasa Melayu";
    m_6.language = [@"ms" languageCountryCode];
    m_6.locale = @"ms-MY";
    
    SwitchLangModel *m_7 = [SwitchLangModel new];
    m_7.title = @"ภาษาไทย";
    m_7.language = [@"th" languageCountryCode];
    m_7.locale = @"th-TH";
    
    SwitchLangModel *m_8 = [SwitchLangModel new];
    m_8.title = @"Tiếng Việt";
    m_8.language = [@"vi" languageCountryCode];
    m_8.locale = @"vi-VN";
    
    SwitchLangModel *m_9 = [SwitchLangModel new];
    m_9.title = @"한국어";
    m_9.language = [@"ko" languageCountryCode];
    m_9.locale = @"ko-KR";
    
    SwitchLangModel *m_10 = [SwitchLangModel new];
    m_10.title = @"Español";
    m_10.language = [@"es" languageCountryCode];
    m_10.locale = @"es-ES";
    
    SwitchLangModel *m_11 = [SwitchLangModel new];
    m_11.title = @"日本語";
    m_11.language = [@"ja" languageCountryCode];
    m_11.locale = @"ja-JP";

    SwitchLangModel *m_12 = [SwitchLangModel new];
    m_12.title = @"اردو";
    m_12.language = [@"ur" languageCountryCode];
    m_12.locale = @"ur-PK";
    
    SwitchLangModel *m_13 = [SwitchLangModel new];
    m_13.title = @"Türkçe";
    m_13.language = [@"tr" languageCountryCode];
    m_13.locale = @"tr-TR";
    
    SwitchLangModel *m_14 = [SwitchLangModel new];
    m_14.title = @"Português";
    m_14.language = [@"pt" languageCountryCode];
    m_14.locale = @"pt-PT";
    
    SwitchLangModel *m_15 = [SwitchLangModel new];
    m_15.title = @"हिंदी";
    m_15.language = [@"hi" languageCountryCode];
    m_15.locale = @"hi-IN";
    
    SwitchLangModel *m_16 = [SwitchLangModel new];
    m_16.title = @"বাংলা";
    m_16.language = [@"bn" languageCountryCode];
    m_16.locale = @"bn-BD";
    
    SwitchLangModel *m_17 = [SwitchLangModel new];
    m_17.title = @"Tagalog (Pilipinas)";
    m_17.language = [@"tl" languageCountryCode];
    m_17.locale = @"tl-PH";
    
    NSArray <SwitchLangModel *>*dataArray = @[m_0, m_1, m_2, m_3, m_4, m_5, m_6, m_7, m_8, m_9, m_10, m_11, m_12, m_13, m_14, m_15, m_16, m_17];
    return dataArray;
}

+ (NSDictionary *)readJsonLocalFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:kNilOptions
                                             error:nil];
}

#pragma mark - Language
+ (void)setRoomCustomModel:(RoomCustomModel *)model {
    NSString *jsonStr = [model mj_JSONString];
    [[NSUserDefaults standardUserDefaults] setValue:jsonStr forKey:DTCustotmModelKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (RoomCustomModel *)roomCustomModel {
    NSString *jsonStr = [[NSUserDefaults standardUserDefaults] valueForKey:DTCustotmModelKey];
    if (jsonStr == nil) {
        return nil;
    }
    RoomCustomModel *model = [RoomCustomModel mj_objectWithKeyValues:jsonStr];
    return model;
}

@end


@implementation NSString (Language)

- (NSString *)languageCountryCode {
    if (@available(iOS 10.0, *)) {
        return [NSString stringWithFormat:@"%@-%@", self, NSLocale.currentLocale.countryCode];
    } else {
        return self;
    }
}

@end
