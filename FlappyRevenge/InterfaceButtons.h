//
//  InterfaceButtons.h
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 29-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface InterfaceButtons : SKSpriteNode

+ (id) showPlayGameButton;
+(id) showFireButton:(NSInteger) numLasers;

@end
