//
//  ShopScene.m
//  FlappyRevenge
//
//  Created by Jeroen van der Es on 22-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import "ShopScene.h"
#import "GameScene.h"
#import "GameViewController.h"

@interface ShopScene(){
    NSInteger totalPoints;
}

@end

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation ShopScene


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        NSLog(@"hoi");
        self.backgroundColor = [SKColor blackColor];
        
        // Set background image
        SKTexture* backgroundShop = [SKTexture textureWithImageNamed:@"ShopView"];
        backgroundShop.filteringMode = SKTextureFilteringNearest;
        SKSpriteNode* background = [SKSpriteNode spriteNodeWithTexture:backgroundShop];
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        background.size = self.size;
        [self addChild:background];
        
        // Retrieve total points
        [self getPoints];
        
        // Set back label
        SKLabelNode *backLabel = [SKLabelNode labelNodeWithFontNamed:@"VisitorTT2BRK"];
        backLabel.text = @"Back";
        backLabel.fontSize = 25;
        backLabel.fontColor = [SKColor blackColor];
        backLabel.position = CGPointMake(CGRectGetMidX(self.frame) / 3, CGRectGetHeight(self.frame)/10);
        backLabel.name = @"back button";
        [self addChild:backLabel];
        
        // Set score label
        SKLabelNode* scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"VisitorTT2BRK"];
        NSString* scoreLabelText = [NSString stringWithFormat:@" Points:%ld",totalPoints];
        scoreLabel.text = scoreLabelText;
        scoreLabel.fontSize = 25;
        scoreLabel.fontColor = [SKColor blackColor];
        scoreLabel.position = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetMidX(self.frame) / 3 - 15, CGRectGetHeight(self.frame)/10);
        [self addChild:scoreLabel];        
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"back button"]) {
        
        SKTransition *reveal = [SKTransition fadeWithDuration:1];
        
        GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition:reveal];
    }
}

-(void)getPoints{
    NSUserDefaults* Points = [NSUserDefaults standardUserDefaults];
    totalPoints = [Points integerForKey:@"totalPoints"];
    NSLog(@"total points %ld", totalPoints);
    
}

@end
