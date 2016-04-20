//
//  ViewController.m
//  MinesweeperGame
//
//  Created by PC-LiuChunhui on 16/4/15.
//  Copyright © 2016年 Mr.Wendao. All rights reserved.
//

#import "ViewController.h"
#define kBorderX 5
#define kBorderY 80
#define kGap 2
#define kTag 100
@interface ViewController () {
    NSInteger _mineNums;//地雷的个数
    NSInteger _leftMarkMineNums;//剩余标记地雷的个数
    NSInteger _rightMarkMineNums;//标记正确的地雷个数
    NSInteger _row;//行数
    NSInteger _column;//列数
    NSInteger _longPressStation;
    NSInteger _seconds;
}
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIView *bgView;//
@property (weak, nonatomic) IBOutlet UILabel *timeLb;
@property (weak, nonatomic) IBOutlet UILabel *leftMarkMineLb;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *restartBtn;

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
    _mineNums = 2;
    _leftMarkMineNums = _mineNums;
    _rightMarkMineNums = 0;
    _row = 10;
    _column = 10;
    [self restartBtnClick:nil];
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
        button.tag = kTag + i;
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
    if ([button.currentBackgroundImage isEqual:[UIImage imageNamed:@"flag_blue_bg"]]) {
        self.leftMarkMineLb.text = [NSString stringWithFormat:@"%ld", (++_leftMarkMineNums)];
    }
    button.selected = YES;
    button.userInteractionEnabled = NO;
    NSInteger mineNum = [self.mineMapArray[button.tag - kTag] integerValue];
    
    
    if (mineNum == 9) {//地雷，游戏结束
        [self.timer invalidate];//计时结束
        //翻转所有单元
        for (UIButton *button  in self.bgView.subviews) {
            button.selected = YES;
            button.userInteractionEnabled = NO;
        }
        _leftMarkMineNums = _mineNums;
        self.leftMarkMineLb.text = [NSString stringWithFormat:@"%ld", (long)_leftMarkMineNums];
        //弹窗游戏结束
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"游戏结束" message:@"你咋恁不小心呢!!" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"再来一局" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self restartBtnClick:nil];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:sure];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
        
        
        return;
    }
    if (mineNum > 0 && mineNum < 9) {//数字单元
        
        NSLog(@"数字单元，翻过来");
        return;
    }
    
    //找到空白单元周围所有可翻转的单元
    [self.turnoverArray removeAllObjects];
    [self findAllTurnover:button.tag - kTag];
    
    //翻转所有可翻转单元
    for (NSNumber *obj in self.turnoverArray) {
        
        UIButton *button = (UIButton *)[self.bgView viewWithTag:[obj integerValue] + kTag];
        if ([button.currentBackgroundImage isEqual:[UIImage imageNamed:@"flag_blue_bg"]]) {
            self.leftMarkMineLb.text = [NSString stringWithFormat:@"%ld", (++_leftMarkMineNums)];
        }
        button.selected = YES;
        button.userInteractionEnabled = NO;
    }
}
/**
 *  长按标记地雷
 */
- (void)markMine:(UILongPressGestureRecognizer *)longPress {
    
    UIButton *button = (UIButton *)longPress.view;
    if(longPress.state == UIGestureRecognizerStateBegan) {
        //当前单元为没有标记
        if ([button.currentBackgroundImage isEqual:[UIImage imageNamed:@"selected_bg"]]) {
            if (_leftMarkMineNums > 0) {//剩余旗帜>0,才能标记旗帜
                [button setBackgroundImage:[UIImage imageNamed:@"flag_blue_bg"] forState:UIControlStateNormal];
                self.leftMarkMineLb.text = [NSString stringWithFormat:@"%ld", (--_leftMarkMineNums)];
                
                if ([self.mineMapArray[button.tag - kTag] isEqualToNumber:@(9)]) {//如果标记的位置是地雷则标对+1
                    _rightMarkMineNums++;
                }
                if (_rightMarkMineNums == _mineNums) {//判断地雷是否已经标记完全，扫雷成功
                    [self.timer invalidate];//结束计时
                    //翻转所有空白单元 和 数字单元
                    for (UIButton *button  in self.bgView.subviews) {
                        if (![self.mineMapArray[button.tag - kTag] isEqualToNumber:@(9)]) {
                            button.selected = YES;
                            button.userInteractionEnabled = NO;
                        }
                    }
                    //弹窗 - 游戏赢了
                    NSString *message = [NSString stringWithFormat:@"你咋恁厉害!!\n用时%02ld:%02ld", _seconds / 60, _seconds % 60];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"你赢了" message:message preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"再来一局" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self restartBtnClick:nil];
                    }];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alert addAction:sure];
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            } else {
                [button setBackgroundImage:[UIImage imageNamed:@"question_mark"] forState:UIControlStateNormal];
            }
            return;
        }
        //当前单元标记为地雷
        if ([button.currentBackgroundImage isEqual:[UIImage imageNamed:@"flag_blue_bg"]]) {
            self.leftMarkMineLb.text = [NSString stringWithFormat:@"%ld", (++_leftMarkMineNums)];
            [button setBackgroundImage:[UIImage imageNamed:@"question_mark"] forState:UIControlStateNormal];
            if ([self.mineMapArray[button.tag - kTag] isEqualToNumber:@(9)]) {
                _rightMarkMineNums--;
            }
            return;
        }
        //当前单元标记为问号
        if ([button.currentBackgroundImage isEqual:[UIImage imageNamed:@"question_mark"]]) {
            [button setBackgroundImage:[UIImage imageNamed:@"selected_bg"] forState:UIControlStateNormal];
            return;
        }
    }
}
- (void)findAllTurnover:(NSInteger)location {
    
    if ([self.mineMapArray[location] integerValue] != 0) {//如果当前单元不是空白单元则，回到上一层继续寻找下一个位置
        if (![self.turnoverArray containsObject:@(location)]) {
            [self.turnoverArray addObject:@(location)];
        }
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
    
    if ([self.turnoverArray containsObject:@(location)]) {//如果已经包含这个单元return
        return;
    }
    [self.turnoverArray addObject:@(location)];
    [self findAllTurnover:location];
}

- (IBAction)restartBtnClick:(id)sender {
    [self.timer invalidate];//结束计时
    _restartBtn.enabled = NO;
    _startBtn.enabled = YES;
    
    
    _leftMarkMineNums = _mineNums;
    _rightMarkMineNums = 0;
    
    self.bgView.userInteractionEnabled = NO;
    self.mineMapArray = nil;
    self.minesArray = nil;
    self.turnoverArray = nil;
    self.leftMarkMineLb.text = [NSString stringWithFormat:@"%ld", (long)_leftMarkMineNums];
    self.timeLb.text = @"00:00";
    [self setupMines];
    [self.bgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self setupMapView];
    
}
- (IBAction)startBtnClick:(UIButton *)button {
    _seconds = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(clockTimer) userInfo:nil repeats:YES];
    self.bgView.userInteractionEnabled = YES;
    _startBtn.enabled = NO;
    _restartBtn.enabled = YES;
    
}
- (void)clockTimer {
    _seconds++;
    self.timeLb.text = [NSString stringWithFormat:@"%02ld:%02ld", _seconds / 60, _seconds % 60];
}
- (void)dealloc {
    
    [self.timer invalidate];
}
@end
