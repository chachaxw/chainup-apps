//
//  LRSChartView.m
//  LRSChartView
//
//  Created by lreson on 23/7/21.
//  Copyright © 2023年 lreson. All rights reserved.
//

#import "LRSChartView.h"
#import "YJYTouchCollectionView.h"
#import "YJYTouchScroll.h"
#import "YJYLinesCell.h"
#import "YJYLinesPaoPaoView.h"
#import "UIColor+custom.h"
#import <EXKit/EXKit-Swift.h>
#import "NSString+Additions.h"

#define btnW 12
//#define titleWOfY 35
#define kPaoPaoWidth 75.f
#define KCircleRadius 3 //Circle radius on the line

@import EXKit;
@interface LRSChartView ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    CGFloat currentPage;
    CGFloat Ymargin;//Offset in the Y-axis direction
    CGPoint lastPoint;//The last coordinate point
    UIButton *firstBtn;
    UIButton *lastBtn;
    CGFloat titleWOfY; //Coordinate width on Y-axis

}

@property (nonatomic,strong)YJYTouchScroll *chartScrollView;
@property (nonatomic,strong)YJYTouchCollectionView * xAxiCollectionView;
@property (nonatomic,strong)UIPageControl *pageControl;
@property (nonatomic,strong)NSMutableArray *leftPointArr;
@property (nonatomic,strong)NSMutableArray *rightPointArr;
@property (nonatomic,strong)NSMutableArray *leftBtnArr;
@property (nonatomic, strong)NSMutableArray *detailLabelArr;
@property (nonatomic,strong)NSArray *leftScaleArr;
@property (nonatomic,strong)NSArray *rightScaleArr;
@property (nonatomic,strong)NSMutableArray *leftScaleViewArr;
@property (nonatomic,strong)UIView *scaleBgView;
@property (nonatomic,strong)UILabel *lineLabel;
@property (nonatomic,strong)UILabel *scaleLabel;
@property (nonatomic,strong)UILabel *dateTimeLabel;
@property (nonatomic,assign)NSInteger row;
@property (nonatomic,assign)CGFloat leftJiange;
@property (nonatomic,assign)CGFloat jiange;
@property (nonatomic,assign)CGFloat rightJiange;
@property (nonatomic,assign)BOOL showSelect;
@property (nonatomic,assign) NSInteger selectIndex;
@property (nonatomic,strong)UIView *selectView;
@property (nonatomic,strong)YJYLinesPaoPaoView * paopaoView;
@property (nonatomic,strong)NSMutableArray *charCircleViewArr;
@property (strong,nonatomic) UIBezierPath *circlePath;
@property (strong,nonatomic) CAGradientLayer *gradientlayer;
@property (strong,nonatomic) CAShapeLayer *percentLayer;

@end

@implementation LRSChartView{
    CGFloat _totalDiff;//The difference between the lowest and highest points
    CGFloat _Ymin;// Get the lowest point among all points
    CGFloat _Ymax;// Get the highest point among all points
    CGFloat _topBottomInset; //Distance between bottom and top
    CGFloat hasload; // Has it been loaded
    NSMutableArray *Ylabels;
    NSMutableArray *dashlines;
    bool _same;// The highest point is the same as the lowest point

    
}

+ (NSBundle *)getSwapBundle{
    NSURL * fwUrl = [[NSBundle mainBundle] URLForResource: @"Frameworks" withExtension:nil];
    NSURL * swapUrl = [fwUrl URLByAppendingPathComponent:@"Swap.framework"];
    return  [NSBundle bundleWithURL:swapUrl];
}
#pragma mark --------init-----------
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        currentPage = 0;
        _precisionScale = 1;
        _topBottomInset = 3;
        titleWOfY = 35;
        Ylabels = [NSMutableArray array];
        dashlines = [NSMutableArray array];
        self.leftPointArr = [NSMutableArray array];
        self.rightPointArr = [NSMutableArray array];
        self.leftBtnArr = [NSMutableArray array];
        self.detailLabelArr = [NSMutableArray array];
        self.leftScaleArr = [NSArray array];
        self.leftScaleViewArr = [NSMutableArray array];
        self.showSelect = NO;
        self.isFloating = NO;
        self.chartViewStyle = 0;
        self.chartLayerStyle = 0;
        self.lineLayerStyle = 0;
        self.proportion = 0.5;
        self.colors = [NSArray array];
        self.lineWidth = 1;
        _Xmargin = 50;
        _row = 10;
        [self addDetailViews];
    }
    
    return self;
    
}

-(UILabel *)scaleLabel{
    if (!_scaleLabel) {
        _scaleLabel = [[UILabel alloc]init];
        _scaleLabel.textAlignment = 1;
        _scaleLabel.text = @"3.3681%";
        _scaleLabel.font = [UIFont systemFontOfSize:11];
        _scaleLabel.backgroundColor = [UIColor colorWithRed:255/255.0 green:159/255.0 blue:106/255.0 alpha:1];
        _scaleLabel.textColor = [UIColor whiteColor];
    }
    return _scaleLabel;
    
}

-(UILabel *)dateTimeLabel{
    if (!_dateTimeLabel) {
        _dateTimeLabel = [[UILabel alloc]init];
        _dateTimeLabel.textAlignment = 1;
        _dateTimeLabel.text = @"2023.04.16";
        _dateTimeLabel.font = [UIFont systemFontOfSize:11];
        _dateTimeLabel.backgroundColor = [UIColor whiteColor];
        _dateTimeLabel.textColor = [UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1];
    }
    return _dateTimeLabel;
}

-(NSMutableArray *)charCircleViewArr{
    if (!_charCircleViewArr) {
        _charCircleViewArr = [NSMutableArray new];
    }
    return _charCircleViewArr;
}
//横轴坐标 English: Horizontal axis coordinates
-(YJYTouchCollectionView *)xAxiCollectionView{
    if (!_xAxiCollectionView) {
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc]init];
        collectionViewLayout.minimumInteritemSpacing = 0;
        collectionViewLayout.minimumLineSpacing = 0;
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 4, 0, 0);
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _xAxiCollectionView = [[YJYTouchCollectionView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_chartScrollView.frame), CGRectGetMaxY(_chartScrollView.frame) + 10, CGRectGetWidth(_chartScrollView.frame), 20) collectionViewLayout:collectionViewLayout];
        _xAxiCollectionView.backgroundColor = [UIColor clearColor];
        [_xAxiCollectionView registerNib:[UINib nibWithNibName:@"YJYLinesCell" bundle: [LRSChartView getSwapBundle]] forCellWithReuseIdentifier:@"YJYLinesCell"];
        _xAxiCollectionView.delegate = self;
        _xAxiCollectionView.dataSource = self;
        _xAxiCollectionView.showsHorizontalScrollIndicator = NO;
        _xAxiCollectionView.userInteractionEnabled = YES;
        [self addSubview:_xAxiCollectionView];
    }
    return _xAxiCollectionView;
}




- (UIView *)selectView {
    if (!_selectView) {
        _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.chartScrollView.frame.size.height)];
        _selectView.backgroundColor = _drawDashLineColor;
        [self.chartScrollView addSubview:_selectView];
    }
    return _selectView;
}

-(YJYLinesPaoPaoView *)paopaoView{
    if (!_paopaoView) {
        _paopaoView = [[YJYLinesPaoPaoView alloc] initWithFrame:CGRectZero];
//        self.paopaoView.backgroundColor = [UIColor clearColor];
//        self.paopaoView.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.paopaoView.layer.shadowOffset = CGSizeMake(0, 3);
//        self.paopaoView.layer.shadowOpacity = 0.5;
        _paopaoView.showPrecent = self.showPrecent;
        [self.chartScrollView addSubview:_paopaoView];
    }
    return _paopaoView;
}

-(UILabel *)lineLabel{
    
    if (!_lineLabel) {
        _lineLabel = [[UILabel alloc]init];
        _lineLabel.backgroundColor = [UIColor colorWithRed:255/255.0 green:159/255.0 blue:106/255.0 alpha:1];
    }
    return _lineLabel;
}

#pragma -mark -------------scrollViewDelegate----------------
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _chartScrollView) {
        _xAxiCollectionView.contentOffset = scrollView.contentOffset;
    }else{
        _chartScrollView.contentOffset = scrollView.contentOffset;
        self.paopaoView.hidden = true;
    }
}
#pragma -mark --------------collViewDelegate----------------
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArrOfX.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    YJYLinesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YJYLinesCell" forIndexPath:indexPath];
    cell.titleLB.font = self.x_Font;
    cell.titleLB.textColor = self.x_Color;
    NSString *date = self.dataArrOfX[indexPath.row];
    NSArray * strs = [date componentsSeparatedByString: @" "];
    date = strs.firstObject;
    
    cell.titleLB.text = date;// self.dataArrOfX[indexPath.row];
    cell.titleLB.textAlignment=NSTextAlignmentCenter;
    return cell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(_Xmargin, 20);
}

-(void)setLeftDataArr:(NSArray *)leftDataArr{
    _leftDataArr = leftDataArr;
}

-(void)setRightDataArr:(NSArray *)rightDataArr{
    _rightDataArr = rightDataArr;
    self.pageControl.numberOfPages = 1;
    _rightJiange = 0;
    
}


//Obtain the maximum data value and calculate the interval value between each row
- (void)spaceValue:(NSArray *)array{
    _Ymin = [array[0] floatValue] * _precisionScale;
    _Ymax = _Ymin;
    for (int i = 0; i < [array count]; i++) {
        
        if ([array[i] floatValue] * _precisionScale> _Ymax) {
            _Ymax = [array[i] floatValue] * _precisionScale;
        }
        if ([array[i] floatValue] * _precisionScale < _Ymin) {
            _Ymin = [array[i] floatValue] * _precisionScale;
        }
    }
//    CGFloat chazhi = fabs(maxValue - minValue);
//    CGFloat jianju =  chazhi / _row;
//    NSLog(@"差值- %f, 间距 -%f",chazhi,jianju); English: NSLog (@ "difference -% f, spacing -% f", chazhi, jianju);
//
//    return jianju;
}
// Only take numbers before the decimal point
- (CGFloat)getNumber:(CGFloat)value{
    NSString *string = [NSString stringWithFormat:@"%f",value];
    if (![[NSMutableString stringWithString:string] containsString:@"."]) {
        return value;
    }
    return [[[string componentsSeparatedByString:@"."] firstObject] floatValue];
}

- (void)clear{
    for (int i = 0; i<self.chartScrollView.layer.sublayers.count; i++) {
        [self.chartScrollView.layer.sublayers[i] removeFromSuperlayer];
    }
}

#pragma mark ----------show---------------
-(void)show{
    [Ylabels removeAllObjects];
    [dashlines removeAllObjects];
    [self.leftPointArr removeAllObjects];
    [self canculateData];
    [self addDetailViews];
    [self resetSubViewF];
    
    [self.xAxiCollectionView reloadData];
    
    if (self.dataArrOfX.count > 0) {
        self.chartScrollView.contentSize = CGSizeMake(_Xmargin*self.dataArrOfX.count, 0);
    }
    
    switch (_chartViewStyle) {
        case 0:
            [self showLeftRightView];
            break;
        case 1:
            [self showLeftRightView];
            break;
        case 2:
            [self showLeftRightView];
            break;
            
        default:
            break;
    }
    
    [self scrollToEnd];

}
- (void)scrollToEnd{
    
    NSIndexPath *index = [NSIndexPath indexPathForItem:self.dataArrOfX.count-1 inSection:0];
    [self.xAxiCollectionView scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionLeft animated:true];
    [self.chartScrollView setContentOffset:self.xAxiCollectionView.contentOffset];
}
-(void)canculateData{
  
    for (int i = 0; i < _leftDataArr.count; i++) {
        [self spaceValue:_leftDataArr[i]];
    }


    //The spacing between the maximum and minimum values, the spacing between each row
    _totalDiff = fabs(_Ymax - _Ymin);
    _same = _totalDiff == 0;
    _leftJiange =  _totalDiff / _row;
    
    NSString *maxValue = [NSString stringWithDecial:self.number value:_Ymax];
    NSString *minValue = [NSString stringWithDecial:self.number value:_Ymin];
    
    if (self.showPrecent){
        maxValue = [maxValue stringByAppendingString:@"%"];
        minValue = [maxValue stringByAppendingString:@"%"];
    }
    CGFloat width1=[maxValue boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 21) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_y_Font} context:nil].size.width + 5;
    //The minimum value may contain a negative sign
    CGFloat width2=[minValue boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 21) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_y_Font} context:nil].size.width + 5;
    if (width1 != titleWOfY) {
        titleWOfY = width1;
    }
    if (width2 > titleWOfY) {
        titleWOfY = width2;
    }
}

-(void)showLeftRightView{
    [self.leftPointArr removeAllObjects];
    if (_leftDataArr.count > 0) {
        NSMutableArray * marr = [NSMutableArray array];
        for (int i = 0; i < _leftDataArr.count; i++) {
            NSArray * arr = _leftDataArr[i];
            [marr addObject:[self addDataPointWith:self.chartScrollView andArr:arr andInterval:_leftJiange]];//添加点 English: Add points
        }
        //
        [self.leftPointArr addObjectsFromArray:marr];
        for (int i = 0; i<marr.count; i++) {
            NSArray * arr = [NSArray array];
            if (i < _colors.count) {
                arr = _colors[i];
            }
            [self addBezierPoint:marr[i] andColorStr:_leftColorStrArr[i] andColors:arr];
        }
    }
    if (self.leftPointArr.count > 0) {
        for (int i = 0; i < self.leftPointArr.count; i++) {
            NSMutableArray * marr = [NSMutableArray arrayWithArray:self.leftPointArr[i]];
            if (marr.count > 2) {
                [marr removeObjectAtIndex:0];
                [marr removeObjectAtIndex:marr.count - 1];
            }
            
            self.leftPointArr[i] = marr;
        }
    }
    
    
    [self addBottomViewsWith:self.chartScrollView];
}


#pragma mark *******************data Source************************

-(void)setDataArrOfX:(NSArray *)dataArrOfX{
    
    _dataArrOfX = dataArrOfX;
}


#pragma mark *******************line************************
-(void)addDetailViews{
    //
  
    self.chartScrollView = [[YJYTouchScroll alloc]initWithFrame:CGRectZero];
    self.chartScrollView.backgroundColor = [UIColor clearColor];
    self.chartScrollView.delegate = self;
    self.chartScrollView.showsHorizontalScrollIndicator = NO;
    self.chartScrollView.userInteractionEnabled = YES;
    [self adddashlies];
    [self addLeftViews];
    [self addSubview:self.chartScrollView];
    [self addSubview:self.xAxiCollectionView];
   
}

- (void)resetSubViewF{
    
    self.chartScrollView.frame = CGRectMake(titleWOfY + 5, 0, self.bounds.size.width-titleWOfY - 10, self.bounds.size.height - 40);
    self.xAxiCollectionView.frame = CGRectMake(CGRectGetMinX(_chartScrollView.frame), CGRectGetMaxY(_chartScrollView.frame) + 10, CGRectGetWidth(_chartScrollView.frame) + 3, 20);
    
    CGFloat h = _chartScrollView.frame.size.height - 2 * _topBottomInset;
    CGFloat spaceY = h / _row;
    int i = 0;
    for (UILabel *ylabel in Ylabels) {
        ylabel.frame = CGRectMake(0, _topBottomInset + (spaceY * i), titleWOfY , spaceY);
      
        CGFloat itemValue = _Ymax - _leftJiange * i;
        NSString * ylabelText = [NSString stringWithDecial:self.number value:itemValue];
        if (self.showPrecent) {
            ylabelText = [ylabelText stringByAppendingString:@"%"];
        }
        ylabel.text = ylabelText;
        ylabel.font = _y_Font;
        ylabel.textColor = _y_Color;
        if (i %2 == 0) {
            ylabel.hidden = true;
        }
        i+=1;
    }
    int j = 1;
    for (UIView *line in dashlines) {
        line.frame = CGRectMake(titleWOfY + 5,_topBottomInset + (h/_row) * j, self.bounds.size.width - titleWOfY - 10 , 0.5);
        [ self drawDashLine:line lineLength:line.bounds.size.width lineSpacing:1 lineColor:self.drawDashLineColor];
        j+=1;
    }
}

- (void)adddashlies{
    CGFloat h = _chartScrollView.frame.size.height - 2 * _topBottomInset;
    for (int i = 1 ; i < _row + 1; i++) {
        UIView *line = [UIView new];
        line.frame = CGRectMake(titleWOfY + 5,_topBottomInset + (h/_row) * i, self.bounds.size.width - titleWOfY - 10 , 0.5);
        [self addSubview:line];
        [dashlines addObject:line];
    }
}



#pragma mark
-(void)buildBGCircleLayer:(NSArray *)colors
{
    CAShapeLayer *bgCircleLayer = [CAShapeLayer layer];
    bgCircleLayer.path = _circlePath.CGPath;
    bgCircleLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    bgCircleLayer.fillColor = [UIColor clearColor].CGColor;
    bgCircleLayer.lineWidth = _lineWidth;
    bgCircleLayer.lineCap = kCALineCapRound; //
    //[self.layer setMask:bgCircleLayer];
    //    [self.layer addSublayer:_bgCircleLayer];
    
    [self addShowPercentLayer:colors];
    [self percentAnimation];
    
}

-(void)addShowPercentLayer:(NSArray *)colors
{
    _gradientlayer = (id)[CAGradientLayer layer];
    if (colors && colors.count > 0) {
        NSMutableArray * marr = [NSMutableArray array];
        for (int i = 0; i < colors.count; i++) {
            UIColor * color = colors[i];
            [marr addObject:(id)color.CGColor];
        }
        _gradientlayer.colors = marr;
    }else{
        _gradientlayer.colors = [NSArray arrayWithObjects:(id)[[UIColor redColor]CGColor],(id)[[UIColor blueColor]CGColor], nil];
    }
    
    _gradientlayer.startPoint= CGPointMake(0.10, 1);
    _gradientlayer.endPoint = CGPointMake(0.90, 1);
    _gradientlayer.locations = @[[NSNumber numberWithFloat:_proportion]];
    NSLog(@"%f-----------%f",self.chartScrollView.contentSize.width,self.chartScrollView.contentSize.height);
    _gradientlayer.frame = CGRectMake(0, 0, self.chartScrollView.contentSize.width, CGRectGetHeight(self.chartScrollView.frame));
    
    _percentLayer = [CAShapeLayer layer];
    _percentLayer.path = _circlePath.CGPath;
    _percentLayer.strokeColor = [UIColor redColor].CGColor;
    _percentLayer.fillColor = [UIColor clearColor].CGColor;
    _percentLayer.lineWidth = _lineWidth;
    _percentLayer.strokeStart = 0;
    _percentLayer.strokeEnd = 1;
    _percentLayer.lineCap = kCALineCapRound;
    
    if (_chartLayerStyle == 2) {
        _percentLayer.shadowColor = [UIColor redColor].CGColor;
        _percentLayer.shadowOffset = CGSizeMake(0,5);
        _percentLayer.shadowOpacity = 0.5;
    }
   
    
    [_gradientlayer setMask:_percentLayer];
    [self.chartScrollView.layer addSublayer:_gradientlayer];
    
}
-(void)percentAnimation
{
    CABasicAnimation *anmi = [CABasicAnimation animation];
    anmi.keyPath = @"strokeEnd";
    anmi.fromValue = [NSNumber numberWithFloat:0];
    anmi.toValue = [NSNumber numberWithFloat:1.0f];
    anmi.duration =2.0f;
    anmi.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anmi.autoreverses = NO;
    [_percentLayer addAnimation:anmi forKey:@"stroke"];
}
//
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"finished");
    
}
#pragma mark ----------draw----------------
-(void)addBezierPoint:(NSArray *)pointArray andColorStr:(NSString *)colorStr andColors:(NSArray *)colors{

    CGPoint p1 = [[pointArray objectAtIndex:0] CGPointValue];
    CGPoint p2 = [[pointArray objectAtIndex:0] CGPointValue];
    p2.y = p2.y + 5 < CGRectGetHeight(self.chartScrollView.frame) ? p2.y + 5 : CGRectGetHeight(self.chartScrollView.frame);

    UIBezierPath *beizer = [UIBezierPath bezierPath];
    [beizer moveToPoint:p1];
    _circlePath = beizer;

    //Line connection
    UIBezierPath *beizer2 = [UIBezierPath bezierPath];
    [beizer2 moveToPoint:p1];
    [beizer2 addLineToPoint:CGPointMake(100, 10)];

    //The shape of the mask layer
    UIBezierPath *bezier1 = [UIBezierPath bezierPath];
    bezier1.lineCapStyle = kCGLineCapRound;
    bezier1.lineJoinStyle = kCGLineJoinMiter;
    [bezier1 moveToPoint:p1];


    for (int i = 0;i<pointArray.count;i++ ) {
        if (i != 0) {

            CGPoint prePoint = [[pointArray objectAtIndex:i-1] CGPointValue];
            CGPoint nowPoint = [[pointArray objectAtIndex:i] CGPointValue];
            //            [beizer addLineToPoint:point];
            [beizer addCurveToPoint:nowPoint controlPoint1:CGPointMake((nowPoint.x+prePoint.x)/2, prePoint.y) controlPoint2:CGPointMake((nowPoint.x+prePoint.x)/2, nowPoint.y)];


            if (_chartLayerStyle == LRSChartGradient) [bezier1 addCurveToPoint:nowPoint controlPoint1:CGPointMake((nowPoint.x+prePoint.x)/2, prePoint.y) controlPoint2:CGPointMake((nowPoint.x+prePoint.x)/2, nowPoint.y)];

            if (i == pointArray.count-1) {
                [beizer moveToPoint:nowPoint];
                lastPoint = nowPoint;
            }

        }
    }


    CGFloat bgViewHeight = self.chartScrollView.bounds.size.height;

   
    CGFloat lastPointX = lastPoint.x;

 

    CGPoint lastPointX1 = CGPointMake(lastPointX, bgViewHeight);

    [bezier1 addLineToPoint:lastPointX1];



    [bezier1 addLineToPoint:CGPointMake(p1.x, bgViewHeight)];

    [bezier1 addLineToPoint:p1];
    
    if (_lineLayerStyle == 1) {
        
        if (_chartLayerStyle == 1) {
            [self addGradientWithBezierPath:bezier1 andColorStr:colorStr];
        }
        
        [self buildBGCircleLayer:colors];
        return;
    }

//    //*********************************//
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = beizer.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor colorWithHexString:colorStr andAlpha:1.0].CGColor;
    shapeLayer.lineWidth = 2;


    switch (_chartLayerStyle) {
        case 0:
            break;
        case 1:
            [self addGradientWithBezierPath:bezier1 andColorStr:colorStr];
            break;
        case 2:
#pragma mark -------------------------
            shapeLayer.shadowOffset = CGSizeMake(0, 5);
            shapeLayer.shadowColor = [UIColor colorWithHexString:colorStr andAlpha:1.0].CGColor;
            shapeLayer.shadowOpacity = 0.5;
            break;
        default:
            break;
    }

    [self.chartScrollView.layer addSublayer:shapeLayer];
    CABasicAnimation *anmi = [CABasicAnimation animation];
    anmi.keyPath = @"strokeEnd";
    anmi.fromValue = [NSNumber numberWithFloat:0];
    anmi.toValue = [NSNumber numberWithFloat:1.0f];
    anmi.duration =2.0f;
    anmi.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anmi.autoreverses = NO;
    [shapeLayer addAnimation:anmi forKey:@"stroke"];
}
#pragma mark    ---------------------------
-(void)addGradientWithBezierPath:(UIBezierPath *)beizer andColorStr:(NSString *)colorStr{
   
    CAShapeLayer *shadeLayer = [CAShapeLayer layer];
    shadeLayer.path = beizer.CGPath;
    shadeLayer.fillColor = [UIColor greenColor].CGColor;
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, 0, self.chartScrollView.bounds.size.height);
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.cornerRadius = 5;
    gradientLayer.masksToBounds = YES;
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithHexString:colorStr andAlpha:0.05].CGColor,(__bridge id)[UIColor colorWithHexString:colorStr andAlpha:0].CGColor];
    gradientLayer.locations = @[@(0.5f)];

    CALayer *baseLayer = [CALayer layer];
    [baseLayer addSublayer:gradientLayer];
    [baseLayer setMask:shadeLayer];
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 40, self.chartScrollView.bounds.size.width-5, self.chartScrollView.bounds.size.height)];
    [self.chartScrollView addSubview:view];
    [self.chartScrollView.layer addSublayer:baseLayer];


    CABasicAnimation *anmi1 = [CABasicAnimation animation];
    anmi1.keyPath = @"bounds";
    anmi1.duration = 2.f;
    anmi1.toValue = [NSValue valueWithCGRect:CGRectMake(5, 0, 2*lastPoint.x, self.chartScrollView.bounds.size.height-60)];
    anmi1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anmi1.fillMode = kCAFillModeForwards;
    anmi1.autoreverses = NO;
    anmi1.removedOnCompletion = NO;

    [gradientLayer addAnimation:anmi1 forKey:@"bounds"];
}
#pragma mark -----------------------
-(NSMutableArray *)addDataPointWith:(UIView *)view andArr:(NSArray *)DataArr andInterval:(CGFloat)interval {
    
    //self.leftScaleArr = leftData;
    
    CGFloat height = self.chartScrollView.bounds.size.height - _topBottomInset * 2;
    
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:DataArr];

    NSMutableArray * marr = [NSMutableArray array];
    for (int i = 0; i<arr.count; i++) {
        
        ////The proportion of subtracting the lowest value/total difference from each one
        float ydiff = [arr[i] floatValue] - _Ymin;
        float y =  (1 -  ydiff / _totalDiff )* height;
        if (_same) {
            y = 0.5 * height;
        }
        y += _topBottomInset;

        NSLog(@" tempHeight =%f",y);
        NSValue *point = [NSValue valueWithCGPoint:CGPointMake(((_Xmargin)*i + _Xmargin / 2),y)];
        
        if (i == 0) {
            NSValue *point1 = [NSValue valueWithCGPoint:CGPointMake(0 , y)];
            
            [marr addObject:point1];
        }
        [marr addObject:point];
        
        if (i + 1 == arr.count) {
            NSValue *point1 = [NSValue valueWithCGPoint:CGPointMake((_Xmargin)* (i + 1) , y)];
            
            [marr addObject:point1];
        }
        
    }
    return marr;
    
}
#pragma mark ---------Add left Y-axis annotation---------------
-(void)addLeftViews{

    CGFloat h =  _chartScrollView.frame.size.height - 2 * _topBottomInset;
    CGFloat spaceY = h / _row;
    for (NSInteger i = 0;i< _row ;i++ ) {
        UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _topBottomInset + (spaceY * i), titleWOfY , spaceY)];
        leftLabel.font = _y_Font;
        leftLabel.textColor = _y_Color;
        leftLabel.textAlignment = NSTextAlignmentRight;
//        NSLog(@"y = %@",NSStringFromCGRect(leftLabel.frame) );
//        leftLabel.text = [NSString stringWithFormat:@"%.6f",_Ymax - _leftJiange * i];
//        if (i %2 != 0) {
            [self addSubview:leftLabel];
            [Ylabels addObject:leftLabel];
//        }
    }
}
#pragma mark -----------------------

- (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor
{
      CAShapeLayer *shapeLayer = [CAShapeLayer layer];
      [shapeLayer setBounds:lineView.bounds];
      [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, 0)];
      [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    
      [shapeLayer setStrokeColor:lineColor.CGColor];
      [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
      [shapeLayer setLineJoin:kCALineJoinRound];

    
      [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineSpacing], [NSNumber numberWithInt:lineSpacing], nil]];

      CGMutablePathRef path = CGPathCreateMutable();
      CGPathMoveToPoint(path, NULL, 0, 0);
      CGPathAddLineToPoint(path, NULL,CGRectGetWidth(lineView.frame), 0);
      [shapeLayer setPath:path];
      CGPathRelease(path);

      [lineView.layer addSublayer:shapeLayer];
  }
#pragma mark ---------Add right Y-axis annotation--------------
-(void)addRightViews{
    
    for (NSInteger i = 0;i<= _row ;i++ ) {
        UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - titleWOfY + 5, CGRectGetHeight(_chartScrollView.frame) - i * Ymargin - 10, titleWOfY - 5, 20)];
        leftLabel.font = [UIFont systemFontOfSize:10.0f];
        leftLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        leftLabel.textAlignment = NSTextAlignmentLeft;
        leftLabel.text = [NSString stringWithFormat:@"%.0f",_rightJiange * i];
        [self addSubview:leftLabel];
        
    }
}


-(void)addBottomViewsWith:(UIView *)View{
    
    NSArray *bottomArr;
    
    if (View == self.chartScrollView) {
        bottomArr = _dataArrOfX;
        
    }else{
        
    }
}



-(void)TopBtnAction:(UIButton *)sender{
    
    for (UIButton*btn in _leftBtnArr) {
        if (sender.tag == btn.tag) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
    }
    [self showDetailLabel:sender];
    
}

-(void)showDetailLabel:(UIButton *)sender{
    
    for (UILabel * label in _detailLabelArr) {
        if (sender.tag+200 == label.tag) {
            label.hidden = NO;
        }else{
            label.hidden = YES;
        }
    }
    
}

#define mark -
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (_chartViewStyle == 0) return;
    UITouch *touch=[touches anyObject];
    
    if (touch.view == self.chartScrollView || touch.view.superview == self.chartScrollView) {
        
        [self.paopaoView removeFromSuperview];
        self.paopaoView = nil;
        
        CGPoint point = [touch locationInView:self.chartScrollView];
        float indexF = (point.x-_Xmargin / 2) / _Xmargin;
        
        NSInteger index = (point.x-_Xmargin / 2) / _Xmargin;
        float disparity = indexF - index;
        if (disparity>0.5) {
            index = index+1;
        }
        [self drawOtherLin:index AndPoint:point];
        return;
    }
    
    UIView *parentView = [touch.view superview];
    while (![parentView isKindOfClass:[UICollectionViewCell class]] && parentView!=nil) {
        parentView = parentView.superview;
    }
    if ([parentView isKindOfClass:[UICollectionViewCell class]]) {
        CGPoint point = [touch locationInView:self.xAxiCollectionView];
        float indexF = (point.x-_Xmargin / 2) / _Xmargin;
        
        NSInteger index = (point.x-_Xmargin / 2) / _Xmargin;
        float disparity = indexF - index;
        if (disparity>0.5) {
            index = index+1;
        }
        [self drawOtherLin:index AndPoint:point];
        return;
    }
}


-(void)drawOtherLin:(NSInteger)index AndPoint:(CGPoint)touchpoint{
    if(index > self.dataArrOfX.count-1 || index<0 || self.dataArrOfX.count == 0){
        return ;
    }
    if (self.showSelect && self.selectIndex== index) {
        self.selectView.hidden = YES;
        self.paopaoView.hidden = YES;
        for (UIView *view in self.charCircleViewArr) {
            [view removeFromSuperview];
        }
        self.showSelect = NO;
        return;
    }
    self.showSelect = YES;
    self.selectIndex = index;
    [self setPaopaoUI:index];
    
}

-(void)setPaopaoUI:(NSInteger)index{

    self.selectView.hidden = NO;
    self.selectView.frame = CGRectMake(_Xmargin*index+_Xmargin / 2, 0, self.selectView.frame.size.width, self.selectView.frame.size.height);
    
    if (self.selectView.superview == nil) {
        [self.chartScrollView addSubview:self.selectView];
    }
    
    [self.chartScrollView bringSubviewToFront:self.paopaoView];
    self.paopaoView.hidden = NO;
    if (self.paoPaoNumber.length > 0) {
        self.paopaoView.number = self.paoPaoNumber;
    }else{
        self.paopaoView.number = self.number;
    }
    
    [self.chartScrollView bringSubviewToFront:self.selectView];
    
    NSMutableArray *dataArr = [NSMutableArray new];
    if (_chartViewStyle == LRSChartViewLeftRightLine) {
        [self.leftDataArr enumerateObjectsUsingBlock:^(NSArray<NSArray *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (index < obj.count) {
                [dataArr addObject:obj[index]];
            }
        }];
        
        [self.rightDataArr enumerateObjectsUsingBlock:^(NSArray<NSArray *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (index < obj.count) {
                [dataArr addObject:obj[index]];
            }
        }];
    }else{
        [self.leftDataArr enumerateObjectsUsingBlock:^(NSArray<NSArray *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (index < obj.count) {
                [dataArr addObject:obj[index]];
            }
        }];
    }
    
    

    
    NSMutableArray *colorArr = [NSMutableArray array];
    
    
    
    for (int i = 0; i < self.leftColorStrArr.count; i++) {
        [colorArr addObject:[UIColor colorWithHexString:self.leftColorStrArr[i]]];
    }
    
    for (int i = 0; i < self.rightColorStrArr.count ; i++) {
         [colorArr addObject:[UIColor colorWithHexString:self.rightColorStrArr[i]]];
    }
    
    CGSize size = [YJYLinesPaoPaoView getWidthAndHeight:dataArr];
    
    float paopao_x = index * _Xmargin + _Xmargin / 2 - size.width * 0.5;
    NSLog(@"%f",self.chartScrollView.contentSize.width);
    if (paopao_x < 0) {
        paopao_x = 0;
    }else if (paopao_x > self.chartScrollView.contentSize.width - size.width) {
        paopao_x = self.chartScrollView.contentSize.width - size.width;
    }
   
    self.paopaoView.frame = CGRectMake(paopao_x, self.paopaoView.frame.origin.y, size.width, 30);
    self.paopaoView.margin = _Xmargin;
    
    if (paopao_x == 0 && size.width > _Xmargin) {
        self.paopaoView.beyondLeft = YES;
    }else if (index * _Xmargin + _Xmargin / 2 - size.width * 0.5 > self.chartScrollView.contentSize.width - size.width && size.width > _Xmargin){
        self.paopaoView.beyondRight = YES;
    }
    
    [self.paopaoView show:dataArr and:self.dataArrOfX[index] colorArr:colorArr];
    
    [self addCircle:index];
}

- (void)addCircle:(NSInteger)index{
    for (UIView *view in self.charCircleViewArr) {
        [view removeFromSuperview];
    }
    NSMutableArray * leftColorArr = [NSMutableArray array];
    
    switch (_chartViewStyle) {
        case 0:
            for (int i = 0; i < _leftColorStrArr.count; i++) {
                [leftColorArr addObject:[UIColor colorWithHexString:_leftColorStrArr[i]]];
            }
            
            [self.charCircleViewArr removeAllObjects];
            [self drawCircle:index arr:self.leftPointArr color:leftColorArr];
            break;
        case 1:
            for (int i = 0; i < _leftColorStrArr.count; i++) {
                [leftColorArr addObject:[UIColor colorWithHexString:_leftColorStrArr[i]]];
            }
            
            [self.charCircleViewArr removeAllObjects];
            [self drawCircle:index arr:self.leftPointArr color:leftColorArr];
            break;
        
        case 2:
            for (int i = 0; i < _leftColorStrArr.count; i++) {
                [leftColorArr addObject:[UIColor colorWithHexString:_leftColorStrArr[i]]];
            }
            
            
            for (int i = 0; i < _rightColorStrArr.count; i++) {
                [leftColorArr addObject:[UIColor colorWithHexString:_rightColorStrArr[i]]];
            }
            
            
            [self.charCircleViewArr removeAllObjects];
            [self drawCircle:index arr:self.leftPointArr color:leftColorArr];
            break;
            
        default:
            break;
    }
    
    
    //[self.chartScrollView bringSubviewToFront:self.paopaoView];
}

- (void) drawCircle:(NSInteger)index arr:(NSArray *)pointArr color:(NSArray<UIColor *> *)colors{
    for (int i = 0; i<pointArr.count; i++) {
        NSArray *arr = pointArr[i];
        if (arr.count > index){
            CGPoint point = [arr[index] CGPointValue];
            UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KCircleRadius*2, KCircleRadius*2)];
            view.center = point;
            if (i == 0 && self.isFloating) {
                if (point.y - CGRectGetHeight(self.paopaoView.frame) - KCircleRadius >= 0) {
                    CGRect frame = self.paopaoView.frame;
                    frame.origin.y = point.y - CGRectGetHeight(self.paopaoView.frame) - KCircleRadius;
                    [self.paopaoView setFrame:frame];
                    [self.paopaoView drawBoxWithDirection:directionTop];
                    
                }else{
                    CGRect frame = self.paopaoView.frame;
                    frame.origin.y = point.y + KCircleRadius;
                    [self.paopaoView setFrame:frame];
                    [self.paopaoView drawBoxWithDirection:directionBottom];
                    
                    
                }
            }else if(i == 0){
                 [self.paopaoView drawBoxWithDirection:directionTop];
            }
            if (colors.count > i) {
                view.backgroundColor = colors[i];
            }else{
                if (self.leftColorStrArr.count > 0){
                    view.backgroundColor = self.leftColorStrArr[0];
                }
            }
            view.layer.cornerRadius = KCircleRadius;
            view.layer.borderColor = [UIColor whiteColor].CGColor;
            view.layer.borderWidth = 1;
            view.layer.masksToBounds = YES;
            [self.chartScrollView addSubview:view];
            [self.charCircleViewArr addObject:view];
        }
    }
    [self.chartScrollView bringSubviewToFront:self.paopaoView];
}

-(void)addLines1With:(UIView *)view{
    
    CGFloat magrginHeight = (view.bounds.size.height)/ _row;
    Ymargin = magrginHeight;
    
    CAShapeLayer * dashLayer = [CAShapeLayer layer];
    dashLayer.strokeColor = [UIColor colorWithRed:224/255.0f green:224/255.0f blue:224/255.0f alpha:1].CGColor;
    dashLayer.lineWidth = 0.5;
    
    UIBezierPath * path = [[UIBezierPath alloc]init];
    path.lineWidth = 1.0;
    
    [path moveToPoint:CGPointMake(titleWOfY, CGRectGetHeight(_chartScrollView.frame))];
    [path addLineToPoint:CGPointMake(titleWOfY,0)];
    [path moveToPoint:CGPointMake(titleWOfY, CGRectGetHeight(_chartScrollView.frame))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(_chartScrollView.frame),CGRectGetHeight(_chartScrollView.frame))];
    if (_chartViewStyle == LRSChartViewLeftRightLine) {
        [path moveToPoint:CGPointMake(CGRectGetMaxX(_chartScrollView.frame) + 1, CGRectGetHeight(_chartScrollView.frame))];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(_chartScrollView.frame) + 1,0)];
    }
    dashLayer.path = path.CGPath;
    [self.layer addSublayer:dashLayer];

}





@end



