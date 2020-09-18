


String username;
Actor d1, d2, d3, d4, d5, d6;
PImage tile, droid, product, none;
String time = "";
int time_cur;

ItemMap testItemMap;
Storage  testStorage;
void settings() {
  size(800, 600, P2D);
  smooth(2);
  PJOGL.setIcon("data/sprites/icon.png");

  
}


void setup() {

  Interactive.make( this );
  surface.setTitle("Ironheads");
  textFont(Interface.font = createFont("data/font/progress_pixel_bolt.ttf", 18));
  textLeading(24);
  strokeCap(SQUARE);
  setupDatabase();
  tile = loadImage("data/sprites/tile_grass.png");
  none = loadImage("data/sprites/no_data.png");
  droid = loadImage("data/sprites/droid.png");
  product = loadImage("data/sprites/item_product.png");
  playerFraction = new Fraction (0, "Robocraft");
  world = new World(5, 42, 12, 24, 32);
  world.getRoomCurrent().add(new Layer(Object.LAYER_STEEL, Item.PLATE_STEEL, 7, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL_STEEL, 0, 8, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL_STONE, 3, 9, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL_STEEL, 0, 12, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL_STONE, 3, 13, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL_STEEL, 0, 17, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL_STEEL, 0, 19, 8, 0));
  world.getRoomCurrent().add(new Layer(Object.LAYER_STEEL, Item.PLATE_STEEL, 21, 9, 0));
  world.getRoomCurrent().add(new Layer(Object.LAYER_STEEL, Item.PLATE_STEEL, 21, 10, 0));
  world.getRoomCurrent().add(new Layer(Object.LAYER_STEEL, Item.PLATE_STEEL, 21, 8, 0));
  world.getRoomCurrent().add(new Flag(Object.POINT_GUARD, 1, 1));
  world.getRoomCurrent().add(new Flag(Object.POINT_GUARD, 21, 1));
  world.getRoomCurrent().add(new Flag(Object.POINT_GUARD, 21, 21));
  world.getRoomCurrent().add(new Flag(Object.POINT_GUARD, 1, 021));
  world.getRoomCurrent().add(new Flag(Object.POINT_STAND, 13, 13));
  world.getRoomCurrent().add(new Flag(Object.POINT_STAND, 13, 14));
  world.getRoomCurrent().add(new Flag(Object.POINT_STAND, 14, 13));
  world.getRoomCurrent().add(new Flag(Object.POINT_STAND, 14, 14));
  world.getRoomCurrent().add(new Flag(Object.POINT_STAND, 21, 10));
  world.getRoomCurrent().add(new Wall(Object.WALL_STEEL, 0, 20, 9, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE_STEEL, Item.STEEL, 0, 0, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE_STEEL, Item.STEEL, 6, 12, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE_STEEL, Item.STEEL, 7, 12, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE_WOOD, Item.STEEL, 21, 7, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE_STEEL, Item.STEEL, 9, 12, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE_STEEL, Item.STEEL, 18, 12, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE_STEEL, Item.STEEL, 20, 20, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE_STEEL, Item.STEEL, 4, 20, 0));
  world.getRoomCurrent().add(new Miner(Object.WELL, 6, 6, 0));
  world.getRoomCurrent().add(new Miner(Object.DRILL, 7, 6, 0));
  world.getRoomCurrent().add(new Miner(Object.DRILL, 9, 6, 0));
  world.getRoomCurrent().add(new Miner(Object.DRILL, 14, 3, 0));
  world.getRoomCurrent().add(new Enviroment(Object.BLOCK, 20, 21, int(random(4)), Item.STEEL));
  world.getRoomCurrent().add(new Enviroment(Object.BLOCK, 13, 11, int(random(4)), Item.STONE));
  world.getRoomCurrent().add(new Enviroment(Object.BLOCK, 18, 20, int(random(4)), Item.STEEL));
  world.getRoomCurrent().add(new Enviroment(Object.BLOCK, 17, 20, int(random(4)), Item.COPPER));

  world.getRoomCurrent().add(new Enviroment(Object.TREE, 10, 12, int(random(4)), Item.WOOD));
  world.getRoomCurrent().add(new Enviroment(Object.TREE, 11, 13, int(random(4)), Item.RUBBER));
  world.getRoomCurrent().add(new Enviroment(Object.TREE, 19, 22, int(random(4)), Item.WOOD));
  world.getRoomCurrent().add(new Enviroment(Object.TREE, 16, 15, int(random(4)), Item.WOOD));
  world.getRoomCurrent().add(new Enviroment(Object.TREE, 17, 12, int(random(4)), Item.WOOD));
  world.getRoomCurrent().add(new Enviroment(Object.TREE, 19, 11, int(random(4)), Item.WOOD));
  world.getRoomCurrent().add(new Enviroment(Object.TREE, 20, 17, int(random(4)), Item.WOOD));
  world.getRoomCurrent().add(new Fabrica(Object.FABRICA, 18, 13, 0));
  world.getRoomCurrent().add(new Support(Object.CHARGE, 8, 20, 0));
  world.getRoomCurrent().add(new Support(Object.CHARGE, 9, 20, 0));
  world.getRoomCurrent().add(new Support(Object.REPAIR, 10, 20, 0));

  world.getRoomCurrent().add(new Build(Object.BUILD, new Wall(Object.WALL_STEEL, 0, 15, 20, 0))); //исправить очередность при назначении работ
  world.getRoomCurrent().add(new Build(Object.BUILD, new Miner(Object.DRILL, 16, 22, 0)));

  world.getRoomCurrent().add(new Bench(Object.BENCH, 18, 15, 0));
  world.getRoomCurrent().add(new Enviroment(Object.TREE, 19, 15, int(random(4)), Item.WOOD));

  //===================
  d1=new Actor(Object.ACTOR, 1, 6);
  d1.skills.append(Job.CRAFT);

  //===================
  d2=new Actor(Object.ACTOR, 1, 4);
  d2.skills.append(Job.BUILD);
  d2.skills.append(Job.CARRY);

  //===================
  d3=new Actor(Object.ACTOR, 15, 4);
  d3.skills.append(Job.GUARD);

  //===================
  d4=new Actor(Object.ACTOR, 7, 0);
  d4.skills.append(Job.MINE);

  //===================
  d5=new Actor(Object.ACTOR, 7, 3);
  d5.skills.append(Job.CARRY);
  d5.skills.append(Job.GUARD);
  //========================
  d6=new Actor(Object.ACTOR, 4, 3);

  d6.skills.append(Job.MAINTENANCE);
  d6.skills.append(Job.CARRY);

  world.getRoomCurrent().add(d1);
  world.getRoomCurrent().add(d3);
  world.getRoomCurrent().add(d2);
  world.getRoomCurrent().add(d4);
  world.getRoomCurrent().add(d5);
  world.getRoomCurrent().add(d6);
  time_cur=0;
  createInterface();
}

void draw() {
  background(0);
  world.update();
 world.draw();
  drawInterface();

}

void keyPressed() {
  if (world.isAllowInput()) {
    if (keyCode==32) {
      world.pause=!world.pause;
      Room room=world.getRoomCurrent();
      if (world.isOverMap()) {
        //
      }
    } else if (keyCode==9) {
      world.showStatus=!world.showStatus;
 
    }
  } else {
    if (windowInput!=null) {
      int len = windowInput.input.length();
      if (keyCode!=BACKSPACE && keyCode!=ENTER && keyCode!=SHIFT && keyCode!=ALT && len<=15)
        windowInput.input+=key;
      if (keyCode==BACKSPACE && len>0) 
        windowInput.input=windowInput.input.substring(0, len-1);
      if (keyCode==ENTER && windowInput.input.length()>0) {
        windowInput.close();
        windowInput=null;
      }
    }
  }
}
