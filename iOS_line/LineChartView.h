//
//  LineChartView.h
//  JNPolicy
//
//  Created by jiang on 2018/4/8.
//  Copyright © 2018年 zhongyijuntai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineChartView : UIView

///线颜色
@property (nonatomic, weak) UIColor *lineColor;
///填充颜色
@property (nonatomic, weak) UIColor *fillColor;
///背景线颜色
@property (nonatomic, weak) UIColor *bgLineColor;

/**
 赋值划线
 @param dataArray           数据源
 */
- (void)setDataArray:(NSArray *)dataArray;

/**
 X轴赋值
 @param xValue              x轴数据源
 */
- (void)setXvalue:(NSArray *)xValue;

@end
