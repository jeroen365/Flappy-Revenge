//
//  GameMenu.m
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 18-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import "GameMenu.h"



@implementation GameMenu

+(id) showGameMenu{
    SKSpriteNode* playGameButton = [SKSpriteNode spriteNodeWithImageNamed:@"Playbutton"];
    playGameButton.scale = 0.5;
    return playGameButton;
}

+(id) showRetryMenu{
    SKSpriteNode* retryGameButton = [SKSpriteNode spriteNodeWithImageNamed:@"Retrybutton"];
    retryGameButton.scale = 0.5;
    retryGameButton.zPosition = 100;
    return retryGameButton;
}

+(id) showShopMenu{
    SKSpriteNode* shopGameButton = [SKSpriteNode spriteNodeWithImageNamed:@"Shopbutton"];
    shopGameButton.scale = 0.5;
    shopGameButton.zPosition = 100;
    return shopGameButton;
}

+(id) showFireButton{
    SKSpriteNode* showFireButton = [SKSpriteNode spriteNodeWithImageNamed:@"FireButton"];
    showFireButton.scale = 0.2;
    showFireButton.name = @"fireButton";
    return showFireButton;
}

+(SKLabelNode*) scoreLabel:(NSInteger)score{
    // Initialize label and create a label which holds the score
    SKLabelNode* scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"VisitorTT2BRK"];
    scoreLabel.fontSize = 800;
    scoreLabel.alpha = 0.5;
    scoreLabel.zPosition = -50;
    scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)score];
    return scoreLabel;
}

+(SKLabelNode*) showScoreLabelText{
    SKLabelNode* scoreLabelText = [SKLabelNode labelNodeWithFontNamed:@"VisitorTT2BRK"];
    scoreLabelText.fontSize = 50;
    scoreLabelText.fontColor = [SKColor blackColor];
    scoreLabelText.zPosition = 110;
    scoreLabelText.text = [NSString stringWithFormat:@"Score"];
    return scoreLabelText;
}

+(SKLabelNode*) highScoreLabel:(NSInteger)highScore{
    SKLabelNode* highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"VisitorTT2BRK"];
    highScoreLabel.fontSize = 300;
    highScoreLabel.zPosition = 100;
    highScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)highScore];
    return highScoreLabel;
}

+(SKLabelNode*) highScoreLabelText{
    SKLabelNode* highScoreLabelText = [SKLabelNode labelNodeWithFontNamed:@"VisitorTT2BRK"];
    highScoreLabelText.fontSize = 50;
    highScoreLabelText.fontColor = [SKColor blackColor];
    highScoreLabelText.zPosition = 110;
    highScoreLabelText.text = [NSString stringWithFormat:@"Highscore"];
    return highScoreLabelText;
}

@end
