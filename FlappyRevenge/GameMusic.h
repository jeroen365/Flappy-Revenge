//
//  GameMusic.h
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 26-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface GameMusic : AVAudioPlayer

+(id) setupShopMusic;
+(id) setupGameMusic;

@end

