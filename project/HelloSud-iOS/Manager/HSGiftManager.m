//
//  HSGiftManager.m
//  HelloSud-iOS
//
//  Created by kaniel on 2022/1/25.
//

#import "HSGiftManager.h"

@interface HSGiftManager()
@property(nonatomic, strong)NSDictionary<NSString*, HSGiftModel*> *dicGift;
@end

@implementation HSGiftManager

+ (instancetype)shared {
    static HSGiftManager *g_manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        g_manager = HSGiftManager.new;
    });
    return g_manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self config];
    }
    return self;
}

- (void)config {
    
    HSGiftModel *giftSvga = HSGiftModel.new;
    giftSvga.giftID = 1;
    giftSvga.smallGiftURL = [NSBundle.mainBundle pathForResource:@"svga_128" ofType:@"png" inDirectory:@"Res"];
    giftSvga.giftURL = [NSBundle.mainBundle pathForResource:@"svga_600" ofType:@"png" inDirectory:@"Res"];
    giftSvga.animateURL = [NSBundle.mainBundle pathForResource:@"svga_600" ofType:@"svga" inDirectory:@"Res"];
    giftSvga.animateType = @"svga";
    giftSvga.giftName = @"svga";
    
    HSGiftModel *giftLottie = HSGiftModel.new;
    giftLottie.giftID = 2;
    giftLottie.smallGiftURL = [NSBundle.mainBundle pathForResource:@"lottie_128" ofType:@"png" inDirectory:@"Res"];
    giftLottie.giftURL = [NSBundle.mainBundle pathForResource:@"lottie_600" ofType:@"png" inDirectory:@"Res"];
    giftLottie.animateURL = [NSBundle.mainBundle pathForResource:@"lottie_600" ofType:@"json" inDirectory:@"Res"];
    giftLottie.animateType = @"lottie";
    giftLottie.giftName = @"lottie";
    
    HSGiftModel *giftWebp = HSGiftModel.new;
    giftWebp.giftID = 3;
    giftWebp.smallGiftURL = [NSBundle.mainBundle pathForResource:@"webp_128" ofType:@"png" inDirectory:@"Res"];
    giftWebp.giftURL = [NSBundle.mainBundle pathForResource:@"webp_600" ofType:@"png" inDirectory:@"Res"];
    giftWebp.animateURL = [NSBundle.mainBundle pathForResource:@"webp_600" ofType:@"webp" inDirectory:@"Res"];
    giftWebp.animateType = @"webp";
    giftWebp.giftName = @"webp";
    
    HSGiftModel *giftMP4 = HSGiftModel.new;
    giftMP4.giftID = 4;
    giftMP4.smallGiftURL = [NSBundle.mainBundle pathForResource:@"mp4_128" ofType:@"png" inDirectory:@"Res"];
    giftMP4.giftURL = [NSBundle.mainBundle pathForResource:@"mp4_600" ofType:@"png" inDirectory:@"Res"];
    giftMP4.animateURL = [NSBundle.mainBundle pathForResource:@"mp4_600" ofType:@"mp4" inDirectory:@"Res"];
    giftMP4.animateType = @"mp4";
    giftMP4.giftName = @"mp4";
    _giftList = @[giftSvga, giftLottie, giftWebp, giftMP4];
    self.dicGift = @{[NSString stringWithFormat:@"%ld", (long)giftSvga.giftID] : giftSvga,
                     [NSString stringWithFormat:@"%ld", (long)giftLottie.giftID] : giftLottie,
                     [NSString stringWithFormat:@"%ld", (long)giftWebp.giftID] : giftWebp,
                     [NSString stringWithFormat:@"%ld", (long)giftMP4.giftID] : giftMP4,
    };
    
}

/// 获取礼物信息
/// @param giftID 礼物ID
- (nullable HSGiftModel *)giftByID:(NSInteger)giftID {
    NSString *strGiftID = [NSString stringWithFormat:@"%ld", giftID];
    return self.dicGift[strGiftID];
}
@end
