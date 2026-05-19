
#import "FingerPrintVerify.h"
#import "Chainup-Swift.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation FingerPrintVerify



#pragma mark
+ (void)fingerPrintLocalAuthenticationFallBackTitle:(NSString *)fallBackTitle localizedReason:(NSString *)reasonTitle callBack:(void(^)(BOOL isSuccess,NSError *_Nullable error,NSString *referenceMsg))fingerBlock
{
    //Create LAContext
    LAContext *context = [LAContext new]; //This attribute is an option to set the pop-up box after fingerprint input failure
    context.localizedFallbackTitle = fallBackTitle;
    NSError *error = nil;
    if (@available(iOS 9.0, *)) {
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication
                                 error:&error]) {
            NSLog(@"start recognition");
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication
                    localizedReason:reasonTitle reply:^(BOOL success, NSError * _Nullable error) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            fingerBlock(success,error,[self referenceErrorCode:error.code fallBack:fallBackTitle]);
                        }];
                    }];
        }else{
            NSLog(@"not supported");
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                fingerBlock(false,error,[self referenceErrorCode:error.code fallBack:fallBackTitle]);
            }];
            
            NSLog (@"[MHD_FingerPrintVerify] error is:% @", error. localizedDescription);
        }
    } else {
        // Fallback on earlier versions
    }
}

+ (void)fingerIsSupportCallBack:(void (^)(NSString *))fingerBlock{
    
    //Check if the device supports TouchID or FaceID
    if (@available(iOS 9.0, *)) {
        LAContext *context = [LAContext new]; //This attribute is an option to set the pop-up box after fingerprint input failure
        
        NSError *authError = nil;
        BOOL isCanEvaluatePolicy = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&authError];
        
        if (authError) {
            NSLog(@"Failed to detect whether the device supports TouchID or FaceID!  N error:==% @", authError. localizedDescription);
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                fingerBlock(@"0");
            }];
            
        } else {
            if (isCanEvaluatePolicy) {
                //Determine whether the device supports TouchID or FaceID
                if (@available(iOS 11.0, *)) {
                    switch (context.biometryType) {
                        case LABiometryNone:
                        {
                            NSLog(@"Does this device support FaceID and TouchID");
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                fingerBlock(@"0");
                            }];
                            
                        }
                            break;
                        case LABiometryTypeTouchID:
                        {
                            NSLog (@"This device supports TouchID");
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                fingerBlock(@"1");
                            }];
                            
                        }
                            break;
                        case LABiometryTypeFaceID:
                        {
                            NSLog(@"This device supports Face ID");
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                fingerBlock(@"2");
                            }];
                            
                        }
                            break;
                        default:
                            break;
                    }
                } else {
                    NSLog(@"This device supports TouchID");
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        fingerBlock(@"1");
                    }];
                    
                }
                
            } else {
                NSLog(@"Does this device support FaceID and TouchID");
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    fingerBlock(@"0");
                }];
                
            }
        }
        
    } else {
        // Fallback on earlier versions
        NSLog (@"Does this device support FaceID and TouchID");
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            fingerBlock(@"0");
        }];
        
    }
    
    
    
    
}
+ (void)fingerIsSupportCallBack1:(void (^)(NSString *))fingerBlock{
    
    //Check if the device supports TouchID or FaceID
    if (@available(iOS 9.0, *)) {
        LAContext *context = [LAContext new]; //This attribute is an option to set the pop-up box after fingerprint input failure
        
        NSError *authError = nil;
        BOOL isCanEvaluatePolicy = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError];
        
//        if (authError) {
//NSLog (@ "Failed to detect whether the device supports TouchID or FaceID!  N error:==% @", authError. localizedDescription);
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                fingerBlock(@"0");
//            }];
//
//        } else {
//            if (isCanEvaluatePolicy) {
                //Determine whether the device supports TouchID or FaceID
                if (@available(iOS 11.0, *)) {
                    switch (context.biometryType) {
                        case LABiometryNone:
                        {
                            NSLog(@"Does this device support FaceID and TouchID");
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                fingerBlock(@"0");
                            }];
                            
                        }
                            break;
                        case LABiometryTypeTouchID:
                        {
                            NSLog (@"This device supports TouchID");
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                fingerBlock(@"1");
                            }];
                            
                        }
                            break;
                        case LABiometryTypeFaceID:
                        {
                            NSLog(@"This device supports Face ID");
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                fingerBlock(@"2");
                            }];
                            
                        }
                            break;
                        default:
                            break;
                    }
                } else {
                    NSLog(@"This device supports TouchID");
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        fingerBlock(@"1");
                    }];
                    
                }
                
//            } else {
//NSLog (@ "Does this device support FaceID and TouchID");
//                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                    fingerBlock(@"0");
//                }];
//
//            }
//        }
        
    } else {
        // Fallback on earlier versions
        NSLog(@"Does this device support FaceID and TouchID");
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            fingerBlock(@"0");
        }];
    }
}
    
#pragma mark returned incorrect reference information
+ (NSString *)referenceErrorCode:(NSInteger)errorCode fallBack:(NSString *)fallBackStr
{
    switch (errorCode) {
        case LAErrorAuthenticationFailed:
            return [LanguageTools getStringWithKey:@"login_tip_authFail"];
            break;
        case LAErrorUserCancel:
            return [LanguageTools getStringWithKey:@"login_tip_userCancelAuth"];
            break;
        case LAErrorUserFallback:
            return fallBackStr;
            break;
        case LAErrorSystemCancel:
            return [LanguageTools getStringWithKey:@"login_tip_systemCancelAuth"];
            break;
        case LAErrorPasscodeNotSet:
            return [LanguageTools getStringWithKey:@"login_tip_systemNoPassword"];
            break;
        case LAErrorBiometryNotAvailable:
            return [LanguageTools getStringWithKey:@"login_tip_deviceNotAvailable"];
            break;
        case LAErrorBiometryNotEnrolled:
            return [LanguageTools getStringWithKey:@"login_tip_deviceNotAvailable"];
            break;
        case LAErrorBiometryLockout:
            return [LanguageTools getStringWithKey:@"login_tip_authCompleteFail"];
            break;
        case LAErrorAppCancel:
            return [LanguageTools getStringWithKey:@"login_tip_authAppCancel"];
            break;
        case LAErrorInvalidContext:
            return [LanguageTools getStringWithKey:@"login_tip_authUserLoseEfficacy"];
            break;
        case LAErrorNotInteractive:
            return [LanguageTools getStringWithKey:@"login_tip_authAppStillending"];
            break;
        default:
            return [LanguageTools getStringWithKey:@"login_tip_authSuccess"];
            break;
    }
}
@end

