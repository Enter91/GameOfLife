//
//  ViewController.m
//  GameOfLife
//
//  Created by Michal Czwarnowski on 09.01.2016.
//  Copyright © 2016 Michal Czwarnowski. All rights reserved.
//

#import "ViewController.h"
#import "Game.h"
#import <Quartz/Quartz.h>

@interface ViewController ()

@property (weak) IBOutlet NSView *gameView;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSButton *nextStepButton;
@property (weak) IBOutlet NSButton *autoGameButton;
@property (weak) IBOutlet NSTextField *rowsTextField;
@property (weak) IBOutlet NSTextField *columnsTextField;
@property (weak) IBOutlet NSButton *saveBoardSizeButton;
@property (weak) IBOutlet NSButton *loadPointsButton;

@property (strong, nonatomic) Game *game;
@property (strong, nonatomic) NSMutableArray *cellViews;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.startButton setTitle:@"Start gry"];
    [self.autoGameButton.cell setState:NSOffState];
    [self.nextStepButton setEnabled:NO];
    
    [self.gameView setWantsLayer:YES];
    
    [self createBoard];
}

- (void)createBoard {
    if (!self.game) {
        NSString *rowsString = [self.rowsTextField stringValue];
        NSString *colsString = [self.columnsTextField stringValue];
        if (rowsString.length > 0 && colsString.length > 0 && rowsString.integerValue > 0 && colsString.integerValue > 0) {
            self.game = [[Game alloc] initWithRows:rowsString.integerValue columns:colsString.integerValue];
        } else {
            self.game = [[Game alloc] init];
        }
    }
    
    [[self.gameView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.cellViews = nil;
    
    if (!self.cellViews) {
        self.cellViews = [[NSMutableArray alloc] initWithCapacity:self.game.rows * self.game.columns];
    }
    
    float heightMultiplier = 1.0/self.game.rows;
    float widthMultiplier = 1.0/self.game.columns;
    
    for (NSUInteger row = 0; row < self.game.rows; row++) {
        for (NSUInteger col = 0; col < self.game.columns; col++) {
            NSView *cellView = [[NSView alloc] initWithFrame:NSZeroRect];
            [cellView setWantsLayer:YES];
            [cellView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [cellView.layer setBorderColor:[[NSColor blackColor] CGColor]];
            [cellView.layer setBorderWidth:1.0];
            [cellView.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
            NSClickGestureRecognizer *tapGesture = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(cellTouched:)];
            [cellView addGestureRecognizer:tapGesture];
            [self.gameView addSubview:cellView];
            [self.cellViews addObject:cellView];
            
            NSUInteger index = (row * self.game.columns) + col;
            
            if (col == 0) {
                [self.gameView addConstraint:[NSLayoutConstraint constraintWithItem:self.cellViews[index] attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.gameView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
            } else {
                [self.gameView addConstraint:[NSLayoutConstraint constraintWithItem:self.cellViews[index] attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.cellViews[index-1] attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
            }
            
            if (row == 0) {
                [self.gameView addConstraint:[NSLayoutConstraint constraintWithItem:self.cellViews[index] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.gameView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            } else if (row == self.game.rows - 1) {
                [self.gameView addConstraint:[NSLayoutConstraint constraintWithItem:self.cellViews[index] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.gameView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            } else {
                [self.gameView addConstraint:[NSLayoutConstraint constraintWithItem:self.cellViews[index] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cellViews[index-self.game.columns] attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            }
            
            [self.gameView addConstraint:[NSLayoutConstraint constraintWithItem:cellView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.gameView attribute:NSLayoutAttributeWidth multiplier:widthMultiplier constant:0]];
            [self.gameView addConstraint:[NSLayoutConstraint constraintWithItem:cellView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.gameView attribute:NSLayoutAttributeHeight multiplier:heightMultiplier constant:0]];
        }
    }
    
}

- (void)cellTouched:(id)sender {
    if (!self.game.isRunning) {
        NSUInteger cellIndex = [self.cellViews indexOfObject:[sender view]];
        [self.game toggleCellStateAtIndex:cellIndex];
        [self updateCellColorAtIndex:cellIndex];
    }
}

- (IBAction)startGame:(id)sender {
    
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(doNextStep:) object:nil];
    
    if (!self.game.isRunning) {
        [self.startButton setTitle:@"Koniec gry"];
        if ([[self.autoGameButton cell] state] == NSOnState) {
            [self.nextStepButton setEnabled:NO];
        } else {
            [self.nextStepButton setEnabled:YES];
        }
    } else {
        [self.startButton setTitle:@"Start gry"];
        [self.nextStepButton setEnabled:NO];
    }
    
    [self.game setIsRunning:!self.game.isRunning];
    
    [self.rowsTextField setEnabled:!self.game.isRunning];
    [self.columnsTextField setEnabled:!self.game.isRunning];
    [self.saveBoardSizeButton setEnabled:!self.game.isRunning];
    [self.autoGameButton setEnabled:!self.game.isRunning];
    [self.loadPointsButton setEnabled:!self.game.isRunning];
    
    if (self.game.isRunning) {
        if ([[self.autoGameButton cell] state] == NSOnState) {
            [self doNextStep:nil];
        }
    }
}

- (IBAction)saveBoardSize:(id)sender {
    self.game = nil;
    [self createBoard];
    
    [self.game setIsRunning:NO];
}

- (void)updateCellColorAtIndex:(NSUInteger)cellIndex {
    if ([[self.game cellAtIndex:cellIndex] state] == CellStateAlive) {
        [[self.cellViews[cellIndex] layer] setBackgroundColor:[[NSColor greenColor] CGColor]];
    } else if ([[self.game cellAtIndex:cellIndex] state] == CellStateKilled) {
        [[self.cellViews[cellIndex] layer] setBackgroundColor:[[NSColor whiteColor] CGColor]];
    }
}

- (void)updateBoard {
    for (NSUInteger row=0; row<self.game.rows; row++) {
        for (NSUInteger col=0; col<self.game.columns; col++) {
            [self updateCellColorAtIndex:(row * self.game.columns + col)];
        }
    }
}

- (IBAction)doNextStep:(id)sender {
    
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(doNextStep:) object:nil];
    
    [self.game nextStep:^(BOOL shouldStop) {
        [self updateBoard];
        if (shouldStop) {
            [self startGame:nil];
        }
        
        if ([[self.autoGameButton cell] state] == NSOnState && self.game.isRunning) {
            [self performSelector:@selector(doNextStep:) withObject:nil afterDelay:0.2];
        }
    }];
    
    
}

- (IBAction)loadRandomPoints:(id)sender {
    
    [self.game clearGame];
    
    NSUInteger numberOfPoints = arc4random_uniform((uint32_t)(self.game.rows * self.game.columns) - 1) + 1;
    
    if (numberOfPoints >= self.game.rows * self.game.columns) {
        numberOfPoints = self.game.rows * self.game.columns;
    }
    
    for (NSUInteger i=0; i<numberOfPoints; i++) {
        NSUInteger randomIndex = arc4random_uniform((uint32_t)(self.game.rows * self.game.columns));
        
        if ([self.game cellStateAtIndex:randomIndex] == CellStateAlive) {
            i--;
        } else {
            [self.game setCellState:CellStateAlive atIndex:randomIndex];
        }
    }
    
    [self updateBoard];
}


@end
