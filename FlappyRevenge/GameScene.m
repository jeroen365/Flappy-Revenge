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
    GameBird* bird;
    NSMutableArray* birdLasers;
    SKColor* skyColor;
    SKTexture* groundTexture;
    SKTexture* skylineTexture;
    SKTexture* pipeTextureDown;
    SKSpriteNode* pipeDown;
    SKTexture* pipeTextureTop;
    SKSpriteNode* pipeTop;
    SKNode* pipePair;
    SKAction* moveAndRemovePipes;
    SKSpriteNode* playGameButton;
    SKSpriteNode* retryGameButton;
    SKSpriteNode* shopGameButton;
    SKSpriteNode* fireButton;
    SKLabelNode *fireLabel;
    SKSpriteNode* birdLaser;
    NSInteger score;
    NSInteger totalPoints;
    SKLabelNode* scoreLabel;
    CGFloat scoreLabelMid;
    BOOL startGame;
    BOOL gameOver;
    SKNode* moving;
    CGFloat gameSpeed;
    NSInteger kVerticalPipeGap;
    NSInteger numLasers;
    
}


@end



@implementation GameScene

static const uint32_t birdCategory = 1 << 0;
static const uint32_t worldCategory = 1 << 1;
static const uint32_t pipeCategory = 1 << 2;
static const uint32_t scoreCategory = 1 << 3;
static const uint32_t laserCategory = 1 << 4;





-(void)didMoveToView:(SKView *)view {
    [self beginGame];
}

-(void)beginGame{
    // initialize world
       
    // Zero gravity to keep the bird in centre
    self.physicsWorld.gravity = CGVectorMake( 0.0, 0.0 );
    self.physicsWorld.contactDelegate = self;
    
    // Set nodes for moving the world
    moving = [SKNode node];
    [self addChild:moving];
    
    // lower is faster
    gameSpeed = 0.005;
    
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
    score = 0;
    
    // Background color
    skyColor = [SKColor colorWithRed:113.0/255.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
    [self setBackgroundColor:skyColor];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = worldCategory;
    
    // show menu
    playGameButton = [GameMenu showGameMenu];
    [playGameButton setPosition:CGPointMake(CGRectGetMidX(self.frame)+5,CGRectGetMidY(self.frame)-40)];
    [self addChild:playGameButton];
    
    GameMenu* scoreLabelTemp = [[GameMenu alloc] init];
    scoreLabel = [scoreLabelTemp scoreLabel:score];
    scoreLabelMid = scoreLabel.fontSize / 4;
    scoreLabel.position = CGPointMake( CGRectGetMidX( self.frame ), CGRectGetMidX(self.frame) - scoreLabelMid );
    [self addChild:scoreLabel];
    

    [self addBird];
    [bird flyIddle];
    

    [self addGround];
    [self addSkyline];
    
    moving.speed = 1;
    startGame = NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (startGame == NO){
        // if screen is touched while playbutton shows
        
        // Start moving the world
        [self pressedButton:playGameButton];
        startGame = YES;
        moving.speed = 1;
        [playGameButton removeFromParent];
        [self removeAllActions];
        [bird removeActionForKey:@"flyIddle"];
        self.physicsWorld.gravity = CGVectorMake( 0.0, -7 );
        [self addLasers];
        [self generateWorld];
        
        
    }
    
    if(moving.speed > 0 & startGame == YES){
        [bird fly];
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
                [self resetScene];
            }
            if ([shopGameButton containsPoint:location]){
                // initiate switch to shopscene
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
        if( ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory ) {
            // Bird passed pipe
            score++;
            if (score >= 10){
                scoreLabel.fontSize = 550;
                if (score >= 100){
                    scoreLabel.fontSize = 400;
                }
            }
            scoreLabel.text = [NSString stringWithFormat:@"%ld", score];
        }
//        else if (([contact.bodyA.node.name isEqualToString:@"laser"]) || ([contact.bodyA.node.name isEqualToString:@"pipe"] && [contact.bodyB.node.name isEqualToString:@"laser"])){
//            NSLog(@"hit1");
//            [contact.bodyA.node removeFromParent];
//            [contact.bodyB.node removeFromParent];
//        }
        else {
            [self dieScene];
        }
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

-(void) pressedButton:(SKSpriteNode*)button{
    SKAction* pressButton = [SKAction runBlock:^{ [button setPosition:CGPointMake(button.position.x, button.position.y -10)];}];
    SKAction* unPressButton = [SKAction runBlock:^{ [button setPosition:CGPointMake(button.position.x, button.position.y +10)];}];
    
    SKAction* runAnimation = [SKAction sequence:@[pressButton, [SKAction waitForDuration:10],unPressButton]];
    
    [button runAction:runAnimation];
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
        for (SKSpriteNode* birdLaserTemp in birdLasers) {
            if (birdLaserTemp.hidden) {
                continue;
            }
            
            if ([birdLaserTemp intersectsNode:pipeDown]) {
                birdLaserTemp.hidden = YES;
                [pipeDown removeFromParent];
                
                NSLog(@"you just destroyed a pipedown");
                NSLog(@"name %@" , birdLaserTemp.name);
                continue;
            }
            else if ([birdLaserTemp intersectsNode:pipeTop]){
                birdLaserTemp.hidden = YES;
                [pipeTop removeFromParent];
                
                NSLog(@"you just destroyed a pipeup");
                continue;
            }
        }
        
    }
    

}

-(void) fireLaser{
    SKSpriteNode* birdLaserTemp = [birdLasers objectAtIndex: numLasers - 1];
    numLasers--;
    
    birdLaserTemp.position = CGPointMake(bird.position.x+birdLaserTemp.size.width/2, bird.position.y+0);
    birdLaserTemp.hidden = NO;
    [birdLaserTemp removeAllActions];
    
    CGPoint location = CGPointMake(self.frame.size.width, bird.position.y);
    
    SKAction* laserMoveAction = [SKAction moveTo:location duration:0.5];
    
    SKAction* laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
        // animation done
        birdLaserTemp.hidden = YES;
    }];
    
    SKAction* moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction, laserDoneAction]];
    [birdLaserTemp runAction:moveLaserActionWithDone withKey: @"laserFired"];
    fireLabel.text = [NSString stringWithFormat:@"%ld",numLasers];
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    [Inventory setInteger:numLasers forKey:@"numLasers"];
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
    
    // Show final score
    scoreLabel.zPosition = 100;
    scoreLabel.alpha = 1;
    scoreLabel.position = CGPointMake( CGRectGetMidX( self.frame ), CGRectGetMidX(self.frame) - (scoreLabelMid / 2));
    
    // Save points
    [self savePoints];
    
    retryGameButton = [GameMenu showRetryMenu];
    [retryGameButton setPosition:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-50)];
    [self addChild:retryGameButton];
    
    shopGameButton = [GameMenu showShopMenu];
    [shopGameButton setPosition:CGPointMake(CGRectGetMidX(self.frame),retryGameButton.position.y-50)];
    [self addChild:shopGameButton];
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
    pipeTextureDown = [SKTexture textureWithImageNamed:@"Pipe1"];
    pipeTextureDown.filteringMode = SKTextureFilteringNearest;
    pipeTextureTop = [SKTexture textureWithImageNamed:@"Pipe2"];
    pipeTextureTop.filteringMode = SKTextureFilteringNearest;
    
    pipePair = [SKNode node];
    pipePair.position = CGPointMake( self.frame.size.width + pipeTextureDown.size.width, 0 );
    pipePair.zPosition = -10;

    //CGFloat y = (arc4random() % (NSInteger)( self.frame.size.height / 3 ) + groundTexture.size.height / 2);
    
    float y = [self randomValueBetween:CGRectGetHeight(self.frame) / 15  andValue:  CGRectGetHeight(self.frame) /3];
    
    pipeDown = [SKSpriteNode spriteNodeWithTexture:pipeTextureDown];
    [pipeDown setScale:2];
    pipeDown.position = CGPointMake( 0, y );
    pipeDown.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipeDown.size];
    pipeDown.name = @"pipe";
    pipeDown.physicsBody.dynamic = NO;
    pipeDown.physicsBody.categoryBitMask = pipeCategory;
    pipeDown.physicsBody.contactTestBitMask = birdCategory & laserCategory;

    [pipePair addChild:pipeDown];
    
    pipeTop = [SKSpriteNode spriteNodeWithTexture:pipeTextureTop];
    [pipeTop setScale:2];
    pipeTop.position = CGPointMake( 0, y + pipeDown.size.height + kVerticalPipeGap );
    pipeTop.name = @"pipe";
    pipeTop.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipeTop.size];
    pipeTop.physicsBody.dynamic = NO;
    pipeTop.physicsBody.categoryBitMask = pipeCategory;
    pipeTop.physicsBody.contactTestBitMask = birdCategory & laserCategory;


    
    [pipePair addChild:pipeTop];
    
    
    // Moving Pipes function
    CGFloat distanceToMove = self.frame.size.width + 2 * pipeTextureDown.size.width;
    SKAction* movePipes = [SKAction moveByX:-distanceToMove y:0 duration:gameSpeed * distanceToMove];
    SKAction* removePipes = [SKAction removeFromParent];
    moveAndRemovePipes = [SKAction sequence:@[movePipes, removePipes]];
    
    // Score node
    SKNode* contactNode = [SKNode node];
    contactNode.position = CGPointMake( pipeDown.size.width + bird.size.width / 2, CGRectGetMidY( self.frame ) );
    contactNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake( pipeTop.size.width, self.frame.size.height )];
    contactNode.physicsBody.dynamic = NO;
    contactNode.physicsBody.categoryBitMask = scoreCategory;
    contactNode.physicsBody.contactTestBitMask = birdCategory;
    
    [pipePair addChild:contactNode];
    
    [pipePair runAction:moveAndRemovePipes];
    
    [moving addChild:pipePair];
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
    
    // Create ground physics container
    
    SKNode* groundBody = [SKNode node];
    groundBody.position = CGPointMake(0, groundTexture.size.height /2);
    groundBody.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width * 2, groundTexture.size.height)];
    groundBody.physicsBody.dynamic = NO;
    groundBody.physicsBody.categoryBitMask = worldCategory;
    groundBody.physicsBody.collisionBitMask = birdCategory;
    [self addChild:groundBody];

}
-(void) addLasers{
    NSUserDefaults* Inventory = [NSUserDefaults standardUserDefaults];
    numLasers = [Inventory integerForKey:@"numLasers"];
    birdLasers = [[NSMutableArray alloc] initWithCapacity:numLasers];
    for (int i = 0; i < numLasers; ++i) {
        birdLaser = [SKSpriteNode spriteNodeWithImageNamed:@"Laserbeam"];
        birdLaser.hidden = YES;
        birdLaser.name = @"laser";
        birdLaser.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:birdLaser.size];
        birdLaser.physicsBody.dynamic = NO;
        birdLaser.physicsBody.categoryBitMask = laserCategory;
        birdLaser.physicsBody.collisionBitMask = pipeCategory;

        [birdLasers addObject:birdLaser];
        [self addChild:birdLaser];
    }
    if (numLasers > 0){
        [self addFireButton];
    }
}

-(void) addFireButton{
    fireButton = [GameMenu showFireButton];
    [fireButton setPosition:CGPointMake(CGRectGetWidth(self.frame) / 3 + 10, CGRectGetHeight(self.frame) / 10 + 10)];
    fireButton.zPosition = 100;
    fireLabel = [SKLabelNode labelNodeWithFontNamed:@"VisitorTT2BRK"];
    fireLabel.text = [NSString stringWithFormat:@"%li", (long)numLasers];
    fireLabel.fontSize = 300;
    fireLabel.position = CGPointMake(CGRectGetWidth(self.frame) / 100, CGRectGetHeight(self.frame) / 100 - 75);
    fireLabel.zPosition = 120;
    [fireButton addChild:fireLabel];
    [self addChild:fireButton];
    
}
@end
