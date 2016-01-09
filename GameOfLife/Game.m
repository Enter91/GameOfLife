//
//  Game.m
//  GameOfLife
//
//  Created by Michal Czwarnowski on 09.01.2016.
//  Copyright © 2016 Michal Czwarnowski. All rights reserved.
//

#import "Game.h"

@implementation Game

- (instancetype) init{
    return [self initWithRows:10 columns:10];
}

- (instancetype)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns {
    self = [super init];
    if (self) {
        self.rows = rows;
        self.columns = columns;
        self.cells = [[NSMutableArray alloc] initWithCapacity:rows*columns];
        for (NSUInteger i=0; i<rows*columns; i++) {
            [self.cells addObject:[[Cell alloc] init]];
        }
    }
    return self;
}

- (Cell *)cellAtRow:(NSUInteger)row column:(NSUInteger)column {
    return [self cellAtIndex:(row * self.columns) + column];
}

- (Cell *)cellAtIndex:(NSUInteger)index {
    return [self.cells objectAtIndex:index];
}

- (void)setCellState:(CellState)state atRow:(NSUInteger)row column:(NSUInteger)column {
    [[self cellAtRow:row column:column] setState:state];
}

- (void)setCellState:(CellState)state atIndex:(NSUInteger)index {
    [[self cellAtIndex:index] setState:state];
}

- (CellState)cellStateAtRow:(NSUInteger)row column:(NSUInteger)column {
    return [[self cellAtRow:row column:column] state];
}

- (CellState)cellStateAtIndex:(NSUInteger)index {
    return [[self cellAtIndex:index] state];
}

- (void)toggleCellStateAtRow:(NSUInteger)row column:(NSUInteger)column {
    [[self cellAtRow:row column:column] toggleValue];
}

- (void)toggleCellStateAtIndex:(NSUInteger)index {
    [[self cellAtIndex:index] toggleValue];
}

- (void)nextStep:(void (^)(BOOL shouldStop))callback {
    NSMutableArray *newCells = [[NSMutableArray alloc] initWithCapacity:[self.cells count]];
    
    for (NSUInteger row = 0; row < self.rows; row++) {
        for (NSUInteger column = 0; column < self.columns; column++) {
            Cell *cell = [self cellAtRow:row column:column];
            
            NSUInteger neighboursCount = [self neighboursAtRow:row column:column];
            if (cell.state == CellStateAlive) {
                if (neighboursCount == 2 || neighboursCount == 3) {
                    [newCells addObject:[[Cell alloc] initWithState:CellStateAlive]];
                } else {
                    [newCells addObject:[[Cell alloc] initWithState:CellStateKilled]];
                }
            } else if (cell.state == CellStateKilled) {
                if (neighboursCount == 3) {
                    [newCells addObject:[[Cell alloc] initWithState:CellStateAlive]];
                } else {
                    [newCells addObject:[[Cell alloc] initWithState:CellStateKilled]];
                }
            }
        }
    }
    
    BOOL hasTheSameCells = YES;
    BOOL hasCellsAlive = NO;
    
    for (NSUInteger i=0; i<[newCells count]; i++) {
        Cell *oldCell = [self cellAtIndex:i];
        Cell *newCell = [newCells objectAtIndex:i];
        
        if (oldCell.state != newCell.state) {
            hasTheSameCells = NO;
        }
        
        if (newCell.state == CellStateAlive) {
            hasCellsAlive = YES;
        }
    }
    
    if (hasTheSameCells || !hasCellsAlive) {
        if (callback) {
            callback(YES);
        }
    }
    
    
    self.cells = newCells;
    
    if (callback) {
        callback(NO);
    }
}

- (BOOL)hasCellsAlive {
    BOOL hasCellsAlive = NO;
    for (NSUInteger i=0; i<[self.cells count]; i++) {
        Cell *cell = [self cellAtIndex:i];
        if (cell.state == CellStateAlive) {
            hasCellsAlive = YES;
        }
    }
    
    return hasCellsAlive;
}

- (void)clearGame {
    for (NSUInteger i=0; i<self.rows*self.columns; i++) {
        [[self.cells objectAtIndex:i] setState:CellStateKilled];
    }
}

- (NSUInteger)neighboursForIndexes:(NSArray *)indexes {
    NSUInteger totalNeighbours = 0;
    for (NSArray *ind in indexes) {
        if ([self cellStateAtRow:[(NSNumber *)ind[0] integerValue] column:[(NSNumber *)ind[1] integerValue]] == CellStateAlive) {
            totalNeighbours++;
        }
    }
    return totalNeighbours;
}

- (NSUInteger)neighboursAtRow:(NSUInteger)row column:(NSUInteger)column {
    
    if (column == 0) {
        //pierwsza kolumna
        
        if (row == 0) {
            return [self neighboursForIndexes:@[@[@(self.rows-1),@(self.columns-1)], @[@(self.rows-1),@(column)], @[@(self.rows-1),@(column+1)],
                                                @[@(row),@(self.columns-1)], @[@(row),@(column+1)],
                                                @[@(row+1),@(self.columns-1)], @[@(row+1),@(column)], @[@(row+1),@(column+1)]]];
        } else if (row == self.rows-1) {
            return [self neighboursForIndexes:@[@[@(row-1),@(self.columns-1)], @[@(row-1),@(column)], @[@(row-1),@(column+1)],
                                                @[@(row),@(self.columns-1)], @[@(row),@(column+1)],
                                                @[@(0),@(self.columns-1)], @[@(0),@(column)], @[@(0),@(column+1)]]];
        } else {
            return [self neighboursForIndexes:@[@[@(row-1),@(self.columns-1)], @[@(row-1),@(column)], @[@(row-1),@(column+1)],
                                                @[@(row),@(self.columns-1)], @[@(row),@(column+1)],
                                                @[@(row+1),@(self.columns-1)], @[@(row+1),@(column)], @[@(row+1),@(column+1)]]];
        }
        
    } else if (column == self.columns - 1) {
        // ostatnia kolumna
        
        if (row == 0) {
            return [self neighboursForIndexes:@[@[@(self.rows-1),@(column-1)], @[@(self.rows-1),@(column)], @[@(self.rows-1),@(0)],
                                                @[@(row),@(column-1)], @[@(row),@(0)],
                                                @[@(row+1),@(column-1)], @[@(row+1),@(column)], @[@(row+1),@(0)]]];
        } else if (row == self.rows-1) {
            return [self neighboursForIndexes:@[@[@(row-1),@(column-1)], @[@(row-1),@(column)], @[@(row-1),@(0)],
                                                @[@(row),@(column-1)], @[@(row),@(0)],
                                                @[@(0),@(column-1)], @[@(0),@(column)], @[@(0),@(0)]]];
        } else {
            return [self neighboursForIndexes:@[@[@(row-1),@(column-1)], @[@(row-1),@(column)], @[@(row-1),@(0)],
                                                @[@(row),@(column-1)], @[@(row),@(0)],
                                                @[@(row+1),@(column-1)], @[@(row+1),@(column)], @[@(row+1),@(0)]]];
        }
        
    } else {
        
        if (row == 0) {
            return [self neighboursForIndexes:@[@[@(self.rows-1),@(column-1)], @[@(self.rows-1),@(column)], @[@(self.rows-1),@(column+1)],
                                                @[@(row),@(column-1)], @[@(row),@(column+1)],
                                                @[@(row+1),@(column-1)], @[@(row+1),@(column)], @[@(row+1),@(column+1)],]];
        } else if (row == self.rows-1) {
            return [self neighboursForIndexes:@[@[@(row-1),@(column-1)], @[@(row-1),@(column)], @[@(row-1),@(column+1)],
                                                @[@(row),@(column-1)], @[@(row),@(column+1)],
                                                @[@(0),@(column-1)], @[@(0),@(column)], @[@(0),@(column+1)],]];
        } else {
            return [self neighboursForIndexes:@[@[@(row-1),@(column-1)], @[@(row-1),@(column)], @[@(row-1),@(column+1)],
                                                @[@(row),@(column-1)], @[@(row),@(column+1)],
                                                @[@(row+1),@(column-1)], @[@(row+1),@(column)], @[@(row+1),@(column+1)],]];
        }
        
    }
}

@end
