//
//  StartGameMenu.m
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 12-01-15.
//  Copyright (c) 2015 Jeroen van der Es. All rights reserved.
//

#import "StartGameMenu.h"

@interface StartGameMenu()

@end



@implementation StartGameMenu

- (id)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        SKSpriteNode* playButton = [SKSpriteNode spriteNodeWithImageNamed:@"Playbutton"];
        playButton.position = CGPointMake(size.width * 0.5f, size.height * 0.30f);
        [self addChild:playButton];
        
        [self setPlayButton:playButton];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if ([_playButton containsPoint:location])
    {
        if([self.delegate respondsToSelector:@selector(startGameMenu:tapRecognizedOnButton:)])
        {
            [self.delegate startGameMenu:self tapRecognizedOnButton:StartGameMenuPlayButton];
        }
    }
}

@end
