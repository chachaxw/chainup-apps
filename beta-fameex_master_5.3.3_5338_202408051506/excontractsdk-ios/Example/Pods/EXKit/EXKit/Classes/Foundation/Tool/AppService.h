//
//  AppService.h
//  Sotao
//
//  Created by Cheney on 5/29/15.
//  Copyright (c) 2015 sotao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void(^CameraAuthCallback)(BOOL isConfrimed);

@interface AppService : NSObject


+ (void)checkCameraPrivacyWithCallback:(CameraAuthCallback)callback;
+ (UIViewController *)topViewController;
+ (NSString*)md5:(NSString *)md5;

@end
