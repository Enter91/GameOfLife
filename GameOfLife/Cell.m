//
//  Cell.m
//  GameOfLife
//
//  Created by Michal Czwarnowski on 09.01.2016.
//  Copyright © 2016 Michal Czwarnowski. All rights reserved.
//

#import "Cell.h"

@implementation Cell

- (instancetype)init {
    return [self initWithState:CellStateKilled];
}

- (instancetype)initWithState:(CellState)state {
    self = [super init];
    if (self) {
        self.state = state;
    }
    return self;
}

- (void)toggleValue {
    switch (self.state) {
        case CellStateKilled: {
            self.state = CellStateAlive;
            break;
        }
        case CellStateAlive: {
            self.state = CellStateKilled;
            break;
        }
    }
}

@end
