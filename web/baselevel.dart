part of ld41;

class BaseLevel {

  Sprite sprite;
  BaseLevelPlayer player;

  BaseLevel() {
    sprite = new Sprite();
    player = new BaseLevelPlayer();
    sprite.addChild(player.sprite);
  }

  void update(num time) {
    bool alive = player.move();
    sprite.x = -player.pos.x + 100;
  }

}

class BaseLevelPlayer {

  Sprite sprite;
  Vector pos;

  BaseLevelPlayer() {
    sprite = new Sprite();
    sprite.graphics.rect(0, 0, Game.TILE_SIZE, Game.TILE_SIZE);
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
    sprite.x = pos.x * Game.TILE_SIZE;
    sprite.y = pos.y * Game.TILE_SIZE;
  }

}

class BaseLevelBlock {

  int x, height;
  Sprite sprite;

  BaseLevelBlock(x, height, spike, respawn) {
    sprite = new Sprite();
    sprite.graphics.rect(0, 0, Game.TILE_SIZE, -height);
    sprite.graphics.fillColor(0xFF000000);
    sprite.x = x * Game.TILE_SIZE;
    sprite.y = Game.HEIGHT;
  }

}