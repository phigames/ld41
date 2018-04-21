part of ld41;

class BaseLevel {

  static final RegExp blockRegex = new RegExp(r"\d");

  Sprite sprite;
  String blockString;
  List<BaseLevelBlock> blocks;
  BaseLevelPlayer player;

  BaseLevel() {
    sprite = new Sprite();
    blockString = "33333333333334444444222222";
    blocks = new List<BaseLevelBlock>();
    addBlock();
    while (blocks[blocks.length - 1].x < Game.WIDTH && blockString.length > 0) {
      addBlock();
    }
    player = new BaseLevelPlayer();
    sprite.addChild(player.sprite);
  }

  void addBlock() {
    Match match = blockRegex.matchAsPrefix(blockString);
    if (match != null) {
      String matchGroup = match.group(0);
      int blockHeight = int.parse(matchGroup);
      BaseLevelBlock block = new BaseLevelBlock(blocks.length, blockHeight, false, false);
      blocks.add(block);
      sprite.addChild(block.sprite);
      blockString = blockString.substring(matchGroup.length);
    } else {
      print("REGEX ERROR");
    }
  }

  void update(num time) {
    bool alive = player.move();
    updateSprite();
  }

  void updateSprite() {
    sprite.x = (-player.pos.x + 5);
  }

}

class BaseLevelPlayer {

  Sprite sprite;
  Vector pos;

  BaseLevelPlayer() {
    sprite = new Sprite();
    sprite.graphics.rect(0, 0, 1, 1);
    sprite.graphics.fillColor(0xFFFF0000);
    pos = new Vector(5, 5);
    updateSprite();
  }

  bool move() {
    pos += new Vector(0.1, 0);
    updateSprite();
    return true;
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