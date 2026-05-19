
#import <Foundation/Foundation.h>

@interface FingerPrintVerify : NSObject
/*
Error code description:
 
-1. LAErrorAuthenticationFailed: Authorization failed
-2. LAErrorUserCancel: User cancels verification of Touch ID
-3. LAErrorUserFallback: * * * Fingerprint verification failed, user selected option under 'fallBackTitle' title***
-4. LAErrorSystemCancel: System cancels authorization, such as accessing other apps
-5. LAErrorPasscodeNotSet: The system has not set a password
-6. LAErrorTouchIDNotAvailable: Device Touch ID is not available, such as not opened
-7. LAErrorTouchIDNotEnrolled: Device Touch ID not available, user not entered
-8. LAErrorTouchIDLockout: Authentication failed, multiple use of Touch ID failed
-9. LAErrorAppCancel: Applications whose authentication has been cancelled
-10. LAErrorInvalidContext: Authorization object invalid
-1004. LAErrorNotInteractive: App not fully started, call failed
Default: Unknown error
 LAErrorBiometryNotAvailable == LAErrorTouchIDNotAvailable
 LAErrorBiometryNotEnrolled == LAErrorTouchIDNotEnrolled
 LAErrorBiometryLockout == LAErrorTouchIDLockout
 
Note: Callbacks have already been processed to return to the main thread
 */

/**
Calling system fingerprint verification
 
@Param fallBackTitle Optional title that appears after fingerprint error
@The text prompt on the fingerprint verification box of param reasonTitle
@Callback for the success or failure of param fingerBlock fingerprint verification
IsSuccess verification successful
Error verification error message
ReferenceMsg Reference Information
 */
+ (void)fingerPrintLocalAuthenticationFallBackTitle:(NSString *)fallBackTitle localizedReason:(NSString *)reasonTitle callBack:(void(^)(BOOL isSuccess,NSError *_Nullable error,NSString *referenceMsg))fingerBlock;



/**
Verify if the system supports touch id or face id
 
@Param fingerBlock 0 does not support 1 touch id 2 faceid
 */
+ (void)fingerIsSupportCallBack:(void(^)(NSString * type))fingerBlock;

+ (void)fingerIsSupportCallBack1:(void(^)(NSString * type))fingerBlock;

@end

