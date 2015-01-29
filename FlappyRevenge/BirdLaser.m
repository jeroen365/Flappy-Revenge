//
//  BirdLaser.m
//  FlappyRevenge
//
//  File loads a Laserbeam node and sets it phyiscal properties.
//
//  Created by Jeroen van der Es on 29-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import "BirdLaser.h"

@implementation BirdLaser

+(SKSpriteNode*)loadLaser{
    SKTexture* birdLaserTexture =[SKTexture textureWithImageNamed:@"Laserbeam"];
    birdLaserTexture.filteringMode = SKTextureFilteringNearest;
    
    SKSpriteNode* birdLaser = [SKSpriteNode spriteNodeWithTexture:birdLaserTexture];
    
    birdLaser.name = @"laser";
    birdLaser.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:birdLaser.size];
    birdLaser.physicsBody.dynamic = YES;
    birdLaser.physicsBody.allowsRotation = NO;
    birdLaser.physicsBody.affectedByGravity = NO;
    birdLaser.physicsBody.mass = 0.1;
    birdLaser.physicsBody.linearDamping = 0.0;
    
    return birdLaser;
}

@end
