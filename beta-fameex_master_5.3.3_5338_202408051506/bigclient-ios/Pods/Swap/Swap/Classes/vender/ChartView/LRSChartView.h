//
//  LRSChartView.h
//  LRSChartView
//
//  Created by lreson on 23/7/21.
//  Copyright © 2023年 lreson. All rights reserved.
//

#import <UIKit/UIKit.h>
#define NS_ENUM(...) CF_ENUM(__VA_ARGS__)


typedef NS_ENUM(NSInteger,LRSChartViewStyle){
    LRSChartViewMoreNoClickLine, //多条折现不可以点击 暂时没做 English: Multiple discounts cannot be clicked and have not been processed yet
    LRSChartViewMoreClickLine,  //多条折现可以点击 English: Multiple discounts can be clicked
    LRSChartViewLeftRightLine,  //左右两种不同数据 English: Two different types of data, left and right
};

typedef NS_ENUM(NSInteger,LRSChartLayerStyle){
    LRSChartNone,   //没有 English: absence
    LRSChartGradient, //渐变 English: Gradient
    LRSChartProjection,  //投影 English: projection
};

typedef NS_ENUM(NSInteger,LRSLineLayerStyle){
    LRSLineLayerNone,   //没有 English: absence
    LRSLineLayerGradient, //渐变 English: Gradient
};

@interface LRSChartView : UIView

/** X轴坐标数据  X-axis coordinate data*/
@property (nonatomic, strong) NSArray *dataArrOfX;
/** Y轴左边数据 English:Data on the left side of the Y-axis*/
@property (nonatomic,strong) NSArray *leftDataArr;
/** Y轴右边数据 没有不用传递 English: There is no data on the right side of the Y-axis, so there is no need to transfer it*/
@property (nonatomic,strong) NSArray *rightDataArr;
/** X轴标题  English: X-axis title*/
@property (nonatomic, strong) UILabel *titleOfX;
/** Y轴标题 English: Y-axis title*/
@property (nonatomic, strong) UILabel *titleOfY;
//线条宽度，默认为1 English: Line width, default to 1
@property (nonatomic, assign) CGFloat lineWidth;
// 计算精度,10,100,1000,默认是1 English: Calculation accuracy, 101001000, default to 1
@property (nonatomic,assign)NSInteger precisionScale;
//折线图样式 默认不可点击 English: The default line chart style is not clickable
@property (nonatomic,assign)LRSChartViewStyle chartViewStyle;
//气泡是否根据折线位置可以浮动，默认不可以 English: Can bubbles float according to the position of the line? It is not allowed by default
@property (nonatomic,assign)BOOL isFloating;
//图层样式 默认没有 English: Layer styles are not available by default
@property (nonatomic,assign) LRSChartLayerStyle chartLayerStyle;
//左侧标注折线颜色组 English: Left annotation line color group
@property (nonatomic, strong) NSArray *leftColorStrArr;
//右侧标注折线颜色组 English: Right annotation line color group
@property (nonatomic, strong) NSArray *rightColorStrArr;
//X轴坐标字体大小 English: Font size for X-axis coordinates
@property (nonatomic, strong) UIFont *x_Font;
//X轴坐标字体颜色 English: X-axis coordinate font color
@property (nonatomic, strong) UIColor *x_Color;
//Y轴坐标字体大小 English: Y-axis coordinate font size
@property (nonatomic, strong) UIFont *y_Font;
//Y轴坐标字体颜色 English: Y-axis coordinate font color
@property (nonatomic, strong) UIColor *y_Color;
@property (nonatomic, strong) UIColor *bgColor;
//X轴间隔大小 English: X-axis interval size
@property (nonatomic, assign) CGFloat Xmargin;
//折现样式  默认没有 English: The default discount style is not available
@property (nonatomic, assign) LRSLineLayerStyle lineLayerStyle;
//折现渐变颜色组 English: Discount gradient color group
@property (nonatomic, strong) NSArray * colors;
//渐变比例 0-1  初始化0.5 English: Gradient scale 0-1 initialization 0.5
@property (nonatomic, assign) CGFloat proportion;
//背景色虚线颜色 English: Background color dashed line color
@property (nonatomic, strong) UIColor *drawDashLineColor;
//百分号 展示小数位数 English: The percentage sign displays the number of decimal places
@property (nonatomic,assign) NSString * number;
@property (nonatomic,assign) NSString * paoPaoNumber;
@property (nonatomic,assign) bool showPrecent; //%
-(void)show;
@end

