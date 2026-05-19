//
//  ZPLocalized.h
//  CoinXman
//
//  Created by wangdong on 2023/6/5.
//  Copyright © 2023年 liuxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LocalizedStingFunction) {
    LocalizedStingFunctionNone,
    LocalizedStingFunctionCapital,
    LocalizedStingFunctionUpperCase,
    LocalizedStingFunctionLowerCase,
};

@interface CMLocalizedLabel : UILabel
@property (nonatomic, readwrite) IBInspectable NSUInteger function;
@end

@interface CMLocalizedButton : UIButton
@property (nonatomic, readwrite) IBInspectable NSUInteger function;
@end

@interface CMLocalizedBarButtonItem : UIBarButtonItem
@property (nonatomic, readwrite) IBInspectable NSUInteger function;
@end

@interface CMLocalizedTextField : UITextField
@property (nonatomic, readwrite) IBInspectable NSUInteger function;
@end
