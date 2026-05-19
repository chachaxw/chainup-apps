//
//  YJYLinesPaoPaoView.h
//  YJYLinesView
//
//  Created by yuhuan on 2023/3/22.
//  Copyright © 2023年 YJY. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,Direction){
    directionTop, //顶部 English: Top
    directionBottom,  //底部 English: bottom
};
@interface YJYLinesPaoPaoView : UIView

@property (nonatomic,strong) UIImage *backgroudImage;

@property (nonatomic,assign) CGFloat margin;
//左侧是否靠边 默认为NO不靠边 English: Whether the left side is adjacent to the edge defaults to NO and not to the edge
@property (nonatomic,assign) BOOL beyondLeft;
//右侧是否靠边 默认为NO不靠边 English: Whether the right side is on the edge is defaulted to NO, not on the edge
@property (nonatomic,assign) BOOL beyondRight;

//百分号 展示小数位数 English: The percentage sign displays the number of decimal places
@property (nonatomic,assign) NSString * number;
@property (nonatomic,assign) bool showPrecent;
- (void)show:(NSArray *)dataArr and:(NSString *)title colorArr:(NSArray *)color;

+(CGSize)getWidthAndHeight:(NSArray *)dataArray;
//画边框并填充颜色 English: Draw borders and fill in colors
-(void)drawBoxWithDirection:(Direction)direction;
@end

