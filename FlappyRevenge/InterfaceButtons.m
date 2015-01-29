//
//  InterfaceButtons.m
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 29-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import "InterfaceButtons.h"

@implementation InterfaceButtons

+(id) showPlayGameButton{
    SKSpriteNode* playGameButton = [SKSpriteNode spriteNodeWithImageNamed:@"Playbutton"];
    playGameButton.scale = 0.5;
    return playGameButton;
}

+(id) showFireButton: (NSInteger) numLasers{
    SKSpriteNode* fireButton = [SKSpriteNode spriteNodeWithImageNamed:@"FireButton"];
    fireButton.scale = 0.2;
    fireButton.name = @"fireButton";
    // Show amount of lasers left
    SKLabelNode* fireLabel = [SKLabelNode labelNodeWithFontNamed:@"VisitorTT2BRK"];
    fireLabel.text = [NSString stringWithFormat:@"%li", (long)numLasers];
    fireLabel.fontSize = 300;
    fireLabel.position = CGPointMake(fireButton.frame.size.width - fireLabel.fontSize / 3, fireButton.frame.size.height - fireLabel.fontSize / 2  );
    fireLabel.zPosition = 120;
    fireLabel.name = @"fireButton";
    [fireButton addChild:fireLabel];
    return fireButton;
}

@end
