//
//  TicketService.m
//  HelloSud-iOS
//
//  Created by Mary on 2022/3/29.
//  Copyright © 2022 Sud.Tech (https://sud.tech). All rights reserved.
//

#import "BaseballService.h"

@implementation BaseballService

+ (id)decodeModel:(Class)cls FromDic:(NSDictionary *)data {
    if (data && ![data isKindOfClass:[NSNull class]]) {
        return [cls mj_objectWithKeyValues:data];
    } else {
        return [cls new];
    }
}

/// 查询我的排行榜
+ (void)reqMyRankingWithFinished:(void (^)(AppBaseballMyRankingModel *respModel))finished {
    NSDictionary *dicParam = @{};
    [HSHttpService postRequestWithURL:kGameURL(@"baseball/my-ranking/v1") param:dicParam respClass:BaseRespModel.class showErrorToast:YES success:^(BaseRespModel *resp) {
        AppBaseballMyRankingModel *model = [self decodeModel:AppBaseballMyRankingModel.class FromDic:resp.srcData];
        if (finished) {
            finished(model);
        }
    }                         failure:nil];
}

/// 排行榜
+ (void)reqRanking:(MGBaseballRanking *)reqModel finished:(void (^)(AppBaseballRankingModel *respModel))finished {
    NSDictionary *dicParam = @{@"page": @(reqModel.page), @"size": @(reqModel.size)};
    [HSHttpService postRequestWithURL:kGameURL(@"baseball/ranking/v1") param:dicParam respClass:BaseRespModel.class showErrorToast:YES success:^(BaseRespModel *resp) {
        AppBaseballRankingModel *model = [self decodeModel:AppBaseballRankingModel.class FromDic:resp.srcData];
        if (finished) {
            finished(model);
        }
    }                         failure:nil];
}

/// 查询排在自己前后的玩家数据
+ (void)reqRangeInfo:(MGBaseballRangeInfo *)reqModel finished:(void (^)(AppBaseballRangeInfoModel *respModel))finished {
    NSDictionary *dicParam = @{@"distance": @(reqModel.distance)};
    [HSHttpService postRequestWithURL:kGameURL(@"baseball/range-info/v1") param:dicParam respClass:BaseRespModel.class showErrorToast:YES success:^(BaseRespModel *resp) {
        AppBaseballRangeInfoModel *model = [self decodeModel:AppBaseballRangeInfoModel.class FromDic:resp.srcData];
        if (finished) {
            finished(model);
        }
    }                         failure:nil];
}
@end
