//
//  GameScene.m
//  FlappyBirdXL
//
//  Created by Jeroen van der Es on 20-12-14.
//  Copyright (c) 2014 Jeroen van der Es. All rights reserved.
//

#import "GameScene.h"
#import "GameBird.h"
#import "GameMenu.h"
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
    SKSpriteNode* retryGameButton;
    SKSpriteNode* shopGameButton;
    SKSpriteNode* fireButton;
    SKLabelNode *fireLabel;
    NSInteger totalPoints;
    SKSpriteNode* birdLaserTemp;
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
    
    [self beginGame];
}

-(void)beginGame{
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
    
    // show menu
    playGameButton = [GameMenu showGameMenu];
    [playGameButton setPosition:CGPointMake(CGRectGetMidX(self.frame)+5,CGRectGetMidY(self.frame)-40)];
    [self addChild:playGameButton];
    
    
    scoreLabel = [GameMenu scoreLabel:score];
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

    // Add Objects
    [self addBird];
    [bird flyIddle];
    [self addGround];
    [self addSkyline];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (startGame == NO){
        // if screen is touched while playbutton shows
        
        // Start moving the world
        startGame = YES;
        moving.speed = 1;
        [playGameButton removeFromParent];
        [self removeAllActions];
        [bird removeActionForKey:@"flyIddle"];
        self.physicsWorld.gravity = CGVectorMake( 0.0, -7 );
        [self addFireButton];
        [self generateWorld];
        
        
    }
    
    if(moving.speed > 0 & startGame == YES){
        [bird fly];
        [self runAction:birdJumpSoundAction];
        if (numLasers > 0) {
            for (UITouch *touch in touches) {
                CGPoint location = [touch locationInNode:self];
                if ([fireButton containsPoint:location]){
                    [self fireLaser];
                }
            }
        }
    }
    else if (gameOver == YES){
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInNode:self];
            if ([retryGameButton containsPoint:location]){
                [self runAction:buttonPressSoundAction];
                [self resetScene];
            }
            if ([shopGameButton containsPoint:location]){
                // initiate switch to shopscene
                [self doVolumeFade];
                [self runAction:buttonPressSoundAction];
                SKTransition *reveal = [SKTransition fadeWithDuration:1];
                ShopScene *scene = [ShopScene sceneWithSize:self.view.bounds.size];
                scene.scaleMode = SKSceneScaleModeAspectFill;
                [self.view presentScene:scene transition:reveal];
            }
        }
    }
}


- (void)didBeginContact:(SKPhysicsContact *)contact {
    if(moving.speed > 0){
        if( ( contact.bodyA.categoryBitMask ) == scoreCategory || ( contact.bodyB.categoryBitMask ) == scoreCategory ) {
            // Bird passed scorenode
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
        else if( ( contact.bodyA.categoryBitMask ) == laserCategory|| ( contact.bodyB.categoryBitMask) == laserCategory ) {
            // Laser hit Pipe
            [contact.bodyA.node removeFromParent];
            [contact.bodyB.node removeFromParent];
        }
        else if( ( contact.bodyA.categoryBitMask ) == birdCategory || ( contact.bodyB.categoryBitMask ) == birdCategory ) {
            // Bird dies
            [self dieScene];
            [self showGameOverMenu];
        }
    }
}


-(void) savePoints{
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    NSInteger totalPointsTemp = [Inventory integerForKey:@"totalPoints"];
    totalPoints = totalPointsTemp;
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


-(void) resetScene{
    
    gameOver = NO;
    [self removeAllChildren];
    [self beginGame];
}

-(void)generateWorld {
    SKAction* spawn = [SKAction performSelector:@selector(spawnPipes) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:1.5];
    SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
    SKAction* spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
    [self runAction:spawnThenDelayForever];
}





-(void) fireLaser{
    //SKSpriteNode* birdLaserTemp = [birdLasers objectAtIndex: numLasers - 1];
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    numLasers = [Inventory integerForKey:@"numLasers"];
    NSLog(@"numLasers %ld", (long)numLasers);
    if (numLasers > 0){
        [self createLaser];
        [self runAction:laserFireSoundAction];
        numLasers--;
        
        birdLaserTemp.physicsBody.velocity = CGVectorMake(0, 0);
        [birdLaserTemp.physicsBody applyImpulse:CGVectorMake(180, 0)];
        
        fireLabel.text = [NSString stringWithFormat:@"%ld",numLasers];
        [Inventory setInteger:numLasers forKey:@"numLasers"];
    }
}

-(void) createLaser{
    SKTexture* birdLaserTexture =[SKTexture textureWithImageNamed:@"Laserbeam"];
    birdLaserTexture.filteringMode = SKTextureFilteringNearest;
    
    birdLaserTemp = [SKSpriteNode spriteNodeWithTexture:birdLaserTexture];

    birdLaserTemp.position = CGPointMake(bird.position.x+birdLaserTemp.size.width/2, bird.position.y);
    birdLaserTemp.name = @"laser";
    birdLaserTemp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:birdLaserTemp.size];
    birdLaserTemp.physicsBody.dynamic = YES;
    birdLaserTemp.physicsBody.allowsRotation = NO;
    birdLaserTemp.physicsBody.affectedByGravity = NO;
    birdLaserTemp.physicsBody.mass = 0.1;
    birdLaserTemp.physicsBody.linearDamping = 0.0;
    birdLaserTemp.physicsBody.categoryBitMask = laserCategory;
    birdLaserTemp.physicsBody.contactTestBitMask = pipeCategory;
    birdLaserTemp.physicsBody.collisionBitMask = pipeCategory;
    
    
    [self addChild:birdLaserTemp];

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
-(void)dieScene{
    // Bird hit anything visible and dies, stop scene
    moving.speed = 0;
    gameOver = YES;
    [self removeAllActions];
    bird.physicsBody.collisionBitMask = worldCategory;
    bird.speed = 0;
    
    // Flash background if bird dies
    [self removeActionForKey:@"flash"];
    [self runAction:[SKAction sequence:@[[SKAction repeatAction:[SKAction sequence:@[[SKAction runBlock:^{
        self.backgroundColor = [SKColor colorWithRed:255.0/255.0 green:150.0/255.0 blue:180.0/255.0 alpha:1.0];
    }], [SKAction waitForDuration:0.1], [SKAction runBlock:^{
        self.backgroundColor = skyColor;
    }], [SKAction waitForDuration:0.1]]] count:4]]] withKey:@"flash"];
    [self runAction:birdDiesSoundAction];

}

-(void) showGameOverMenu{
    // Show final score
    scoreLabel.zPosition = 100;
    scoreLabel.fontSize = 300;
    scoreLabel.alpha = 1;
    scoreLabel.position = CGPointMake( CGRectGetMidX( self.frame ), CGRectGetHeight(self.frame) - 5 * scoreLabelMid / 4);
    
    SKLabelNode* scoreLabelText = [GameMenu showScoreLabelText];
    scoreLabelText.position = CGPointMake(scoreLabel.position.x, scoreLabel.position.y + scoreLabel.fontSize / 2);
    [self addChild:scoreLabelText];
    
    
    if ([self checkHighScore]){
        NSLog(@"yay");
    }
    
    
    SKLabelNode* highScoreLabelText = [GameMenu highScoreLabelText];
    highScoreLabelText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + highScoreLabelText.fontSize);
    [self addChild:highScoreLabelText];
    
    SKLabelNode* highScoreLabel = [GameMenu highScoreLabel:highScore];
    highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), highScoreLabelText.position.y - highScoreLabel.fontSize / 2 );
    [self addChild:highScoreLabel];

    // Save points
    [self savePoints];
    
    retryGameButton = [GameMenu showRetryMenu];
    [retryGameButton setPosition:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-150)];
    [self addChild:retryGameButton];
    
    shopGameButton = [GameMenu showShopMenu];
    [shopGameButton setPosition:CGPointMake(CGRectGetMidX(self.frame),retryGameButton.position.y-50)];
    [self addChild:shopGameButton];

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
    //pipeDown.physicsBody.contactTestBitMask = birdCategory | laserCategory;
    
    pipeTop = [GameBackGround addPipeTop];
    pipeTop.position = CGPointMake( 0, y + pipeDown.size.height + kVerticalPipeGap );
    pipeTop.physicsBody.categoryBitMask = pipeCategory;
   // pipeTop.physicsBody.contactTestBitMask = birdCategory | laserCategory;

    pipePair = [SKNode node];
    pipePair.position = CGPointMake( self.frame.size.width + pipeDown.size.width, 0 );
    pipePair.zPosition = -10;

    [pipePair addChild:pipeDown];
    [pipePair addChild:pipeTop];
    
    
    // Moving Pipes function
    CGFloat distanceToMove = self.frame.size.width + 2 * pipeDown.size.width;
    SKAction* movePipes = [SKAction moveByX:-distanceToMove y:0 duration:gameSpeed * distanceToMove];
    SKAction* removePipes = [SKAction removeFromParent];
    moveAndRemovePipes = [SKAction sequence:@[movePipes, removePipes]];
    
    [self addScoreNode];
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
    fireButton = [GameMenu showFireButton];
    [fireButton setPosition:CGPointMake(CGRectGetWidth(self.frame) / 3 + 10, CGRectGetHeight(self.frame) / 10 + 10)];
    fireButton.zPosition = 100;
    
    // Show amount of lasers left
    fireLabel = [SKLabelNode labelNodeWithFontNamed:@"VisitorTT2BRK"];
    fireLabel.text = [NSString stringWithFormat:@"%li", (long)numLasers];
    fireLabel.fontSize = 300;
    fireLabel.position = CGPointMake(CGRectGetWidth(self.frame) / 100, CGRectGetHeight(self.frame) / 100 - 75);
    fireLabel.zPosition = 120;
    [fireButton addChild:fireLabel];
    [self addChild:fireButton];
    
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
