//
//  GameMenu.m
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 18-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import "GameMenu.h"
#import "GameMenuItems.h"



@implementation GameMenu

- (id)initWithSize: (CGSize)size and:(NSInteger)score and:(NSInteger)highScore {
    self = [super init];
    
//    SKTexture* backgroundMenu = [SKTexture textureWithImageNamed:@"GameMenu"];
//    backgroundMenu.filteringMode = SKTextureFilteringNearest;
//    SKSpriteNode* background = [SKSpriteNode spriteNodeWithTexture:backgroundMenu];
//    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 75);
//    background.size = size;
//    background.alpha = 0.8;
//    [self addChild:background];
    
    // Initialize first label, then position other labels under the next
    SKLabelNode* scoreLabelText = [GameMenuItems showScoreLabelText];
    scoreLabelText.position = CGPointMake(CGRectGetMidX(self.frame), 300);
    [self addChild:scoreLabelText];
    
    SKLabelNode* scoreLabel = [GameMenuItems scoreLabel:score];
    scoreLabel.zPosition = 100;
    scoreLabel.fontSize = 300;
    scoreLabel.alpha = 1;
    scoreLabel.position = CGPointMake( CGRectGetMidX(self.frame), scoreLabelText.position.y - scoreLabel.fontSize / 2);
    [self addChild:scoreLabel];

    
    SKLabelNode* highScoreLabelText = [GameMenuItems highScoreLabelText];
    highScoreLabelText.position = CGPointMake(CGRectGetMidX(self.frame), scoreLabel.position.y - highScoreLabelText.fontSize);
    [self addChild:highScoreLabelText];
    
    SKLabelNode* highScoreLabel = [GameMenuItems highScoreLabel:highScore];
    highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), highScoreLabelText.position.y - highScoreLabel.fontSize / 2 );
    [self addChild:highScoreLabel];
    
    SKLabelNode* retryGameButton = [GameMenuItems showRetryMenu];
    [retryGameButton setPosition:CGPointMake(CGRectGetMidX(self.frame),highScoreLabel.position.y - retryGameButton.frame.size.height)];
    [self addChild:retryGameButton];
    
    SKLabelNode* shopGameButton = [GameMenuItems showShopMenu];
    [shopGameButton setPosition:CGPointMake(CGRectGetMidX(self.frame),retryGameButton.position.y- shopGameButton.frame.size.height)];
    [self addChild:shopGameButton];

    return self;
}

@end
