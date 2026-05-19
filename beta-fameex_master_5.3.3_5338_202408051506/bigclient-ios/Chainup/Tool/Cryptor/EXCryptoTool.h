//
//  EXCryptoTool.h
//  Chainup
//
//  Created by zq on 2024/6/27.
//  Copyright © 2024 Chainup. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EXCryptoTool : NSObject
///
+ (NSString * _Nullable)encryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv;
+ (NSString * _Nullable)decryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv;
///
+ (NSData * _Nullable)encryptedDataWith:(NSData *)data key:(NSData *)key iv:(NSData *)iv;
+ (NSData * _Nullable)decryptedDataWith:(NSData *)data key:(NSData *)key iv:(NSData *)iv;
@end

NS_ASSUME_NONNULL_END
