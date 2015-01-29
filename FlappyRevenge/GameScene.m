//
//  GameScene.m
//  FlappyBirdXL
//
//  Created by Jeroen van der Es on 20-12-14.
//  Copyright (c) 2014 Jeroen van der Es. All rights reserved.
//

#import "GameScene.h"
#import "GameBird.h"
#import "InterfaceButtons.h"
#import "GameMenu.h"
#import "GameMenuItems.h"
#import "GameBackGround.h"
#import "GameViewController.h"
#import "ShopScene.h"

@interface GameScene() <SKPhysicsContactDelegate> {
    // Scene textures/nodes
    GameBird* bird;
    SKColor* skyColor;
    SKTexture* groundTexture;
    SKTexture* skylineTexture;
    SKSpriteNode* pipeDown;
    SKSpriteNode* pipeTop;
    SKNode* pipePair;
    
    // Menu labels
    SKSpriteNode* playGameButton;
    SKSpriteNode* fireButton;
    SKSpriteNode* birdLaser;
    SKLabelNode* scoreLabel;
    CGFloat scoreLabelMid;

    // GamePlay variables
    BOOL startGame;
    BOOL gameOver;
    NSInteger score;
    NSInteger highScore;
    SKNode* moving;
    CGFloat gameSpeed;
    NSInteger kVerticalPipeGap;
    NSInteger numLasers;
    
    // Music actions
    SKAction* moveAndRemovePipes;
    SKAction* laserFireSoundAction;
    SKAction* birdJumpSoundAction;
    SKAction* birdDiesSoundAction;
    SKAction* buttonPressSoundAction;
    SKAction* scoreSoundAction;
    SKAction* highScoreSoundAction;
}


@end



@implementation GameScene
@synthesize player, laserSound;


static const uint32_t birdCategory = 1 << 0;
static const uint32_t worldCategory = 1 << 1;
static const uint32_t pipeCategory = 1 << 2;
static const uint32_t laserCategory = 1 << 3;
static const uint32_t scoreCategory = 1 << 4;




-(void)didMoveToView:(SKView *)view {
    // Load music once
    [self setupGameMusic];
    laserFireSoundAction = [SKAction playSoundFileNamed:@"LaserSound2.mp3" waitForCompletion:NO];
    birdJumpSoundAction = [SKAction playSoundFileNamed:@"JumpSound.wav" waitForCompletion:NO];
    birdDiesSoundAction = [SKAction playSoundFileNamed:@"BirdDied.wav" waitForCompletion:NO];
    buttonPressSoundAction = [SKAction playSoundFileNamed:@"ButtonPress.mp3" waitForCompletion:NO];
    scoreSoundAction = [SKAction playSoundFileNamed:@"Score.wav" waitForCompletion:NO];
    highScoreSoundAction = [SKAction playSoundFileNamed:@"HighScoreSound.mp3" waitForCompletion:NO];

    [self initializeGame];
}

-(void)initializeGame{
    // initialize world
    
    // Set global node for moving the world
    moving = [SKNode node];
    [self addChild:moving];
    
    // Lower is faster
    gameSpeed = 0.005;
    
    // Reset score
    score = 0;
    moving.speed = 1;
    startGame = NO;
    
    // Background color
    skyColor = [SKColor colorWithRed:113.0/255.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
    [self setBackgroundColor:skyColor];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = worldCategory;
    
    // Show Play Game Button
    playGameButton = [InterfaceButtons showPlayGameButton];
    [playGameButton setPosition:CGPointMake(CGRectGetMidX(self.frame)+5,CGRectGetMidY(self.frame)-40)];
    [self addChild:playGameButton];
    
    scoreLabel = [GameMenuItems scoreLabel:score];
    scoreLabelMid = scoreLabel.fontSize / 4;
    scoreLabel.position = CGPointMake( CGRectGetMidX( self.frame ), CGRectGetMidX(self.frame) - scoreLabelMid );
    [self addChild:scoreLabel];
    
    // Set zero gravity to keep the bird in centre
    self.physicsWorld.gravity = CGVectorMake( 0.0, 0.0 );
    self.physicsWorld.contactDelegate = self;
    
    // Get items from Inventory
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    numLasers = [Inventory integerForKey:@"numLasers"];
    highScore = [Inventory integerForKey:@"highScore"];
    [self checkForEasyGameTokens];
    if (numLasers > 0)
        [self addFireButton];

    // Add Objects
    [self addBird];
    [bird flyIddle];
    [self addGround];
    [self addSkyline];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Check for user interaction
    if (startGame == NO)
        [self beginGame];
    
    // Set variables interaction
    for (UITouch* touch in touches){
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        
        // Touches during the game
        if(moving.speed > 0 & startGame == YES){
            [bird fly];
            [self runAction:birdJumpSoundAction];
            if (numLasers > 0) {
                if ([node.name isEqualToString:@"fireButton"])
                    [self fireLaser];
            }
        }
        // Touches in the game over menu
        else if (gameOver == YES){
            if ([node.name isEqualToString:@"retryButton"]){
                [self runAction:buttonPressSoundAction];
                [self resetScene];
            }
            if ([node.name isEqualToString:@"shopButton"]){
                [self runAction:buttonPressSoundAction];
                [self switchToShopScene];
            }
        }
    }
}


- (void)didBeginContact:(SKPhysicsContact *)contact {
    if(moving.speed > 0){
        if( ( contact.bodyA.categoryBitMask ) == scoreCategory || ( contact.bodyB.categoryBitMask ) == scoreCategory ) {
            // Bird passed scorenode
            [self updateScore];
        }
        else if( ( contact.bodyA.categoryBitMask ) == laserCategory|| ( contact.bodyB.categoryBitMask) == laserCategory ) {
            // Laser hit Pipe
            [contact.bodyA.node removeFromParent];
            [contact.bodyB.node removeFromParent];
        }
        else if( ( contact.bodyA.categoryBitMask ) == birdCategory || ( contact.bodyB.categoryBitMask ) == birdCategory ) {
            // Bird dies
            [self stopScene];
            bool finished = [self hitAnimation];
            if (finished)
                [self showGameOverMenu];
        }
    }
}

-(void) updateScore{
    score++;
    [self runAction:scoreSoundAction];
    if (score >= 10){
        scoreLabel.fontSize = 550;
        if (score >= 100){
            scoreLabel.fontSize = 400;
        }
    }
    scoreLabel.text = [NSString stringWithFormat:@"%ld", score];
}

-(void) savePoints{
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    NSInteger totalPoints = [Inventory integerForKey:@"totalPoints"];
    totalPoints += score;
    NSLog(@"totalPoints %ld",(long)totalPoints);
    [Inventory setInteger:totalPoints forKey:@"totalPoints"];
    [Inventory synchronize];

}


CGFloat clamp(CGFloat min, CGFloat max, CGFloat value) {
    if( value > max ) {
        return max;
    } else if( value < min ) {
        return min;
    } else {
        return value;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    if(startGame == YES){
        bird.zRotation = clamp( -1, 0.5, bird.physicsBody.velocity.dy * ( bird.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) );
    }
}

-(void) beginGame{
    // Start moving the world
    startGame = YES;
    moving.speed = 1;
    [playGameButton removeFromParent];
    [self removeAllActions];
    [bird removeActionForKey:@"flyIddle"];
    self.physicsWorld.gravity = CGVectorMake( 0.0, -7 );
    [self generateWorld];
}

-(void) resetScene{
    
    gameOver = NO;
    [self removeAllChildren];
    [self initializeGame];
}

-(void)generateWorld {
    SKAction* spawn = [SKAction performSelector:@selector(spawnPipes) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:1.5];
    SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
    SKAction* spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
    [self runAction:spawnThenDelayForever];
}





-(void) fireLaser{
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    numLasers = [Inventory integerForKey:@"numLasers"];

    if (numLasers > 0){
        [self createLaser];
        [self runAction:laserFireSoundAction];
        numLasers--;
        
        birdLaser.physicsBody.velocity = CGVectorMake(0, 0);
        [birdLaser.physicsBody applyImpulse:CGVectorMake(180, 0)];
        
        [self updateFireButton];
        [Inventory setInteger:numLasers forKey:@"numLasers"];
    }
}

-(void) createLaser{
    SKTexture* birdLaserTexture =[SKTexture textureWithImageNamed:@"Laserbeam"];
    birdLaserTexture.filteringMode = SKTextureFilteringNearest;
    
    birdLaser = [SKSpriteNode spriteNodeWithTexture:birdLaserTexture];

    birdLaser.position = CGPointMake(bird.position.x+birdLaser.size.width/2, bird.position.y);
    birdLaser.name = @"laser";
    birdLaser.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:birdLaser.size];
    birdLaser.physicsBody.dynamic = YES;
    birdLaser.physicsBody.allowsRotation = NO;
    birdLaser.physicsBody.affectedByGravity = NO;
    birdLaser.physicsBody.mass = 0.1;
    birdLaser.physicsBody.linearDamping = 0.0;
    birdLaser.physicsBody.categoryBitMask = laserCategory;
    birdLaser.physicsBody.contactTestBitMask = pipeCategory;
    birdLaser.physicsBody.collisionBitMask = pipeCategory;
    
    [self addChild:birdLaser];
}

-(void) checkForEasyGameTokens{
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    NSInteger easyGameTokens = [Inventory integerForKey:@"easyGameTokens"];
    if (easyGameTokens > 0){
        kVerticalPipeGap = 170;
        NSLog(@"easy");
        easyGameTokens -= 1;
        [Inventory setInteger:easyGameTokens forKey:@"easyGameTokens"];
        [Inventory synchronize];
    }
    else{
        kVerticalPipeGap = 140;
        NSLog(@"normal");
    }
}
-(void)stopScene{
    // Bird hit anything visible and dies, stop scene
    moving.speed = 0;
    gameOver = YES;
    [scoreLabel removeFromParent];
    [self removeAllActions];
    bird.physicsBody.collisionBitMask = worldCategory;
    bird.speed = 0;
    
}

-(BOOL) hitAnimation{
    // Flash background if bird dies
    NSLog(@"jaja");
    [self removeActionForKey:@"flash"];
    [self runAction:[SKAction sequence:@[[SKAction repeatAction:[SKAction sequence:@[[SKAction runBlock:^{
        self.backgroundColor = [SKColor colorWithRed:255.0/255.0 green:150.0/255.0 blue:180.0/255.0 alpha:1.0];
    }], [SKAction waitForDuration:0.1], [SKAction runBlock:^{
        self.backgroundColor = skyColor;
    }], [SKAction waitForDuration:0.1]]] count:4]]] withKey:@"flash"];
    [self runAction:birdDiesSoundAction];
    return true;
}

-(void) showGameOverMenu{
    
    if ([self checkHighScore]){
        NSLog(@"yay");
        [self runAction:highScoreSoundAction];
        // highscore sound
    }
    
    NSLog(@"size x %f, size y %f",CGRectGetMidX(self.frame) / 2, CGRectGetHeight(self.frame) );
    
    GameMenu* gameOverMenu = [[GameMenu alloc] initWithSize: CGSizeMake(CGRectGetMidX(self.frame) / 2, CGRectGetHeight(self.frame) - 200) and:score and:highScore];
    gameOverMenu.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) );
    gameOverMenu.zPosition = 100;
    gameOverMenu.color = [SKColor colorWithWhite:1 alpha:0.8];
    [self addChild:gameOverMenu];
    
    // Save points
    [self savePoints];
    


}

-(BOOL) checkHighScore{
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    if (score> highScore){
        highScore = score;
        [Inventory setInteger:highScore forKey:@"highScore"];
        return YES;
    }
    return NO;
}

-(void)addBird{
    bird = [GameBird bird];
    bird.position = CGPointMake((self.frame.size.width / 2.5), CGRectGetMidY(self.frame));
    bird.speed = 1;
    bird.physicsBody.categoryBitMask = birdCategory;
    bird.physicsBody.collisionBitMask = worldCategory | pipeCategory;
    bird.physicsBody.contactTestBitMask = worldCategory | pipeCategory;
    [self addChild:bird];
}

-(void)addSkyline{
    // Load skyline
    skylineTexture = [SKTexture textureWithImageNamed:@"Skyline"];
    skylineTexture.filteringMode = SKTextureFilteringNearest;
    
    // refractor: replace skylinetexture size with skylineNode size, load skylineNode in GameBackground.
    
    SKAction* moveSkylineSprite = [SKAction moveByX:-skylineTexture.size.width*2 y:0 duration:0.05 * skylineTexture.size.width*2];
    SKAction* resetSkylineSprite = [SKAction moveByX:skylineTexture.size.width*2 y:0 duration:0];
    SKAction* moveSkylineSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSkylineSprite, resetSkylineSprite]]];
    
    
    for( int i = 0; i < 2 + self.frame.size.width / ( skylineTexture.size.width ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:skylineTexture];
        sprite.zPosition = -20;
        sprite.position = CGPointMake(i * sprite.size.width, groundTexture.size.height / 2);

        [sprite runAction: moveSkylineSpritesForever];
        [moving addChild:sprite];
    }
}


-(float)randomValueBetween:(float)low andValue: (float)high {
    return (((float)arc4random()/ 0xFFFFFFFFu)*(high - low)) + low;
    
}


-(void)spawnPipes {
    
    // Random y to generate random height pipes
    float y = [self randomValueBetween:CGRectGetHeight(self.frame) / 15  andValue:  CGRectGetHeight(self.frame) /3];
    
    pipeDown = [GameBackGround addPipeDown];
    pipeDown.position = CGPointMake( 0, y );
    pipeDown.physicsBody.categoryBitMask = pipeCategory;
    
    pipeTop = [GameBackGround addPipeTop];
    pipeTop.position = CGPointMake( 0, y + pipeDown.size.height + kVerticalPipeGap );
    pipeTop.physicsBody.categoryBitMask = pipeCategory;
    
    [self addScoreNode];
    [self animatePipes];
   
}

-(void) animatePipes{
    // Moving Pipes function
    CGFloat distanceToMove = self.frame.size.width + 2 * pipeDown.size.width;
    SKAction* movePipes = [SKAction moveByX:-distanceToMove y:0 duration:gameSpeed * distanceToMove];
    SKAction* removePipes = [SKAction removeFromParent];
    moveAndRemovePipes = [SKAction sequence:@[movePipes, removePipes]];
    
    pipePair = [SKNode node];
    pipePair.position = CGPointMake( self.frame.size.width + pipeDown.size.width, 0 );
    pipePair.zPosition = -10;
    
    [pipePair addChild:pipeDown];
    [pipePair addChild:pipeTop];
    
    [pipePair runAction:moveAndRemovePipes];
    [moving addChild:pipePair];
 
}

-(void) addScoreNode{
    // Score node
    SKNode* scoreNode = [SKNode node];
    scoreNode.position = CGPointMake( pipeDown.size.width + bird.size.width / 2, CGRectGetMidY( self.frame ) );
    scoreNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake( pipeTop.size.width, self.frame.size.height )];
    scoreNode.physicsBody.dynamic = NO;
    scoreNode.physicsBody.categoryBitMask = scoreCategory;
    scoreNode.physicsBody.contactTestBitMask = birdCategory;
    
    [pipePair addChild:scoreNode];
}

-(void)addGround{
    // Load ground
    groundTexture = [SKTexture textureWithImageNamed:
                                @"Ground"];
    groundTexture.filteringMode = SKTextureFilteringNearest;
    
    SKAction* moveGroundSprite = [SKAction moveByX:-groundTexture.size.width * 2 y:0 duration:gameSpeed * groundTexture.size.width*2];
    SKAction* resetGroundSprite = [SKAction moveByX:groundTexture.size.width * 2 y:0 duration:0];
    SKAction* moveGroundSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite, resetGroundSprite]]];
    
    
    for( int i = 0; i < 2 + self.frame.size.width / ( groundTexture.size.width ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
        sprite.position = CGPointMake(i * sprite.size.width, groundTexture.size.height / 2);
        [sprite runAction:moveGroundSpritesForever];
        sprite.name = @"world";
        [moving addChild:sprite];
    }
    
    [self addGroundPhysics];

}

-(void) addGroundPhysics{
    
    // Create ground physics container
    SKNode* groundBody = [SKNode node];
    groundBody.position = CGPointMake(0, groundTexture.size.height /2);
    groundBody.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width * 2, groundTexture.size.height)];
    groundBody.physicsBody.dynamic = NO;
    groundBody.physicsBody.categoryBitMask = worldCategory;
    groundBody.physicsBody.collisionBitMask = birdCategory;
    [self addChild:groundBody];
}


-(void) addFireButton{
    fireButton = [InterfaceButtons showFireButton:numLasers];
    [fireButton setPosition:CGPointMake(CGRectGetWidth(self.frame) / 3 + 10, CGRectGetHeight(self.frame) / 10 + 10)];
    fireButton.zPosition = 100;
    [self addChild:fireButton];
    
}
-(void) updateFireButton{
    [fireButton removeFromParent];
    [self addFireButton];
}

-(void) switchToShopScene{
    // initiate switch to shopscene
    [self doVolumeFade];
    [self runAction:buttonPressSoundAction];
    SKTransition *reveal = [SKTransition fadeWithDuration:1];
    ShopScene *scene = [ShopScene sceneWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:scene transition:reveal];

}

-(void) setupGameMusic{
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/GameSceneMusic.mp3"];
    
    NSError* err;
    
    //Initialize our player pointing to the path to our resource
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:
              [NSURL fileURLWithPath:resourcePath] error:&err];
    
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


-(void)doVolumeFade
{
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
