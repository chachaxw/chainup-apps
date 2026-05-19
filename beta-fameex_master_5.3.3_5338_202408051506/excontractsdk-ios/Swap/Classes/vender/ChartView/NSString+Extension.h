//
//  NSString+Extension.h
//  SCH
//
//  Created by SCH_YUH on 2023/1/10.
//  Copyright © 2023年 SCH_YUH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (Extension)
///得到现在时间戳的字符串 English: /Obtain the current timestamp string
+ (instancetype)getDateUnqueDescription;
#pragma mark - 判断一个字符串是不是空
/**
 *函数描述 : 判断一个字符串是不是空 English: *Function description: Determine if a string is empty
 *@returns 为空则返回真 English: *@If returns are empty, return true
 */
- (BOOL)isEmpty;
-(BOOL)isNull;
+ (BOOL) isNullOrEmpty:(NSString *)string;

#pragma mark - 验证号码
#pragma mark -
/**
 *函数描述 :验证邮箱是否合法 English: *Function description: Verify whether the email is legal
 *返回 :YES=合法邮箱 English: *Return: YES=Legal Email
 **/
-(BOOL)verifyEmail;
/**
 *函数描述 :验手机号是否合法 English: *Function description: Verify whether the phone number is legal
 *返回 :YES=合法手机号 English: *Return: YES=Legal phone number
 */
-(BOOL)isPhoneNumber;
/**
 验证座机 English: Verify landline
 */
-(BOOL)isTelephoneNumber;


//返回值是该字符串所占一行的width English: The return value is the width of the line occupied by the string
-(CGFloat)getSingleLineTextSizeWithFont: (UIFont*)font;


/**
 拨打电话 English: Making phone calls
 */
-(void)call;

/**
 随机图片名称 English: Random image name
 
 @return 图片名称 English: @Return Image Name
 */
+ (NSString *)pictureNaming;
/**
 获取刻度尺 English: Obtain a scale ruler
 
 @param num 数量 English: @Param num quantity
 @param unit 单位 English: @Param unit
 @return 返回需要的字符串 English: @Return returns the required string
 */
+(NSString *)roundUpNum:(CGFloat)num unit:(NSString *)unit;

/**
 获取刻度尺 得到的数字之间将小数点后面一位之后的舍去 English: Round off the digits obtained from the scale after one decimal point
 
 @param num 数量 English: @Param num quantity
 @param unit 单位 English: @Param unit
 @return 返回需要的字符串 English: @Return returns the required string
 */
+(NSString *)roundUpFloorfNum:(CGFloat )num unit:(NSString *)unit;

+(NSDictionary *)dic_roundUpNum:(CGFloat )num unit:(NSString *)unit;
+(NSString *)dic_roundUpNum:(NSDictionary *)dic;
+(NSString *)dic_roundUpUnit:(NSDictionary *)dic;
/**
 获取字符串宽 English: Get string width
 
 @param str 文字 English: @Param str text
 @param wordFont 字体大小 English: @Param wordFont font size
 @return 文字宽度 English: @Return text width
 */
+(CGSize)getAttributeSizeWithText:(NSString *)text fontSize:(int)fontSize;
+(float)measureSinglelineStringWidth:(NSString*)str andFont:(UIFont*)wordFont;
@end

