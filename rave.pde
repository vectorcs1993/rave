
Actor d1, d2, d3, d4, d5, d6;
PImage tile, droid, sprite_object_drill, sprite_object_well, sprite_object_fabrica, station_charge, station_repair, sprite_floor_steel, sprite_wall_steel, 
  none, sprite_box_steel, sprite_box_wood, 
  sprite_block_steel, sprite_block_copper, sprite_block, sprite_tree, sprite_object_bench, sprite_object_point_stand, sprite_object_point_guard;
String time = "";
int time_cur;

ItemMap testItemMap;
Storage  testStorage;
void settings() {
  size(800, 600, P2D);
  smooth(2);
  PJOGL.setIcon("sprites/icon.png");
}


void setup() {
  surface.setTitle("Ironheads");
  textFont(Interface.font = createFont("font/progress_pixel_bolt.ttf", 18));
  textLeading(24);
  strokeCap(SQUARE);
  tile = loadImage("sprites/tile_grass.png");
  sprite_floor_steel = loadImage("sprites/floor_steel.png");
  sprite_wall_steel = loadImage("sprites/wall_steel.png");
  sprite_box_steel = loadImage("sprites/storage_steel_box.png");
  sprite_box_wood = loadImage("sprites/storage_wood_box.png");
  none = loadImage("sprites/no_data.png");
  sprite_item_steel = loadImage("sprites/item_steel.png");
  droid = loadImage("sprites/droid.png");
  station_charge = loadImage("sprites/station_charge.png");
  station_repair = loadImage("sprites/station_repair.png");
  sprite_item_wood = loadImage("sprites/item_wood.png");
  sprite_item_copper = loadImage("sprites/item_copper.png");
  sprite_item_stone = loadImage("sprites/item_stone.png");
  sprite_item_plate_steel = loadImage("sprites/item_plate_steel.png");
  sprite_item_plate_copper = loadImage("sprites/item_plate_copper.png");
  sprite_item_block_stone = loadImage("sprites/item_block_stone.png");
  sprite_item_oil = loadImage("sprites/item_oil.png");
  sprite_item_rubber = loadImage("sprites/item_rubber.png");
  sprite_item_kit_repair = loadImage("sprites/item_kit_repair.png");
  sprite_object_drill = loadImage("sprites/drill.png");
  sprite_object_well = loadImage("sprites/well.png");
  sprite_object_fabrica = loadImage("sprites/fabrica.png");
  sprite_object_bench = loadImage("sprites/bench.png");
  sprite_block = loadImage("sprites/block_stone.png");
  sprite_tree = loadImage("sprites/tree.png");
  sprite_object_point_stand=loadImage("sprites/point_stand.png");
  sprite_object_point_guard=loadImage("sprites/point_guard.png");
  playerFraction = new Fraction (0, "Robocraft");
  world = new World(5, 42, 12, 24, 32);

  world.getRoomCurrent().add(new Layer(Object.LAYER, Item.PLATE_STEEL, 7, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 8, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 9, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 12, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 13, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 17, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 19, 8, 0));
  world.getRoomCurrent().add(new Layer(Object.LAYER, Item.PLATE_STEEL, 21, 9, 0));
  world.getRoomCurrent().add(new Layer(Object.LAYER, Item.PLATE_STEEL, 21, 10, 0));
  world.getRoomCurrent().add(new Layer(Object.LAYER, Item.PLATE_STEEL, 21, 8, 0));
  world.getRoomCurrent().add(new Flag(Object.POINT_GUARD, 1, 1));
  world.getRoomCurrent().add(new Flag(Object.POINT_GUARD, 21, 1));
  world.getRoomCurrent().add(new Flag(Object.POINT_GUARD, 21, 21));
  world.getRoomCurrent().add(new Flag(Object.POINT_GUARD, 1, 21));
  world.getRoomCurrent().add(new Flag(Object.POINT_STAND, 13, 13));
  world.getRoomCurrent().add(new Flag(Object.POINT_STAND, 13, 14));
  world.getRoomCurrent().add(new Flag(Object.POINT_STAND, 14, 13));
  world.getRoomCurrent().add(new Flag(Object.POINT_STAND, 14, 14));
  world.getRoomCurrent().add(new Flag(Object.POINT_STAND, 21, 10));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 20, 9, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 0, 0, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 6, 12, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 7, 12, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 21, 7, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 9, 12, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 18, 12, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 20, 20, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 4, 20, 0));
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

  world.getRoomCurrent().add(new Bench(Object.BENCH, 18, 15, 0));

  world.getRoomCurrent().add(new Support(Object.CHARGE, 8, 20, 0));
  world.getRoomCurrent().add(new Support(Object.CHARGE, 9, 20, 0));
  world.getRoomCurrent().add(new Support(Object.REPAIR, 10, 20, 0));

  world.getRoomCurrent().add(new Build(Object.BUILD, new Wall(Object.WALL, 0, 15, 20, 0)));
  world.getRoomCurrent().add(new Build(Object.BUILD, new Miner(Object.DRILL, 16, 22, 0)));
  ItemProjectMap s= new ItemProjectMap (19,13, new Item (Item.KIT_REPAIR));
  world.getRoomCurrent().add(s);
Job job =new JobCraft(s);
  //===================
  d1=new Actor(Object.ACTOR, 1, 6);
d1.addJob(job);
  //d1.skills.append(Job.CARRY);
  //===================
  d2=new Actor(Object.ACTOR, 1, 4);
  d2.skills.append(Job.CARRY);

  //===================
  d3=new Actor(Object.ACTOR, 15, 4);
  //d3.skills.append(Job.MINE);
  d3.skills.append(Job.GUARD);

  //===================
  d4=new Actor(Object.ACTOR, 7, 0);
  d4.skills.append(Job.MINE);

  //===================
  d5=new Actor(Object.ACTOR, 7, 3);
  //d5.skills.append(Job.CARRY);
d5.skills.append(Job.GUARD);
  //========================
  d6=new Actor(Object.ACTOR, 4, 3);
  d6.skills.append(Job.BUILD);
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


void mouseClicked() {

  Room room=world.getRoomCurrent();
  if (mouseButton==LEFT) {
    if (world.isPermissionInput()) {
      if (world.isOverWindow()) {
        if (world.isOverMap()) {
          if (room.getObject(world.getMouseMapX(), world.getMouseMapY())!=null) {
            if (room.currentObject!=null ) 
              room.setNextCurrentObject(world.getMouseMapX(), world.getMouseMapY());
            else 
            room.setCurrentObject(world.getMouseMapX(), world.getMouseMapY());
          } else {
            room.resetSelect();
          }
        } else {
          room.resetSelect();
        }
      }
    }
  }
}

void mouseWheel(MouseEvent event) {
  if (world.isPermissionInput()) {
    float e = event.getCount();
    if (world.isOverWindow()) {
      if (e==-1) 
        world.setScaleUp();
      else if (e==1) 
        world.setScaleDown();
    } else {
      for (scrollable part : Interface.getScrollObjects()) {
        if (part.isMouseOver()) {
          if (e==-1) 
            part.scrollUp();
          else if (e==1) {
            part.scrollDown();
          }
          break;
        }
      }
    }
  }
}
void mousePressed() {
  if (world.isPermissionInput()) {
    if (mouseButton==RIGHT) {
      if (world.isOverWindow() && !world.isMoveUnlock()) {
        world.beginMove();
        world.setMoveUnlock(true);
      }
    }
  }
}

void mouseReleased() { 
  if (world.isPermissionInput())
    world.setMoveUnlock(false);
}


void mouseDragged() {
  if (world.isPermissionInput()) {
    if (mouseButton==RIGHT) {
      if (world.isMoveUnlock()) 
        world.mouseMove();
    }
  }
}

void keyPressed() {
  if (world.isPermissionInput()) {
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
