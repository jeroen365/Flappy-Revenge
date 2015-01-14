//
//  GameMenuLayer.m
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 12-01-15.
//  Copyright (c) 2015 Jeroen van der Es. All rights reserved.
//

#import "GameMenuLayer.h"

@implementation GameMenuLayer

- (id)initWithSize:(CGSize)size
{
    self = [super init];
    if (self)
    {
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:1.0 alpha:0.0] size:size];
        node.anchorPoint = CGPointZero;
        [self addChild:node];
        node.zPosition = -1;
        node.name = @"transparent";
    }
    return self;
}


@end
