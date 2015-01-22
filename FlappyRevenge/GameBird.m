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
    
    
    [bird setScale:0.7];
    [bird runAction:flap];
    
    bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bird.size.height/2];
    bird.physicsBody.dynamic = YES;
    bird.physicsBody.allowsRotation = NO;
    bird.physicsBody.mass = 0.5;
    return bird;
}

- (void)fly
{
    self.physicsBody.velocity = CGVectorMake(0, 0);
    [self.physicsBody applyImpulse:CGVectorMake(0, 170)];
}

- (void)flyIddle
{
    // zero gravity =
    
    SKAction* wiggleUp =[SKAction sequence:@[[SKAction runBlock:^{ [self.physicsBody applyImpulse: CGVectorMake(0, 20)];}], [SKAction waitForDuration:0.8], [SKAction runBlock:^{ [self.physicsBody applyImpulse: CGVectorMake( 0, -15)];}],[SKAction waitForDuration:0.4], [SKAction runBlock:^{ [self.physicsBody applyImpulse: CGVectorMake( 0, -5)];}]]];
    SKAction* wiggleDown =[SKAction sequence:@[[SKAction runBlock:^{ [self.physicsBody applyImpulse: CGVectorMake(0, -20)];}], [SKAction waitForDuration:0.8], [SKAction runBlock:^{ [self.physicsBody applyImpulse: CGVectorMake( 0, 15)];}],[SKAction waitForDuration:0.4], [SKAction runBlock:^{ [self.physicsBody applyImpulse: CGVectorMake( 0, 5)];}]]];
    SKAction* wiggleForever = [SKAction repeatActionForever:[SKAction sequence:@[wiggleUp,wiggleDown]]];
    [self runAction:wiggleForever withKey:@"flyIddle"];
     
    
    // 1 gravity =
    
    /*
    self.physicsBody.velocity = CGVectorMake(0, 0);
    SKAction* wiggle = [SKAction sequence:@[[SKAction runBlock:^{ [self.physicsBody applyImpulse: CGVectorMake(0, 75)];}],[SKAction waitForDuration:1]]];
    SKAction* wiggleForever = [SKAction repeatActionForever:wiggle];
    [self runAction:wiggleForever withKey:@"stop"];
     */
    
}

@end
