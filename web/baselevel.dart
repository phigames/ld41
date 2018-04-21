part of ld41;

class BaseLevel extends Level {

  static const LEFT_MARGIN = 5;

  /* 4[rs]
   * 4 = height
   * s = spikes
   * r = respawn
   */
  static final RegExp BLOCK_REGEXP = new RegExp(r"(\d)([rs]?)");

  String blockString;
  List<BaseLevelBlock> blocks;
  List<BaseLevelBlock> respawnBlocks;
  BaseLevelPlayer player;
  num scrollX;

  BaseLevel() {
    sprite = new Sprite();
    blockString = "333333r333333333333333444s4444444444s33333331234";
    blocks = new List<BaseLevelBlock>();
    respawnBlocks = new List<BaseLevelBlock>();
    scrollX = 0;
    addBlocks(false);
    player = new BaseLevelPlayer(respawnBlocks[0].x, Game.HEIGHT - respawnBlocks[0].height - 1);
    sprite.addChild(player.sprite);
    updateSprite();
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
    print(blocks.length);
  }

  void update(num time) {
    bool alive = player.updatePhysics(time, blocks);
    scrollX = (-player.x + LEFT_MARGIN);
    updateSprite();
    addBlocks(true);
    removeOffscreenBlocks();
    if (!alive) {
      player.resetPhysics(respawnBlocks[0].x, Game.HEIGHT - respawnBlocks[0].height - 1);
      game.setLevel(new MiniLevel(MiniLevel.LEVEL_1, this));
    }
  }

  void updateSprite() {
    sprite.x = scrollX;
  }

}

class BaseLevelPlayer {

  static const num GRAVITY = 150;
  static const num JUMP = -30;
  static const num SPEED = 13; // 780 blocks/min -> ♩ = 195?

  Sprite sprite;
  num x, y;
  num velocityX, velocityY;
  bool onGround;

  BaseLevelPlayer(this.x, this.y) {
    sprite = new Sprite();
    sprite.graphics.rect(0, 0, 1, 1);
    sprite.graphics.fillColor(0xFFFF0000);
    resetPhysics(x, y);
    updateSprite();
  }

  void resetPhysics(num x, num y) {
    this.x = x;
    this.y = y;
    velocityX = SPEED;
    velocityY = 0;
    onGround = false;
  }

  void jump() {
    if (onGround) {
      velocityY = JUMP;
    }
  }

  bool updatePhysics(num time, List<BaseLevelBlock> blocks) {
    bool alive = true;
    // move y
    velocityY += GRAVITY * time;
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
      if (x > block.x - 1 && x < block.x + 1 && y + 1 > Game.HEIGHT - block.height) {
        if (block.spikes) {
          spikesBlock = block;
        } else {
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
    sprite.x = x;
    sprite.y = y;
  }

}

class BaseLevelBlock {

  int x, height;
  bool spikes, respawn;
  Sprite sprite;

  BaseLevelBlock(this.x, this.height, this.spikes, this.respawn, bool animate) {
    sprite = new Sprite();
    if (spikes) {
      sprite.graphics.rect(0, 0, 1, -height + 1);
      sprite.graphics.fillColor(0xFF000000);
      sprite.graphics.beginPath();
      sprite.graphics.moveTo(0, -height + 1);
      sprite.graphics.lineTo(0.25, -height);
      sprite.graphics.lineTo(0.5, -height + 1);
      sprite.graphics.lineTo(0.75, -height);
      sprite.graphics.lineTo(1, -height + 1);
      sprite.graphics.closePath();
      sprite.graphics.fillColor(0xFF000000);
    } else {
      sprite.graphics.rect(0, 0, 1, -height);
      sprite.graphics.fillColor(0xFF000000);
      if (respawn) {
        sprite.graphics.beginPath();
        sprite.graphics.moveTo(0.4, -height);
        sprite.graphics.lineTo(0.4, -height - 1);
        sprite.graphics.lineTo(1, -height - 0.7);
        sprite.graphics.lineTo(0.6, -height - 0.7);
        sprite.graphics.lineTo(0.6, -height);
        sprite.graphics.closePath();
        sprite.graphics.fillColor(0xFF000000);
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