//
//  GT3Tool.m
//  GT3Example
//
//  Created by xue on 2023/11/5.
//  Copyright © 2023 Xniko. All rights reserved.
//

#import "GT3Tool.h"
#import "Chainup-Swift.h"
#import <objc/runtime.h>
#import <EXKit-Swift.h>

//The interface deployed by the website master for verifying login (api_1)
//#define api_1 @"https://rd1appapi.chaindown.com/common/tartCaptcha"
//Interface for secondary verification deployed by website master (api_2)
//#define api_2 @"https://rd1appapi.chaindown.com/user/login_in"


@interface NSObject (ExAdd)

+ (void) kk_swizzleMehod:(nonnull NSString *)sysMethod
             systemClass:(nonnull NSString *)sysClass
           replaceMethod:(nonnull NSString *)replaceMethod
             targetClass:(nonnull NSString *)targetClass;

@end

@implementation NSObject (ExAdd)

+(void)kk_swizzleMehod:(NSString *)sysMethod
           systemClass:(NSString *)sysClass
         replaceMethod:(NSString *)replaceMethod
           targetClass:(NSString *)targetClass{
    
    Method orignalMethod = class_getInstanceMethod(NSClassFromString(sysClass), NSSelectorFromString(sysMethod));
    Method newsMethod = class_getInstanceMethod(NSClassFromString(targetClass), NSSelectorFromString(replaceMethod));
    method_exchangeImplementations(newsMethod, orignalMethod);
}

@end


@interface NSDictionary (ExAdd)

/**
 nil will Returns NO; otherwise Returns YES.
 */
- (BOOL)ex_isNotBlank;

@end


@implementation NSDictionary (ExAdd)

-(BOOL)ex_isNotBlank{
    if (self == nil) return false;
    if ([self isKindOfClass:NSNull.class]) return false;
    if ([self isKindOfClass:NSDictionary.class] == false) false;
    if (self.count == 0) return false;
    return true;
}

@end


@interface NSMutableDictionary(ExAdd)

@end

@implementation NSMutableDictionary(ExAdd)
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self kk_swizzleMehod:@"ex_removeObjectForKey:"
                  systemClass:@"NSMutableDictionary"
                replaceMethod:@"removeObjectForKey:"
                  targetClass:@"__NSDictionaryM"];
        
        [self kk_swizzleMehod:@"ex_setObject:forKey:"
                  systemClass:@"NSMutableDictionary"
                replaceMethod:@"setObject:forKey:"
                  targetClass:@"__NSDictionaryM"];
    });
}

-(void)ex_removeObjectForKey:(id)aKey{
    if (aKey == nil) return;
    [self ex_removeObjectForKey:aKey];
}

-(void)ex_setObject:(id)anObject forKey:(id<NSCopying>)aKey{
    if (anObject == nil) return;
    if (aKey == nil) return;
    [self ex_setObject:anObject forKey:aKey];
}


@end



@interface GT3Tool()<GT3CaptchaManagerDelegate, GT3CaptchaButtonDelegate, GT3CaptchaManagerViewDelegate>

@end

@implementation GT3Tool


- (void)start{
    [self setLan];
    GT3CaptchaManager  *captchaManager  = self.captchaButton.captchaManager;
    [captchaManager resetGTCaptcha];
    NSString * gt = self.data[@"gt"];
    NSString * challenge = self.data[@"challenge"];
    NSNumber * success = self.data[@"success"];
    [captchaManager configureGTest:gt challenge:challenge success:success withAPI2:nil];
    [captchaManager startGTCaptchaWithAnimated:true];


}

- (void)setLan{
    
    NSString * currentLan = LanguageHandler.priviatePhoneLanguage;
    GT3CaptchaManager  * cm  = self.captchaButton.captchaManager;
    GT3LanguageType lan =  GT3LANGTYPE_AUTO;
    if ([currentLan containsString:@"zh_CN"]){
        lan = GT3LANGTYPE_ZH_CN;
    }else if ([currentLan containsString:@"el_GR"]){
        lan = GT3LANGTYPE_ZH_TW;
    }else if ([currentLan containsString:@"en_US"]){
        lan = GT3LANGTYPE_EN;
    }else if ([currentLan containsString:@"ko_KR"]){
        lan = GT3LANGTYPE_KO_KR;
    }else if ([currentLan containsString:@"vi_VN"]){
//        lan = GT3LANGTYPE;
        [cm useLanguageCode:@"vi"];
        return;
    }else if ([currentLan containsString:@"ja_JP"]){
        lan = GT3LANGTYPE_JA_JP;
    }else if ([currentLan containsString:@"th_TH"]){
        [cm useLanguageCode:@"th"];
        return;
    }else if ([currentLan containsString:@"id_ID"]){
        lan = GT3LANGTYPE_ID;
    }
    [cm useLanguage:lan];
}


- (void)startWithSucceededBlock:(void (^)(void))succeededBlock failedBlock:(void (^)(GT3Error *))failedBlock
{
    self.validationSucceededBlock = succeededBlock;
    self.validationFailedBlock = failedBlock;
    [self start];
}

- (GT3CaptchaButton *)captchaButton {
    if (!_captchaButton) {
        //Create a validation manager instance
        GT3CaptchaManager *captchaManager = [[GT3CaptchaManager alloc] initWithAPI1:nil API2:nil timeout:5.0];
        captchaManager.delegate = self;
        captchaManager.maskColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        //        if ([LanguageTools isHan]){
        [captchaManager useLanguage:GT3LANGTYPE_ZH_CN];
        //
        //        }else{
        //
        [captchaManager useLanguage:GT3LANGTYPE_EN];
        //        }
        
        //debug mode
        //        [captchaManager enableDebugMode:YES];
        //Create an instance of the validation view
        _captchaButton = [[GT3CaptchaButton alloc] initWithFrame:CGRectMake(0, 0, 0, 40) captchaManager:captchaManager];
        NSMutableDictionary *mu = [NSMutableDictionary dictionary];
        
        NSString *inactive = @"";
        NSString *active = @"";
        NSString *initial = @"";
        NSString *waiting = @"";
        NSString *collecting = @"";
        NSString *computing = @"";
        NSString *success = @"";
        NSString *fail = @"";
        NSString *error = @"";
        NSString *cancel = @"";
        //Waiting=@ "Intelligent detection in progress";
        //Collecting=@ "Intelligent detection in progress";
        //Computing=@ "Intelligent detection in progress";
        //        waiting = @"Analysing...";
        //        collecting = @"Analysing...";
        //        computing = @"Analysing...";
        if ([LanguageTools isHan]){
            inactive = @"请点击按钮进行验证";
            active = @"请点击按钮进行验证";
            initial = @"请点击按钮进行验证";
            waiting = @"请点击按钮进行验证";
            collecting = @"请点击按钮进行验证";
            computing = @"请点击按钮进行验证";
            success = @"验证成功";
            fail = @"验证失败";
            error = @"验证错误";
            cancel = @"验证已取消";
            [captchaManager useLanguage:GT3LANGTYPE_ZH_CN];
        }else{
            
            inactive = @"Please click captcha button";
            active = @"Please click captcha button";
            initial = @"Please click captcha button";
            waiting = @"Please click captcha button";
            collecting = @"Please click captcha button";
            computing = @"Please click captcha button";
            success = @"Success";
            fail = @"Fail";
            error = @"Error";
            cancel = @"Cancel";
            [captchaManager useLanguage:GT3LANGTYPE_EN];
            
        }
        
        mu[@"inactive"] = [self generate:inactive fontSize:15 color:nil];
        mu[@"active"] = [self generate:active fontSize:15  color:nil];
        mu[@"initial"] = [self generate:initial fontSize:15  color:nil];
        mu[@"waiting"] = [self generate:waiting fontSize:15  color:nil];
        mu[@"collecting"] = [self generate:collecting fontSize:15  color:nil];
        mu[@"computing"] = [self generate:computing fontSize:15  color:nil];
        mu[@"success"] = [self generate:success fontSize:15  color:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:88/255.0 alpha:1.0]];
        mu[@"fail"] = [self generate:fail fontSize:15  color:[UIColor colorWithRed:229/255.0 green:83/255.0 blue:71/255.0 alpha:1.0]];
        mu[@"error"] = [self generate:error fontSize:15  color:[UIColor colorWithRed:229/255.0 green:83/255.0 blue:71/255.0 alpha:1.0]];
        mu[@"cancel"] = [self generate:cancel fontSize:15 color:[UIColor colorWithRed:229/255.0 green:83/255.0 blue:71/255.0 alpha:1.0]];
        
        _captchaButton.tipsDict = mu;
    }
    return _captchaButton;
}
#pragma MARK - CaptchaButtonDelegate
- (void)disableBackgroundUserInteraction:(BOOL)disable{
    
    
}


#pragma MARK - GT3CaptchaManagerDelegate

- (void)gtCaptcha:(GT3CaptchaManager *)manager errorHandler:(GT3Error *)error {
//    if (self.validationFailedBlock != nil) {
//        self.validationFailedBlock(error);
//    }
    //Handling errors returned during validation
    if (error.code == -999) {
        //The request was unexpectedly interrupted, usually caused by a user canceling the operation, and the error can be ignored
    }
    else if (error.code == -10) {
        //Blocked during pre judgment, no further graphic verification will be performed
    }
    else if (error.code == -20) {
        //Try too much
    }
    else {
        //Network issues or parsing failures, please refer to the development documentation for more error codes
    }
    NSLog(@"errorHandler = %ld",(long)error.code);
}

- (void)gtCaptchaUserDidCloseGTView:(GT3CaptchaManager *)manager {
    //    NSLog(@"User Did Close GTView.");
//    if (self.validationFailedBlock != nil) {
//        GT3Error *err =  [GT3Error errorWithDomainType: 1 code: -1 userInfo:@{@"error":@"UserCancel"} withGTDesciption:@"a"];
//        self.validationFailedBlock(err);
//    }
}



- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveCaptchaCode:(NSString *)code result:(NSDictionary *)result message:(NSString *)message{
    
    if ([code isEqualToString:@"1"]){
        self.geetest_challenge = result[@"geetest_challenge"];
        self.geetest_seccode = result[@"geetest_seccode"];
        self.geetest_validate = result[@"geetest_validate"];
        
        if (self.validationSucceededBlock != nil) {
            self.validationSucceededBlock();
        }
    }
    
    
}


- (BOOL)shouldUseDefaultRegisterAPI:(GT3CaptchaManager *)manager {
    return NO;
}
- (BOOL)shouldUseDefaultSecondaryValidate:(GT3CaptchaManager *)manager{
    return  NO;
}

- (NSAttributedString *)generate:(NSString *)aString fontSize:(CGFloat)fontSize color:(UIColor *)color{
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    //    style.alignment = NSTextAlignmentCenter;
    //    style.paragraphSpacingBefore = 4.0;
    //    style.minimumLineHeight = 10.0;
    if (color == nil){
        color = [UIColor blackColor];
    }
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:aString attributes:@{ NSFontAttributeName : font, NSParagraphStyleAttributeName : style,NSForegroundColorAttributeName:color}];
    
    return attrString;
}
@end







