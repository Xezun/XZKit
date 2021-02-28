//
//  XZAppLanguageBundle.h
//  XZKit
//
//  Created by Xezun on 2021/2/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZAppLanguageBundle : NSBundle
- (NSString *)localizedStringForKey:(NSString *)key value:(nullable NSString *)value table:(nullable NSString *)tableName;
- (BOOL)xz_supportsInAppLanguageSwitching;
@end

NS_ASSUME_NONNULL_END
