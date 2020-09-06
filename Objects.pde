
interface listened {
  public void drawList();
}
interface renamed {
  public String getName();
  public void setName(String name);
}
interface rotated {
  public void setDirectionNext();
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
  public final static int  ITEM=1, LAYER=2, WALL=3, DOOR=4, 
    STORAGE=5, BLOCK=6, REPAIR=7, CHARGE=8, BENCH=9, FLAG=10, BUILD=11, TREE=12, ACTOR=13, DRILL=14, WELL=15, FABRICA=16, POINT_GUARD=17, 
    POINT_STAND=18;  //классификация по id

  public final static int  ROTATE0=0, ROTATE90=1, ROTETE180=2, ROTATE270=3;  //углы поворота
  protected Job job;

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
    job=null;
  }
  public void drawList() {
    text(name, 0, 0);
  }
  Object (int id, int x, int y, int direction) {
    this(id, x, y);
    this.direction=direction;
  }
  protected String isJob() {
    if (job!=null)
      if (job.worker!=null)
        return job.name+" \n("+job.worker.name+")";
      else
        return job.name;
    else 
    return text_no;
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
  public void setName(String name) {
    this.name=name;
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
    case DRILL: 
      return text_object_drill;
    case WELL: 
      return text_object_well;
    case FABRICA: 
      return text_object_fabrica;
    case BENCH: 
      return text_object_bench;
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
    case POINT_GUARD: 
      return text_object_point_guard;
    case POINT_STAND: 
      return text_object_point_stand;
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
  public void update() {
  }
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
  protected void drawCount(int count) {
    pushMatrix();
    translate(x*world.grid_size, y*world.grid_size);
    pushStyle();
    textSize(10);
    textAlign(RIGHT, BOTTOM);
    fill(white);
    text(count, world.grid_size-3, world.grid_size+2);
    popStyle();  
    popMatrix();
  }
  protected void drawLock() {
    pushMatrix();
    translate(x*world.grid_size, y*world.grid_size);
    pushStyle();
    strokeWeight(3);
    stroke(red);
    line(5, 5, world.grid_size-5, world.grid_size-5);
    line(world.grid_size-5, 5, 5, world.grid_size-5);
    popStyle();  
    popMatrix();
  }

  public void drawIndicator(boolean status) {
    if (status)
      fill(green);
    else
      fill(red);
    stroke(black);
    rect(3, 0, 5, 5);
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

class Layer extends Object implements rotated {
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
  protected String getDescript() {
    return text_name+": "+getName()+"\n"+
      text_status+": "+getHpStatus()+"\n"+
      text_material+": "+material.getName()+"\n"+
      text_job+": "+isJob()+"\n";
  }
  protected void endDraw() {
    super.endDraw();
    drawHealthStatus();
  }

  protected PImage getSpriteDatabase() {
    if (material!=null) {
      switch (material.id) {
      case Item.PLATE_STEEL:
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

class Flag extends Object implements rotated {
  protected Actor user;

  Flag (int id, int x, int y) {
    super (id, x, y, 0);
    user=null;
    world.currentRoom.node[x][y].solid=false;
    sprite = getSpriteDatabase();
  }

  private String isStand() {
    if (user!=null) 
      return user.name;
    else
      return text_nobody;
  }

  public void update () {
    if (user!=null) {
      if (user.x==x && user.y==y && user.job!=null)
        user=null;
    }
  }

  protected String getDescript() {
    return text_name+": "+getName()+"\n"+
      text_user+": "+isStand()+"\n";
  }

  protected PImage getSpriteDatabase() {
    switch (id) {
    case POINT_GUARD:
      return sprite_object_point_guard;
    case POINT_STAND:
      return sprite_object_point_stand;
    default:
      return none;
    }
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
  protected Item product;
  protected int count;

  Enviroment(int id, int x, int y, int direction, int product) {
    this(id, x, y, direction);
    this.product = new Item(product);
  }
  Enviroment(int id, int x, int y, int direction) {
    super(id, x, y, direction);
    count=getCountResourcesDatabase();
    world.currentRoom.node[x][y].solid=true;
    sprite = getSpriteDatabase();
  }
  protected String getDescript() {
    return text_name+": "+getName()+"\n"+
      text_status+": "+getHpStatus()+"\n"+
      text_resource+": "+product.getName()+" ("+count+")\n"+
      text_job+": "+isJob()+"\n";
  }
  public int getCountResourcesDatabase() {
    return (int)random(1, 5);
  }
  protected void delete() {
    super.delete();
    world.currentRoom.addItemHere(x, y, (Item)product.clone(), count);
  }
  protected void endDraw() {
    super.endDraw();
    if (id==BLOCK && product!=null) {
      pushMatrix();
      translate(x*world.grid_size, y*world.grid_size);
      image(product.sprite, 4, 4, 24, 24);
      popMatrix();
    }
    drawStatus(5, hp, hpMax, green, red);
  }

  protected PImage getSpriteDatabase() {
    if (id==BLOCK) {
      return sprite_block;
    } else if (id==TREE) 
      return sprite_tree;
    else return none;
  }
}



class ItemMap extends Object {
  Item item;
  int count;
  boolean lock;

  ItemMap (int x, int y, Item item) {
    super (ITEM, x, y);
    this.item = item;
    this.count=1;
    lock = false;
    sprite = getSpriteDatabase();
  }

  ItemMap (int x, int y, Item item, int count) {
    this(x, y, item);
    this.count=count;
  }

  public int getRotateMax() {
    return 0;
  }

  protected void endDraw() {
    popStyle();
    popMatrix();
    if (lock)
      drawLock();
    if (count>1) 
      drawCount(count);
  }

  protected String isAllow() {
    if (lock)
      return text_no;
    else 
    return text_yes;
  }


  protected String getDescript() {
    return getName() +": "+item.name+"\n"+
      text_count+": "+count+"\n"+
      text_allow+": "+isAllow()+"\n"+
      text_stack+": "+item.stack+"\n"+
      text_weight+": "+item.weight+" (общий: "+item.weight*count+")"+"\n"+
      text_job+": "+isJob()+"\n";
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
class ItemProjectMap extends ItemMap {
  int progress, progressMax;

  ItemProjectMap (int x, int y, Item item) {
    super (x, y, item);
    progress=0;
    progressMax=100;
  }
  protected void beginDraw() {
    transparent=(int)map(progress, 0, progressMax, 70, 255);
    super.beginDraw();
  }
  protected String getDescript() {
    return getName()+": "+text_item_project+"\n"+  
      text_product+": "+item.name+"\n"+
      text_progress+": "+getPercent(progress, progressMax, 100)+" %\n"+
      text_allow+": "+isAllow()+"\n"+
      text_job+": "+isJob()+"\n";
  }
    protected void endDraw() {
    super.endDraw();
    drawStatus(9, progress, progressMax, yellow, red);
  }
}

class Storage extends Wall implements renamed {
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

  protected String getDescript() {
    return super.getDescript()+
      text_capacity+": "+getCapacity()+"/"+capacity+"\n"+
      text_items+": "+items.getNames();
  }

  protected void endDraw() {
    if (isFreeCapacity()) 
      drawIndicator(true);
    else 
    drawIndicator(false);
    popStyle();
    popMatrix();
  }
}




class Fabrica extends Miner {
  private ItemIntList components;
  protected ItemIntList reciept;

  Fabrica(int id, int x, int y, int direction) {
    super(id, x, y, direction);
    setProduct(Item.BLOCK_STONE, 10);
    components = new ItemIntList();
  }

  public void setProduct(int id, int count) {
    product = new Item(id);
    this.count=count;
    progress=0;
    progressMax = product.getItemProgressMaxDatabase();
    reciept =  product.getRecieptDatabase();
  }

  public boolean isPermissionCreate() {
    for (int part : reciept.sortItem()) {
      if (components.calculationItem(part)<reciept.calculationItem(part)) 
        return false;
    }
    return true;
  }

  public boolean isPermissionCarry() {
    for (int part : reciept.sortItem()) {
      if (components.calculationItem(part)<reciept.calculationItem(part)*count) 
        return true;
    }
    return false;
  }

  protected PImage getSpriteDatabase() {
    return sprite_object_fabrica;
  }

  protected String getDescript() {
    return text_name+": "+getName()+"\n"+
      text_status+": "+getHpStatus()+"\n"+
      text_product+": "+isProductNull()+"\n"+
      text_items+": "+components.getNames()+
      text_job+": "+isJob()+"\n";
  }

  public IntList getNeedItems() { 
    IntList needItems = new IntList();
    for (int part : reciept.sortItem()) {
      if (components.calculationItem(part)<reciept.calculationItem(part)*count) 
        needItems.append(part);
    }
    return needItems;
  }

  private String isProductNull() {
    if (product!=null) {
      return product.getName()+" ("+product.getItemStackDatabase()+")\n"+
        text_reciept+": "+reciept.getNames()+
        text_count+": "+count+"\n"+
        text_progress+": "+getPercent(progress, progressMax, 100)+" %\n"+
        getStatus();
    } else 
    return text_no;
  }

  private String getStatus() {
    if (product!=null) {
      if (!isPlace(product.getItemStackDatabase()))
        return text_no_place_free;
      else {
        if (isPermissionCreate()) 
          return text_in_process;
        else 
        return text_no_components;
      }
    } else return text_empty;
  }
  protected void drawIndicator() {
    if (product!=null || count>0)
      drawIndicator(true);
    else
      drawIndicator(false);
  }
  public void update() {
    if (product!=null && count>0 && isPermissionCreate()) {
      if (isPlace(product.getItemStackDatabase())) { 
        if (progress<progressMax) {
          progress++;
        } else {
          progress=0;
          world.getRoomCurrent().addItemHere(getPlace(x, y, direction)[0], getPlace(x, y, direction)[1], (Item)product.clone(), product.getItemStackDatabase());
          count-=product.getItemStackDatabase();
          for (int part : reciept) {
            if (components.hasValue(part))
              components.remove(components.index(part));
          }
          if (count==0)
            product=null;
        }
      }
    }
  }
}


class Bench extends Fabrica {

  Bench (int id, int x, int y, int direction) {
    super(id, x, y, direction);
    product=null;
  }

  protected PImage getSpriteDatabase() {
    return sprite_object_bench;
  }
}




class Miner extends Enviroment implements rotated {
  protected int progress, progressMax;
  private Room.Sector sector;
  private IntList requestResource;

  Miner (int id, int x, int y, int direction) {
    super(id, x, y, direction); //убрать инициализацию ресурсы
    progress=0;
    progressMax=10;
    count=2;
    sector=world.currentRoom.getSector(x, y);
    product=new Item (sector.resource);
    requestResource = getRequestResourceDatabase();
  }
  protected int getTick() {
    return 50;
  }
  private IntList getRequestResourceDatabase() {
    IntList list = new IntList ();
    if (id==DRILL) {
      list.append(Item.STEEL);
      list.append(Item.COPPER);
      list.append(Item.STONE);
    } else if (id==WELL) 
      list.append(Item.OIL);
    return list;
  }
  protected PImage getSpriteDatabase() {
    switch (id) {
    case DRILL:
      return sprite_object_drill;
    case WELL:
      return sprite_object_well;
    default:
      return none;
    }
  }
  private boolean isPlaceRersource() {
    if (sector.count>0 && requestResource.hasValue(product.id)) {
      if (isPlace(count)) 
        return true;
      else
        return false;
    } else 
    return false;
  }

  protected boolean isPlace(int countItem) {
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
        if (itemMap.item.id==product.id && itemMap.count<=product.stack-countItem) 
          return true;
        else 
        return false;
      } else 
      return false;
    }
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
        world.getRoomCurrent().addItemHere(getPlace(x, y, direction)[0], getPlace(x, y, direction)[1], (Item)product.clone(), newCount);
        sector.count-=newCount;
      }
    }
  }
  protected void drawIndicator() {
    if (sector.count>0)
      drawIndicator(true);
    else
      drawIndicator(false);
  }
  protected void endDraw() {
    drawIndicator();
    super.endDraw();
    drawStatus(5, hp, hpMax, green, red);
    if (product!=null)
      drawStatus(9, progress, progressMax, yellow, red);
  }
  private String isPlaceFree() {
    if (!isPlaceRersource()) {
      if (sector.count<=0)
        return text_no_resources;
      else if (!requestResource.hasValue(product.id))
        return text_no_request;
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
      resources.append(Item.COPPER);
    return resources;
  }
}


class Actor extends Object implements renamed {
  private int speed, radiusView, carryingCapacity, pathFull;
  private float  energy, energyMax, energyLeak;
  private GraphList path;
  private Graph target, nextNode;
  public ItemList items;
  public IntList skills;

  Actor (int id, int x, int y) {
    super(id, x, y);
    speed=40;//+int(random(1000));
    radiusView=int(random(5))+1;  //мин-1, макс-5
    direction=int(random(3));
    setFraction(playerFraction);
    path = new GraphList ();
    pathFull = 0;
    target = nextNode = null;
    energyMax=getEnergyDatabase();
    energy=energyMax;
    energyLeak=0.01+random(0.09);
    items = new ItemList();
    carryingCapacity=5;//(int)random(9)+1;
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
      text_items+": "+items.getNames()+
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
    if (!items.isEmpty())
      image(items.get(0).sprite, x*world.grid_size, y*world.grid_size+6);
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
          if (world.currentRoom.getObject(gx, gy) instanceof Actor) {
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


class Support extends Object implements rotated {
  Actor user;

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
    if (isPlaceUser())
      drawIndicator(true);
    else
      drawIndicator(false);
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
  ItemIntList reciept, items;

  Build (int id, Object build) {
    super(id, build.x, build.y, build.direction);
    this.build=build;
    hp=0;
    sprite = getSpriteDatabase();
    reciept = build.getRecieptDatabase();
    items = new ItemIntList();
  }

  protected String getDescript() {
    return text_name+": "+getName()+"\n"+
      text_status+": "+getHpStatus()+"\n"+
      text_object_build+": "+getBuildDescript()+"\n"+
      text_reciept+": "+reciept.getNames()+
      text_items+": "+items.getNames()+
      text_job+": "+isJob();
  }

  public boolean isPermissionBuild() {
    for (int part : reciept.sortItem()) {
      if (items.calculationItem(part)<reciept.calculationItem(part)) 
        return false;
    }
    return true;
  }

  public void getSurpluses() {  //выбрасывает излишки предметов оставшиеся после строительства
    for (int part : reciept.sortItem()) {
      int countItem=items.calculationItem(part);
      int countReciept=reciept.calculationItem(part);
      if (countItem>countReciept) 
        world.currentRoom.addItemOrder(x, y, new Item(part), countItem-countReciept);
    }
  }

  public IntList getNeedItems() { 
    IntList needItems = new IntList();
    for (int part : reciept.sortItem()) {
      if (items.calculationItem(part)<reciept.calculationItem(part)) 
        needItems.append(part);
    }
    return needItems;
  }

  private String getBuildDescript() {
    return build.getName();
  }
  protected PImage getSpriteDatabase() {
    if (build!=null)
      return build.sprite;
    else
      return none;
  }
  public boolean isComplete() {
    if (build.hp>=build.hpMax)
      return true;
    else 
    return false;
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

  public boolean isActor() {
    for (Object object : this) {
      if (object instanceof Actor)
        return true;
    }
    return false;
  }

  public ObjectList getActorListJobFree() {
    ObjectList droids = new ObjectList ();
    for (Object object : this) {
      if (object instanceof Actor) {
        Actor droid = (Actor) object;
        if (droid.job==null)
          droids.add(object);
      }
    }
    return droids;
  }
  public ObjectList getActorList() {
    ObjectList droids = new ObjectList ();
    for (Object object : this) {
      if (object instanceof Actor) 
        droids.add(object);
    }
    return droids;
  }
  public Actor getActorJobFree() {
    for (Object object : this) {
      if (object instanceof Actor) {
        Actor droid = (Actor) object;
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


  public ObjectList getStorageListFree() {
    ObjectList objects= new ObjectList();
    for (Object object : this) {
      if (object instanceof Storage) {
        Storage storage = (Storage) object;
        if (storage.getCapacity()<storage.capacity)
          objects.add(storage);
      }
    }
    return objects;
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

  public ObjectList getIsItem(int id) {
    ObjectList objects= new ObjectList();
    for (Object object : this) {
      if (object instanceof Storage && object.job==null) {
        if (((Storage)object).items.calculationItem(id)>0)
          objects.add(object);
      }
    }
    return objects;
  }

  public ObjectList getEnviroments() {
    ObjectList objects= new ObjectList();
    for (Object object : this) {
      if (object instanceof Enviroment && !(object instanceof Miner) && !(object instanceof Fabrica))
        objects.add(object);
    }
    return objects;
  }

  public ObjectList getObjectsFreeFabrica() {  //получает список свободных от работы фабрик нуждающихся в 
    ObjectList fabrics= new ObjectList();
    for (Object object : this) {
      if (object instanceof Fabrica && object.job==null) 
        fabrics.add(object);
    }
    return fabrics;
  }

  public Object getObjectStand() {
    for (Object object : this) {
      if (object.id==Object.POINT_STAND) {
        return object;
      }
    }
    return null;
  }
  public Object getObjectDamaged() {
    for (Object object : this) {
      if (object.hp<object.hpMax && object.job==null)
        return object;
    }
    return null;
  }
  public ObjectList getObjectsBuild() {
    ObjectList objectsBuild= new ObjectList();
    for (Object object : this) {
      if (object instanceof Build && object.job==null)
        objectsBuild.add(object);
    }
    return objectsBuild;
  }
  public ObjectList getObjectsPermissionRepair() {
    ObjectList objectsNoActors= new ObjectList();
    for (Object object : this) {
      if ((!(object instanceof Actor) && !(object instanceof Enviroment)  && !(object instanceof Build)  && !(object instanceof Flag)) 
        || (object instanceof Miner) || (object instanceof Fabrica))
        objectsNoActors.add(object);
    }
    return objectsNoActors;
  }

  public ObjectList getObjectsPermissionMine() {
    ObjectList objectsMine= new ObjectList();
    for (Object object : this) {
      if (object.job==null) 
        //здесь будет условие определяющие какой объект окружения помечен на удаление
        objectsMine.add(object);
    }
    return objectsMine;
  }

  public Object getNearestObject(int tx, int ty) {
    float [] dist=new float [this.size()];
    for (int i=0; i<this.size(); i++) 
      dist[i]=dist(this.get(i).x, this.get(i).y, tx, ty);
    for (Object part : this) {  
      float tdist = dist(part.x, part.y, tx, ty);
      if (tdist==min(dist)) 
        return part;
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
          if (job instanceof JobCarryItemMap) {
            JobCarryItemMap jobTrans = (JobCarryItemMap) job;
            if (!itemMap.equals(jobTrans.itemMap)) 
              items.add(itemMap);
          }
        }
      }
    }
    return items;
  }
  public ObjectList getItemNoLock() {
    ObjectList items = new ObjectList();
    for (Object object : this) {
      if (object instanceof ItemMap && !(object instanceof ItemProjectMap)) {
        ItemMap itemMap = (ItemMap)object;
        if (!itemMap.lock && itemMap.job==null)
          items.add(object);
      }
    }
    return items;
  }

  public ObjectList getFlagStandList() {
    ObjectList flags= new ObjectList();
    for (Object object : this) {
      if (object instanceof Flag) {
        if (object.id==Object.POINT_STAND  && world.currentRoom.getObjects(object.x, object.y).getActorList().isEmpty() && ((Flag)object).user==null) 
          flags.add(object);
      }
    }
    return flags;
  }

  public ObjectList getFlagGuardList() {
    ObjectList flags= new ObjectList();
    for (Object object : this) {
      if (object instanceof Flag) {
        if (object.id==Object.POINT_GUARD  && world.currentRoom.getObjects(object.x, object.y).getActorList().isEmpty() && ((Flag)object).user==null) 
          flags.add(object);
      }
    }
    return flags;
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
