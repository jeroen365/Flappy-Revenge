//
//  GameMusic.m
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 29-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import "GameMusic.h"

@implementation GameMusic


+(id) setupShopMusic{
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/pokecenter sound.mp3"];
    NSLog(@"Path to play: %@", resourcePath);
    NSError* err;
    
    //Initialize our player pointing to the path to our resource
    AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                             [NSURL fileURLWithPath:resourcePath] error:&err];
    
    
    return player;
}

+(id) setupGameMusic{
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/GameSceneMusic.mp3"];
    
    NSError* err;
    
    //Initialize our player pointing to the path to our resource
    AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                             [NSURL fileURLWithPath:resourcePath] error:&err];
    return player;
}
@end