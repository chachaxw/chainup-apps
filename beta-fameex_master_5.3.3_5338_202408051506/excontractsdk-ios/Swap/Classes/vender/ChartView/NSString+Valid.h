//
//  NSString+Valid.h
//  Kurrent
//
//  Created by hcl on 15/9/14.
//  Copyright (c) 2015年 Kurrent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Valid)


///合法身份证 English: /Legal ID card
- (BOOL)isValidPersonIDCardNumber;

///银行卡校验规则(Luhn算法) English: /Bank Card Verification Rules (Luhn Algorithm)
- (BOOL)isValidBankCardNumber;

/// 是否是是航班号  车次号 English: /Is it the flight number or train number
- (BOOL)isFlightOrTrainNumber;

///是否全部是数字 English: /Is it all numbers
- (BOOL)isNumber;

/// 是否全部数字和字母组成 English: /Is it composed entirely of numbers and letters
- (BOOL)isAlphanumeric;

///中文 字母等 English: /Chinese letters, etc
- (BOOL)isChineseAlphabet;
///手机号码 English: /Mobile phone number
- (BOOL)isValidMobileNumber;
///邮箱地址 English: /Email address
- (BOOL)isValidEmailAddress;
///网页html English: /Web HTML
- (BOOL)isValidHtmlURL;
///合法密码 English: /Legal password
- (BOOL)isValidPassword;
///合法IP地址 English: /Legal IP address
- (BOOL)isValildIPAddress;
///合法IP端口 English: /Legal IP port
- (BOOL)isValidIPPort;

#pragma mark -textField
///合法金额输入...用于textField  delegate English: /Legal amount input Used for textField delegate
- (BOOL)isValidMoneyWithRange:(NSRange)range replacementString:(NSString *)string;
///判断text 最大长度 maxLength = 0 return YES English: /Determine the maximum length of the text, maxLength=0 return YES
- (BOOL)isValidMaxLength:(NSUInteger)maxLength WithRange:(NSRange)range replacementString:(NSString *)string;

@end

