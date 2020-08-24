
interface listened {
  public void drawList();
}

interface cloneable {
  public cloneable clone();
}

abstract class Object implements listened {
  protected final int id, _id;
  protected int x, y, direction, transparent, hp, hpMax;
  protected String name;
  protected PImage sprite;
  protected Timer timerTick; 
  protected Fraction fraction;
  public final static int MINER=0, ITEM=1, LAYER=2, WALL=3, DOOR=4, 
    STORAGE=5, BLOCK=6, REPAIR=7, CHARGE=8, BENCH=9, FLAG=10, BUILD=11, TREE=12, ACTOR=13;  //классификация по id

  Object (int id, int x, int y) {
    _id=world.getNewId();
    this.id=id;
    this.x=x;
    this.y=y;
    this.timerTick=new Timer();
    transparent = 255;
    hp=50+(int)random(50);
    hpMax=100;
    timers.add(timerTick);
    fraction = null;
    name = getNameDatabase(id);
  }
  public void drawList() {
    text(name, 0, 0);
  }
  Object (int id, int x, int y, int direction) {
    this(id, x, y);
    this.direction=direction;
  }

  public void setFraction(Fraction fraction) {
    this.fraction=fraction;
  }
  protected String getDescriptFraction() {
    if (fraction==null)
      return text_no;
    else 
    return fraction.name;
  }
  public String getName() {
    return name;
  }
  public String getNameShort() {
    return getName();
  }
  protected String getHpStatus() {
    return hp+"/"+hpMax;
  }
  protected int getTick() {
    return 0;
  }
  protected abstract String getDescript();
  protected void tick() {
    if (!timerTick.check() && !world.pause) {
      update();
      timerTick.set(getTick());
    }
  }

  public void draw() {
    beginDraw();
    endDraw();
  }
  abstract protected PImage getSpriteDatabase();
  protected String getNameDatabase(int id) {
    switch (id) {
    case MINER: 
      return text_object_miner;
    case REPAIR: 
      return text_object_repair;
    case CHARGE: 
      return text_object_charge;
    case WALL: 
      return text_object_wall;
    case LAYER: 
      return text_object_layer;
    case STORAGE: 
      return text_object_storage;
    case BUILD: 
      return text_object_project;
    case ITEM: 
      return text_object_item;
    case BLOCK: 
      return text_object_block;
    case TREE: 
      return text_object_tree;
    case ACTOR: 
      return text_object_actor;
    default: 
      return text_no_name;
    }
  }
  public ItemIntList  getRecieptDatabase() {
    return null;
  }
  protected void delete() {
    world.currentRoom.node[x][y].solid=false;
  }

  protected void beginDraw() {
    pushMatrix();
    pushStyle();
    tint(white, transparent);
    translate(x*world.grid_size+(world.grid_size/2), y*world.grid_size+(world.grid_size/2));
    rotate(getDirectionRad(direction));
    image(sprite, -world.grid_size/2, -world.grid_size/2);
  }
  protected void endDraw() {
    popStyle();
    popMatrix();
  }
  public void control() {
    tick();
    this.draw();
  }
  public abstract void update();
  public int getRotateMax() {
    return 3;
  }
  public void drawHealthStatus() {
    if (hp<hpMax) 
      drawStatus(5, hp, hpMax, green, red);
  }
  public void drawLine(int x1, int y1, int x2, int y2, color c) {
    pushStyle();
    strokeWeight(3);
    stroke(c);
    line(world.getAbsX(x1), world.getAbsY(y1), world.getAbsX(x2), world.getAbsY(y2));
    popStyle();
  }
  public void drawStatus(int ty, float a, float b, color one, color two) {
    if (a<b) {
      pushStyle();
      pushMatrix();
      strokeWeight(3);
      translate(x*world.grid_size, y*world.grid_size);
      stroke(one);
      float xMax = map(a, 0, b, 2, world.grid_size-2);
      line(2, ty, xMax, ty);
      stroke(two);
      line(xMax, ty, world.grid_size-2, ty);
      popMatrix();
      popStyle();
    }
  }
  public void drawPlace(int x, int y) {
    pushStyle();
    noFill();
    strokeWeight(3);
    stroke(blue);
    rect(x*world.grid_size+3, y*world.grid_size+3, world.grid_size-6, world.grid_size-6);
    popStyle();
  }
  protected int getDirectionRandom() {
    return int(random(getRotateMax()+1));
  }


  public void setDirectionNext() {
    if (direction<getRotateMax()) 
      direction++;
    else 
    direction=0;
  }
  protected float getDirectionRad(int dir) {
    dir=constrain(dir, 0, 7);
    switch (dir) {
    case 1: 
      return radians(90);
    case 2:  
      return radians(180);
    case 3:  
      return radians(270);
    case 4:  
      return radians(45);
    case 5:  
      return radians(135);
    case 6:  
      return radians(-135);
    case 7:  
      return radians(-45);
    default:  
      return radians(0);
    }
  }

  public void drawSelected () {
    pushStyle();
    noFill();
    strokeWeight(3);
    rect(x*world.grid_size, y*world.grid_size, world.grid_size, world.grid_size);
    popStyle();
  }
} 

class Layer extends Object {
  final Item material;

  Layer(int id, int material, int x, int y, int direction) {
    super (id, x, y, direction);
    this.material=new Item (material);
    world.currentRoom.node[x][y].solid=false;
    sprite = getSpriteDatabase();
  }

  public String getNameShort() {
    return getName()+" ("+material.getName()+")";
  }
  public void update() {
  }
  protected String getDescript() {
    return text_name+": "+getName()+"\n"+
      text_status+": "+getHpStatus()+"\n"+
      text_material+": "+material.getName()+"\n";
  }
  protected void endDraw() {
    super.endDraw();
    drawHealthStatus();
  }
  protected PImage getSpriteDatabase() {
    if (material!=null) {
      switch (material.id) {
      case Item.STEEL:
        return sprite_floor_steel;
      case Item.WOOD:
        return sprite_floor_steel;
      default:
        return none;
      }
    } 
    return none;
  }
  public ItemIntList  getRecieptDatabase() {
    ItemIntList resources = new ItemIntList();
    for (int i=0; i<2; i++)
      resources.append(Item.STEEL);
    return resources;
  }
}

class Wall extends Layer {
  Wall(int id, int material, int x, int y, int direction) {
    super (id, material, x, y, direction);
    world.currentRoom.node[x][y].solid=true;
  }
  protected PImage getSpriteDatabase() {
    if (material!=null) {
      switch (material.id) {
      case Item.STEEL:
        return sprite_wall_steel;
      case Item.WOOD:
        return sprite_wall_steel;
      default:
        return none;
      }
    } 
    return none;
  }
  public ItemIntList  getRecieptDatabase() {
    ItemIntList resources = new ItemIntList();
    for (int i=0; i<4; i++)
      resources.append(Item.STEEL);
    return resources;
  }
}

class Enviroment extends Object {
  Item resource;
  int count;

  Enviroment(int id, int x, int y, int direction, int resource) {
    this(id, x, y, direction);
    this.resource = new Item(resource);
  }
  Enviroment(int id, int x, int y, int direction) {
    super(id, x, y, direction);
    count=getCountResourcesDatabase();
    sprite = getSpriteDatabase();
    world.currentRoom.node[x][y].solid=true;
  }
  public void update() {
  }
  protected String getDescript() {
    return text_name+": "+getName()+"\n"+
      text_status+": "+getHpStatus()+"\n"+
      text_resource+": "+resource.getName()+" ("+count+")\n";
  }
  public int getCountResourcesDatabase() {
    return (int)random(1, 5);
  }
  protected void delete() {
    super.delete();
    world.currentRoom.addItemHere(x, y, (Item)resource.clone(), count);
  }
  protected void endDraw() {
    super.endDraw();
    drawStatus(5, hp, hpMax, green, red);
  }

  protected PImage getSpriteDatabase() {
    switch (id) {
    case BLOCK:
      return sprite_block_steel;
    case TREE:
      return sprite_block_steel;
    default:
      return none;
    }
  }
}



class ItemMap extends Object {
  Item item;
  int count;
  boolean lock;
  ItemMap (int x, int y, Item item, int count) {
    super (ITEM, x, y);
    this.item = item;
    this.count=count;
    lock = false;
    sprite = getSpriteDatabase();
  }
  public int getRotateMax() {
    return 0;
  }
  protected void endDraw() { 
    if (count>1) {
      textSize(10);
      textAlign(RIGHT, BOTTOM);
      text(count, world.grid_size/2-3, world.grid_size/2+2);
    }
    popStyle();
    popMatrix();
  }
  protected String getDescript() {
    return getName() +": "+item.name+"\n"+
      text_count+": "+count+"\n"+
      text_stack+": "+item.stack+"\n"+
      text_weight+": "+item.weight+" (общий: "+item.weight*count+")"+"\n";
  }
  protected PImage getSpriteDatabase() {
    if (item!=null)
      return item.sprite;
    else 
    return none;
  }
  public void update() {
    if (count>item.stack) {
      int adj = count-item.stack;
      world.currentRoom.addItemOrder(x, y, item, adj);
      count-= adj;
    }
  }
}

class Storage extends Wall {
  ItemList items = new ItemList();
  int capacity;
  Storage (int id, int material, int x, int y, int direction) {
    super (id, material, x, y, direction);
    capacity = getCapacityDatabase();
  }
  public int getCapacity() {
    int capacity = 0;
    for (Item item : items) 
      capacity+=item.weight;
    return capacity;
  }
  private int getCapacityDatabase() {
    switch (material.id) {
    case Item.STEEL: 
      return 60;
    case Item.WOOD: 
      return 40;
    default: 
      return 10;
    }
  }
  public boolean isFreeCapacity() {
    if (getCapacity()<capacity) 
      return true;
    else
      return false;
  }
  public boolean isFreeCapacity(int count) {
    if (getCapacity()+count<=capacity) 
      return true;
    else
      return false;
  }

  public int getFreeCapacity() {
    return capacity-getCapacity();
  }
  public boolean add(Item item) {
    if (getCapacity()+item.weight<=capacity) {
      items.add(item);
      return true;
    } else 
    return false;
  }
  protected PImage getSpriteDatabase() {
    if (material!=null) {
      switch (material.id) {
      case Item.STEEL:
        return sprite_box_steel;
      case Item.WOOD:
        return sprite_box_wood;
      default:
        return none;
      }
    } 
    return none;
  }
  public void add(Item [] itemsList) {
    for (Item item : itemsList) 
      items.add(item);
  }
  private String getListNames() {
    if (items.isEmpty())
      return text_empty;
    else 
    return items.getNames();
  }
  protected String getDescript() {
    return super.getDescript()+
      text_capacity+": "+getCapacity()+"/"+capacity+"\n"+
      text_items+": "+getListNames()+"\n";
  }
}



class Miner extends Enviroment {
  int progress, progressMax;
  Room.Sector sector;

  Miner (int id, int x, int y, int direction) {
    super(id, x, y, direction); //убрать инициализацию ресурсы
    progress=0;
    progressMax=10;
    count=2;
    sector=world.currentRoom.getSector(x, y);
    resource=new Item (sector.resource);
  }
  protected int getTick() {
    return 50;
  }
  protected PImage getSpriteDatabase() {
    return fabrica;
  }
  private boolean isPlaceRersource() {
    if (sector.count>0) {
      ArrayList <Object> objects = world.currentRoom.getObjects(getPlace(x, y, direction)[0], getPlace(x, y, direction)[1]);
      if (objects.isEmpty()) 
        return true;
      else {
        Object current = objects.get(0);
        if (current instanceof Storage) {
          if (((Storage)current).isFreeCapacity())
            return true;
          else 
          return false;
        } else if (current instanceof ItemMap) {
          ItemMap itemMap = (ItemMap)current;
          if (itemMap.item.id==resource.id && itemMap.count<=resource.stack-count) 
            return true;
          else 
          return false;
        } else 
        return false;
      }
    } else 
    return false;
  }

  public void setDirectionNext() {
    if (direction<3) 
      direction++;
    else 
    direction=0;
  }
  public void update() {
    if (progress<progressMax) {
      if (isPlaceRersource())
        progress++;
    } else {
      progress=0;
      if (isPlaceRersource()) {
        int newCount = constrain(count, 1, sector.count);
        world.getRoomCurrent().addItemHere(getPlace(x, y, direction)[0], getPlace(x, y, direction)[1], (Item)resource.clone(), newCount);
        sector.count-=newCount;
      }
    }
  }
  protected void endDraw() {
    super.endDraw();
    drawStatus(5, hp, hpMax, green, red);
    drawStatus(9, progress, progressMax, yellow, red);
  }
  private String isPlaceFree() {
    if (!isPlaceRersource()) {
      if (sector.count<=0)
        return text_no_resources;
      else
        return text_no_place_free;
    } else 
    return text_in_process;
  }
  private String isResource() {
    if (sector.count>0)
      return getItemNameDatabase(sector.resource)+" ("+sector.count+")";
    else
      return text_empty;
  }

  protected String getDescript() {
    return text_name+": "+getName()+"\n"+
      text_status+": "+getHpStatus()+"\n"+
      text_recources+": "+isResource()+"\n"+
      text_productivity+": "+count+"\n"+
      text_progress+": "+getPercent(progress, progressMax, 100)+" %\n"+isPlaceFree()+"\n";
  }
  public void drawSelected () {
    super.drawSelected();
    drawPlace(getPlace(x, y, direction)[0], getPlace(x, y, direction)[1]);
  }

  public ItemIntList  getRecieptDatabase() {
    ItemIntList resources = new ItemIntList();
    for (int i=0; i<4; i++) 
      resources.append(Item.STEEL);
    for (int i=0; i<10; i++) 
      resources.append(Item.COOPER);
    return resources;
  }
}


class Droid extends Object {
  private int speed, radiusView, carryingCapacity, pathFull;
  private float  energy, energyMax, energyLeak;
  private GraphList path;
  private Graph target, nextNode;
  private Job job;
  public ItemList items;
  public IntList skills;

  Droid (int id, int x, int y) {
    super(id, x, y);
    speed=40;//+int(random(1000));
    radiusView=int(random(5))+1;  //мин-1, макс-5
    direction=int(random(3));
    setFraction(playerFraction);
    path = new GraphList ();
    pathFull = 0;
    target = nextNode = null;
    energyMax=getEnergyDatabase();
    energy=energyMax/4;
    energyLeak=0.01+random(0.09);
    items = new ItemList();
    job=null;
    carryingCapacity=1;//(int)random(9)+1;
    skills = new IntList ();
    sprite = getSpriteDatabase();
  }
  protected String getNameDatabase(int id) {
    return super.getNameDatabase(id)+" "+str(_id);
  }
  protected PImage getSpriteDatabase() {
    return droid;
  }
  public float getEnergyDatabase() {
    return 50+random(49)+1;
  }
  private String getListNames() {
    if (items.isEmpty())
      return text_empty;
    else 
    return items.getNames();
  }
  public void addJob(Job job) {
    job.setWorker(this);
    this.job=job;
    fraction.jobs.add(job);
  }
  private String getCurrentJob() {
    if (job!=null) {
      return  job.name+"\n"+
        "("+job.getDescript()+")";
    } else return text_no;
  }
  public String getDescript() {
    return text_name+": "+name+"\n"+
      text_status+": "+getHpStatus()+"\n"+
      text_job+": "+getCurrentJob()+"\n"+
      text_items+": "+getListNames()+"\n"+
      text_fraction+": "+getDescriptFraction()+"\n"+
      text_speed+": "+getSpeedAbs(speed)+" ("+speed+")"+"\n"+
      text_energy+": "+energy*100/energyMax+" %\n"+
      text_leak+": -"+energyLeak+" %\n"+
      text_radius+": "+radiusView+"\n"+
      text_carrying_capacity+": "+carryingCapacity+"\n"+
      text_skills+": "+getSkillsJob();
  }

  private String getSkillsJob() {
    if (skills.size()>0) {
      String text="";
      for (int i : skills) {
        if (i==Job.CARRY)
          text+=text_carry+"\n";
        else if (i==Job.MAINTENANCE)
          text+=text_maintenance+"\n";
        else if (i==Job.GUARD)
          text+=text_guard+"\n";
        else if (i==Job.MINE)
          text+=text_mine+"\n";
        else if (i==Job.BUILD)
          text+=text_build+"\n";
      } 
      return  text;
    } else return text_no;
  }
  protected int getTick() {
    if (energy>0)
      return speed;
    else 
    return 1000;
  }
  float getSpeedAbs(int speed) {
    return map(speed, 20, 1000, 10, 1);
  }
  public void update() {
    if (job!=null) { //если есть работа для выполнения
      job.update(); //обновляет выполнение текущей работы
      if (job.isComplete()) { //проверяет завершена ли она 
        fraction.removeJob(job);
        job.worker=null;
        job=null;
      }
    }
  }
  public boolean isAlarmHealth() {
    if (hp<hpMax*0.8)
      return true;
    else
      return false;
  }
  public boolean isAlarmEnergy() {
    if (energy<energyMax*0.2)
      return true;
    else
      return false;
  }
  public void moveTo(int x, int y) {
    if (!world.currentRoom.node[x][y].solid) {
      target=world.currentRoom.node[x][y];
      if (path!=null) 
        path.clear();
      path=getPathTo(world.currentRoom.node[this.x][this.y], world.currentRoom.node[x][y]);
      pathFull=path.size();
      if (path!=null) 
        if (!path.isEmpty())
          target=path.get(0);
    }
  }
  void moveNextPoint() {
    if (!path.isEmpty()) {
      nextNode=path.get(path.size()-1);
      if (direction!=getDirectionToObject(nextNode.x, nextNode.y)) {
        setDirection(nextNode.x, nextNode.y);
      } else {
        moveTo(nextNode);
        path.remove(nextNode);
      }
      setEnergy();
    }
  }
  public void setEnergy() {
    energy-=energyLeak;
    energy=constrain(energy, 0, energyMax);
  }
  private void setDirection(int x, int y) {
    if (x<this.x && y==this.y)
      direction=3;
    if (x>this.x && y==this.y)
      direction=1;
    if (y<this.y && x==this.x)
      direction=0;
    if (y>this.y && x==this.x)
      direction=2;
    if (y<this.y && x<this.x)
      direction=7;
    if (y<this.y && x>this.x)
      direction=4;
    if (y>this.y && x>this.x)
      direction=5;
    if (y>this.y && x<this.x)
      direction=6;
  }
  public void moveTo(Graph object) {
    if (object.x<x && object.y==y) { //влево          270              
      x-=1;
    } else if (object.x>x && object.y==y) {       //вправо 90
      x+=1;
    } else if (object.y<y && object.x==x) {      //вверх 0
      y-=1;
    } else if (object.y>y && object.x==x) {   //вниз 180
      y+=1;
    } else if (object.x<x && object.y<y) {  //влево  и вверх -45                      
      x-=1;
      y-=1;
    } else if (object.x>x && object.y<y) {  //вправо и вверх 45                      
      x+=1;
      y-=1;
    } else if (object.x>x && object.y>y) { //вправо и вниз 135                      
      x+=1;
      y+=1;
    } else if (object.x<x && object.y>y) {  //влево и вниз -135                      
      x-=1;
      y+=1;
    } 
    x=constrain(object.x, 0, world.getSize()-1);                             
    y=constrain(object.y, 0, world.getSize()-1);
  }
  protected void endDraw() {
    super.endDraw();
    drawHealthStatus();
    drawEnergyStatus();
  }
  private void drawView() { //отображает секту прямой видимости
    pushMatrix();
    translate(x*world.grid_size, y*world.grid_size);
    pushStyle();
    strokeWeight(4);

    for (int l=0; l<matrixLine.length; l++) {
      int px=x, py=y;
      for (int i=0; i<constrain(radiusView, 1, matrixLine[l].length); i++) { 
        int ix=matrixShearch[matrixLine[l][i]][0];
        int iy=matrixShearch[matrixLine[l][i]][1];
        int gx=constrain(x+ix, 0, world.getSize()-1);
        int gy=constrain(y+iy, 0, world.getSize()-1);
        if (!getApplyDiagonalMove(gx, gy, px, py))
          break;
        else {
          px=gx;
          py=gy;
        }
        if ((ix!=0 || iy!=0) && ix>=-x && iy>=-y && x+ix<=world.getSize()-1 && iy+y<=world.getSize()-1) {  
          if (world.currentRoom.getObject(gx, gy) instanceof Droid) {
            stroke(red);
            line(world.grid_size/2, world.grid_size/2, world.getAbsX(ix), world.getAbsY(iy) );
          } else 
          stroke(white);
          pushMatrix();
          translate(ix*world.grid_size, iy*world.grid_size);  
          point(world.grid_size/2, world.grid_size/2);
          popMatrix();
        }
        if (world.currentRoom.node[gx][gy].solid)
          break;
      }
    }
    popStyle();
    popMatrix();
  }

  private int getDirectionToObject(int x, int y) {
    if (x<this.x && y==this.y)
      return 3;
    if (x>this.x && y==this.y)
      return 1;
    if (y<this.y && x==this.x)
      return 0;
    if (y>this.y && x==this.x)
      return 2;
    if (y<this.y && x<this.x)
      return 7;
    if (y<this.y && x>this.x)
      return 4;
    if (y>this.y && x>this.x)
      return 5;
    if (y>this.y && x<this.x)
      return 6;
    else 
    return -1;
  }
  protected void drawEnergyStatus() {
    drawStatus(9, energy, energyMax, blue, red);
  }
  public void drawPath() {   //функция отображает путь выбранного персонажа
    if (target!=null) {
      pushMatrix();
      translate(target.x*world.grid_size, target.y*world.grid_size);
      noFill();
      strokeWeight(3);
      stroke(blue);
      rect(0, 0, world.grid_size, world.grid_size);
      popMatrix();
    }
    noFill();
    strokeWeight(2);
    stroke(white);
    if (path!=null) {
      if (!path.isEmpty()) {
        line(world.getAbsX(x), world.getAbsY(y), world.getAbsX(path.get(path.size()-1).x), world.getAbsY(path.get(path.size()-1).y) );
        int sizeMap= path.size()-1;
        for (int i=0; i<sizeMap; i++) {
          Graph next = path.get(i);
          Graph part = path.get(i+1);
          line(world.getAbsX(next.x), world.getAbsY(next.y), world.getAbsX(part.x), world.getAbsY(part.y));
        }
      }
    }
  }
}


class Support extends Object {
  Droid user;

  Support (int id, int x, int y, int direction) {
    super(id, x, y, direction);
    sprite = getSpriteDatabase();
    world.currentRoom.node[x][y].solid=true;
    user=null;
  }
  public void update() {
    if (isPlaceUser()) {
      if (id==Object.CHARGE) {
        user.energy+=0.1;
      } else if (id==Object.REPAIR)
        user.hp++;
    }
  }
  private boolean isPlaceUser() {
    if (user!=null) {
      if (user.x==getPlace(x, y, direction)[0] && user.y==getPlace(x, y, direction)[1])
        return true;
      else
        return false;
    } else
      return false;
  }
  public boolean isComplete() {
    if (user!=null) {
      if (id==Object.CHARGE) {
        if (user.energy>=user.energyMax) {
          user=null;
          return true;
        } else
          return false;
      } else if (id==Object.REPAIR) {
        if (user.hp>=user.hpMax) {
          user=null;
          return true;
        } else
          return false;
      } else
        return false;
    } else 
    return false;
  }
  protected int getTick() {
    return 5;
  }
  private String getUserDescript() {
    if (user!=null)
      return user.name;
    else 
    return text_nobody;
  }
  protected PImage getSpriteDatabase() {
    switch (id) {
    case Object.CHARGE: 
      return station_charge;
    case Object.REPAIR: 
      return station_repair;
    }
    return none;
  }

  protected String getDescript() {
    return text_name+": "+getName()+"\n"+
      text_status+": "+getHpStatus()+"\n"+
      text_user+": "+getUserDescript()+"\n";
  }
  protected void endDraw() {
    super.endDraw();
    drawHealthStatus();
    if (isPlaceUser())
      drawLine(x, y, user.x, user.y, blue);
  }
  public void drawSelected () {
    super.drawSelected();
    drawPlace(getPlace(x, y, direction)[0], getPlace(x, y, direction)[1]);
  }
}



class Build extends Object {
  Object build;
  ItemIntList reciept;

  Build (int id, Object build) {
    super(id, build.x, build.y, build.direction);
    this.build=build;
    hp=0;
    sprite = getSpriteDatabase();
    reciept = build.getRecieptDatabase();
  }
  protected String getDescript() {
    return text_name+": "+getName()+"\n"+
      text_status+": "+getHpStatus()+"\n"+
      text_object_build+": "+getBuildDescript()+"\n"+
      text_reciept+": "+reciept.getNames()+"\n";
  }
  private String getBuildDescript() {
    return build.getNameShort();
  }
  protected PImage getSpriteDatabase() {
    if (build!=null)
      return build.sprite;
    else
      return none;
  }
  public void update() {
    build.hp=hp; 
    transparent=(int)map(build.hp, 0, build.hpMax, 70, 255);
  }
  protected void endDraw() {
    super.endDraw();
    drawHealthStatus();
  }
}





class ObjectList extends ArrayList <Object> {

  public Object getEntryBottom() {
    for (Object object : this) {
      if (object instanceof Droid || object instanceof Storage || object instanceof Wall)
        return object;
    }
    return null;
  }

  public ObjectList getDroidListJobFree() {
    ObjectList droids = new ObjectList ();
    for (Object object : this) {
      if (object instanceof Droid) {
        Droid droid = (Droid) object;
        if (droid.job==null)
          droids.add(object);
      }
    }
    return droids;
  }
  public ObjectList getDroidList() {
    ObjectList droids = new ObjectList ();
    for (Object object : this) {
      if (object instanceof Droid) 
        droids.add(object);
    }
    return droids;
  }
  public Droid getDroidJobFree() {
    for (Object object : this) {
      if (object instanceof Droid) {
        Droid droid = (Droid) object;
        if (droid.job==null)
          return droid;
      }
    }
    return null;
  }

  public Storage getStorageFree() {
    for (Object object : this) {
      if (object instanceof Storage) {
        Storage storage = (Storage) object;
        if (storage.getCapacity()<storage.capacity)
          return storage;
      }
    }
    return null;
  }

  public Support getSupportFree(int type) {
    for (Object object : this) {
      if (object instanceof Support && object.id==type) {
        Support support = (Support) object;
        if (support.user==null)
          return support;
      }
    }
    return null;
  }

  public ObjectList getEnviroments() {
    ObjectList objects= new ObjectList();
    for (Object object : this) {
      if (object instanceof Enviroment && !(object instanceof Miner))
        objects.add(object);
    }
    return objects;
  }


  public Object getObjectDamaged() {
    for (Object object : this) {
      if (object.hp<object.hpMax)
        return object;
    }
    return null;
  }
  public Object getObjectBuild() {
    for (Object object : this) {
      if (object instanceof Build)
        return object;
    }
    return null;
  }
  public ObjectList getObjectsPermissionRepair() {
    ObjectList objectsNoDroids= new ObjectList();
    for (Object object : this) {
      if ((!(object instanceof Droid) && !(object instanceof Enviroment)) || (object instanceof Miner))
        objectsNoDroids.add(object);
    }
    return objectsNoDroids;
  }

  public Object getObjectsPermissionMine() {
    for (Object object : this) {
      //здесь будет условие определяющие какой объект окружения помечен на удаление
      return object;
    }
    return null;
  }

  public Object getNearestObject(int tx, int ty) {
    float [] dist=new float [this.size()];
    for (int i=0; i<this.size(); i++) 
      dist[i]=dist(this.get(i).x, this.get(i).y, tx, ty);
    for (Object part : this) {
      if (part instanceof Storage) {
        float tdist = dist(part.x, part.y, tx, ty);
        if (tdist==min(dist)) 
          return part;
      }
    }

    return null;
  }




  public ObjectList getItemsFree() {
    ObjectList items = new ObjectList();
    for (Object partItem : this) {
      ItemMap itemMap = (ItemMap) partItem;



      if (playerFraction.jobs.isEmpty()) {
        items.add(itemMap);
      } else {
        for (Job job : playerFraction.jobs) {
          if (job instanceof JobCarry) {
            JobCarry jobTrans = (JobCarry) job;
            if (!itemMap.equals(jobTrans.itemMap)) 
              items.add(itemMap);
          }
        }
      }
    }
    return items;
  }


  public ObjectList getItemMapList() {
    ObjectList items = new ObjectList();
    for (Object object : this) {
      if (object instanceof ItemMap) 
        items.add(object);
    }
    return items;
  }
}
