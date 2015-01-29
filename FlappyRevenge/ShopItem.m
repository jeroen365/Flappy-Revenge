//
//  ShopItem.m
//  FlappyRevenge
//
//  This class initializes a individual shop Item and passes them to ShopItems.
//
//  Created by Jeroen van der Es on 22-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import "ShopItem.h"

@implementation ShopItem

+(id)shopItemWithTextureNamed:(NSString*) textureName withSize:(CGSize)size withCost: (NSInteger) cost{
    ShopItem* shopItem = [[ShopItem alloc] init];
    
    shopItem.texture = [SKTexture textureWithImageNamed:textureName];
    shopItem.texture.filteringMode = SKTextureFilteringNearest;
    shopItem.cost = cost;
    shopItem.size = CGSizeMake(size.width, 100);
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    NSInteger totalPoints = [Inventory integerForKey:@"totalPoints"];
    if (totalPoints >= shopItem.cost)
        shopItem.purchasable = YES;
    else{
        shopItem.purchasable = NO;
        shopItem.color = [SKColor blackColor];
        shopItem.colorBlendFactor = 0.2;
    }
    return shopItem;
}


@end
