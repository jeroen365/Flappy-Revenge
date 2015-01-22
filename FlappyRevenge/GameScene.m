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
#import "GameViewController.h"
#import "ShopScene.h"

@interface GameScene() <SKPhysicsContactDelegate> {
    GameBird* bird;
    SKColor* skyColor;
    SKTexture* groundTexture;
    SKTexture* skylineTexture;
    SKTexture* pipeTextureDown;
    SKTexture* pipeTextureTop;
    SKAction* moveAndRemovePipes;
    SKSpriteNode* playGameButton;
    SKSpriteNode* retryGameButton;
    SKSpriteNode* shopGameButton;
    NSInteger score;
    NSInteger totalPoints;
    SKLabelNode* scoreLabel;
    CGFloat scoreLabelMid;
    BOOL startGame;
    BOOL gameOver;
    SKNode* moving;
    CGFloat gameSpeed;
    
}


@end



@implementation GameScene

static const uint32_t birdCategory = 1 << 0;
static const uint32_t worldCategory = 1 << 1;
static const uint32_t pipeCategory = 1 << 2;
static const uint32_t scoreCategory = 1 << 3;

static NSInteger const kVerticalPipeGap = 140;


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
    gameSpeed = 0.008;
   
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
    
    // Add bird
    bird = [GameBird bird];
    bird.position = CGPointMake((self.frame.size.width / 2.5), CGRectGetMidY(self.frame));
    bird.speed = 1;
    bird.physicsBody.categoryBitMask = birdCategory;
    bird.physicsBody.collisionBitMask = worldCategory | pipeCategory;
    bird.physicsBody.contactTestBitMask = worldCategory | pipeCategory;
    [self addChild:bird];
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
        self.physicsWorld.gravity = CGVectorMake( 0.0, -6 );
        [self generateWorld];
        
        
    }
    
    if(moving.speed > 0 & startGame == YES){
        [bird fly];
    }
    
    else if(gameOver == YES){
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInNode:self];
            NSLog(@"position %f, %f", location.x, location.y);
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
        else {
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
    }
}

-(void) resetScene{
    
    gameOver = NO;
    [self removeAllChildren];
    [self beginGame];
}

-(void)generateWorld {
    SKAction* spawn = [SKAction performSelector:@selector(spawnPipes) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:2.2];
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
    NSUserDefaults* Points = [NSUserDefaults standardUserDefaults];
    NSInteger totalPointsTemp = [Points integerForKey:@"totalPoints"];
    totalPoints = totalPointsTemp;
    totalPoints += score;
    NSLog(@"totalPoints %ld",(long)totalPoints);
    [Points setInteger:totalPoints forKey:@"totalPoints"];
    [Points synchronize];

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

-(void)addSkyline{
    // Load skyline
    skylineTexture = [SKTexture textureWithImageNamed:@"Skyline"];
    skylineTexture.filteringMode = SKTextureFilteringNearest;
    
    SKAction* moveSkylineSprite = [SKAction moveByX:-skylineTexture.size.width*2 y:0 duration:0.1 * skylineTexture.size.width*2];
    SKAction* resetSkylineSprite = [SKAction moveByX:skylineTexture.size.width*2 y:0 duration:0];
    SKAction* moveSkylineSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSkylineSprite, resetSkylineSprite]]];
    
    
    for( int i = 0; i < 2 + self.frame.size.width / ( skylineTexture.size.width ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:skylineTexture];
        sprite.zPosition = -20;
        sprite.position = CGPointMake(i * sprite.size.width, groundTexture.size.height / 2);

        [sprite runAction: moveSkylineSpritesForever];
        sprite.name = @"world";
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
    
    SKNode* pipePair = [SKNode node];
    pipePair.position = CGPointMake( self.frame.size.width + pipeTextureDown.size.width, 0 );
    pipePair.zPosition = -10;
    
    CGFloat y = (arc4random() % (NSInteger)( self.frame.size.height / 3 ) + groundTexture.size.height / 2);
    
   // float y = [self randomValueBetween:groundTexture.size.height / 2 andValue: self.frame.size.height / 2];
    
    SKSpriteNode* pipe1 = [SKSpriteNode spriteNodeWithTexture:pipeTextureDown];
    [pipe1 setScale:2];
    pipe1.name = @"world";
    pipe1.position = CGPointMake( 0, y );
    pipe1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
    pipe1.physicsBody.dynamic = NO;
    pipe1.physicsBody.categoryBitMask = pipeCategory;
    pipe1.physicsBody.contactTestBitMask = birdCategory;
    [pipePair addChild:pipe1];
    
    SKSpriteNode* pipe2 = [SKSpriteNode spriteNodeWithTexture:pipeTextureTop];
    [pipe2 setScale:2];
    pipe2.name = @"world";
    pipe2.position = CGPointMake( 0, y + pipe1.size.height + kVerticalPipeGap );
    pipe2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe2.size];
    pipe2.physicsBody.dynamic = NO;
    pipe2.physicsBody.categoryBitMask = pipeCategory;
    pipe2.physicsBody.contactTestBitMask = birdCategory;

    
    [pipePair addChild:pipe2];
    
    
    // Moving Pipes function
    CGFloat distanceToMove = self.frame.size.width + 2 * pipeTextureDown.size.width;
    SKAction* movePipes = [SKAction moveByX:-distanceToMove y:0 duration:gameSpeed * distanceToMove];
    SKAction* removePipes = [SKAction removeFromParent];
    moveAndRemovePipes = [SKAction sequence:@[movePipes, removePipes]];
    
    // Score node
    SKNode* contactNode = [SKNode node];
    contactNode.position = CGPointMake( pipe1.size.width + bird.size.width / 2, CGRectGetMidY( self.frame ) );
    contactNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake( pipe2.size.width, self.frame.size.height )];
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

@end
