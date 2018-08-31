//
//  ViewController.m
//  iOS_line
//
//  Created by 姜艳昌 on 2018/8/29.
//  Copyright © 2018年 jiang. All rights reserved.
//

#import "ViewController.h"
#import "LineChartView.h"

@interface ViewController ()

@property (nonatomic, strong) LineChartView *lineChart;

@end

#define COLORHEX(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define MainScreenWidth         [UIScreen mainScreen].bounds.size.width     //屏幕宽
#define MainScreenHeight        [UIScreen mainScreen].bounds.size.height    //屏幕高
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(MainScreenWidth/2-50, MainScreenHeight-350, 100, 50);
    [button setTitle:@"刷新线图" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didClickRefresh:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [self.view addSubview:self.lineChart];
//    [self.lineChart setXvalue:@[@"1",@"2",@"3",@"4",@"5"]];
//    [self.lineChart setDataArray:@[@"0.2",@"0.4",@"0",@"-0.2",@"0.1",@"-0.4",@"-0.1"]];
}

#pragma mark -- click --
- (void)didClickRefresh:(UIButton *)sender
{
    NSMutableArray *xArray = [NSMutableArray new];
    NSMutableArray *yArray = [NSMutableArray new];
    int x = 10+arc4random()%5;
    NSLog(@"x:%d",x);
    for (int i=1; i<x; i++) {
        [xArray addObject:[NSString stringWithFormat:@"%d",i]];
        int y1 = (arc4random()%10)-5;
        float y2 = (arc4random()%100) / 100.0;
        float y = (float)(y1+y2);
        NSLog(@"y1:%d y2:%f",y1,y2);
        [yArray addObject:[NSString stringWithFormat:@"%.2f",y]];
    }
    [self.lineChart setXvalue:xArray];
    [self.lineChart setDataArray:yArray];
}

#pragma mark -- lazy --
- (LineChartView *)lineChart
{
    if (!_lineChart) {
        _lineChart = [[LineChartView alloc] initWithFrame:CGRectMake(15, 60, MainScreenWidth-15, 125)];
        _lineChart.lineColor = [COLORHEX(0x24d8fd) colorWithAlphaComponent:1.0];
        _lineChart.fillColor = [COLORHEX(0x24d8fd) colorWithAlphaComponent:0.2];
        _lineChart.bgLineColor = [COLORHEX(0xf2f2f2) colorWithAlphaComponent:1.0];
    }
    return _lineChart;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
