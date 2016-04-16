//
//  ViewController.m
//  MinesweeperGame
//
//  Created by PC-LiuChunhui on 16/4/15.
//  Copyright © 2016年 Mr.Wendao. All rights reserved.
//

#import "ViewController.h"
#define BorderX 5
#define BorderY 5
@interface ViewController () {
    NSInteger _mineNums;//地雷的个数
    NSInteger _row;//行数
    NSInteger _column;//列数
}
@property (nonatomic, strong) NSMutableArray *mineMapArray;//地雷地图数组
@property (nonatomic, strong) NSMutableArray *minesArray;//所有地雷位置
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
- (NSMutableArray *)minesArray {
    if (!_minesArray) {
        _minesArray = [NSMutableArray array];
    }
    return _minesArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _mineNums = 10;
    _row = 10;
    _column = 10;
    // Do any additional setup after loading the view, typically from a nib.
}
/**
 *  初始化地雷
 */
- (void)setupMines {
    //1.创建临时地图位置数组，用于随机出地雷位置
    NSMutableArray *tmpArray = [NSMutableArray array];//临时地图位置数组
    for (int i = 0; i < _row * _column; i++) {
        [tmpArray addObject:@(i)];
    }
    //2.更新地图地雷位置和记录地雷位置
    int delIndex;//随机数组删除的位置
    int addIndex;//地雷地图添加的位置
    for (int i = 0; i < _mineNums; i++) {
        delIndex = arc4random() % tmpArray.count;
        addIndex = [tmpArray[delIndex] intValue];
        
        [self.mineMapArray replaceObjectAtIndex:addIndex withObject:@(9)];//更地图上地雷位置
        [self.minesArray addObject:tmpArray[delIndex]];//添加地雷位置到存储所有地雷位置的数组
        [tmpArray removeObjectAtIndex:delIndex];//删除临时随机的地雷位置
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
    for (int index = 0; index < _row * _column; index++) {
        UILabel *label = [[UILabel alloc] init];
        //设置frame
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGFloat buttonW = (screenBounds.size.width - BorderX * 2) / _column;
        CGFloat buttonH = buttonW;
        CGFloat buttonX = (index % _column) * buttonW + BorderX;
        CGFloat buttonY = (index / _column) * buttonW + BorderY;
        label.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        label.backgroundColor = [UIColor grayColor];
        label.text = [NSString stringWithFormat:@"%@", self.mineMapArray[index]];
        [self.view addSubview:label];
    }
}


- (IBAction)btnClick:(id)sender {
    self.mineMapArray = nil;
    self.minesArray = nil;
    [self setupMines];
    [self setupMapView];
    
}

@end
