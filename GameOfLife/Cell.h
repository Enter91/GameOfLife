//
//  Cell.h
//  GameOfLife
//
//  Created by Michal Czwarnowski on 09.01.2016.
//  Copyright © 2016 Michal Czwarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CellState) {
    CellStateKilled,
    CellStateAlive
};

@interface Cell : NSObject

@property (assign, nonatomic) CellState state;

- (instancetype)initWithState:(CellState)state;
- (void)toggleValue;

@end
