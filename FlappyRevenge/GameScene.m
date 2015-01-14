//
//  GameScene.m
//  FlappyBirdXL
//
//  Created by Jeroen van der Es on 20-12-14.
//  Copyright (c) 2014 Jeroen van der Es. All rights reserved.
//

#import "GameScene.h"
#import "GameBird.h"
#import "GamePipes.h"
#import "StartGameMenu.h"

@interface GameScene() <SKPhysicsContactDelegate, StartGameMenuDelegate> {
    GameBird* bird;
    SKColor* skyColor;
    SKTexture* groundTexture;
    SKTexture* skylineTexture;
    SKTexture* pipeTexture1;
    SKTexture* pipeTexture2;
    SKAction* moveAndRemovePipes;
    StartGameMenu* startGameMenu;
    BOOL* gameStarted;
    SKNode* moving;
}


@end



@implementation GameScene

static const uint32_t birdCategory = 1 << 0;
static const uint32_t worldCategory = 1 << 1;
static const uint32_t pipeCategory = 1 << 2;

static NSInteger const kVerticalPipeGap = 140;

-(void)didMoveToView:(SKView *)view {
    
    // initialize world
    self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 );
    self.physicsWorld.contactDelegate = self;
    moving = [SKNode node];
    [self addChild:moving];
    
    // Background color
    skyColor = [SKColor colorWithRed:113.0/255.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
    [self setBackgroundColor:skyColor];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    gameStarted = NO;

    
    // Add bird
    bird = [GameBird bird];
    bird.position = CGPointMake((self.frame.size.width / 2.5), CGRectGetMidY(self.frame));
    bird.physicsBody.categoryBitMask = birdCategory;
    bird.physicsBody.collisionBitMask = worldCategory | pipeCategory;
    bird.physicsBody.contactTestBitMask = worldCategory | pipeCategory;
    [self addChild:bird];
    
    
    [self addGround];
    [self addSkyline];
    [self addPipes];
    [self generateWorld];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(moving.speed > 0){
        [bird fly];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if(moving.speed > 0){
        moving.speed = 0;
        
        bird.physicsBody.collisionBitMask = worldCategory;
        bird.speed = 0;

        // Flash background if contact is detected
        [self removeActionForKey:@"flash"];
        [self runAction:[SKAction sequence:@[[SKAction repeatAction:[SKAction sequence:@[[SKAction runBlock:^{
            self.backgroundColor = [SKColor colorWithRed:255.0/255.0 green:150.0/255.0 blue:180.0/255.0 alpha:1.0];
        }], [SKAction waitForDuration:0.1], [SKAction runBlock:^{
            self.backgroundColor = skyColor;
        }], [SKAction waitForDuration:0.1]]] count:4]]] withKey:@"flash"];
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
        NSLog(@" skyline height %f", sprite.position.y);
        [sprite runAction: moveSkylineSpritesForever];
        [moving addChild:sprite];
    }
}


-(void)addPipes{
    // Create pipes
    
    pipeTexture1 = [SKTexture textureWithImageNamed:@"Pipe1"];
    pipeTexture1.filteringMode = SKTextureFilteringNearest;
    pipeTexture2 = [SKTexture textureWithImageNamed:@"Pipe2"];
    pipeTexture2.filteringMode = SKTextureFilteringNearest;
    
    SKNode* pipePair = [SKNode node];
    pipePair.position = CGPointMake( self.frame.size.width + pipeTexture1.size.width * 2, 0 );
    pipePair.zPosition = -10;
    
    CGFloat y = arc4random() % (NSInteger)( self.frame.size.height / 3 );
    
    SKSpriteNode* pipe1 = [SKSpriteNode spriteNodeWithTexture:pipeTexture1];
    [pipe1 setScale:2];
    pipe1.position = CGPointMake( 0, y );
    pipe1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
    pipe1.physicsBody.dynamic = NO;
    [pipePair addChild:pipe1];
    
    SKSpriteNode* pipe2 = [SKSpriteNode spriteNodeWithTexture:pipeTexture2];
    [pipe2 setScale:2];
    pipe2.position = CGPointMake( 0, y + pipe1.size.height + kVerticalPipeGap );
    pipe2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe2.size];
    pipe2.physicsBody.dynamic = NO;
    [pipePair addChild:pipe2];
    
    SKAction* movePipes = [SKAction repeatActionForever:[SKAction moveByX:-1 y:0 duration:0.02]];

    [pipePair runAction:movePipes];
    
}

- (void) initializeStartGameLayer
{
    startGameMenu = [[StartGameMenu alloc]initWithSize:self.size];
    startGameMenu.userInteractionEnabled = YES;
    startGameMenu.delegate = self;
}

-(float)randomValueBetween:(float)low andValue: (float)high {
    return (((float)arc4random()/ 0xFFFFFFFFu)*(high - low)) + low;
    
}

-(void)generateWorld
    {
    CGFloat distanceToMove = self.frame.size.width + 2 * pipeTexture1.size.width;
    SKAction* movePipes = [SKAction moveByX:-distanceToMove y:0 duration:0.01 * distanceToMove];
    SKAction* removePipes = [SKAction removeFromParent];
    moveAndRemovePipes = [SKAction sequence:@[movePipes, removePipes]];
    
    SKAction* spawn = [SKAction performSelector:@selector(spawnPipes) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:5.0];
    SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
    SKAction* spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
    [self runAction:spawnThenDelayForever];
}

-(void)spawnPipes {
    SKNode* pipePair = [SKNode node];
    pipePair.position = CGPointMake( self.frame.size.width + pipeTexture1.size.width, 0 );
    pipePair.zPosition = -10;
    
    CGFloat y = (arc4random() % (NSInteger)( self.frame.size.height / 3 ) + groundTexture.size.height / 2);
    
   // float y = [self randomValueBetween:groundTexture.size.height / 2 andValue: self.frame.size.height / 2];
    
    SKSpriteNode* pipe1 = [SKSpriteNode spriteNodeWithTexture:pipeTexture1];
    [pipe1 setScale:2];
    pipe1.position = CGPointMake( 0, y );
    pipe1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
    pipe1.physicsBody.dynamic = NO;
    pipe1.physicsBody.categoryBitMask = pipeCategory;
    pipe1.physicsBody.contactTestBitMask = birdCategory;
    [pipePair addChild:pipe1];
    
    SKSpriteNode* pipe2 = [SKSpriteNode spriteNodeWithTexture:pipeTexture2];
    [pipe2 setScale:2];
    pipe2.position = CGPointMake( 0, y + pipe1.size.height + kVerticalPipeGap );
    pipe2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe2.size];
    pipe2.physicsBody.dynamic = NO;
    pipe2.physicsBody.categoryBitMask = pipeCategory;
    pipe2.physicsBody.contactTestBitMask = birdCategory;
    [pipePair addChild:pipe2];
    
    [pipePair runAction:moveAndRemovePipes];
    
    [moving addChild:pipePair];
}

-(void)addGround{
    // Load ground
    groundTexture = [SKTexture textureWithImageNamed:
                                @"Ground"];
    groundTexture.filteringMode = SKTextureFilteringNearest;
    
    SKAction* moveGroundSprite = [SKAction moveByX:-groundTexture.size.width * 2 y:0 duration:0.01 * groundTexture.size.width*2];
    SKAction* resetGroundSprite = [SKAction moveByX:groundTexture.size.width * 2 y:0 duration:0];
    SKAction* moveGroundSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite, resetGroundSprite]]];
    
    
    for( int i = 0; i < 2 + self.frame.size.width / ( groundTexture.size.width ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
        sprite.position = CGPointMake(i * sprite.size.width, groundTexture.size.height / 2);
        NSLog(@"ground height %f", sprite.position.y);
        NSLog(@"ground text height %f", groundTexture.size.height);
        [sprite runAction:moveGroundSpritesForever];
        
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
    if(moving > 0){
        bird.zRotation = clamp( -1, 0.5, bird.physicsBody.velocity.dy * ( bird.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) );
    }
}

@end
