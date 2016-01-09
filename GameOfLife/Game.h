//
//  Game.h
//  GameOfLife
//
//  Created by Michal Czwarnowski on 09.01.2016.
//  Copyright © 2016 Michal Czwarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cell.h"

@interface Game : NSObject

@property (assign, nonatomic) NSUInteger rows;
@property (assign, nonatomic) NSUInteger columns;
@property (strong, nonatomic) NSMutableArray *cells;
@property (assign, nonatomic) BOOL isRunning;

- (instancetype)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns;

- (Cell *)cellAtRow:(NSUInteger)row column:(NSUInteger)column;
- (Cell *)cellAtIndex:(NSUInteger)index;

- (void)setCellState:(CellState)state atRow:(NSUInteger)row column:(NSUInteger)column;
- (void)setCellState:(CellState)state atIndex:(NSUInteger)index;

- (void)toggleCellStateAtRow:(NSUInteger)row column:(NSUInteger)column;
- (void)toggleCellStateAtIndex:(NSUInteger)index;

- (CellState)cellStateAtRow:(NSUInteger)row column:(NSUInteger)column;
- (CellState)cellStateAtIndex:(NSUInteger)index;

- (void)nextStep:(void (^)(BOOL shouldStop))callback;
- (void)clearGame;

@end
