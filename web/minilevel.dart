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

  Sprite blockSprite;
  String blockString;
  MiniLevelPlayer player;
  List<List<MiniLevelBlock>> blocks;
  BaseLevel baseLevel;

  MiniLevel(this.blockString, this.baseLevel) {
    sprite = new Sprite();
    blockSprite = new Sprite();
    sprite.addChild(blockSprite);
    reset();
    sprite.addChild(
      new TextField("press [R] to restart", new TextFormat("Roboto", 1, 0xFF000000, align: "center"))
        ..x = 0
        ..y = Game.HEIGHT - 2
        ..width = Game.WIDTH
    );
  }

  void reset() {
    blockSprite.removeChildren();
    blocks = new List<List<MiniLevelBlock>>();
    List<String> lines = blockString.trim().split("\n");
    for (int i = 0; i < lines.length; i++) {
      blocks.add(new List<MiniLevelBlock>());
      List<String> chars = lines[i].trim().split('');
      for (int j = 0; j < chars.length; j++) {
        MiniLevelBlock block;
        switch (chars[j]) {
          case "#":
            block = new MiniLevelBlock(i, j, false);
            break;
          case "o":
            block = new MiniLevelBlock(i, j, true);
            break;
          case " ":
            block = null;
            break;
          case "P":
            block = player = new MiniLevelPlayer(i, j);
            break;
          case "G":
            block = new MiniLevelGoal(i, j);
            break;
          default:
            print("MINILEVEL PARSING ERROR: char " + chars[j]);
        }
        blocks[i].add(block);
        if (block != null) {
          blockSprite.addChild(block.sprite);
        }
      }
    }
    blockSprite.x = (Game.WIDTH - blockSprite.width) / 2;
    blockSprite.y = (Game.HEIGHT - blockSprite.height) / 2;
  }

  void leftPressed() {
    player.move(-1, 0, blocks);
    checkWon();
  }

  void upPressed() {
    player.move(0, -1, blocks);
    checkWon();
  }

  void rightPressed() {
    player.move(1, 0, blocks);
    checkWon();
  }

  void downPressed() {
    player.move(0, 1, blocks);
    checkWon();
  }

  void rPressed() {
    reset();
  }

  void update(num time) { }

  void checkWon() {
    if (player.won) {
      game.setLevel(baseLevel);
    } 
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
    updateSprite(false);
  }

  bool move(int dx, int dy, List<List<MiniLevelBlock>> blocks) {
    if (movable) {
      MiniLevelBlock adjacientBlock = blocks[x + dx][y + dy];
      if (adjacientBlock == null || adjacientBlock.move(dx, dy, blocks)) {
        blocks[x][y] = null;
        blocks[x + dx][y + dy] = this;
        x = x + dx;
        y = y + dy;
        updateSprite(true);
        return true;
      }
    }
    return false;
  }

  void updateSprite(bool animate) {
    if (animate) {
      stage.juggler.add(
        new Tween(sprite, 0.1, Transition.easeOutCubic)
          ..animate.x.to(x)
          ..animate.y.to(y)
      );
    } else {
      sprite.x = x;
      sprite.y = y;
    }
  }

}

class MiniLevelPlayer extends MiniLevelBlock {

  bool won;

  MiniLevelPlayer(int x, int y) : super(x, y, true, false) {
    sprite.graphics.rect(0, 0, 1, 1);
    sprite.graphics.fillColor(0xFFFF0000);
    won = false;
  }

}

class MiniLevelGoal extends MiniLevelBlock {

  MiniLevelGoal(int x, int y) : super(x, y, false, false) {
    sprite.graphics.rect(0, 0, 1, 1);
    sprite.graphics.fillColor(0xFFFF00FF);
  }

  @override
  bool move(int dx, int dy, List<List<MiniLevelBlock>> blocks) {
    if (blocks[x - dx][y - dy] is MiniLevelPlayer) {
      (blocks[x - dx][y - dy] as MiniLevelPlayer).won = true;
      return true;
    }
    return false;
  }

}