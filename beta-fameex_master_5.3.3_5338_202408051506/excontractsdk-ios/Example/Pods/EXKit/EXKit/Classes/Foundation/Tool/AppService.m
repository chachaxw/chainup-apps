//
//  AppService.m
//  Sotao
//
//  Created by Cheney on 5/29/15.
//  Copyright (c) 2015 sotao. All rights reserved.
//

#import "AppService.h"

#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
@implementation AppService



+ (void)checkCameraPrivacyWithCallback:(CameraAuthCallback)callback
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            callback(granted);
                        });
                    }];
                }
                break;
            }
            case AVAuthorizationStatusAuthorized: {
                callback(YES);
                break;
            }
            case AVAuthorizationStatusDenied: {
                {
                    
                    UIViewController *vc = [self topViewController];
                    if ( vc ) {
                        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"open_seting", nil) preferredStyle:(UIAlertControllerStyleAlert)];
                        UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                            
                        }];
                        [alertC addAction:alertA];
                        [vc presentViewController:alertC animated:YES completion:nil];
                    }
                    callback(NO);
                }
                break;
            }
            case AVAuthorizationStatusRestricted: {
                callback(NO);
                break;
            }
                
            default:
                callback(NO);
                break;
        }
    }else {
        callback(NO);
    }
}

+ (UIViewController *)topViewController
{
    UIViewController *currentController;
    id windowRootVC =  [[UIApplication sharedApplication]keyWindow].rootViewController;
    currentController = [self findTopViewController:windowRootVC];
    return currentController;
}


+ (id)findTopViewController:(id)inController
{
    if ([inController isKindOfClass:[UITabBarController class]])
    {
        return [self findTopViewController:[inController selectedViewController]];
    }
    else if ([inController isKindOfClass:[UINavigationController class]])
    {
        return [self findTopViewController:[inController visibleViewController]];
    }
    else if ([inController isKindOfClass:[UIViewController class]])
    {
        return inController;
    }
    else
    {
        NSLog(@"Unhandled ViewController class : %@",inController);
        return nil;
    }
}

+ (NSString *)dateFormatter:(NSString *)string{
    // iOS 生成的时间戳是10位
    NSTimeInterval interval    =[string doubleValue] / 1000.0;
//    NSDate *date               = [NSDate dateWithTimeIntervalSince1970:interval];
//
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString *dateString       = [formatter stringFromDate: date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // （@"YYYY-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:interval];
    
//    NSLog(@"1296035591  = %@",confromTimesp);
    
    
    
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    

    return confromTimespStr;

}


+ (NSString*)md5:(NSString *)md5
{
    const char *cStr = [md5 UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    unsigned int length = (unsigned int)strlen(cStr);
    CC_MD5(cStr, length, result);
    
    NSString *resultText = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                            result[0], result[1], result[2], result[3],
                            result[4], result[5], result[6], result[7],
                            result[8], result[9], result[10], result[11],
                            result[12], result[13], result[14], result[15]
                            ];
    
    return [resultText lowercaseString];
}

@end
