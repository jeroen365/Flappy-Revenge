//
//  GameScene.h
//  FlappyBirdXL
//

//  Copyright (c) 2014 Jeroen van der Es. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

@class SpriteViewController;

@interface GameScene : SKScene<AVAudioPlayerDelegate>{
    AVAudioPlayer* player;
    AVAudioPlayer* laserSound;
}

@property (nonatomic, retain) AVAudioPlayer* player;
@property (nonatomic, retain) AVAudioPlayer* laserSound;


@property (weak, nonatomic) SpriteViewController *spriteViewController;

@end
