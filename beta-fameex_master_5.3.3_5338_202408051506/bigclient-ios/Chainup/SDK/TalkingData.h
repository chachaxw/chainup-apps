//
//  TalkingData.h
//  __MyProjectName__
//
//  Created by Biao Hou on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#if TARGET_OS_IOS
typedef NS_ENUM(NSUInteger, TDAccountType) {
    TDAccountTypeAnonymous      = 0,    //anonymous account 
    TDAccountTypeRegistered     = 1,    //Explicit registration account
    TDAccountTypeSinaWeibo      = 2,    //Sina Weibo
    TDAccountTypeQQ             = 3,    //QQ account
    TDAccountTypeTencentWeibo   = 4,    //Tencent Weibo
    TDAccountTypeND91           = 5,    //91 Account
    TDAccountTypeWeiXin         = 6,    //WeChat
    TDAccountTypeType1          = 11,   //Custom Type 1
    TDAccountTypeType2          = 12,   //Custom Type 2
    TDAccountTypeType3          = 13,   //Custom Type 3
    TDAccountTypeType4          = 14,   //Custom Type 4
    TDAccountTypeType5          = 15,   //Custom Type 5
    TDAccountTypeType6          = 16,   //Custom Type 6
    TDAccountTypeType7          = 17,   //Custom Type 7
    TDAccountTypeType8          = 18,   //Custom Type 8
    TDAccountTypeType9          = 19,   //Custom Type 9
    TDAccountTypeType10         = 20    //Custom Type 10
};
#endif


#if TARGET_OS_IOS
@interface TalkingDataOrder : NSObject

/**
 *  @method createOrder
*@ param orderId Order ID Type: NSString
*@ param total Order total price type: int
*@ param currencyType Currency Type: NSString
 */
+ (TalkingDataOrder *)createOrder:(NSString *)orderId total:(int)total currencyType:(NSString *)currencyType;

/**
 *  @method addItemWithCategory
*@ param itemId Product Id Type: NSString
*@ param category Product category type: NSString
*@ param name Product name Type: NSString
*@ param unitPrice Product unit price type: int
*@ param amount Product quantity type: int
 */
- (TalkingDataOrder *)addItem:(NSString *)itemId category:(NSString *)category name:(NSString *)name unitPrice:(int)unitPrice amount:(int)amount;

@end


@interface TalkingDataShoppingCart : NSObject

/**
 *  @method createShoppingCart
 */
+ (TalkingDataShoppingCart *)createShoppingCart;

/**
 *  @method addItem
*@ param itemId Product Id Type: NSString
*@ param category Product category type: NSString
*@ param name Product name Type: NSString
*@ param unitPrice Product unit price type: int
*@ param amount Product quantity type: int
 */
- (TalkingDataShoppingCart *)addItem:(NSString *)itemId category:(NSString *)category name:(NSString *)name unitPrice:(int)unitPrice amount:(int)amount;

@end
#endif


@interface TalkingData: NSObject

/**
 *  @method getDeviceID
*Obtain the DeviceID used by the SDK
 *  @return DeviceID
 */
+ (NSString *)getDeviceID;

/**
 *  @method setLogEnabled
*Statistical log switch (optional)
*@ param enable is enabled by default
 */
+ (void)setLogEnabled:(BOOL)enable;

#if TARGET_OS_IOS
/**
 *  @method setExceptionReportEnabled
*Capture program crash records (optional)
*If you need to record program crash logs, please set the value to YES and call it as soon as possible after initialization
*@ param enable defaults to NO
 */
+ (void)setExceptionReportEnabled:(BOOL)enable;

/**
 *  @method setSignalReportEnabled
*Whether to capture abnormal signals (optional)
*If you need to enable the abnormal signal capture function, please set the value to YES and call it as soon as possible after initialization
*@ param enable defaults to NO
 */
+ (void)setSignalReportEnabled:(BOOL)enable;
#endif



#if TARGET_OS_IOS
/**
 *  @method setLatitude:longitude:
*Set location information (optional)
*Param latitude dimension
*Param longitude
 */
+ (void)setLatitude:(double)latitude longitude:(double)longitude;
#endif

/**
 *  @method backgroundSessionEnabled
*To enable background usage duration statistics, it needs to be called before SDK initialization.
 */
+ (void)backgroundSessionEnabled;

#if TARGET_OS_IOS
/**
 *  @method sessionStarted:withChannelId:
*Initialize the statistics instance, please call it in the application: didFinishLaunchingWithOptions: method
*The unique identifier of the @ param appKey application, obtained through backend registration
*@ param channelId channel name, such as' app store '(optional)
 */
+ (void)sessionStarted:(NSString *)appKey withChannelId:(NSString *)channelId;
#endif



/**
 *  @method setAccountId:
*Set Account ID
*@ param accountId Account ID
 */
+ (void)setAccountId:(NSString *)accountId API_DEPRECATED("", ios(1, 1));

#if TARGET_OS_IOS
/**
*@ method onRegister Registration
*@ param accountId Account ID
*@ param type account type
*@ param name account nickname
 */
+ (void)onRegister:(NSString *)accountId type:(TDAccountType)type name:(NSString *)name;

/**
*@ method onLogin login
*@ param accountId Account ID
*@ param type account type
*@ param name account nickname
 */
+ (void)onLogin:(NSString *)accountId type:(TDAccountType)type name:(NSString *)name;
#endif

/**
 *  @method trackEvent
*Statistical custom events (optional), such as purchase actions
*@ param eventId event name (custom)
 */
+ (void)trackEvent:(NSString *)eventId;

/**
 *  @method trackEvent:label:
*Statistical custom events with labels (optional), which can be used to distinguish different application scenarios of the same event
If purchasing a specific product
*@ param eventId event name (custom)
*@ param eventLabel event label (custom)
 */
+ (void)trackEvent:(NSString *)eventId label:(NSString *)eventLabel;

/**
 *  @method trackEvent:label:parameters
*Count custom events with secondary parameters, and the number of parameters in a single call cannot exceed 10
*@ param eventId event name (custom)
*@ param eventLabel event label (custom)
*@ param parameters event parameters (key only supports NSString, value supports NSString and NSNumber)
 */
+ (void)trackEvent:(NSString *)eventId
             label:(NSString *)eventLabel
        parameters:(NSDictionary *)parameters;

/**
 *  @method trackEvent:label:parameters:value:
*Numerical events
*@ param eventId event name (custom)
*@ param eventLabel event label (custom)
*@ param parameters event parameters (key only supports NSString, value supports NSString and NSNumber)
*@ param eventValue Event Value (double)
 */
+ (void)trackEvent:(NSString *)eventId
             label:(NSString *)eventLabel
        parameters:(NSDictionary *)parameters
             value:(double)eventValue;

/**
 *  @method setGlobalKV:value:
*Add global fields, and the content here will be sent to the server with every customization. That is to say, if each item in your custom event needs to have the same content, such as username, etc., it can be added
*@ param key is the key for customizing events. If there is the same key when creating a customization in the future, it will overwrite the content of the same key globally
*@ param value Here is the NSObject type, or the NSString or NSNumber type
 */
+ (void)setGlobalKV:(NSString *)key value:(id)value;

/**
 *  @method removeGlobalKV:
*Delete global data
*@ param key Customize the key of the event
 */
+ (void)removeGlobalKV:(NSString *)key;

/**
 *  @method trackPageBegin
*Start tracking a certain page (optional), record the time the page was opened
Suggest calling in the viewWillAppear or viewDidAppear methods
*@ param pageName Page name (custom)
 */
+ (void)trackPageBegin:(NSString *)pageName;


/**
 *  @method trackPageEnd
*End tracking of a certain page (optional), record the closing time of the page
This method is paired with the trackPageBegin method,
It is recommended to call the viewWillDisappear or viewDidDisappear method in iOS applications
It is recommended to call the DidDeactivate method in Watch applications
*@ param pageName Page name, please match the page name of the trackPageBegin method
 */
+ (void)trackPageEnd:(NSString *)pageName;

#if TARGET_OS_IOS
/**
*Place an order with @ method onPlaceOrder
*@ param accountId Account ID Type: NSString
*@ param order Order type: TalkingDataOrder
 */
+ (void)onPlaceOrder:(NSString *)accountId order:(TalkingDataOrder *)order;

/**
*@ method onOrderPaySucc payment
*@ param accountId Account ID Type: NSString
*@ param payType Payment type: NSString
*@ param order Order detail type: TalkingDataOrder
 */
+ (void)onOrderPaySucc:(NSString *)accountId payType:(NSString *)payType order:(TalkingDataOrder *)order;

/**
 *  @method onViewItem
*@ param itemId Product Id Type: NSString
*@ param category Product category type: NSString
*@ param name Product name Type: NSString
*@ param unitPrice Product unit price type: int
 */
+ (void)onViewItem:(NSString *)itemId category:(NSString *)category name:(NSString *)name unitPrice:(int)unitPrice;

/**
 *  @method onAddItemToShoppingCart
*@ param itemId Product Id Type: NSString
*@ param category Product category type: NSString
*@ param name Product name Type: NSString
*@ param unitPrice Product unit price type: int
*@ param amount Product quantity type: int
 */
+ (void)onAddItemToShoppingCart:(NSString *)itemId category:(NSString *)category name:(NSString *)name unitPrice:(int)unitPrice amount:(int)amount;

/**
 *  @method onViewShoppingCart
*@ param shoppingCart Shopping Cart Information Type: TalkingDataShoppingCart
 */
+ (void)onViewShoppingCart:(TalkingDataShoppingCart *)shoppingCart;
#endif



@end

