//
//  GameMenu.h
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 18-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameMenu : SKSpriteNode

+ (id) showGameMenu;
+(id) showRetryMenu;
+(id) showShopMenu;
+(id) showFireButton;
- (SKLabelNode*) scoreLabel:(NSInteger)score;

@end
