//
//  ServiceConstHeader.h
//  HelloSud-iOS
//
//  Created by kaniel on 2022/2/19.
//

#ifndef ServiceConstHeader_h
#define ServiceConstHeader_h

#define kBASEURL(url) [NSString stringWithFormat:@"%@/%@",HsAppPreferences.shared.baseUrl, url]
#define kINTERACTURL(url) [NSString stringWithFormat:@"%@/%@",HsAppPreferences.shared.interactUrl, url]
#define kGameURL(url) [NSString stringWithFormat:@"%@/%@",HsAppPreferences.shared.gameUrl, url]
#endif /* ServiceConstHeader_h */
