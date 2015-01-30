//
//  GameExplosion.m
//  FlappyRevenge
//
//  This file loads all the textures needed for an explosion animation
//  and sends it to GameScene.
//
//  Created by Jeroen van der Es on 30-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import "GameExplosion.h"

@implementation GameExplosion

+(id) loadExplosion{
    
    SKTexture* explosionTexture1 = [SKTexture textureWithImageNamed:@"Explosion1"];
    SKTexture* explosionTexture2 = [SKTexture textureWithImageNamed:@"Explosion2"];
    SKTexture* explosionTexture3 = [SKTexture textureWithImageNamed:@"Explosion3"];
    SKTexture* explosionTexture4 = [SKTexture textureWithImageNamed:@"Explosion4"];
    SKTexture* explosionTexture5 = [SKTexture textureWithImageNamed:@"Explosion5"];
    SKTexture* explosionTexture6 = [SKTexture textureWithImageNamed:@"Explosion6"];
    SKTexture* explosionTexture7 = [SKTexture textureWithImageNamed:@"Explosion7"];
    SKTexture* explosionTexture8 = [SKTexture textureWithImageNamed:@"Explosion8"];
    SKTexture* explosionTexture9 = [SKTexture textureWithImageNamed:@"Explosion9"];
    
    GameExplosion* explosion = [GameExplosion spriteNodeWithTexture:explosionTexture1];

    
    SKAction* explode = [SKAction animateWithTextures:@[explosionTexture1,explosionTexture2,explosionTexture3,explosionTexture4,explosionTexture5,explosionTexture6,explosionTexture7,explosionTexture8,explosionTexture9] timePerFrame:0.1];
    

    SKAction*  remove = [SKAction sequence:@[ [SKAction waitForDuration:1], [SKAction runBlock:^{[explosion removeFromParent];}]]];
    [explosion runAction:explode];
    [explosion runAction:remove];
    
    return explosion;
}

@end
