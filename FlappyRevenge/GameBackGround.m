//
//  GameBackGround.m
//  FlappyRevenge
//
//  This file loads several background textures and passes them to GameScene.
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
    // Load textures
    SKTexture* pipeTextureDown = [SKTexture textureWithImageNamed:@"Pipe1"];
    pipeTextureDown.filteringMode = SKTextureFilteringNearest;

    // Set physicsbody
    SKSpriteNode* pipeDown = [SKSpriteNode spriteNodeWithTexture:pipeTextureDown];
    [pipeDown setScale:2];
    pipeDown.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipeDown.size];
    pipeDown.name = @"pipe";
    pipeDown.physicsBody.dynamic = NO;
 
    return pipeDown;
}

+(SKSpriteNode*) addPipeTop{
    // Load textures
    SKTexture* pipeTextureTop = [SKTexture textureWithImageNamed:@"Pipe2"];
    pipeTextureTop.filteringMode = SKTextureFilteringNearest;
    
    // Set physicsbody
    SKSpriteNode* pipeTop = [SKSpriteNode spriteNodeWithTexture:pipeTextureTop];
    [pipeTop setScale:2];
    pipeTop.name = @"pipe";
    pipeTop.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipeTop.size];
    pipeTop.physicsBody.dynamic = NO;
    
    return pipeTop;
}

+(SKTexture*) loadGround{
    // Load textures
    SKTexture* groundTexture = [SKTexture textureWithImageNamed:
                     @"Ground"];
    groundTexture.filteringMode = SKTextureFilteringNearest;
    return groundTexture;
}

+(SKTexture*) loadSkyline{
    // Load textures
    SKTexture* skylineTexture = [SKTexture textureWithImageNamed:@"Skyline"];
    skylineTexture.filteringMode = SKTextureFilteringNearest;
    return skylineTexture;
}


@end
