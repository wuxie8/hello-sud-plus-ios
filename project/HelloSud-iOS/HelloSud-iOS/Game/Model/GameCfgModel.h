//
//  GameCfgModel.h
//  HelloSud-iOS
//
//  Created by Mary on 2022/2/17.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface GameCfgLobbyPlayers : BaseModel
@property (nonatomic, assign) BOOL hide;

@end

@interface GameCfgUIModel : BaseModel
@property (nonatomic, strong) GameCfgLobbyPlayers *lobby_players;

@end

@interface GameCfgModel : BaseModel
@property (nonatomic, strong) GameCfgUIModel *ui;

@end

NS_ASSUME_NONNULL_END
