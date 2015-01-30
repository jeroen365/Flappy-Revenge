//
//  GameScene.m
//  FlappyBirdXL
//
//  This scene presents the gameplay. Every game object is loaded from the imported header files and
//  positioned as well as animated in this scene.
//  It transitions to the shop.
//
//  Created by Jeroen van der Es on 20-12-14.
//  Copyright (c) 2014 Jeroen van der Es. All rights reserved.
//

#import "GameScene.h"
#import "GameBird.h"
#import "InterfaceButtons.h"
#import "GameMusic.h"
#import "GameMenu.h"
#import "GameMenuItems.h"
#import "GameBackGround.h"
#import "GameExplosion.h"
#import "GameViewController.h"
#import "ShopScene.h"
#import "BirdLaser.h"

@interface GameScene() <SKPhysicsContactDelegate> {
    // Scene textures/nodes
    GameBird* bird;
    SKColor* skyColor;
    SKTexture* groundTexture;
    SKTexture* skylineTexture;
    SKSpriteNode* pipeDown;
    SKSpriteNode* pipeTop;
    SKNode* pipePair;
    SKSpriteNode* birdLaser;
    GameExplosion* explosion;
    
    // Animations
    SKAction* moveGroundSpritesForever;
    SKAction* moveSkylineSpritesForever;
    
    // Menu labels
    SKSpriteNode* playGameButton;
    SKSpriteNode* playEasyModeButton;
    SKSpriteNode* fireButton;
    SKLabelNode* scoreLabel;

    // GamePlay variables
    BOOL startGame;
    BOOL gameOver;
    NSInteger score;
    NSInteger highScore;
    SKNode* moving;
    CGFloat gameSpeed;
    NSInteger kVerticalPipeGap;
    NSInteger numLasers;
    NSInteger easyGameTokens;
    CGFloat distanceToMove;
    
    // Music actions
    SKAction* moveAndRemovePipes;
    SKAction* laserFireSoundAction;
    SKAction* birdJumpSoundAction;
    SKAction* birdDiesSoundAction;
    SKAction* buttonPressSoundAction;
    SKAction* scoreSoundAction;
    SKAction* highScoreSoundAction;
    SKAction* explosionSoundAction;
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
    // Load music once to prevent lagg
    [self setupGameMusic];
    laserFireSoundAction = [SKAction playSoundFileNamed:@"LaserSound2.mp3" waitForCompletion:NO];
    birdJumpSoundAction = [SKAction playSoundFileNamed:@"JumpSound.wav" waitForCompletion:NO];
    birdDiesSoundAction = [SKAction playSoundFileNamed:@"BirdDied.wav" waitForCompletion:NO];
    buttonPressSoundAction = [SKAction playSoundFileNamed:@"ButtonPress.mp3" waitForCompletion:NO];
    scoreSoundAction = [SKAction playSoundFileNamed:@"Score.wav" waitForCompletion:NO];
    highScoreSoundAction = [SKAction playSoundFileNamed:@"HighScoreSound.mp3" waitForCompletion:NO];
    explosionSoundAction = [SKAction playSoundFileNamed:@"Explosion.wav" waitForCompletion:NO];
    
    [self initializeGame];
}

-(void)initializeGame{
    // Set global node for moving the world
    moving = [SKNode node];
    [self addChild:moving];
    
    // Setting variables
    gameSpeed = 0.005;
    distanceToMove = self.frame.size.width + 2 * pipeDown.size.width;
    
    // Set zero gravity to keep the bird in centre
    self.physicsWorld.gravity = CGVectorMake( 0.0, 0.0 );
    self.physicsWorld.contactDelegate = self;
    
    // Reset score
    score = 0;
    moving.speed = 1;
    startGame = NO;

    
    // Background color
    skyColor = [SKColor colorWithRed:113.0/255.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
    [self setBackgroundColor:skyColor];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = worldCategory;
    
    // Show UI
    [self addPlayGameButton];
    
    [self addScoreLabel];
    
    // Add Objects
    [self addBird];
    [bird flyIddle];
    [self addGround];
    [self addSkyline];
    
    // Get items from Inventory
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    numLasers = [Inventory integerForKey:@"numLasers"];
    highScore = [Inventory integerForKey:@"highScore"];
    [self checkForEasyGameTokens];
    if (numLasers > 0)
        [self addFireButton];

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
            // Fire laser is fireButton is touched while player has a laser
            if (numLasers > 0) {
                if ([node.name isEqualToString:@"fireButton"])
                    [self fireLaser];
            }
        }
        // Touches in the game over menu
        else if (gameOver == YES){
            // Retry button touched, reset scene
            if ([node.name isEqualToString:@"retryButton"]){
                [self runAction:buttonPressSoundAction];
                [self resetScene];
            }
            // Shop button touched, switch to shop 
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
            // Body B is the laser, use the laser's coordinates
            if (contact.bodyB.node.position.x > contact.bodyA.node.position.x)
                [self runExplosion:contact.bodyB.node.position.x and:contact.bodyB.node.position.y];
            // Body A is the laser, use the laser's coordinates
            else
                [self runExplosion:contact.bodyA.node.position.x and:contact.bodyA.node.position.y];
            [contact.bodyA.node removeFromParent];
            [contact.bodyB.node removeFromParent];
        }
        else if( ( contact.bodyA.categoryBitMask ) == birdCategory || ( contact.bodyB.categoryBitMask ) == birdCategory ) {
            // Bird hit anything visible and dies, stop scene
            [self stopScene];
            [self hitAnimation];
            [self showGameOverMenu];
        }
    }
}

-(void) updateScore{
    score++;
    [self runAction:scoreSoundAction];
    // If score is to large, lower the font
    if (score >= 10){
        scoreLabel.fontSize = 550;
        if (score >= 100){
            scoreLabel.fontSize = 400;
        }
    }
    // Update the scorelabel
    scoreLabel.text = [NSString stringWithFormat:@"%ld", score];
}

-(void) savePointsToInventory{
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    NSInteger totalPoints = [Inventory integerForKey:@"totalPoints"];
    totalPoints += score;
    [Inventory setInteger:totalPoints forKey:@"totalPoints"];
    [Inventory synchronize];

}

-(void) beginGame{
    // Start moving the world
    startGame = YES;
    moving.speed = 1;
    [playGameButton removeFromParent];
    [playEasyModeButton removeFromParent];
    [self removeAllActions];
    [bird removeActionForKey:@"flyIddle"];
    self.physicsWorld.gravity = CGVectorMake( 0.0, -7 );
    [self generateWorld];
}

-(void) resetScene{
    // Remove current scene and re-initialize
    gameOver = NO;
    [self removeAllChildren];
    [self initializeGame];
}

-(void)generateWorld {
    // Spawn pipes forever
    SKAction* spawn = [SKAction performSelector:@selector(spawnPipes) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:1.5];
    SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
    SKAction* spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
    [self runAction:spawnThenDelayForever];
}


-(void) checkForEasyGameTokens{
    // Loads easyGameTokens
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    easyGameTokens = [Inventory integerForKey:@"easyGameTokens"];
    // If any tokens, widen the pipeGap
    if (easyGameTokens > 0){
        kVerticalPipeGap = 170;
        [playGameButton removeFromParent];
        [self addPlayEasyModeButton];
        easyGameTokens -= 1;
        [Inventory setInteger:easyGameTokens forKey:@"easyGameTokens"];
        [Inventory synchronize];
    }
    else
        kVerticalPipeGap = 140;
}
-(void)stopScene{
    // Stops animating the scene
    moving.speed = 0;
    gameOver = YES;
    [scoreLabel removeFromParent];
    [self removeAllActions];
    bird.physicsBody.collisionBitMask = worldCategory;
    bird.speed = 0;
    
}

-(BOOL) checkHighScore{
    // Load highscore
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    // If highscore is broken, set new highscore
    if (score> highScore){
        highScore = score;
        [Inventory setInteger:highScore forKey:@"highScore"];
        return YES;
    }
    return NO;
}

-(void) showGameOverMenu{
    // Check for highscore
    if ([self checkHighScore])
        [self runAction:highScoreSoundAction];
    
    [self savePointsToInventory];
    
    // Initializes and shows gameOverMenu
    GameMenu* gameOverMenu = [[GameMenu alloc] initWithSize: CGSizeMake(CGRectGetMidX(self.frame) / 2, CGRectGetHeight(self.frame) - 200) and:score and:highScore];
    gameOverMenu.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) );
    gameOverMenu.zPosition = 100;
    [self addChild:gameOverMenu];
}

-(void) hitAnimation{
    // Flash background if bird dies
    [self removeActionForKey:@"flash"];
    [self runAction:[SKAction sequence:@[[SKAction repeatAction:[SKAction sequence:@[[SKAction runBlock:^{
        self.backgroundColor = [SKColor colorWithRed:255.0/255.0 green:150.0/255.0 blue:180.0/255.0 alpha:1.0];
    }], [SKAction waitForDuration:0.1], [SKAction runBlock:^{
        self.backgroundColor = skyColor;
    }], [SKAction waitForDuration:0.1]]] count:4]]] withKey:@"flash"];
    
    [self runAction:birdDiesSoundAction];
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
    // Load skyline texture
    skylineTexture = [GameBackGround loadSkyline];
    
    [self loadAnimationSkyline];
    
    // Places several sprites next to eachother to fill the screen
    for( int i = 0; i < 2 + self.frame.size.width / ( skylineTexture.size.width ); ++i ) {
        SKSpriteNode* skylineSprite = [SKSpriteNode spriteNodeWithTexture:skylineTexture];
        skylineSprite.zPosition = -20;
        skylineSprite.position = CGPointMake(i * skylineSprite.size.width, groundTexture.size.height / 2);
        [skylineSprite runAction: moveSkylineSpritesForever];
        [moving addChild:skylineSprite];
    }
}

-(void) loadAnimationSkyline{
    // Moves skylineSprites to the left then resets them, forever
    SKAction* moveSkylineSprite = [SKAction moveByX:-skylineTexture.size.width*2 y:0 duration:0.05 * skylineTexture.size.width*2];
    SKAction* resetSkylineSprite = [SKAction moveByX:skylineTexture.size.width*2 y:0 duration:0];
    moveSkylineSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSkylineSprite, resetSkylineSprite]]];

}


-(float)randomValueBetween:(float)low andValue: (float)high {
    return (((float)arc4random()/ 0xFFFFFFFFu)*(high - low)) + low;
    
}


-(void)spawnPipes {
    
    // Generate random y to generate random height pipes
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
    // Add both pipes to 1 pair node
    pipePair = [SKNode node];
    pipePair.position = CGPointMake( self.frame.size.width + pipeDown.size.width, 0 );
    pipePair.zPosition = -10;
    
    [pipePair addChild:pipeDown];
    [pipePair addChild:pipeTop];
    
    // Animate the pipes
    [self loadAnimationPipes];
    [pipePair runAction:moveAndRemovePipes];
    [moving addChild:pipePair];
 
}

-(void) loadAnimationPipes{
    // Moving Pipes function
    SKAction* movePipes = [SKAction moveByX:-distanceToMove y:0 duration:gameSpeed * distanceToMove];
    SKAction* removePipes = [SKAction removeFromParent];
    moveAndRemovePipes = [SKAction sequence:@[movePipes, removePipes]];

}

-(void) addScoreNode{
    // Load scoreNode
    SKNode* scoreNode = [SKNode node];
    scoreNode.position = CGPointMake( pipeDown.size.width + bird.size.width / 2, CGRectGetMidY( self.frame ) );
    scoreNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake( pipeTop.size.width, self.frame.size.height )];
    scoreNode.physicsBody.dynamic = NO;
    scoreNode.physicsBody.categoryBitMask = scoreCategory;
    scoreNode.physicsBody.contactTestBitMask = birdCategory;
    
    // Add scoreNode to the pipePair
    [pipePair addChild:scoreNode];
}

-(void)addGround{
    // Load ground texture
    groundTexture = [GameBackGround loadGround];
    
    [self loadAnimationGround];
    
    // Places several sprites next to eachother to fill the screen
    for( int i = 0; i < 2 + self.frame.size.width / ( groundTexture.size.width ); ++i ) {
        SKSpriteNode* groundSprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
        groundSprite.position = CGPointMake(i * groundSprite.size.width, groundTexture.size.height / 2);
        [groundSprite runAction:moveGroundSpritesForever];
        groundSprite.name = @"world";
        [moving addChild:groundSprite];
    }
    [self addGroundPhysics];

}

-(void) loadAnimationGround{
     // Moves groundSprites to the left then resets them, forever
    SKAction* moveGroundSprite = [SKAction moveByX:-groundTexture.size.width * 2 y:0 duration:gameSpeed * groundTexture.size.width*2];
    SKAction* resetGroundSprite = [SKAction moveByX:groundTexture.size.width * 2 y:0 duration:0];
    moveGroundSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite, resetGroundSprite]]];
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
    // Load fireButton node
    fireButton = [InterfaceButtons showFireButton:numLasers];
    [fireButton setPosition:CGPointMake(CGRectGetWidth(self.frame) / 3 + 10, CGRectGetHeight(self.frame) / 10 + 10)];
    fireButton.zPosition = 100;
    [self addChild:fireButton];
    
}
-(void) addPlayGameButton{
    playGameButton = [InterfaceButtons showPlayGameButton];
    [playGameButton setPosition:CGPointMake(CGRectGetMidX(self.frame)+5,CGRectGetMidY(self.frame)-40)];
    [self addChild:playGameButton];
}

-(void) addPlayEasyModeButton{
    playEasyModeButton = [InterfaceButtons showPlayEasyModeButton];
    [playEasyModeButton setPosition:CGPointMake(CGRectGetMidX(self.frame)+5,CGRectGetMidY(self.frame)-40)];
    [self addChild:playEasyModeButton];
}

-(void) addScoreLabel{
    scoreLabel = [GameMenuItems scoreLabel:score];
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidX(self.frame) - scoreLabel.fontSize / 4 );
    [self addChild:scoreLabel];
}
-(void) fireLaser{
    // Get amount of lasers
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    numLasers = [Inventory integerForKey:@"numLasers"];
    
    if (numLasers > 0){
        [self createLaser];
        [self runAction:laserFireSoundAction];
        numLasers--;
        
        // Fire laser
        birdLaser.physicsBody.velocity = CGVectorMake(0, 0);
        [birdLaser.physicsBody applyImpulse:CGVectorMake(180, 0)];
        
        [self updateFireButton];
        [Inventory setInteger:numLasers forKey:@"numLasers"];
    }
}

-(void) updateFireButton{
    // Update the counter on the fireButton
    [fireButton removeFromParent];
    [self addFireButton];
}

-(void) createLaser{
    // Load birdLaserNode
    birdLaser = [BirdLaser loadLaser];
    birdLaser.position = CGPointMake(bird.position.x+birdLaser.size.width/2, bird.position.y);
    birdLaser.physicsBody.categoryBitMask = laserCategory;
    birdLaser.physicsBody.contactTestBitMask = pipeCategory;
    birdLaser.physicsBody.collisionBitMask = pipeCategory;
    
    [self addChild:birdLaser];
}

-(void) runExplosion:(CGFloat)x and:(CGFloat)y{
    explosion = [GameExplosion loadExplosion];
    explosion.position = CGPointMake(x + explosion.size.width / 2, y);
    [self animateExplosion];
    [self addChild:explosion];
}

-(void) animateExplosion{
    SKAction* moveExplosion = [SKAction moveByX:-distanceToMove y:0 duration:gameSpeed * distanceToMove];
    [explosion runAction:moveExplosion];
    [self runAction:explosionSoundAction];
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
    //Initialize our player pointing to the path to our resource
    player = [GameMusic setupGameMusic];
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

CGFloat clamp(CGFloat min, CGFloat max, CGFloat value) {
    // Creates value to rotate the bird as he moves
    if( value > max ) {
        return max;
    } else if( value < min ) {
        return min;
    } else {
        return value;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    // Rotates bird according to velocity
    if(startGame == YES)
        bird.zRotation = clamp( -1, 0.5, bird.physicsBody.velocity.dy * ( bird.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) );
}
@end
