part of ld41;

class BaseLevel extends Level {

  static const LEFT_MARGIN = 5;

  /* 4[rs]
   * 4 = height
   * s = spikes
   * r = respawn
   */
  static final RegExp BLOCK_REGEXP = new RegExp(r"(\d)([rs]?)");
  
  static const String LEVEL = 
    "333333r333333333333333333333333333333333334444444455555555533s333333333333334s33333333333332s2s33r333333" +
    "4444444455555555666666667s666666661s1s666666667s666666661s1s666r66666777777888888999999" + 
    "333333333334s333334s333334s333334s333334s444445s555556s66666111r11111112s11111111112s2s11112s11111" +
    "11111s1s1111s1s111r11111122222233333344444455555566666677777788889s33333333444455556666777788889r" +
    "8765432111111s1s111s1s111111333555776543211r1111112s11111222222333333444445s44445s44445s44222222223s3s22222222223s3s22r2222" +
    "22223s3s33334s4s44445s5s55556s6s6666333r33333334s333334s333334s333334s333334s4s333334444466666888889s9s88889s9s88888" +
    "3s3s3s3s3s333333s3s333r333333333344445s5s444455555566666677777s7s333333333334s33334s33334s333r3333" +
    "11111122222233333344445555666677778s777778s7777779s555556s333r3333331s1s1s33334s4s33331s1s1s333333" +
    "11111222233334444555566667777888899999s";

  String blockString;
  num winningX;
  List<BaseLevelBlock> blocks;
  List<BaseLevelBlock> respawnBlocks;
  BaseLevelPlayer player;
  num scrollX;
  TextField countdownText;
  num countdownTime;
  int miniLevelIndex;
  int deathCount;
  TextField wonText;
  Sound music;
  SoundChannel musicChannel;
  num playerMusicOffset;

  BaseLevel() {
    sprite = new Sprite();
    blockString = LEVEL;
    winningX = 765;
    blocks = new List<BaseLevelBlock>();
    respawnBlocks = new List<BaseLevelBlock>();
    //player = new BaseLevelPlayer(respawnBlocks[0].x, Game.HEIGHT - respawnBlocks[0].height - 1);
    player = new BaseLevelPlayer(LEFT_MARGIN + 1, Game.HEIGHT - 4);
    //player = new BaseLevelPlayer(700, 7);
    sprite.addChild(player.sprite);
    updateSprite();
    addBlocks(false);
    countdownText = new TextField("", new TextFormat("Comfortaa", 4, BaseLevelBlock.COLOR_BLOCK, align: "center"));
    countdownText.pivotX = 5;
    countdownText.pivotY = 2;
    countdownText.width = 10;
    resetCountdown();
    sprite.addChild(countdownText);
    miniLevelIndex = 0;
    deathCount = 0;
    wonText = new TextField("YOU DID IT!\nyou died $deathCount times\nthank you for playing <3", new TextFormat("Comfortaa", 1, BaseLevelBlock.COLOR_BLOCK, align: "center"))
      ..x = winningX
      ..y = 4
      ..width = Game.WIDTH;
    sprite.addChild(wonText);
    music = resources.getSound('song');
    musicChannel = music.play();
  }

  void resetCountdown() {
    countdownText.x = player.x + 0.5;
    countdownText.y = player.y - 5;
    countdownTime = 3.01;
  }

  void leftPressed() { }

  void upPressed() {
    player.jump();
  }

  void rightPressed() { }

  void downPressed() { }

  void rPressed() { }

  void addBlocks(bool animate) {
    int lastX = 0;
    while ((blocks.length == 0 || (lastX = blocks[blocks.length - 1].x) < Game.WIDTH - scrollX) && blockString.length > 0) {
      Match match = BLOCK_REGEXP.matchAsPrefix(blockString);
      if (match != null) {
        int blockHeight = int.parse(match.group(1));
        bool spikes = match.group(2) == "s";
        bool respawn = match.group(2) == "r";
        BaseLevelBlock block = new BaseLevelBlock(lastX + 1, blockHeight, spikes, respawn, animate);
        blocks.add(block);
        sprite.addChild(block.sprite);
        if (respawn) {
          respawnBlocks.add(block);
        }
        // remove added blocks from blockString
        blockString = blockString.substring(match.group(0).length);
      } else {
        print("BASELEVEL PARSING ERROR: blockString " + blockString);
        break;
      }
    }
  }

  void removeOffscreenBlocks() {
    while (blocks.length > 0 && // if there are blocks left and ...
          respawnBlocks.length > 1 && // ... there is more than one respawn block left and ...
          respawnBlocks[1].x - LEFT_MARGIN < -scrollX - 1) { // ... the player has passed the second respawn block
      BaseLevelBlock removedBlock = blocks.removeAt(0);
      sprite.removeChild(removedBlock.sprite);
      if (removedBlock.respawn) {
        respawnBlocks.remove(removedBlock);
      }
    }
  }

  void update(num time) {
    if (musicChannel.paused) {
      musicChannel.soundTransform = new SoundTransform(1);
      game.fadeSound(null, musicChannel);
    }
    if (countdownTime > 0) {
      if (playerMusicOffset == null) {
        playerMusicOffset = musicChannel.position - player.x / BaseLevelPlayer.SPEED;
      }
      int before = countdownTime.ceil();
      countdownTime -= time * 13 / 8; // ?
      int after = countdownTime.ceil();
      if (after != before) {
        if (after > 0) {
          countdownText.text = after.toString();
        } else {
          countdownText.text = "GO";
        }
        countdownText.scaleX = countdownText.scaleY = 1;
        countdownText.alpha = 1;
        stage.juggler.add(
          new Tween(countdownText, 0.5, Transition.easeOutQuadratic)
            ..animate.scaleX.to(0.7)
            ..animate.scaleY.to(0.7)
            ..animate.alpha.to(0)
        );
      }
    } else {
      if (player.x < winningX) {
        bool alive = player.updatePhysics(time, blocks);
        updateSprite();
        addBlocks(true);
        removeOffscreenBlocks();
        if (!alive) {
          player.resetPhysics(respawnBlocks[0].x, Game.HEIGHT - respawnBlocks[0].height - 1);
          game.setLevel(new MiniLevel(MiniLevel.LEVELS[miniLevelIndex], this));
          miniLevelIndex++;
          if (miniLevelIndex >= MiniLevel.LEVELS.length) {
            miniLevelIndex = 0;
          }
          deathCount++;
          wonText.text = "YOU DID IT!\nyou died $deathCount times\nthank you for playing <3";
          game.fadeSound(musicChannel, null, onComplete: () => musicChannel.position = player.x / BaseLevelPlayer.SPEED + playerMusicOffset);
        }
      } else {
        player.float();
        player.updatePhysics(time, blocks);
        updateSprite();
        print('win');
      }
    }
  }

  void updateSprite() {
    scrollX = (-player.x + LEFT_MARGIN);
    sprite.x = scrollX;
  }

}

class BaseLevelPlayer {

  static const int COLOR = 0xFF3984C6;
  static const num GRAVITY = 170;
  static const num JUMP = -30;
  static const num SPEED = 13; // 780 blocks/min

  Sprite sprite;
  num x, y;
  num velocityX, velocityY;
  num accelerationY;
  bool onGround;

  BaseLevelPlayer(this.x, this.y) {
    sprite = new Sprite();
    sprite.graphics.rect(0, 0, 1, 1);
    sprite.graphics.fillColor(COLOR);
    sprite.pivotX = 0.5;
    sprite.pivotY = 0.5;
    resetPhysics(x, y);
    updateSprite();
  }

  void resetPhysics(num x, num y) {
    this.x = x;
    this.y = y;
    velocityX = SPEED;
    velocityY = 0;
    accelerationY = GRAVITY;
    onGround = false;
  }

  void jump() {
    if (onGround) {
      velocityY = JUMP;
    }
  }

  void float() {
    velocityX -= 0.3;
    if (velocityX < 0) {
      velocityX = 0;
    }
    if (y > Game.HEIGHT / 2) {
      accelerationY = -GRAVITY / 2;
    } else {
      accelerationY = GRAVITY / 2;
    }
  }

  bool updatePhysics(num time, List<BaseLevelBlock> blocks) {
    bool alive = true;
    // move y
    velocityY += accelerationY * time;
    y += velocityY * time;
    BaseLevelBlock collidingBlock = getCollidingBlock(blocks);
    // hit the floor?
    if (collidingBlock != null) {
      velocityY = 0;
      y = Game.HEIGHT - collidingBlock.height - 1;
      onGround = true;
      if (collidingBlock.spikes) {
        alive = false;
      }
      // allow hold-to-jump
      if (game.upPressed) {
        jump();
      }
    } else {
      onGround = false;
    }
    // move x
    x += velocityX * time;
    collidingBlock = getCollidingBlock(blocks);
    // hit a block from the side?
    if (collidingBlock != null) {
      alive = false;
    }
    updateSprite();
    return alive;
  }

  BaseLevelBlock getCollidingBlock(List<BaseLevelBlock> blocks) {
    BaseLevelBlock spikesBlock = null;
    for (BaseLevelBlock block in blocks) {
      if (block.spikes) {
        // higher tolerance for spikes
        num tolerance = 0.3;
        if (x + 1 > block.x + tolerance && x < block.x + 1 - tolerance && y + 1 > Game.HEIGHT - block.height + tolerance) {
          spikesBlock = block;
        }
      } else {
        if (x + 1 > block.x && x < block.x + 1 && y + 1 > Game.HEIGHT - block.height) {
          return block;
        }
      }
    }
    // be nice to the player: only collide with spikes when there is no other collision
    if (spikesBlock != null) {
      return spikesBlock;
    }
    return null;
  }

  void updateSprite() {
    sprite.x = x + 0.5;
    sprite.y = y + 0.5;
  }

}

class BaseLevelBlock {

  static const int COLOR_BLOCK = 0xFF333333;
  static const int COLOR_SPIKES = 0xFF666666;
  static const int COLOR_RESPAWN = 0xFF666666;

  int x, height;
  bool spikes, respawn;
  Sprite sprite;

  BaseLevelBlock(this.x, this.height, this.spikes, this.respawn, bool animate) {
    sprite = new Sprite();
    if (spikes) {
      sprite.graphics.rect(0, 0, 1, -height + 1);
      sprite.graphics.fillColor(COLOR_BLOCK);
      sprite.graphics.beginPath();
      sprite.graphics.moveTo(0, -height + 1);
      sprite.graphics.lineTo(0.25, -height);
      sprite.graphics.lineTo(0.5, -height + 1);
      sprite.graphics.lineTo(0.75, -height);
      sprite.graphics.lineTo(1, -height + 1);
      sprite.graphics.closePath();
      sprite.graphics.fillColor(COLOR_SPIKES);
    } else {
      sprite.graphics.rect(0, 0, 1, -height);
      sprite.graphics.fillColor(COLOR_BLOCK);
      if (respawn) {
        sprite.graphics.beginPath();
        sprite.graphics.moveTo(0.4, -height);
        sprite.graphics.lineTo(0.4, -height - 1);
        sprite.graphics.lineTo(1, -height - 0.5);
        sprite.graphics.lineTo(0.6, -height - 0.5);
        sprite.graphics.lineTo(0.6, -height);
        sprite.graphics.closePath();
        sprite.graphics.fillColor(COLOR_RESPAWN);
      }
    }
    sprite.x = x;
    sprite.y = Game.HEIGHT;
    if (animate) {
      sprite.rotation = PI / 2;
      stage.juggler.add(
        new Tween(sprite, 0.5, Transition.easeOutCubic)
          ..animate.rotation.to(0)
          ..delay = 0.1
      );
    }
  }

}