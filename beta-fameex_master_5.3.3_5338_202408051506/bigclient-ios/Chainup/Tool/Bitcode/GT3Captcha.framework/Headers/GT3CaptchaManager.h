//
//  GTCaptchaManager.h
//  GTCaptcha
//
//  Created by NikoXu on 8/22/16.
//  Copyright © 2016 Geetest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GT3AsyncTaskProtocol.h"
#import "GT3Utils.h"
#import "GT3Error.h"

@protocol GT3CaptchaManagerDelegate, GT3CaptchaNetworkDelegate, GT3CaptchaManagerViewDelegate, GT3CaptchaManagerStatisticDelegate;

@interface GT3CaptchaManager : NSObject

/**SDK version number*/
+ (NSString *)sdkVersion;

/**Authentication Management Agent*/
@property (nonatomic, weak) id<GT3CaptchaManagerDelegate> delegate;
/**Verify Network Proxy*/
@property (nonatomic, weak) id<GT3CaptchaNetworkDelegate> networkDelegate;
/**Verify View Proxy*/
@property (nonatomic, weak) id<GT3CaptchaManagerViewDelegate> viewDelegate;
/**Validation Statistics Agent*/
@property (nonatomic, weak) id<GT3CaptchaManagerStatisticDelegate> statisticDelegate;

/**Verification status*/
@property (nonatomic, readonly) GT3CaptchaState captchaState;
/**Display status of graphic validation*/
@property (nonatomic, readonly) BOOL isShowing;
/**Interface for obtaining startup validation parameters*/
@property (nonatomic, readonly) NSURL *API_1;
/**Interface for secondary verification*/
@property (nonatomic, readonly) NSURL *API_2;
/**Verified ID*/
@property (nonatomic, readonly, strong) NSString *gt_captcha_id;
/**Verified session ID*/
@property (nonatomic, readonly, strong) NSString *gt_challenge;
/**Verified service status, 1 normal/0 down*/
@property (nonatomic, readonly, strong) NSNumber *gt_success_code;

/**Background verification*/
@property (nonatomic, strong) UIColor *maskColor;

#pragma mark - Basic Method
/**
*@ abstract Verify initialization method
 *
*@ discussion, please do not use the interface API_ 1 and API_ The URL of 2 comes with dynamic parameters. If you need to modify the API_ 1 and API_ Please refer to the GT3CaptchaManagerDelegate proxy method 'gtCaptcha: willSendRequestAPI 1: with ReplacedHandle:' and 'gtCaptcha: willSendSecondaryCaptcha Request: with ReplacedRequest:' for the modification of the request for 2`
 *
*@ seealso 'gtCaptcha: willSendRequestAPI 1: with ReplacedHandle:' and 'gtCaptcha: willSendSecondaryCaptcha Request: with ReplacedRequest:`
 *
*@ param API_ 1. Interface for obtaining validation parameters
*@ param API_ 2. Interface for secondary verification
*Param timeout timeout
*@ return GT3CaptchaManager instance
 *
 */
- (instancetype)initWithAPI1:(NSString *)api_1
                        API2:(NSString *)api_2
                     timeout:(NSTimeInterval)timeout NS_DESIGNATED_INITIALIZER;

/**
*@ abstract Cancel asynchronous request
 *
 *  @discussion
*Call this method when you want to cancel the executing<b>NSURLSessionDataTask</b>
 *
* ❗ Internal requests are based on NSURLSeetion</b>
 */
- (void)cancelRequest;

/**
*@ abstract Custom configuration validation parameters
 *
 *  @discussion
*The validation parameters obtained from the backend SDK, where a single challenge can only be used in the same validation session
 *
*@ param gt_ Captcha with ID applied on the official website_ ID
*@ param gt_ Challenge generated based on the SDK of the polar server
*@ param gt_ Success_ Code website main server monitors the availability status of Geetest service 0/1 Unavailable/Available
*@ param API_ 2. Interface for secondary verification. The website owner deploys it based on the SDK of the verification server
 *
 */
- (void)configureGTest:(NSString *)gt_id
             challenge:(NSString *)gt_challenge
               success:(NSNumber *)gt_success_code
              withAPI2:(NSString *)api_2 API_DEPRECATED_WITH_REPLACEMENT("registerCaptchaWithCustomAsyncTask:completion:", ios(2.0, 6.0));

/**
 *
*@ abstract registration verification
 *
*Callback after successful registration of @ param completionHandler
 */
- (void)registerCaptcha:(GT3CaptchaDefaultBlock)completionHandler;

/**
 *
*@ abstract registration verification, and customize API1 and API2 processes
 *
*@ param customAsyncTask Customize API1 and API2 task objects
*Callback after successful registration of @ param completionHandler
 *
 *  @discussion
*Because the manager holds customAsyncTask in the form of Weak reference, the developer needs to
*Maintain in the calling class to ensure that the manager can access the object normally in subsequent processes.
 *
 *  @seealso GT3AsyncTaskProtocol
 *
 */
- (void)registerCaptchaWithCustomAsyncTask:(id<GT3AsyncTaskProtocol>)customAsyncTask completion:(GT3CaptchaDefaultBlock)completionHandler;

/**
* ❗ Necessary methods</b> ❗ :
*@ abstract Start validation
 *
 *  @discussion
*After obtaining the posture and submitting the analysis, if necessary, display the GTView validation view for polar verification on the '[UIApplication sharedApplication]. delete window]'
*Extreme verification GTWebView communicates with SDK through JS
*The internal logic will change depending on the current state of the 'captcha State' attribute
 *
 */
- (void)startGTCaptchaWithAnimated:(BOOL)animated;

/**
*Terminate validation
 */
- (void)stopGTCaptcha;

/**
*@ abstract reset verification
 *
 *  @discussion
*After calling 'stopGTCaptcha' internally, after a delay of 0.3 seconds in the main thread
*Execute the internal method of 'startCaptcha'.
*Only in 'GT3CaptchaStateFailure', 'GT3CaptchaStateError',
*Execute in the 'GT3Captcha State Success' and' GT3Captcha State Cancel 'states.
 */
- (void)resetGTCaptcha;

/**
*If the verification is displayed, close the verification interface
 */
- (void)closeGTViewIfIsOpen;

/**
*Get cookie value
 *
*@ param cookie Name The key name of the cookie
*The value of the cookie corresponding to @ return
 */
- (NSString *)getCookieValue:(NSString *)cookieName;

#pragma mark Other configuration

/**
*@ Abstract: The duration of graphic validation timeout
 *
*@ param timeout GT3WebView resource request timeout
 */
- (void)useGTViewWithTimeout:(NSTimeInterval)timeout;

/**
*@ abstract Set the rounded corner size for graphic validation
*
*Param Cornerradius rounded size, size not exceeding 30 px
*/
- (void)useGTViewWithCornerRadius:(CGFloat)cornerRadius;

/**
*@ abstract Verify static parameters
 *
 *  @discussion
*Internally convert parameters into form format and concatenate them onto requests for static resources
 *
*@ param params custom parameters
 */
- (void)useGTViewWithParams:(NSDictionary *)params;

/**
*@ abstract Verify Title
 *
 *  @discussion
*Default not enabled The character length cannot exceed 28, and one Chinese character is two 2-character lengths
 *
*@ param title Verify title string
 */
- (void)useGTViewWithTitle:(NSString *)title;

/**
*Abstract Configuration Status Indicator
 *
 *  @discussion
*For the convenience of debugging animations, real machine debugging simulates low-speed network Settings ->Developer
 *  ->Status->Enable->Edge(😂)
 *
*The animation block that needs to be implemented during @ param animationBlock customization is only executed when the type is configured as GTIndicatorCustomType
*The type of @ param type status indicator
 */
- (void)useAnimatedAcitvityIndicator:(GT3IndicatorAnimationViewBlock)animationBlock
                         withIndicatorType:(GT3ActivityIndicatorType)type;

/**
*@ abstract Configuration Background Blurred
 *
 *  @discussion
*IOS8 or above effective
 *
*Param blur Effect
 */
- (void)useVisualViewWithEffect:(UIBlurEffect *)blurEffect;

/**
*@ abstract Switch validation language
 *
 *  @discussion
*By default, it follows the system language. Unsupported languages are displayed in English.
 *
*@ param type Language type
 */
- (void)useLanguage:(GT3LanguageType)type;

/**
*@ abstract Switch validation language
 *
 *  @discussion
*Not set or passed nil, defaults to following the system language. Unsupported languages are in English.
 *
*@ param lang language abbreviation. Please refer to the relevant language abbreviation list.
 */
- (void)useLanguageCode:(NSString *)lang;

/**
*@ abstract Switch Verification Service Cluster Node
 *
 *  @discussion
*Default China node. Using other nodes requires corresponding configurations, otherwise the authentication service cannot be accessed correctly.
*Before using this method, please fully understand the extreme service cluster nodes.
 *
*@ param node cluster node
 */
- (void)useServiceNode:(GT3CaptchaServiceNode)node;

/**
*@ abstract Completely uses HTTPS protocol for request validation
 *
 *  @discussion
*Enable HTTPS by default
 *
*Does @ param disable disable HTTPS support
 */
- (void)disableSecurityAuthentication:(BOOL)disable;

/**
*Switch for verifying background interaction events using abstract
 *
*@ discussion is closed by default
 *
*@ param disable YES Ignore interaction events/NO Accept interaction events
 */
- (void)disableBackgroundUserInteraction:(BOOL)disable;

/**
*@ abstract Control the network reachability detection inside the validation manager
 *
*Param enable YES on/NO off Default YES
 */
- (void)enableNetworkReachability:(BOOL)enable;

/**
 *  @abstract Debug Mode
 *
 *  @discussion
*Turn on debugMode and call this method before turning on validation
*Default not enabled
 *
*@ param enable YES on, NO off
 */
- (void)enableDebugMode:(BOOL)enable;

/**
*@ abstract Set whether to allow printing of logs
 *
*@ param enabled YES, allow log printing NO, prohibit log printing
 */
+ (void)setLogEnabled:(BOOL)enabled;

/**
*@ abstract Allow printing of logs
 *
*@ return YES, allow printing of logs NO, prohibit printing of logs
 */
+ (BOOL)isLogEnabled;

@end

#pragma mark - validation proxy method

@protocol GT3CaptchaManagerDelegate <NSObject>

@required
/**
*Validation error handling
 *
*@ discussion threw an internal error, such as GTWebView and other errors
 *
*Param manager validation manager
*@ param error Error Source
 */
- (void)gtCaptcha:(GT3CaptchaManager *)manager errorHandler:(GT3Error *)error;

/**
*@ abstract notifies that the second validation result has been received, and we will process the final validation result here
 *
 *  @discussion
*The error of the second validation is only returned here, and 'decisionHandler' needs to be processed
 *
*Param manager validation manager
*@ param data The data returned from the second validation
*Param response response for secondary validation
*@ param error Error Source
*View of @ param decisionHandler updating validation results
 */
- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveSecondaryCaptchaData:(NSData *)data response:(NSURLResponse *)response error:(GT3Error *)error decisionHandler:(void (^)(GT3SecondaryCaptchaPolicy captchaPolicy))decisionHandler;

@optional

/**
*Does @ abstract use the internal default API1 request logic
 *
*Param manager validation manager
*@ return YES used, NO not used
 */
- (BOOL)shouldUseDefaultRegisterAPI:(GT3CaptchaManager *)manager;

/**
*This method is called when @ abstract is about to send a request to API1. This method allows you to modify the request to be sent
 *
*@ warning does not support sub thread operations.
 *
*When calling this method, @ discussion must execute<b>requestHandler</b>, otherwise it may cause memory leakage.
 *
*Param manager validation manager
*The default request object sent by @ param originalRequest
*@ param replacedHandler modifies the execution block of the request
 */
- (void)gtCaptcha:(GT3CaptchaManager *)manager willSendRequestAPI1:(NSURLRequest *)originalRequest withReplacedHandler:(void (^)(NSURLRequest * request))replacedHandler;

/**
*When receiving data from<b>API1</b>, notify to return the dictionary, including<b>gt_ Public_ Key</b>,
 *  <b>gt_challenge</b>, <b>gt_success_code</b>
 *
*@ warning does not support sub thread operations.
 *
 *  @discussion
*If this method is implemented, it is necessary to parse the data required for validation and return it.
If the validation initialization data is not returned, use internal parsing rules for parsing. By default, the first level structure is parsed first, and then the data in the key name "data" or "gtcap" is matched.
 *
*Param manager validation manager
*@ param dictionary API1 returned data (not parsed)
*Error returned by @ param error
 *
*@ return Verify initialization data, format shown below
 <pre>
 {
 "challenge" : "12ae1159ffdfcbbc306897e8d9bf6d06",
 "gt" : "ad872a4e1a51888967bdb7cb45589605",
 "success" : 1
 }
 </pre>
 */
- (NSDictionary *)gtCaptcha:(GT3CaptchaManager *)manager didReceiveDataFromAPI1:(NSDictionary *)dictionary withError:(GT3Error *)error;

/**
*@ abstract notification received the returned validation interaction result
 *
*The @ discussion method is only the preliminary result returned by the front-end, not the final result of validation.
 *
*Param manager validation manager
*@ param code validation interaction result, 0 failed/1 succeeded
*Param result Secondary validation data
*Param message with message
 */
- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveCaptchaCode:(NSString *)code result:(NSDictionary *)result message:(NSString *)message;

/**
*Does @ abstract use the internal default API2 request logic
 *
*@ discussion returns YES by default;
 *
*Param manager validation manager
*@ return YES used, NO not used
 */
- (BOOL)shouldUseDefaultSecondaryValidate:(GT3CaptchaManager *)manager;

/**
*Abstract notifies that a second validation is about to be conducted and modifies the validation sent to API2 again.
 *
*@ warning does not support sub thread operations.
 *
 *  @discussion
*Please do not modify the thread or queue where the<b>requestHandler</b>executes, otherwise it may cause
*Request for modification failed The request method for secondary verification should be POST, and the header information should be:
 *  <pre>{"Content-Type":@"application/x-www-form-urlencoded;charset=UTF-8"}</pre>
 *
*Param manager validation manager
*@ param replacedRequest Modify the block of the secondary validation request
 */
- (void)gtCaptcha:(GT3CaptchaManager *)manager willSendSecondaryCaptchaRequest:(NSURLRequest *)originalRequest withReplacedRequest:(void (^)(NSMutableURLRequest * request))replacedRequest;

/**
*@ abstract: The user actively closed the verification code interface
 *
*Param manager validation manager
 */
- (void)gtCaptchaUserDidCloseGTView:(GT3CaptchaManager *)manager;

@end

@protocol GT3CaptchaNetworkDelegate <NSObject>

- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * credential))completionHandler;

@end

@protocol GT3CaptchaManagerViewDelegate <NSObject>

@optional

/**
*@ abstract notification validation mode
 *
*Param manager validation manager
*@ param mode validation mode
 */
- (void)gtCaptcha:(GT3CaptchaManager *)manager notifyCaptchaMode:(GT3CaptchaMode)mode;

/**
*@ abstract Notify that graphic validation will be displayed
 *
*Param manager validation manager
 */
- (void)gtCaptchaWillShowGTView:(GT3CaptchaManager *)manager;

/**
*@ abstract Update Validation Status
 *
*Param manager validation manager
*@ param state Verify status
*@ param error error message
 */
- (void)gtCaptcha:(GT3CaptchaManager *)manager updateCaptchaStatus:(GT3CaptchaState)state error:(GT3Error *)error;

/**
*@ abstract Update Validation View
 *
*Param manager validation manager
*@ param from Value starting value
*@ param toValue termination value
*@ param timeInterval Time interval
 */
- (void)gtCaptcha:(GT3CaptchaManager *)manager updateCaptchaViewWithFactor:(CGFloat)fromValue to:(CGFloat)toValue timeInterval:(NSTimeInterval)timeInterval;

@end

@protocol GT3CaptchaManagerStatisticDelegate <NSObject>

@optional

- (void)gtCaptchaDidStartCaptcha:(GT3CaptchaManager *)manager;
- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveFullpageResult:(NSString *)result;
- (void)gtCaptchaNotifyGTViewDidReady:(GT3CaptchaManager *)manager;

- (void)gtCaptcha:(GT3CaptchaManager *)manager didReturnStatisticInfomation:(NSData *)data;

@end

