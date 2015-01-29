//
//  GameMenuItems.h
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 29-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameMenuItems : SKSpriteNode

+ (id) showGameMenu;
+(id) showRetryMenu;
+(id) showShopMenu;
+(id) showFireButton;
+(SKLabelNode*) scoreLabel:(NSInteger)score;
+(SKLabelNode*) showScoreLabelText;
+(SKLabelNode*) highScoreLabel:(NSInteger)highScore;
+(SKLabelNode*) highScoreLabelText;

@end
