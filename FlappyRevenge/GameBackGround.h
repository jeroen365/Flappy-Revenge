//
//  GameBackGround.h
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 18-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameBackGround : SKNode

+(SKSpriteNode*) addPipeDown;
+(SKSpriteNode*) addPipeTop;

+(SKTexture*) loadGround;
+(SKTexture*) loadSkyline;

@end
