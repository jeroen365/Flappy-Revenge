//
//  ShopItem.h
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 22-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ShopItem : SKSpriteNode

+(id)shopItemWithTextureNamed:(NSString*) textureName withSize:(CGSize)size withCost: (NSInteger) cost;

@property BOOL purchasable;
@property NSInteger cost;


@end
