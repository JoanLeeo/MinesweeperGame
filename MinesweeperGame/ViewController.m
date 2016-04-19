//
//  ViewController.m
//  MinesweeperGame
//
//  Created by PC-LiuChunhui on 16/4/15.
//  Copyright © 2016年 Mr.Wendao. All rights reserved.
//

#import "ViewController.h"
#define kBorderX 5
#define kBorderY 100
#define kGap 2
@interface ViewController () {
    NSInteger _mineNums;//地雷的个数
    NSInteger _row;//行数
    NSInteger _column;//列数
    NSInteger _cycleNums;
}

@property (nonatomic, strong) UIView *bgView;//

@property (nonatomic, strong) NSMutableArray *mineMapArray;//地雷地图数组
@property (nonatomic, strong) NSMutableArray *minesArray;//所有地雷位置
@property (nonatomic, strong) NSMutableArray *turnoverArray;//可翻转单元的位置数组
@end

@implementation ViewController

- (NSMutableArray *)mineMapArray {
    if (!_mineMapArray) {
        _mineMapArray = [NSMutableArray array];
        for (int i = 0; i < _row * _column; i++) {//初始化单元没有地雷
            [_mineMapArray addObject:@(0)];
        }
    }
    return _mineMapArray;
}
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kBorderY, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds))];
        _bgView.backgroundColor = [UIColor grayColor];
        [self.view addSubview:_bgView];
        
    }
    return _bgView;
}
- (NSMutableArray *)minesArray {
    if (!_minesArray) {
        _minesArray = [NSMutableArray array];
    }
    return _minesArray;
}
- (NSMutableArray *)turnoverArray {
    if (!_turnoverArray) {
        _turnoverArray = [NSMutableArray array];
    }
    return _turnoverArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _mineNums = 10;
    _row = 10;
    _column = 10;
}
/**
 *  初始化地雷
 */
- (void)setupMines {
    //1.创建临时地图位置数组，用于随机出地雷位置
    NSMutableArray *tmpMapArray = [NSMutableArray array];//临时地图位置数组
    for (int i = 0; i < _row * _column; i++) {
        [tmpMapArray addObject:@(i)];
    }
    //2.更新地图地雷位置和记录地雷位置
    int delIndex;//随机数组删除的位置
    int addIndex;//地雷地图添加的位置
    for (int i = 0; i < _mineNums; i++) {
        delIndex = arc4random() % tmpMapArray.count;
        addIndex = [tmpMapArray[delIndex] intValue];
        [self.mineMapArray replaceObjectAtIndex:addIndex withObject:@(9)];//更地图上地雷位置
        [self.minesArray addObject:tmpMapArray[delIndex]];//添加地雷位置到存储所有地雷位置的数组
        [tmpMapArray removeObjectAtIndex:delIndex];//删除临时随机的地雷位置
    }
    //3.标记地雷周围数字
    for (NSNumber *obj in self.minesArray) {//找到地雷周围位置，标记数值加1
        NSInteger location = [obj integerValue];
        NSInteger aroundLocation;//遍历地雷周围8个位置
        
        
        
        //location / _column != 0 判断是否在第一行
        //location % _column != 0 判断是否在第一列
        //location / _column != _column - 1 判断是否在最后一行
        //location % _column != _column - 1 判断是否在最后一列
        //
        aroundLocation = location - _column - 1;//左上
        if (location / _column != 0 && location % _column != 0) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location - _column;//上
        if (location / _column != 0) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location - _column + 1;//右上
        if (location / _column && location % _column != _column - 1) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location + 1;//右
        if (location % _column != _column - 1) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location + _column + 1;//右下
        if (location % _column != _column - 1 && location / _column != _column - 1) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location + _column;//下
        if (location / _column != _column - 1) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location + _column - 1;//左下
        if (location / _column != _column - 1 && location % _column != 0) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location - 1;//左
        if (location % _column != 0) {
            [self locationPlus:aroundLocation];
        }
        
    }
}
- (void)locationPlus:(NSInteger)location {
    NSInteger cellMineNums = [[self.mineMapArray objectAtIndex:location] integerValue];
    if (cellMineNums != 9) {
        cellMineNums++;
    }
    [self.mineMapArray replaceObjectAtIndex:location withObject:@(cellMineNums)];
}
- (void)setupMapView {
    
    for (int i = 0; i < _row * _column; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        //设置frame
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGFloat buttonW = (screenBounds.size.width - kBorderX * 2 - (_column - 1) * kGap) / _column;
        CGFloat buttonH = buttonW;
        CGFloat buttonX = (i % _column) * (buttonW + kGap) + kBorderX;
        CGFloat buttonY = (i / _column) * (buttonH + kGap) + kBorderX;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        button.backgroundColor = [UIColor grayColor];
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"selected_%@", self.mineMapArray[i]]] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageNamed:@"selected_bg"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cellButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(markMine:)];
        [button addGestureRecognizer:longPress];
        [self.bgView addSubview:button];
    }
}

- (void)cellButtonSelect:(UIButton *)button {
    _cycleNums = 0;
    button.selected = YES;
    button.userInteractionEnabled = NO;
    NSInteger mineNum = [self.mineMapArray[button.tag] integerValue];
    
    if (mineNum == 9) {//地雷，游戏结束
        NSLog(@"此为地雷，游戏结束");
        return;
    }
    if (mineNum > 0 && mineNum < 9) {//数字单元
        
        NSLog(@"数字单元，翻过来");
        return;
    }
    
    //找到空白单元周围所有可翻转的单元
    [self.turnoverArray removeAllObjects];
    [self findAllTurnover:button.tag];
    
    
}
/**
 *  长按标记地雷
 */
- (void)markMine:(UILongPressGestureRecognizer *)longPress {
    NSLog(@"longPress");
    UIButton *button = (UIButton *)longPress.view;
    [button setBackgroundImage:[UIImage imageNamed:@"flag_white_bg"] forState:UIControlStateNormal];
    
}
- (void)findAllTurnover:(NSInteger)location {
    
    if ([self.mineMapArray[location] integerValue] != 0) {//如果当前单元不是空白单元则，回到上一层继续寻找下一个位置
        [self.turnoverArray addObject:@(location)];
        return;
    }
    
    NSInteger aroundLocation;
    aroundLocation = location - _column - 1;//左上
    if (location / _column != 0 && location % _column != 0) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location - _column;//上
    if (location / _column != 0) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location - _column + 1;//右上
    if (location / _column && location % _column != _column - 1) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location + 1;//右
    if (location % _column != _column - 1) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location + _column + 1;//右下
    if (location % _column != _column - 1 && location / _column != _column - 1) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location + _column;//下
    if (location / _column != _column - 1) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location + _column - 1;//左下
    if (location / _column != _column - 1 && location % _column != 0) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location - 1;//左
    if (location % _column != 0) {
        [self addTurnover:aroundLocation];
    }
    
}
- (void)addTurnover:(NSInteger)location {
    if ([self.turnoverArray containsObject:self.mineMapArray[location]]) {//如果已经包含这个单元return
        return;
    }
    _cycleNums++;
    NSLog(@"turnover - %ld", (long)location);
    [self.turnoverArray addObject:@(location)];
    
    [self findAllTurnover:location];
}

- (IBAction)btnClick:(id)sender {
    self.mineMapArray = nil;
    self.minesArray = nil;
    [self setupMines];
    
    
    NSLog(@"%@",self.mineMapArray);
    [self setupMapView];
    
}

@end
