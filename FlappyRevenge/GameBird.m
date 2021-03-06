//
//  GameBird.m
//  FlappyBirdXL
//
//  This file loads the game bird and sets it physical properties.
//  Includes two actions the bird can run.
//
//  Created by Jeroen van der Es on 08-01-15.
//  Copyright (c) 2015 Jeroen van der Es. All rights reserved.
//

#import "GameBird.h"


@implementation GameBird


+ (id)bird
{
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    NSInteger flappySkin = [Inventory integerForKey:@"flappySkin"];
    
    SKTexture *birdTexture1;
    SKTexture *birdTexture2;
    
    if (flappySkin == 1){
        // Load mechaFlappy textures
        birdTexture1 = [SKTexture textureWithImageNamed:@"MechaFlappyL"];
        birdTexture1.filteringMode = SKTextureFilteringNearest;
        birdTexture2 = [SKTexture textureWithImageNamed:@"MechaFlappyH"];
        birdTexture2.filteringMode = SKTextureFilteringNearest;
    }
    else{
        // Load normal textures
        birdTexture1 = [SKTexture textureWithImageNamed:@"InitFlappyL"];
        birdTexture1.filteringMode = SKTextureFilteringNearest;
        birdTexture2 = [SKTexture textureWithImageNamed:@"InitFlappyH"];
        birdTexture2.filteringMode = SKTextureFilteringNearest;

    }
    
    // Create flapping animation
    SKAction* flap = [SKAction repeatActionForever:[SKAction animateWithTextures:@[birdTexture1, birdTexture2] timePerFrame: 0.5]];
    GameBird *bird = [GameBird spriteNodeWithTexture:birdTexture1];
    
    

    // Create physicsbody
    bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bird.size.height/2];
    bird.physicsBody.dynamic = YES;
    bird.physicsBody.allowsRotation = NO;
    bird.physicsBody.mass = 0.5;
    [bird setScale:0.7];
    [bird runAction:flap];
    return bird;
}

- (void)fly
{
    // Apply impuls to fly
    self.physicsBody.velocity = CGVectorMake(0, 0);
    [self.physicsBody applyImpulse:CGVectorMake(0, 180)];
}


- (void)flyIddle
{
    // zero gravity fly up and down forever
    SKAction* wiggleUp =[SKAction sequence:@[[SKAction runBlock:^{ [self.physicsBody applyImpulse: CGVectorMake(0, 20)];}], [SKAction waitForDuration:0.8], [SKAction runBlock:^{ [self.physicsBody applyImpulse: CGVectorMake( 0, -15)];}],[SKAction waitForDuration:0.4], [SKAction runBlock:^{ [self.physicsBody applyImpulse: CGVectorMake( 0, -5)];}]]];
    SKAction* wiggleDown =[SKAction sequence:@[[SKAction runBlock:^{ [self.physicsBody applyImpulse: CGVectorMake(0, -20)];}], [SKAction waitForDuration:0.8], [SKAction runBlock:^{ [self.physicsBody applyImpulse: CGVectorMake( 0, 15)];}],[SKAction waitForDuration:0.4], [SKAction runBlock:^{ [self.physicsBody applyImpulse: CGVectorMake( 0, 5)];}]]];
    SKAction* wiggleForever = [SKAction repeatActionForever:[SKAction sequence:@[wiggleUp,wiggleDown]]];
    [self runAction:wiggleForever withKey:@"flyIddle"];
}

@end
