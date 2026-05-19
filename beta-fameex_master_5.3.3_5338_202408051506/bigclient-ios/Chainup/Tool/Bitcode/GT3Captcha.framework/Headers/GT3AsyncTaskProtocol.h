//
//  GT3AsyncTaskProtocol.h
//  GT3Captcha
//
//  Created by NikoXu on 2019/12/10.
//  Copyright © 2019 Geetest. All rights reserved.
//

#import "GT3Parameter.h"
#import "GT3Error.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GT3AsyncTaskProtocol <NSObject>

/**Task for custom validation registration*/
- (void)executeRegisterTaskWithCompletion:(void(^)(GT3RegisterParameter * _Nullable params, GT3Error * _Nullable error))completion;

/**Task for custom validation result validation*/
- (void)executeValidationTaskWithValidateParam:(GT3ValidationParam *)param completion:(void(^)(BOOL validationResult, GT3Error * _Nullable error))completion;

/**Used to cancel all customized tasks*/
- (void)cancel;

@end

NS_ASSUME_NONNULL_END

