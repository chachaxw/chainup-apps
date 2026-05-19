//
//  ZPLocalized.m
//  CoinXman
//
//  Created by wangdong on 2023/6/5.
//  Copyright © 2023年 liuxuan. All rights reserved.
//

#import "ZPLocalized.h"
#import "Chainup-Swift.h"

static NSString * localizedStringFunction(NSString *key, LocalizedStingFunction function)
{
    
  NSString *raw = [LanguageTools getStringWithKey:key];
    
//    NSString *raw = NSLocalizedString(key,nil);
    
    return
    function == LocalizedStingFunctionCapital ? [[raw lowercaseString] capitalizedString] :
    function == LocalizedStingFunctionUpperCase ? [raw uppercaseString] :
    function == LocalizedStingFunctionLowerCase ? [raw lowercaseString] :
    raw;
}

@implementation CMLocalizedLabel

- (void)awakeFromNib
{
    [super awakeFromNib];

    if (self.attributedText.length > 0 && ![self.attributedText.string containsString:@"cp_"]) {
        NSDictionary *dic = [self.attributedText attributesAtIndex:0 effectiveRange:NULL];
        self.attributedText = [[NSAttributedString alloc] initWithString:[LanguageTools getStringWithKey:self.attributedText.string]attributes:dic];
    }
    else {
        self.text = localizedStringFunction(self.text, _function);
    }
    
}

@end

@implementation CMLocalizedButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSString *maybeKey = [self titleForState:UIControlStateNormal];
    [self setTitle:localizedStringFunction(maybeKey, _function) forState:UIControlStateNormal];
}

@end

@implementation CMLocalizedBarButtonItem

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.title = localizedStringFunction(self.title, _function);
}

@end

@implementation CMLocalizedTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSString *holder = localizedStringFunction(self.placeholder, _function);
    self.placeholder = holder;
}

@end
