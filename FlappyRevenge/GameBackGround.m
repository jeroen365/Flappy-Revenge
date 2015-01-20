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

//+ (id) skyLine{
   /*
    
    // Load skyline
    SKTexture* skylineTexture = [SKTexture textureWithImageNamed:@"Skyline"];
    skylineTexture.filteringMode = SKTextureFilteringNearest;
    
    SKAction* moveSkylineSprite = [SKAction moveByX:-skylineTexture.size.width*2 y:0 duration:0.1 * skylineTexture.size.width*2];
    SKAction* resetSkylineSprite = [SKAction moveByX:skylineTexture.size.width*2 y:0 duration:0];
    SKAction* moveSkylineSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSkylineSprite, resetSkylineSprite]]];
    
    
    for( int i = 0; i < 2 + self.frame.size.width / ( skylineTexture.size.width ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:skylineTexture];
        sprite.zPosition = -20;
        sprite.position = CGPointMake(i * sprite.size.width, groundTexture.size.height / 2);
        
        [sprite runAction: moveSkylineSpritesForever];
        sprite.name = @"world";
        [moving addChild:sprite];
    }
    */


/*+ (id) addGround{
    // Load ground
    SKTexture* groundTexture = [SKTexture textureWithImageNamed:
                     @"Ground"];
    groundTexture.filteringMode = SKTextureFilteringNearest;
    
    SKAction* moveGroundSprite = [SKAction moveByX:-groundTexture.size.width * 2 y:0 duration:0.01 * groundTexture.size.width*2];
    SKAction* resetGroundSprite = [SKAction moveByX:groundTexture.size.width * 2 y:0 duration:0];
    SKAction* moveGroundSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite, resetGroundSprite]]];
    
    
    for( int i = 0; i < 2 + self.frame.size.width / ( groundTexture.size.width ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
        sprite.position = CGPointMake(i * sprite.size.width, groundTexture.size.height / 2);
        [sprite runAction:moveGroundSpritesForever];
        sprite.name = @"world";
        [moving addChild:sprite];
    }
    
    // Create ground physics container
    
    SKNode* groundBody = [SKNode node];
    groundBody.position = CGPointMake(0, groundTexture.size.height /2);
    groundBody.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width * 2, groundTexture.size.height)];
    groundBody.physicsBody.dynamic = NO;
    groundBody.physicsBody.categoryBitMask = worldCategory;
    groundBody.physicsBody.collisionBitMask = birdCategory;
    [self addChild:groundBody];
    
}
*/
@end
