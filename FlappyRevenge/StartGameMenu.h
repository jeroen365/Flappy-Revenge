//
//  StartGameMenu.h
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 12-01-15.
//  Copyright (c) 2015 Jeroen van der Es. All rights reserved.
//

#import "GameMenuLayer.h"
typedef NS_ENUM(NSUInteger, StartGameMenuButtonType)
{
    StartGameMenuPlayButton = 0
};


@protocol StartGameMenuDelegate;

@interface StartGameMenu : GameMenuLayer

@property (nonatomic, retain) SKSpriteNode* playButton;



@property (nonatomic, assign) id<StartGameMenuDelegate> delegate;
@end

@protocol StartGameMenuDelegate <NSObject>
@optional

- (void) startGameMenu:(StartGameMenu*)sender tapRecognizedOnButton:(StartGameMenuButtonType) startGameMenuButton;
@end