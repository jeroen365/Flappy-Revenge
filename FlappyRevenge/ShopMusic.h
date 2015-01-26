//
//  ShopMusic.h
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 26-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface ShopMusic : AVAudioPlayer <AVAudioPlayerDelegate>{
    AVAudioPlayer *player;
}

-(void) setupShopMusic;

@property (nonatomic, retain) AVAudioPlayer *player;

@end
