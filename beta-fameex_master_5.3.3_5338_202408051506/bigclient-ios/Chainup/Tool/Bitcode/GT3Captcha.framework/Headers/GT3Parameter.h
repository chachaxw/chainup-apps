//
//  GT3Parameter.h
//  GT3Captcha
//
//  Created by NikoXu on 2019/12/10.
//  Copyright © 2019 Geetest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GT3RegisterParameter : NSObject

/**Verify ID (gt)*/
@property (nonatomic, strong) NSString *gt;

/**Verification serial number*/
@property (nonatomic, strong) NSString *challenge;

/**Verify the crash status@ (1) Normal, @ (0) is down*/
@property (nonatomic, strong) NSNumber *success;

@end

@interface GT3ValidationParam : NSObject

/**Verify the preliminary judgment results@ '1' passed, @ '0' did not pass*/
@property (nonatomic, strong) NSString *code;

/**Verify the results and verify the data. Use this data to verify the results through the validate interface to obtain the final validation result*/
@property (nullable, nonatomic, strong) NSDictionary *result;

/**Attached message*/
@property (nullable, nonatomic, strong) NSString *message;

@end

NS_ASSUME_NONNULL_END

