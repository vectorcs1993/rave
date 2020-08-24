Droid d1, d2, d3, d4, d5;
PImage tile, droid, fabrica, station_charge, station_repair, sprite_floor_steel, sprite_wall_steel, none, sprite_box_steel, sprite_box_wood, 
sprite_item_steel, sprite_item_wood, sprite_item_cooper, sprite_block_steel;
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
  sprite_floor_steel = requestImage("sprites/floor_stone.png");
  sprite_wall_steel = requestImage("sprites/wall_steel.png");
  sprite_box_steel = requestImage("sprites/storage_steel_box.png");
  sprite_box_wood = requestImage("sprites/storage_wood_box.png");
  none = requestImage("sprites/no_data.png");
  sprite_item_steel = requestImage("sprites/item_steel.png");
  droid = requestImage("sprites/droid.png");
  station_charge = requestImage("sprites/station_charge.png");
  station_repair = requestImage("sprites/station_repair.png");
  sprite_item_wood = requestImage("sprites/item_wood.png");
  sprite_item_cooper = requestImage("sprites/item_cooper.png");
  fabrica = requestImage("sprites/fabrica.png");
  sprite_block_steel = requestImage("sprites/block_steel.png");
  playerFraction = new Fraction (0, "Robocraft");
  world = new World(5, 42, 12, 24, 32);

  world.getRoomCurrent().add(new Layer(Object.LAYER, Item.STEEL, 7, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 8, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 9, 8, 0));

  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 12, 8, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 13, 8, 0));

  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 17, 8, 0));

  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 19, 8, 0));
  world.getRoomCurrent().add(new Layer(Object.LAYER,  Item.STEEL, 20, 9,0));
  world.getRoomCurrent().add(new Layer(Object.LAYER,  Item.STEEL, 20, 10, 0));
  world.getRoomCurrent().add(new Layer(Object.LAYER,  Item.STEEL, 21, 9, 0));
  world.getRoomCurrent().add(new Wall(Object.WALL, 0, 20, 9, 0));

  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 0, 0, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 6, 12, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 7, 12, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 21, 7, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 9, 12, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 18, 9, 0));

  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 20, 20, 0));
  world.getRoomCurrent().add(new Storage(Object.STORAGE, Item.STEEL, 4, 20, 0));

  world.getRoomCurrent().add(new Miner(Object.MINER, 6, 6,  0));
  world.getRoomCurrent().add(new Miner(Object.MINER, 7, 6, 0));
  world.getRoomCurrent().add(new Miner(Object.MINER, 9, 6, 0));

  world.getRoomCurrent().add(new Enviroment(Object.BLOCK, 20, 21, int(random(4)),Item.STEEL));
world.getRoomCurrent().add(new Enviroment(Object.BLOCK, 19, 20, int(random(4)),Item.STEEL));
world.getRoomCurrent().add(new Enviroment(Object.BLOCK,18, 20, int(random(4)),Item.STEEL));
world.getRoomCurrent().add(new Enviroment(Object.BLOCK, 17, 20, int(random(4)),Item.STEEL));

  world.getRoomCurrent().add(new Support(Object.CHARGE, 8, 20, 0));
  world.getRoomCurrent().add(new Support(Object.CHARGE, 9, 20, 0));
  world.getRoomCurrent().add(new Support(Object.REPAIR, 10, 20, 0));
  
  world.getRoomCurrent().add(new Build(Object.BUILD, new Wall(Object.WALL, 0, 15, 20, 0)));
 world.getRoomCurrent().add(new Build(Object.BUILD, new Miner(Object.MINER, 16, 22,  0)));
  //===================
  d1=new Droid(Object.ACTOR, 1, 6);
  d1.skills.append(Job.GUARD);

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
 d4.skills.append(Job.GUARD);
  //===================
  d5=new Droid(Object.ACTOR, 7, 3);
  d5.skills.append(Job.BUILD);
   d5.skills.append(Job.CARRY);
 
world.getRoomCurrent().add(d1);
  world.getRoomCurrent().add(d3);
  world.getRoomCurrent().add(d2);
  world.getRoomCurrent().add(d4);
 world.getRoomCurrent().add(d5);
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
      if (room.currentObject instanceof Droid) {
        Droid droid = (Droid)room.currentObject;
        //droid.moveTo(world.getMouseMapX(), world.getMouseMapY());
      }
    }
  } else if (keyCode==82) {
    if (world.currentRoom.currentObject!=null)
      world.currentRoom.currentObject.setDirectionNext();
  } else if (keyCode==9) {
    world.showStatus=!world.showStatus;
  }
}
