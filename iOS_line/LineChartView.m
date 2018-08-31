//
//  LineChartView.m
//  JNPolicy
//
//  Created by jiang on 2018/4/8.
//  Copyright © 2018年 zhongyijuntai. All rights reserved.
//

#import "LineChartView.h"

@interface LineChartView()

@property (nonatomic, strong) UIView *x_view;                      //存放xview
@property (nonatomic, strong) UIView *y_view;                      //存放yview

@property (nonatomic, strong) NSMutableArray *dataValue;           //折线数据
@property (nonatomic, strong) NSMutableArray *X_value;             //x轴数据
@property (nonatomic, strong) NSMutableArray *Y_value;             //y轴数据

@property (nonatomic, strong) CAShapeLayer *lineLayer;             //线layer
@property (nonatomic, strong) CAShapeLayer *fillLayer;             //填充layer
@property (nonatomic, strong) CAShapeLayer *bgLayer;               //背景线layer

@property (nonatomic, assign) CGFloat yWidth;                      //y宽度
@property (nonatomic, assign) CGFloat xheight;                     //x高度
@property (nonatomic, assign) CGFloat lineHeight;                  //线的高度
@property (nonatomic, assign) CGFloat maxValue;                    //数据源最大值
@property (nonatomic, assign) CGFloat minValue;                    //数据最小值

@end

#define COLORHEX(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation LineChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineColor = COLORHEX(0x212121);
        self.fillColor = [UIColor clearColor];
        self.bgLineColor = COLORHEX(0xf2f2f2);
        
        self.yWidth = 60;
        self.xheight = 20;
        self.lineHeight = frame.size.height - self.xheight;
        [self JN_initUI];
        
    }
    return self;
}

#pragma mark -- ui --
- (void)JN_initUI
{
    self.x_view = [[UIView alloc] init];
    self.x_view.backgroundColor = [UIColor clearColor];
    self.x_view.frame = CGRectMake(0, self.frame.size.height-self.xheight+5, self.frame.size.width, self.xheight-5);
    [self addSubview:self.x_view];
    self.y_view = [[UIView alloc] init];
    self.y_view.backgroundColor = [UIColor clearColor];
    self.y_view.frame = CGRectMake(self.frame.size.width-self.yWidth+5, 0, self.yWidth-5, self.frame.size.height);
    [self addSubview:self.y_view];
}

#pragma mark -- 画线 --
- (void)setDataArray:(NSArray *)dataArray
{
    [self.lineLayer removeFromSuperlayer];
    [self.fillLayer removeFromSuperlayer];
    self.lineLayer = nil;
    self.fillLayer = nil;
    
    _lineLayer = [CAShapeLayer layer];
    _fillLayer = [CAShapeLayer layer];
    
    [self drawBgLineWithArray:[self dataArrayWithYarray:dataArray]];
    ///折线图
    _lineLayer.lineWidth = 1.0;
//?为什么用_linecolor和_fillcolor重绘时会没有颜色呢，思考解决
    _lineLayer.strokeColor = COLORHEX(0x24d8fd).CGColor;
    _lineLayer.fillColor = [UIColor clearColor].CGColor;
    _fillLayer.fillColor = [COLORHEX(0x24d8fd) colorWithAlphaComponent:0.2].CGColor;
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    UIBezierPath *fillpath = [UIBezierPath bezierPath];
    
    //值差与高度的比例
    CGFloat unitValue = (_maxValue - _minValue)/self.lineHeight;
    //平均宽度
    CGFloat unitWidth = (self.frame.size.width-self.yWidth)/(dataArray.count-1);
    NSInteger startY = ABS(self.lineHeight - ([dataArray[0] floatValue]-self.minValue) / unitValue);
    [linePath moveToPoint:CGPointMake(0, startY)];
    [fillpath moveToPoint:CGPointMake(0, startY)];
    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat xPosition = unitWidth * idx;
        CGFloat yPosition;
        if (unitValue == 0.00) {
            yPosition = 0.00;
        }else {
            yPosition = ABS(self.lineHeight - ([obj floatValue]-self.minValue) / unitValue);
        }
        
        [linePath addLineToPoint:CGPointMake(xPosition, yPosition)];
        [fillpath addLineToPoint:CGPointMake(xPosition, yPosition)];
        //在最后一组数据时给填充路径形成一个闭包
        if (idx == dataArray.count-1) {
            [fillpath addLineToPoint:CGPointMake(self.frame.size.width-self.yWidth, self.lineHeight)];
            [fillpath addLineToPoint:CGPointMake(0, self.lineHeight)];
            [fillpath moveToPoint:CGPointMake(0, startY)];
        }
    }];
    _lineLayer.path = linePath.CGPath;
    _fillLayer.path = fillpath.CGPath;

    //动画效果
    [self.layer addSublayer:_lineLayer];
    CABasicAnimation *ani = [ CABasicAnimation animationWithKeyPath : NSStringFromSelector ( @selector (strokeEnd))];
    ani.fromValue = @0;
    ani.toValue = @1;
    ani.duration = 2.0;
    [_lineLayer addAnimation:ani forKey:NSStringFromSelector(@selector(strokeEnd))];
    __block typeof(&*self) ws = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ws.layer addSublayer:ws.fillLayer];
    });
}

- (void)resetDraw
{
//    NSArray *array = self.layer.sublayers;
    [self.lineLayer removeFromSuperlayer];
    [self.fillLayer removeFromSuperlayer];
    [self.bgLayer removeFromSuperlayer];
    self.lineLayer = nil;
    self.fillLayer = nil;
    self.bgLayer = nil;
}

#pragma mark -- 画背景线及y轴赋值 --
- (void)drawBgLineWithArray:(NSArray *)yValue
{
    CAShapeLayer *bgLayer = [CAShapeLayer layer];
    bgLayer.strokeColor = self.bgLineColor.CGColor;
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    linePath.lineWidth = 2.0;
    //背景线
    [yValue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger i, BOOL * _Nonnull stop) {
        [linePath moveToPoint:CGPointMake(0 , self.lineHeight / (yValue.count - 1) * i)];
        [linePath addLineToPoint:CGPointMake(self.frame.size.width-self.yWidth ,self.lineHeight / (yValue.count - 1) * i)];
    }];
    bgLayer.path = linePath.CGPath;
    [self.layer addSublayer:bgLayer];
    
    //y轴数据
    for (UILabel *label in self.y_view.subviews) {
        [label removeFromSuperview];
    }
    [yValue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger i, BOOL * _Nonnull stop) {
        UILabel *yLabel = [[UILabel alloc] init];
        yLabel.font = [UIFont systemFontOfSize:11.0];
        yLabel.textColor = COLORHEX(0x212121);
        yLabel.frame = CGRectMake(0, self.lineHeight / (yValue.count - 1) * i-self.xheight/2, self.y_view.frame.size.width, self.xheight);
        yLabel.text = obj;
        [self.y_view addSubview:yLabel];
    }];
}

#pragma mark -- x轴赋值 --
- (void)setXvalue:(NSArray *)xValue
{
    for (UILabel *label in self.x_view.subviews) {
        [label removeFromSuperview];
    }
    CGFloat xWidth = (self.frame.size.width-self.yWidth)/2;
    [xValue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *xLabel = [[UILabel alloc] init];
        xLabel.font = [UIFont systemFontOfSize:12.0];
        xLabel.textColor = COLORHEX(0x212121);
        xLabel.tag = 10+idx;
        if (idx == 0) {
            xLabel.text = obj;
            xLabel.frame = CGRectMake(0, 0, xWidth, self.x_view.frame.size.height);
            xLabel.textAlignment = NSTextAlignmentLeft;
        }
//        else if (idx == xValue.count/2) {
//            xLabel.text = obj;
//            xLabel.textAlignment = NSTextAlignmentCenter;
//        }
        else if(idx == xValue.count-1){
            xLabel.text = obj;
            xLabel.textAlignment = NSTextAlignmentRight;
            xLabel.frame = CGRectMake(xWidth, 0, xWidth, self.x_view.frame.size.height);
        }
        [self.x_view addSubview:xLabel];
    }];
}

//#pragma mark -- setter --
//- (void)setLineColor:(UIColor *)lineColor
//{
//    _lineColor = lineColor;
////    _lineLayer.strokeColor = lineColor.CGColor;
//}
//- (void)setFillColor:(UIColor *)fillColor
//{
//    _fillColor = fillColor;
////    _fillLayer.fillColor = fillColor.CGColor;
//}
//- (void)setBgLineColor:(UIColor *)bgLineColor
//{
//    _bgLineColor = bgLineColor;
//}

#pragma mark -- lazy --
- (NSMutableArray *)dataArrayWithYarray:(NSArray *)yArray
{
    NSMutableArray *dataArray = [NSMutableArray new];
    CGFloat max = [[yArray valueForKeyPath:@"@max.floatValue"] floatValue];
    _maxValue = max;
    CGFloat min = [[yArray valueForKeyPath:@"@min.floatValue"] floatValue];
    _minValue = min;
    if (max>=0) {
        _maxValue = max * 1.4;
    }else {
        _maxValue = max * 0.6;
    }
    if (min>=0) {
        _minValue = min * 0.6;
    }else {
        _minValue = min * 1.4;
    }
    CGFloat ava = (_maxValue-_minValue)/3;
    [dataArray addObject:[NSString stringWithFormat:@"%.2f%%",_maxValue]];
    [dataArray addObject:[NSString stringWithFormat:@"%.2f%%",(_maxValue-ava)]];
    [dataArray addObject:[NSString stringWithFormat:@"%.2f%%",(_minValue+ava)]];
    [dataArray addObject:[NSString stringWithFormat:@"%.2f%%",_minValue]];
    return dataArray;
}

@end
