//
//  GameBackGround.m
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 18-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import "GameBackGround.h"

@interface GameBackGround(){
    SKTexture* groundTexture;
}

@end

@implementation GameBackGround


+ (SKSpriteNode*) addPipeDown{
    SKTexture* pipeTextureDown = [SKTexture textureWithImageNamed:@"Pipe1"];
    pipeTextureDown.filteringMode = SKTextureFilteringNearest;

    SKSpriteNode* pipeDown = [SKSpriteNode spriteNodeWithTexture:pipeTextureDown];
    [pipeDown setScale:2];
    pipeDown.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipeDown.size];
    pipeDown.name = @"pipe";
    pipeDown.physicsBody.dynamic = NO;
 
    return pipeDown;
}

+(SKSpriteNode*) addPipeTop{
    SKTexture* pipeTextureTop = [SKTexture textureWithImageNamed:@"Pipe2"];
    pipeTextureTop.filteringMode = SKTextureFilteringNearest;
    
    SKSpriteNode* pipeTop = [SKSpriteNode spriteNodeWithTexture:pipeTextureTop];
    [pipeTop setScale:2];
    pipeTop.name = @"pipe";
    pipeTop.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipeTop.size];
    pipeTop.physicsBody.dynamic = NO;
    
    return pipeTop;
}

+(SKTexture*) loadGround{
    SKTexture* groundTexture = [SKTexture textureWithImageNamed:
                     @"Ground"];
    groundTexture.filteringMode = SKTextureFilteringNearest;
    return groundTexture;
}

+(SKTexture*) loadSkyline{
    SKTexture* skylineTexture = [SKTexture textureWithImageNamed:@"Skyline"];
    skylineTexture.filteringMode = SKTextureFilteringNearest;
    return skylineTexture;
}


@end
