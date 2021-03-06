//
//  ShopScene.h
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 22-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface ShopScene : SKScene <AVAudioPlayerDelegate>{
    AVAudioPlayer *player;
}

@property (nonatomic, retain) AVAudioPlayer *player;


@end
