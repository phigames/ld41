part of ld41;

class MiniLevel extends Level {

  /* '#' = solid block
   * 'o' = movable block
   * ' ' = air
   * 'P' = player
   * 'G' = goal
   */

  static const String LEVEL_1 =
    """
    #####
    #Po #
    #o oG
    #   #
    #####
    """;

  MiniLevelPlayer player;
  List<List<MiniLevelBlock>> blocks;

  MiniLevel(String blockString) {
    sprite = new Sprite();
    player = new MiniLevelPlayer(1, 2);
    sprite.addChild(player.sprite);
    blocks = new List<List<MiniLevelBlock>>();
    for (int i = 0; i < 5; i++) {
      blocks.add(new List<MiniLevelBlock>());
      for (int j = 0; j < 5; j++) {
        blocks[i].add(new MiniLevelBlock(i, j, false));
        sprite.addChild(blocks[i][j].sprite);
      }
    }
    sprite.removeChild(blocks[1][2].sprite);
    blocks[1][2] = null;
    sprite.removeChild(blocks[2][2].sprite);
    blocks[2][2] = new MiniLevelBlock(2, 2, true);
    sprite.addChild(blocks[2][2].sprite);
    sprite.removeChild(blocks[3][2].sprite);
    blocks[3][2] = null;
  }

  void leftPressed() {
    player.move(-1, 0, blocks);
  }

  void upPressed() {
    player.move(0, -1, blocks);
  }

  void rightPressed() {
    player.move(1, 0, blocks);
  }

  void downPressed() {
    player.move(0, 1, blocks);
  }

  void update(num time) { }

}

class MiniLevelPlayer extends MiniLevelBlock {

  MiniLevelPlayer(int x, int y) : super(x, y, true, false) {
    sprite.graphics.rect(0, 0, 1, 1);
    sprite.graphics.fillColor(0xFFFF0000);
  }

}

class MiniLevelBlock {

  Sprite sprite;
  int x, y;
  bool movable;

  MiniLevelBlock(this.x, this.y, this.movable, [bool draw = true]) {
    sprite = new Sprite();
    if (draw) {
      sprite.graphics.rect(0, 0, 1, 1);
      if (movable) {
        sprite.graphics.fillColor(0xFF00FF00);
      } else {
        sprite.graphics.fillColor(0xFF0000FF);
      }
    }
    updateSprite();
  }

  bool move(int dx, int dy, List<List<MiniLevelBlock>> blocks) {
    print('move');
    if (movable) {
      MiniLevelBlock adjacientBlock = blocks[x + dx][y + dy];
      if (adjacientBlock == null || adjacientBlock.move(dx, dy, blocks)) {
        blocks[x][y] = null;
        blocks[x + dx][y + dy] = this;
        x = x + dx;
        y = y + dy;
        updateSprite();
        return true;
      }
    }
    return false;
  }

  void updateSprite() {
    sprite.x = x;
    sprite.y = y;
  }

}