//
//  ShopItems.m
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 22-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import "ShopItems.h"
#import "ShopItem.h"


@implementation ShopItems


//+ (id) laserBundle{
//    SKTexture* laserBundleTexture = [SKTexture textureWithImageNamed:@"Laserbundle"];
//    laserBundleTexture.filteringMode = SKTextureFilteringNearest;
//    SKSpriteNode* laserBundle = [SKSpriteNode spriteNodeWithTexture:laserBundleTexture];
//    
//    NSInteger cost = 15;
//    	
//    NSUserDefaults* Points = [NSUserDefaults standardUserDefaults];
//    NSInteger totalPoints =[Points integerForKey:@"totalPoints"];
//    
//    if (totalPoints < cost){
//        laserBundle.color = [SKColor grayColor];
//    }
//    else {
//        //laserBundle.purchasable = YES;
//    }
//    return laserBundle;
//}

- (id)initWithSize: (CGSize)size {
    self = [super init];

    // Add Laser to item shop
    ShopItem* laserBundle = [ShopItem shopItemWithTextureNamed:@"Laserbundle" withSize:size withCost:15];
    laserBundle.position = CGPointMake(0, 120 );
    laserBundle.name = @"laserBundle";
    [self addChild:laserBundle];

    
    // Add EasyMode to item shop
    ShopItem* easyMode = [ShopItem shopItemWithTextureNamed:@"EasyMode" withSize:size withCost:40];
    easyMode.position = CGPointMake(0, laserBundle.position.y - easyMode.size.height );
    easyMode.name = @"easyMode";
    [self addChild:easyMode];
    
    ShopItem* mechaFlappyItem = [ShopItem shopItemWithTextureNamed:@"MechaFlappyItem" withSize:size withCost:100];
    mechaFlappyItem.position = CGPointMake(0, easyMode.position.y - mechaFlappyItem.size.height);
    mechaFlappyItem.name = @"mechaFlappyItem";
    [self addChild:mechaFlappyItem];
    
    return self;
}

@end
