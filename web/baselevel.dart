part of ld41;

class BaseLevel {

  static final RegExp blockRegex = new RegExp(r"\d");

  Sprite sprite;
  String blockString;
  List<BaseLevelBlock> blocks;
  BaseLevelPlayer player;
  num scrollX;

  BaseLevel() {
    sprite = new Sprite();
    blockString = "333333333333333333333444444444444433333331234";
    blocks = new List<BaseLevelBlock>();
    player = new BaseLevelPlayer();
    sprite.addChild(player.sprite);
    scrollX = 0;
    addBlocks();
    updateSprite();
  }

  void upPressed() {
    player.jump();
  }

  void addBlocks() {
    int lastX = 0;
    while ((blocks.length == 0 || (lastX = blocks[blocks.length - 1].x) < Game.WIDTH - scrollX) && blockString.length > 0) {
      Match match = blockRegex.matchAsPrefix(blockString);
      if (match != null) {
        String matchGroup = match.group(0);
        int blockHeight = int.parse(matchGroup);
        BaseLevelBlock block = new BaseLevelBlock(lastX + 1, blockHeight, false, false);
        blocks.add(block);
        sprite.addChild(block.sprite);
        blockString = blockString.substring(matchGroup.length);
        //print('add ' + matchGroup + ', total ' + blocks.length.toString());
      } else {
        print("REGEX ERROR");
        break;
      }
    }
  }

  void removeOffscreenBlocks() {
    while (blocks.length > 0 && blocks[0].x < -scrollX) {
      print('remove, total ' + blocks.length.toString());
      blocks.removeAt(0);
    }
  }

  void update(num time) {
    bool alive = player.updateMovement(blocks);
    scrollX = (-player.pos.x + 5);
    updateSprite();
    addBlocks();
    removeOffscreenBlocks();
  }

  void updateSprite() {
    sprite.x = scrollX;
  }

}

class BaseLevelPlayer {

  static const num GRAVITY = 0.03;
  static const num JUMP = -0.4;

  Sprite sprite;
  Vector pos;
  num velocityX, velocityY;
  bool onGround;

  BaseLevelPlayer() {
    sprite = new Sprite();
    sprite.graphics.rect(0, 0, 1, 1);
    sprite.graphics.fillColor(0xFFFF0000);
    pos = new Vector(5, 5);
    velocityX = 0.2;
    velocityY = 0;
    onGround = false;
    updateSprite();
  }

  void jump() {
    if (onGround) {
      velocityY = JUMP;
    }
  }

  bool updateMovement(List<BaseLevelBlock> blocks) {
    // move y
    velocityY += GRAVITY;
    pos += new Vector(0, velocityY);
    BaseLevelBlock collidingBlock = getCollidingBlock(blocks);
    // hit the floor?
    if (collidingBlock != null) {
      velocityY = 0;
      pos = new Vector(pos.x, Game.HEIGHT - collidingBlock.height - 1);
      onGround = true;
    } else {
      onGround = false;
    }
    // move x
    pos += new Vector(velocityX, 0);
    collidingBlock = getCollidingBlock(blocks);
    // hit a block from the side?
    if (collidingBlock != null) {
      return false;
    }
    updateSprite();
    return true;
  }

  BaseLevelBlock getCollidingBlock(List<BaseLevelBlock> blocks) {
    for (BaseLevelBlock block in blocks) {
      if (pos.x > block.x - 1 && pos.x < block.x + 1 && pos.y + 1 > Game.HEIGHT - block.height) {
        return block;
      }
    }
    return null;
  }

  void updateSprite() {
    sprite.x = pos.x;
    sprite.y = pos.y;
  }

}

class BaseLevelBlock {

  int x, height;
  Sprite sprite;

  BaseLevelBlock(this.x, this.height, spike, respawn) {
    sprite = new Sprite();
    sprite.graphics.rect(0, 0, 1, -height);
    sprite.graphics.fillColor(0xFF000000);
    sprite.x = x;
    sprite.y = Game.HEIGHT;
  }

}