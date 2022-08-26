//
//  WalletItemModel.h
//  SudMGP
//
//  Created by kaniel on 2022/7/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 钱包链类型
@interface SudNFTChainInfoModel : NSObject
/// 链名称
@property(nonatomic, copy) NSString *name;
/// 图标名称
@property(nonatomic, copy) NSString *icon;
/// 链类型
@property(nonatomic, assign) NSInteger type;
@end

/// 钱包数据模型
@interface SudNFTWalletInfoModel : NSObject
/// 钱包类型
@property(nonatomic, assign) NSInteger type;
/// 区域类型 0 海外， 1 国内
@property(nonatomic, assign) NSInteger zoneType;
/// 名称
@property(nonatomic, copy) NSString *name;
/// 图标
@property(nonatomic, copy) NSString *icon;
/// 支持链列表
@property(nonatomic, strong) NSArray<SudNFTChainInfoModel *> *chainList;
@property(nonatomic, strong)NSArray<SudNFTWalletInfoModel *> *walletList;
@end

/// 获取钱包列表数据模型
@interface SudNFTGetWalletListModel : NSObject
/// 钱包列表
@property(nonatomic, copy) NSArray<SudNFTWalletInfoModel *> *walletList;
@end

/// NFT数据模型
@interface SudNFTInfoModel : NSObject
/// 合约地址
@property(nonatomic, copy) NSString *contractAddress;
/// NFT tokenId
@property(nonatomic, copy) NSString *tokenId;
/// token类型
@property(nonatomic, copy) NSString *tokenType;
/// 名称
@property(nonatomic, copy) NSString *name;
/// 描述
@property(nonatomic, copy) NSString *desc;
/// 藏品地址
@property(nonatomic, copy) NSString *fileURL;
/// 藏品类型
@property(nonatomic, copy) NSString *fileType;
/// 封面，存在的情况下
@property(nonatomic, copy) NSString *coverURL;
@end

/// NFT数据模型
@interface SudNFTGetNFTListModel : NSObject
/// 合约列表
@property(nonatomic, copy) NSArray <SudNFTInfoModel *> *nftList;
/// 总数量
@property(nonatomic, assign) NSInteger totalCount;
/// 分页键，第一次不设置，当返回值存在page_key时，使用该值请求下一页数据，page_key有效期10分钟
@property(nonatomic, copy) NSString *pageKey;
@end

/// 钱包信息
@interface SudNFTBindWalletModel : NSObject
/// 钱包地址
@property(nonatomic, copy) NSString *walletAddress;
/// 钱包绑定token
@property(nonatomic, copy) NSString *walletToken;
/// token过期时间戳，毫秒
@property(nonatomic, assign) NSInteger expireAtMs;
/// token有效期延时，毫秒
@property(nonatomic, assign) NSInteger delayMs;
@end

/// 生成NFT详情token model (穿戴)
@interface SudNFTGenNFTCredentialsTokenModel : NSObject
/// nft详情令牌
@property(nonatomic, copy) NSString *nftDetailsToken;
@end

/// 初始化NFT参数model
@interface SudInitNFTParamModel : NSObject
/// 应用ID
@property(nonatomic, copy, nonnull) NSString *appId;
/// 应用key
@property(nonatomic, copy, nonnull) NSString *appKey;
/// 用户ID
@property(nonatomic, copy, nonnull) NSString *userId;
/// 应用universalLink; 前面必须完整https,后面不需要/ 如：https://links.example.com
@property(nonatomic, copy, nonnull) NSString *universalLink;
/// 是否测试环境 默认 NO, YES为测试环境，NO为正式环境
@property(nonatomic, assign) BOOL isTestEnv;
@end

/// 绑定钱包参数model
@interface SudNFTBindWalletParamModel : NSObject
/// 钱包类型
@property(nonatomic, assign) NSInteger walletType;
@end

/// 生成NFT使用凭证参数model
@interface SudNFTCredentialsTokenParamModel : NSObject
/// 钱包token
@property(nonatomic, copy) NSString *walletToken;
/// 合约地址
@property(nonatomic, copy, nonnull) NSString *contractAddress;
/// NFT tokenId
@property(nonatomic, copy, nonnull) NSString *tokenId;
/// 链网类型
@property(nonatomic, assign) NSInteger chainType;
@end

/// 获取NFT列表参数model
@interface SudNFTGetNFTListParamModel : NSObject
/// 钱包token
@property(nonatomic, copy) NSString *walletToken;
/// 钱包地址
@property(nonatomic, copy, nonnull) NSString *walletAddress;
/// 分页key,首页可不传,下一页时，请求上一页返回pageKey
@property(nonatomic, copy, nullable) NSString *pageKey;
/// 链网类型
@property(nonatomic, assign) NSInteger chainType;
@end

#pragma mark CN

/// 发送验证码参数model [CN]
@interface SudNFTSendVerifyCodeParamModel : NSObject
/// 手机号码
@property(nonatomic, copy) NSString *phone;
/// 钱包类型
@property(nonatomic, assign) NSInteger walletType;
@end

/// 绑定用户参数model [CN]
@interface SudNFTBindUserParamModel : NSObject
/// 手机号码
@property(nonatomic, copy) NSString *phone;
/// 验证码
@property(nonatomic, copy) NSString *phoneCode;
/// 用ID
@property(nonatomic, copy) NSString *userId;
/// 钱包类型
@property(nonatomic, assign) NSInteger walletType;
@end

/// 钱包信息
@interface SudNFTBindUserModel : NSObject
/// 钱包绑定token
@property(nonatomic, copy) NSString *walletToken;
/// token过期时间戳，毫秒
@property(nonatomic, assign) NSInteger expireAtMs;
/// token有效期延时，毫秒
@property(nonatomic, assign) NSInteger delayMs;
@end

/// 获取藏品列表参数model
@interface SudNFTGetCardListParamModel : NSObject
/// 钱包类型
@property(nonatomic, assign) NSInteger walletType;
/// 钱包绑定token
@property(nonatomic, copy) NSString *walletToken;
/// 页码，从0开始
@property(nonatomic, assign) NSInteger page;
/// 每页大小
@property(nonatomic, assign) NSInteger pageSize;
@end

/// 藏品信息model
@interface SudNFTCardModel : NSObject
/// 名称
@property(nonatomic, copy) NSString *name;
/// 描述
@property(nonatomic, copy) NSString *desc;
/// 藏品地址
@property(nonatomic, copy) NSString *fileURL;
/// 封面
@property(nonatomic, copy) NSString *coverURL;
/// hash
@property(nonatomic, copy) NSString *hash;
/// 链地址
@property(nonatomic, copy) NSString *chainAddr;
/// 藏品ID
@property(nonatomic, copy) NSString *cardId;
/// 藏品文件类型
@property(nonatomic, assign) NSInteger fileType;
@end

/// 藏品信息返回列表
@interface SudNFTGetCardListModel : NSObject
/// 当前页
@property(nonatomic, assign) NSInteger page;
/// 总数
@property(nonatomic, assign) NSInteger totalCount;
/// 藏品列表
@property(nonatomic, assign) NSArray<SudNFTGetCardListModel *> *list;
@end

/// 生成藏品使用参数model
@interface SudNFTCardCredentialsTokenParamModel : NSObject
/// 钱包类型
@property(nonatomic, assign) NSInteger walletType;
/// 钱包绑定token
@property(nonatomic, copy) NSString *walletToken;
/// 藏品ID
@property(nonatomic, copy) NSString *cardId;
@end

/// 生成藏品使用认证token model (穿戴)
@interface SudNFTCardCredentialsTokenModel : NSObject
/// nft详情令牌
@property(nonatomic, copy) NSString *detailsToken;
@end

NS_ASSUME_NONNULL_END
