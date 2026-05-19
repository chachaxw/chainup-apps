//
//  GT3Error.h
//  GTViewManager
//
//  Created by NikoXu on 8/16/16.
//  Copyright © 2016 Geetest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
*Wrong type of extreme definition
 */
typedef NS_ENUM(NSUInteger, GT3ErrorType) {
/**Unknown error type*/
    GT3ErrorTypeUnknown = 0,
/**User interrupt verification caused*/
    GT3ErrorTypeUser,
/**The server returned an error*/
    GT3ErrorTypeServer,
/**Internal network threw error type*/
    GT3ErrorTypeNetWorking,
/**Error types thrown by internal browsers*/
    GT3ErrorTypeWebView,
/**Error types thrown from the front-end library*/
    GT3ErrorTypeJavaScript,
/**Internal decoding error type*/
    GT3ErrorTypeDecode,
/**External error type*/
    GT3ErrorTypeExtern
};

/**
*NSError in polar packaging
 */
@interface GT3Error : NSError

/**The metadata received when an error occurs, nil if there is no data*/
@property (nonatomic, readonly, strong) NSData * _Nullable metaData;
/**Error codes for locating polar problems*/
@property (nonatomic, strong, readonly) NSString *error_code;
/**Extreme additional error information, returning userInfo*/
@property (nonatomic, readonly, strong) NSString *gtDescription;

/**Original error*/
@property (nonatomic, readonly, strong) NSError * _Nullable originalError;

/** 
*Initialize GT3Error through the provided detailed parameters
 *  @seealso NSError
 */
+ (instancetype)errorWithDomainType:(GT3ErrorType)type code:(NSInteger)code userInfo:(nullable NSDictionary *)dict withGTDesciption:(NSString *)description;
/** 
*Based on the provided NSError, package it into GT3Error
 *  @seealso NSError
 */
+ (instancetype)errorWithDomainType:(GT3ErrorType)type originalError:(NSError *)originalError withGTDesciption:(NSString *)description;

@end

NS_ASSUME_NONNULL_END

