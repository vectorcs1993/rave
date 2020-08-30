Droid d1, d2, d3, d4, d5, d6;
PImage tile, droid, sprite_object_drill, sprite_object_well, sprite_object_fabrica, station_charge, station_repair, sprite_floor_steel, sprite_wall_steel, none, sprite_box_steel, sprite_box_wood, 
  sprite_item_steel, sprite_item_plate_steel, sprite_item_plate_copper,sprite_item_rubber, sprite_item_wood, sprite_item_oil, sprite_item_copper, sprite_block_steel, sprite_tree;
String time = "";
int time_cur;

ItemMap testItemMap;
Storage  testStorage;
void setup() {
  size(800, 600, P2D);
  smooth(4); 
  textFont(Interface.font = createFont("font/progress_pixel_bolt.ttf", 18));
  textLeading(24);
  strokeCap(SQUARE);
  tile = requestImage("sprites/tile_grass.png");
  sprite_floor_steel = requestImage("sprites/floor_steel.png");
  sprite_wall_steel = requestImage("sprites/wall_steel.png");
  sprite_box_steel = requestImage("sprites/storage_steel_box.png");
  sprite_box_wood = requestImage("sprites/storage_wood_box.png");
  none = requestImage("sprites/no_data.png");
  sprite_item_steel = requestImage("sprites/item_steel.png");
  droid = requestImage("sprites/droid.png");
  station_charge = requestImage("sprites/station_charge.png");
  station_repair = requestImage("sprites/station_repair.png");
  sprite_item_wood = requestImage("sprites/item_wood.png");
  sprite_item_copper = requestImage("sprites/item_copper.png");
  sprite_item_plate_steel = requestImage("sprites/item_plate_steel.png");
  sprite_item_plate_copper = requestImage("sprites/item_plate_copper.png");
  sprite_item_oil = requestImage("sprites/item_oil.png");
  sprite_item_rubber = requestImage("sprites/item_rubber.png");
  sprite_object_drill = requestImage("sprites/drill.png");
  sprite_object_well = requestImage("sprites/well.png");
  sprite_object_fabrica = requestImage("sprites/fabrica.png");
  sprite_block_steel = requestImage("sprites/block_steel.png");
  sprite_tree = requestImage("sprites/tree.png");
  playerFraction = new Fraction (0, "Robocraft");
  world = new World(5, 42, 12, 24, 32);

  world.getRoomCurrent().add(new Layer(Object.LAYER, Item.STEEL, 7, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 8, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 9, 8, 0));

  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 12, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 13, 8, 0));

  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 17, 8, 0));

  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 19, 8, 0));
  world.getRoomCurrent().add(new Layer(Object.LAYER, Item.STEEL, 20, 9, 0));
  world.getRoomCurrent().add(new Layer(Object.LAYER, Item.STEEL, 20, 10, 0));
  world.getRoomCurrent().add(new Layer(Object.LAYER, Item.STEEL, 21, 9, 0));
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
  world.getRoomCurrent().add(new Enviroment(Object.BLOCK, 13, 11, int(random(4)), Item.STEEL));
  world.getRoomCurrent().add(new Enviroment(Object.BLOCK, 18, 20, int(random(4)), Item.STEEL));
  world.getRoomCurrent().add(new Enviroment(Object.BLOCK, 17, 20, int(random(4)), Item.STEEL));

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

  world.getRoomCurrent().add(new Build(Object.BUILD, new Wall(Object.WALL, 0, 15, 20, 0)));
  world.getRoomCurrent().add(new Build(Object.BUILD, new Miner(Object.DRILL, 16, 22, 0)));

  //===================
  d1=new Droid(Object.ACTOR, 1, 6);
  //d1.skills.append(Job.GUARD);
  d1.skills.append(Job.CARRY);
  //===================
  d2=new Droid(Object.ACTOR, 1, 4);
  d2.skills.append(Job.CARRY);
  //===================
  d3=new Droid(Object.ACTOR, 15, 4);
  d3.skills.append(Job.MAINTENANCE);
  d3.skills.append(Job.GUARD);
  //===================
  d4=new Droid(Object.ACTOR, 7, 0);
  d4.skills.append(Job.MINE);
   d4.skills.append(Job.CARRY);
  d4.skills.append(Job.GUARD);
  //===================
  d5=new Droid(Object.ACTOR, 7, 3);
  d5.skills.append(Job.BUILD);
  //d5.skills.append(Job.MINE);
  d5.skills.append(Job.CARRY);
  //d5.skills.append(Job.MAINTENANCE);
  //========================
  d6=new Droid(Object.ACTOR, 4, 3);
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
  drawInterface();

  world.update();
  world.draw();
}


void mouseClicked() {
  Room room=world.getRoomCurrent();
  if (mouseButton==LEFT) {
    if ( world.isOverWindow()) {
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

void mouseWheel(MouseEvent event) {
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
void mousePressed() {
  Interface.update();
  if (mouseButton==RIGHT) {
    if (world.isOverWindow() && !world.isMoveUnlock()) {
      world.beginMove();
      world.setMoveUnlock(true);
    }
  }
}

void mouseReleased() { 
  world.setMoveUnlock(false);
}


void mouseDragged() {
  if (mouseButton==RIGHT) {
    if (world.isMoveUnlock()) {
      world.mouseMove();
    }
  }
}

void keyPressed() {
  if (keyCode==32) {
    world.pause=!world.pause;
    Room room=world.getRoomCurrent();

    if (world.isOverMap()) {
      if (room.currentObject instanceof ItemMap) {
        ItemMap item = (ItemMap)room.currentObject;
        item.lock=!item.lock;
      }
    }
  } else if (keyCode==82) {
    if (world.currentRoom.currentObject!=null)
      world.currentRoom.currentObject.setDirectionNext();
  } else if (keyCode==9) {
    world.showStatus=!world.showStatus;
  }
}
