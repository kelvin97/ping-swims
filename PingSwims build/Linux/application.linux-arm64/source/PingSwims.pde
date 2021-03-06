import ddf.minim.*;
PowerUp powerup;
Pinguin thePinguin;
Obstacles ship;
Obstacles ice;
ScoreScreen score;
Encounter encounter;
GameState GameStateManager;

ScoreSave save;
DeveloperTools tools;
Bullet[] bullets;
Menu menu;
Snow snow;

int index;

//point pickup
int scoreForPoint = 15;
int pickupScore;
int seconde = 60;
int pointcountdown;
float scoreHeightAlt;
boolean isCollected = false;
float pointX;

PFont font;
Level l1;
int lifecounter;
Minim minim;

AudioPlayer 
  song, 
  playSong, 
  damage, 
  point, 
  shoot, 
  bulletHit, 
  star_pickup, 
  star_hit, 
  gun_pickup, 
  bubble_pickup, 
  gameOver_sound, 
  selectSound;


Timer startTimer;
boolean isNotDead = false;

float //Ship spawn values
  shipHeight, 
  shipWidth, 
  shipSpawnTime;
String shipType;

float //ice spawn values
  iceHeight, 
  iceWidth, 
  iceSpawnTime;
String iceType;

float //powerup spawn values
  powerupWidth, 
  powerupHeight, 
  xPos, 
  yPos, 
  powerupSpawnTime;
int powerupKind;

float //pinguin spawn values
  startX, 
  startY;

//Pinguin sprites
int 
  framesPinguin = 18, 
  pinguinFrame = 0;

int EnemyComboBonus;
int perComboBonus = 1;

PImage[] pinguinSprite = new PImage[framesPinguin];

void setup() {
  //============================================
  font = createFont("./font/8-bit pusab.ttf", 1);
  textFont(font);
  fullScreen();
  //size(1280, 1000);
  initAudioFiles();
  gameOver_sound.play();
  song.play();
  song.loop(); //loop the background music.

  song.setGain(-20.0); //set volume a bit lower, needs to be handled by controls in menu later.
  playSong.setGain(-20);
  bulletHit.setGain(-20);
  shoot.setGain(-20);
  gun_pickup.setGain(-20);
  bubble_pickup.setGain(-20);
  star_pickup.setGain(-20);
  //Initializing gameStateManager and setting gamestate to 0 (menu).
  GameStateManager = new GameState();
  GameStateManager.changeGameState(0);
}

//===============================================

void initAudioFiles() {
  minim = new Minim(this); 
  damage = minim.loadFile("./sounds/damage.wav");
  point = minim.loadFile("./sounds/coin.wav");
  selectSound = minim.loadFile("./sounds/Select.wav");
  song = minim.loadFile("./sounds/background_music.wav");
  playSong = minim.loadFile("./sounds/play_bg_music.wav");
  shoot = minim.loadFile("./sounds/shoot.wav");
  bulletHit = minim.loadFile("./sounds/bullet_hit.wav");
  star_pickup = minim.loadFile("./sounds/powerup_pickup.wav");
  star_hit = minim.loadFile("./sounds/star_hit_enemy.wav");
  gun_pickup = minim.loadFile("./sounds/gun_pickup.wav");
  bubble_pickup = minim.loadFile("./sounds/bubble_pickup.wav");
  gameOver_sound = minim.loadFile("./sounds/gameOverSound.wav");
}

void initMenuElements() {
  startX = 50;
  startY = height/2;
  thePinguin = new Pinguin(startX, startY);
  for (int i = 0; i<framesPinguin; i++) {
    pinguinSprite[i] = loadImage("./Images/Pinguin/pinguin-"+i+".png");
  }

  menu = new Menu();
  menu.init();
}

//===============================================

void initPlayElements() {
  song.pause();
  playSong.play();
  playSong.loop();

  lifecounter=1;
  index = 0;

  //INIT CLASSSES.
  tools = new DeveloperTools();
  powerup = new PowerUp();
  bullets = new Bullet[6];
  ice = new Obstacles();
  ship = new Obstacles();
  snow = new Snow();

  //Spawn values
  shipHeight = 100;
  shipWidth = 260;
  shipSpawnTime = 5;
  shipType = "Ship";

  iceHeight = 100;
  iceWidth = 100;
  iceSpawnTime = 3;
  iceType = "Ice";

  powerupWidth = width;                   
  powerupHeight =(height/2);                  
  xPos = 10;                     
  yPos = 10;                       
  powerupSpawnTime = random(30, 60); 
  powerupKind = (int)random(1, 4); 

  //audio
  startTimer = new Timer(500);//store the current time in frames
  point.setGain(-20);
}

//===============================================


void draw() {
  GameStateManager.UpdateGameState();
  noCursor();
}

//===============================================

void playDrawElements() {
  if (!isNotDead) {

    l1.draw();
    fill(0, 255, 0);

    ship.draw();
    ice.draw();
    tools.draw();

    fill(255, 0, 0);
    encounter.draw();


    for (int i=0; i<bullets.length; i++) {
      bullets[i].update();
      bullets[i].draw();
    }

    powerup.draw();

    fill(255, 0, 0);

    for (int i = 0; i < encounter.maxEnemies; i++) {
      if (encounter.collidesWithEnemy(thePinguin, encounter.enemy[i] ) || 
        ice.collides(thePinguin) || ship.collides(thePinguin)) {

        damage.play();
        damage.rewind();
        lifecounter--; // a live will be taken
        if (lifecounter == 0)
        {
          GameStateManager.changeGameState(4);
          isNotDead = true;
        } else if (lifecounter <= powerup.shieldLife && lifecounter > powerup.shootLife)//no damagesound is heard when you collide with the enemy and have a shield powerup & will activate the shield timer.
        {
          damage.pause();
          powerup.startTime = true;
        }
      }
    } 

    // geef punten als de speler tegen punten aan komt
    if (encounter.collidesWithPoint(thePinguin)) {
      point.play();
      point.rewind();
      if (pointcountdown > 0) {
        EnemyComboBonus += perComboBonus;
        score.score += scoreForPoint + EnemyComboBonus;
        pickupScore += scoreForPoint + EnemyComboBonus;
      } else {
        EnemyComboBonus = 0;
        score.score += scoreForPoint;
        pickupScore = scoreForPoint;
      }
      pointcountdown = seconde * 1;
      scoreHeightAlt = thePinguin.position.y - 20;
      pointX = thePinguin.position.x;
    }

    if (pointcountdown > 0) { 
      //haalt score eraf 
      pointcountdown -= 1;
      textSize(23);
      fill(255, 255, 255);
      text("+" + pickupScore, pointX, scoreHeightAlt);
      scoreHeightAlt -= 1;
    }

    score.draw();
    thePinguin.update();
    thePinguin.draw();


    //text(frameRate, width/2, 100); fps checken
  } else {
  }
}

//===============RESET FUNCTION====================

void resetGame() {
  isNotDead = false;
  score = new ScoreScreen();
  save = new ScoreSave();

  l1 = new Level();
  l1.init();
  snow.init();
  lifecounter =1;
  encounter = new Encounter();
  thePinguin.initial();
  powerup.init();
  score.init();
  save.setup();

  //spawnObstacle(x, y, w, h, spawnTime);
  ship.spawnObstacle(width, height - shipHeight, shipWidth, shipHeight, shipSpawnTime, shipType); 
  ice.spawnObstacle(width, 0 -(iceHeight/2), iceWidth, iceHeight, iceSpawnTime, iceType);  //0 - (iceHeight/2) will get the upper half of the ice obstacle stick out of the screen.

  ship.init();
  ice.init();

  powerup.spawnPowerUp(width, (height/2), 10, 10, powerupSpawnTime, powerupKind);///
  for (index=0; index<bullets.length; index++) { 
    bullets[index]= new Bullet(); //Display the bullets at the position where the character was when shooting
    bullets[index].init();
  }
}

//===============================================

void keyPressed() {
  switch(GameStateManager.gameStateVal) {
  case 0: //menu
    {
      menu.keyPressed();
      break;
    }
  case 1: //play
    {
      tools.keyPressed();
      thePinguin.keyPressed();
      break;
    }
  case 2: //help
    {
      score.keyPressed();
      break;
    }
  case 4://score
    {
      score.keyPressed();
      break;
    }
  }
}

void keyReleased() {
  switch(GameStateManager.gameStateVal) {
  case 1: //play
    {
      thePinguin.keyReleased();
      break;
    }
  case 2: //help
    {
      score.keyReleased();
      break;
    }
  case 4://score
    {
      score.keyReleased();
      break;
    }
  }
}
