//
//  GTUtils.h
//  GTFramework
//
//  Created by LYJ on 15/5/18.
//  Copyright (c) 2015年 gt. All rights reserved.
//

#ifndef GTFramework_GTUtils_h
#define GTFramework_GTUtils_h

#if __has_feature(objc_generics)
#define GT3_GENERICS(class, ...) class<__VA_ARGS__>
#define GT3_GENERICS_TYPE(type) type
#else
#define GT3_GENERICS(class, ...) class
#define GT3_GENERICS_TYPE(type) id
#endif

#import <UIKit/UIKit.h>


/**
Enumerators for polar validation states
 */
typedef NS_ENUM(NSInteger, GT3CaptchaState) {
/**Verification not activated*/
    GT3CaptchaStateInactive = 0,
/**Verify Activation*/
    GT3CaptchaStateActive,
/**Verifying initialization*/
    GT3CaptchaStateInitial,
/**Validation waiting for interaction*/
    GT3CaptchaStateWaiting,
/**Verifying detection data*/
    GT3CaptchaStateCollecting,
/**Verification result judgment in progress*/
    GT3CaptchaStateComputing,
/**Verification passed*/
    GT3CaptchaStateSuccess,
/**Verification failed*/
    GT3CaptchaStateFail,
/**Verification Cancellation*/
    GT3CaptchaStateCancel,
/**Validation error occurred*/
    GT3CaptchaStateError
};

/**
*Verify cluster nodes
 */
typedef NS_ENUM(NSInteger, GT3CaptchaServiceNode) {
/**China Service Cluster*/
    GT3CaptchaServiceNodeCN = 0,
/**North American Service Cluster*/
    GT3CaptchaServiceNodeNA,
/**Default service cluster*/
    GT3CaptchaServiceNodeDefault = GT3CaptchaServiceNodeCN
};

/**
*Validation Mode Enumerator
 */
typedef NS_ENUM(NSInteger, GT3CaptchaMode) {
/**Verify default mode*/
    GT3CaptchaModeDefault,
/**Verify downtime mode*/
    GT3CaptchaModeFailback,
    GT3CaptchaModeNoLogo,
    GT3CaptchaModeLogo
};

/**
*Update strategy for results on views
 */
typedef NS_ENUM(NSInteger, GT3SecondaryCaptchaPolicy) {
/**Secondary verification passed*/
    GT3SecondaryCaptchaPolicyAllow,
/**Second verification rejected*/
    GT3SecondaryCaptchaPolicyForbidden
};

/**
*Language options for graphic validation
 */
typedef NS_ENUM(NSInteger, GT3LanguageType) {
/**Simplified Chinese*/
    GT3LANGTYPE_ZH_CN = 0,
/**Traditional Chinese*/
    GT3LANGTYPE_ZH_TW,
/**Traditional Chinese*/
    GT3LANGTYPE_ZH_HK,
/**Korean*/
    GT3LANGTYPE_KO_KR,
/**Japenese Japanese*/
    GT3LANGTYPE_JA_JP,
/**English*/
    GT3LANGTYPE_EN,
/**Indonesian language*/
    GT3LANGTYPE_ID,
/**Arabic*/
    GT3LANGTYPE_AR,
/**German*/
    GT3LANGTYPE_DE,
/**Spanish*/
    GT3LANGTYPE_ES,
/**French*/
    GT3LANGTYPE_FR,
/**Portuguese*/
    GT3LANGTYPE_PT_PT,
/**Russian*/
    GT3LANGTYPE_RU,
/**System language follows the system language*/
    GT3LANGTYPE_AUTO = 999
};

/**
*Activity Indicator Type
 */
typedef NS_ENUM(NSInteger, GT3ActivityIndicatorType) {
    /** Geetest Defualt Indicator Type */
    GT3IndicatorTypeDefault = 0,
    /** System Indicator Type */
    GT3IndicatorTypeSystem,
    /** Cirle */
    GT3IndicatorTypeCirle,
    /** Custom Indicator Type */
    GT3IndicatorTypeCustom
};

/**
*Verify default callback
 */
typedef void(^GT3CaptchaDefaultBlock)(void);

/**
*Animation Implementation Block for Custom Status Indicator
 *
*The layer of the @ param layer status indicator view
*The size of the @ param size layer, default to {64, 64}
*The color of the @ param color layer, default to blue [UIColor colorWithRed: 0.3 green: 0.6 blue: 0.9 alpha: 1]
 */
typedef void(^GT3IndicatorAnimationViewBlock)(CALayer *layer, CGSize size, UIColor *color);

#endif

