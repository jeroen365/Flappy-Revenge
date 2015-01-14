//
//  GameBird.m
//  FlappyBirdXL
//
//  Created by Jeroen van der Es on 08-01-15.
//  Copyright (c) 2015 Jeroen van der Es. All rights reserved.
//

#import "GameBird.h"

@implementation GameBird

+ (id)bird
{
    // Load bird textures
    SKTexture *birdTexture1 = [SKTexture textureWithImageNamed:@"initBirdL1"];
    birdTexture1.filteringMode = SKTextureFilteringNearest;
    SKTexture *birdTexture2 = [SKTexture textureWithImageNamed:@"initBirdH1"];
    birdTexture2.filteringMode = SKTextureFilteringNearest;
    
    
    SKAction* flap = [SKAction repeatActionForever:[SKAction animateWithTextures:@[birdTexture1, birdTexture2] timePerFrame: 0.5]];
    GameBird *bird = [GameBird spriteNodeWithTexture:birdTexture1];
    
    
    [bird setScale:0.75];
    [bird runAction:flap];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    bird.position = CGPointMake((screenRect.size.width / 2.5), CGRectGetMidY(screenRect));
    
    bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bird.size.height/2];
    bird.physicsBody.dynamic = YES;
    bird.physicsBody.allowsRotation = NO;
    bird.physicsBody.mass = 0.5;
    return bird;
}

- (void)fly
{
    self.physicsBody.velocity = CGVectorMake(0, 0);
    [self.physicsBody applyImpulse:CGVectorMake(0, 150)];
}

@end
