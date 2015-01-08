//
//  GamePipes.m
//  FlappyBirdXL
//
//  Created by Jeroen van der Es on 08-01-15.
//  Copyright (c) 2015 Jeroen van der Es. All rights reserved.
//

#import "GamePipes.h"
#import "GameScene.h"

@implementation GamePipes


static NSInteger const kVerticalPipeGap = 125;

+(void)pipes
{
    SKTexture *pipeTexture1 = [SKTexture textureWithImageNamed:@"Pipe1"];
    pipeTexture1.filteringMode = SKTextureFilteringNearest;
    SKTexture *pipeTexture2 = [SKTexture textureWithImageNamed:@"Pipe2"];
    pipeTexture2.filteringMode = SKTextureFilteringNearest;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    SKNode* pipePair = [SKNode node];
    pipePair.position = CGPointMake( screenRect.size.width + pipeTexture1.size.width * 2, 0 );
    pipePair.zPosition = -10;
    
   
    CGFloat y = arc4random() % (NSInteger)( screenRect.size.height / 3 );
    
    SKSpriteNode* pipe1 = [SKSpriteNode spriteNodeWithTexture:pipeTexture1];
    [pipe1 setScale:2];
    pipe1.position = CGPointMake( 0, y );
    pipe1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
    pipe1.physicsBody.dynamic = NO;
    [pipePair addChild:pipe1];
    
    SKSpriteNode* pipe2 = [SKSpriteNode spriteNodeWithTexture:pipeTexture2];
    [pipe2 setScale:2];
    pipe2.position = CGPointMake( 0, y + pipe1.size.height + kVerticalPipeGap );
    pipe2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe2.size];
    pipe2.physicsBody.dynamic = NO;
    [pipePair addChild:pipe2];
    
    
    SKAction* movePipes = [SKAction repeatActionForever:[SKAction moveByX:-1 y:0 duration:0.02]];
    
    [pipePair runAction:movePipes];
    
}

-(void)spawnPipes {
    SKNode* pipePair = [SKNode node];
    pipePair.position = CGPointMake( self.frame.size.width + pipeTexture1.size.width, 0 );
    pipePair.zPosition = -10;
    
    CGFloat y = (arc4random() % (NSInteger)( self.frame.size.height / 3 ) + groundTexture.size.height / 2);
    NSLog(@" %u ", arc4random());
    
    // float y = [self randomValueBetween:groundTexture.size.height / 2 andValue: self.frame.size.height / 2];
    
    SKSpriteNode* pipe1 = [SKSpriteNode spriteNodeWithTexture:pipeTexture1];
    [pipe1 setScale:2];
    pipe1.position = CGPointMake( 0, y );
    pipe1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
    pipe1.physicsBody.dynamic = NO;
    [pipePair addChild:pipe1];
    
    SKSpriteNode* pipe2 = [SKSpriteNode spriteNodeWithTexture:pipeTexture2];
    [pipe2 setScale:2];
    pipe2.position = CGPointMake( 0, y + pipe1.size.height + kVerticalPipeGap );
    pipe2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe2.size];
    pipe2.physicsBody.dynamic = NO;
    [pipePair addChild:pipe2];
    
    [pipePair runAction:moveAndRemovePipes];
    
    [self addChild:pipePair];
}

@end
