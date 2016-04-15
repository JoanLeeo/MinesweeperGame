//
//  MineCellModel.h
//  MinesweeperGame
//
//  Created by PC-LiuChunhui on 16/4/15.
//  Copyright © 2016年 Mr.Wendao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MineCellModel : NSObject
@property (nonatomic, strong) NSNumber *aroundMines;//周围地雷数量，0-8（周围地雷数量），9，地雷
@property (nonatomic, strong) NSString *station;//状态
@property (nonatomic) NSInteger tag;
@end
