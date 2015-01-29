//
//  ShopScene.m
//  FlappyRevenge
//
//  This scene presents the game shop. It imports upgrades from ShopItems header.
//  It sends and receives data to and from GameScene via NSUserdefaults.
//  It transitions back to GameScene.
//
//  Created by Jeroen van der Es on 22-01-15.
//  Copyright (c) 2015 mprog. All rights reserved.
//

#import "ShopScene.h"
#import "GameScene.h"
#import "GameViewController.h"
#import "ShopItems.h"
#import "ShopItem.h"
#import "GameMusic.h"



@interface ShopScene(){
    NSInteger totalPoints;
    NSInteger numLasers;
    NSInteger itemCost;
    NSInteger easyGameTokens;
    SKAction* buttonPressSoundAction;
    SKAction* purchaseSoundAction;
    
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
@synthesize player;


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        [self setupShopMusic];
        [self loadInterface];
        buttonPressSoundAction = [SKAction playSoundFileNamed:@"ButtonPress.mp3" waitForCompletion:NO];
        purchaseSoundAction = [SKAction playSoundFileNamed:@"Score.wav" waitForCompletion:NO];

    }
    return self;
}

-(void)loadInterface{
    // Set background image
    [self addBackGround];
    
    // Retrieve total points
    [self getPoints];
    
    // Set back label
    [self addBackButton];
    
    // Set score label
    [self addScoreLabel];
    
    // Add Shopitems
    ShopItems* shopItems = [[ShopItems alloc] initWithSize: CGSizeMake(CGRectGetWidth(self.frame)-25, 400)];
    shopItems.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 100);
    shopItems.zPosition = 100;
    [self addChild:shopItems];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"back button"]) {
        [self runAction:buttonPressSoundAction];
        SKTransition *reveal = [SKTransition fadeWithDuration:1];
        GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self doVolumeFade];
        [self.view presentScene:scene transition:reveal];
    }

    if ([node.name isEqualToString:@"laserBundle"]){
        ShopItem* laserBundle = (ShopItem*) node;
        itemCost = laserBundle.cost;
        if (laserBundle.purchasable){
            [self runAction:purchaseSoundAction];
            [self boughtLaserBundle];
        }
    }
    if ([node.name isEqualToString:@"easyMode"]){
        ShopItem* easyMode = (ShopItem*) node;
        itemCost = easyMode.cost;
        if (easyMode.purchasable){
            [self runAction:purchaseSoundAction];
            [self boughtEasyMode];
        }
    }
    if ([node.name isEqualToString:@"mechaFlappyItem"]){
        ShopItem* mechaFlappyItem = (ShopItem*) node;
        itemCost = mechaFlappyItem.cost;
        if (mechaFlappyItem.purchasable){
            [self runAction:purchaseSoundAction];
            [self boughtMechaFlappy];
        }
    }

}


-(void)getPoints{
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    totalPoints = [Inventory integerForKey:@"totalPoints"];
    NSLog(@"total points %ld", totalPoints);
    
}

-(void)updateInterface{
    [self removeAllChildren];
    [self loadInterface];
}

-(void) boughtEasyMode{
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    [self substractPoints];
    
    // Add one easy game token to inventory
    easyGameTokens = [Inventory integerForKey:@"easyGameTokens"];
    easyGameTokens += 1;
    [Inventory setInteger:easyGameTokens forKey:@"easyGameTokens"];
    
    [Inventory synchronize];
    [self updateInterface];
}

-(void) boughtLaserBundle{
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    [self substractPoints];
    
    // Add 3 lasers to inventory
    numLasers = [Inventory integerForKey:@"numLasers"];
    numLasers += 3;
    [Inventory setInteger:numLasers forKey:@"numLasers"];
    
    [Inventory synchronize];
    [self updateInterface];
}

-(void) boughtMechaFlappy{
    // Sets mechaFlappy skin
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    [self substractPoints];
    
    [Inventory setInteger:1 forKey:@"flappySkin"];
    [Inventory synchronize];
    [self updateInterface];
}

-(void) substractPoints{
    // Substract cost from points
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];

    totalPoints = [Inventory integerForKey:@"totalPoints"];
    totalPoints -= itemCost;
    [Inventory setInteger:totalPoints forKey:@"totalPoints"];

}

-(void) addBackGround{
    SKTexture* backgroundShop = [SKTexture textureWithImageNamed:@"ShopView"];
    backgroundShop.filteringMode = SKTextureFilteringNearest;
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithTexture:backgroundShop];
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    background.size = self.size;
    [self addChild:background];
}

-(void) addBackButton{
    SKTexture *backLabel = [SKTexture textureWithImageNamed:@"ShopBackButton"];
    backLabel.filteringMode = SKTextureFilteringNearest;
    SKSpriteNode* shopBackButton = [SKSpriteNode spriteNodeWithTexture:backLabel];
    shopBackButton.position = CGPointMake(CGRectGetMidX(self.frame) / 3, CGRectGetHeight(self.frame)/10);
    shopBackButton.scale = 0.35;
    shopBackButton.name = @"back button";
    [self addChild:shopBackButton];
}

-(void) addScoreLabel{
    SKLabelNode* scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"VisitorTT2BRK"];
    NSString* scoreLabelText = [NSString stringWithFormat:@" Points:%ld",totalPoints];
    scoreLabel.text = scoreLabelText;
    scoreLabel.fontSize = 25;
    scoreLabel.fontColor = [SKColor blackColor];
    scoreLabel.position = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetMidX(self.frame) / 3 - 15, CGRectGetHeight(self.frame)/10);
    [self addChild:scoreLabel];
}

-(void) setupShopMusic{
    //Initialize our player pointing to the path to our resource
    player = [GameMusic setupShopMusic];
    NSError* err;
    
    if( err ){
        //bail!
        NSLog(@"Failed with reason: %@", [err localizedDescription]);
    }
    else{
        //set our delegate and begin playback
        player.delegate = self;
        [player play];
        player.numberOfLoops = -1;
        player.currentTime = 0;
        player.volume = 1.0;
    }
}

-(void)doVolumeFade{
    // Initializes a volumeFade for scene switch
    if (self.player.volume > 0.1) {
        self.player.volume = self.player.volume - 0.1;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];
    } else {
        // Stop and get the sound ready for playing again
        [self.player stop];
        self.player.currentTime = 0;
        [self.player prepareToPlay];
        self.player.volume = 1.0;
    }
}
@end
