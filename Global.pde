World world;

public final class World {
  private int x_window, y_window, x_map, y_map, global_id;
  private ArrayList<Room> rooms;
  private Room currentRoom;
  private int size, size_window, grid_size;
  private int tick;
  private Timer timerTick;
  private float scale;
  private int deltaX, deltaY;
  private boolean moveUnlock;
  public boolean pause, showStatus, input;

  private World (int x, int y, int size_window, int size, int grid_size) {
    tick=50;
    this.size_window=size_window;
    this.grid_size=grid_size;
    x_map=this.x_window=x+getCenterWindow();
    y_map=this.y_window=y+getCenterWindow();
    this.size=size;
    scale=1;
    moveUnlock=false;
    global_id=0;
    timerTick=new Timer();
    rooms = new ArrayList<Room>(size);
    input=true;

    for (int ix=0; ix<5; ix++) {
      for (int iy=0; iy<5; iy++) {
        Room room = new Room (ix, iy, size, grid_size);
        room.setName(rooms.size());
        rooms.add(room);
      }
    }
    currentRoom=rooms.get(0);
    createLand();
    pause=showStatus=false;
  }

  public int getNewId() {
    global_id++;
    return global_id;
  }

  public boolean isPermissionInput() {   //запрещает или разрешает любой ВВОД от пользователя
    if (input)
      return true;
    else
      return false;
  }
  void createLand() {
    int n=0;
    for (int ix=-5; ix<6; ix++) {
      for (int iy=-5; iy<6; iy++) {
        matrixShearch[n][0]=ix;
        matrixShearch[n][1]=iy;
        n++;
      }
    }
  }

  public int getAbsX(int x) {
    return x*grid_size+grid_size/2;
  }
  public int getAbsY(int y) {
    return y*grid_size+grid_size/2;
  }
  public Room getRoomCurrent() {
    return currentRoom;
  }
  public int getCenter() {
    return (size*grid_size)/2;
  }
  public int getCenterWindow() {
    return (size_window*grid_size)/2;
  }
  public void mouseMove() {
    x_map=getConstrain(mouseX-deltaX, "x");
    y_map=getConstrain(mouseY-deltaY, "y");
  }

  public void beginMove() {
    deltaX=mouseX-x_map;
    deltaY=mouseY-y_map;
    mouseMove();
  }

  public boolean isMoveUnlock() {
    return moveUnlock;
  }

  public void setMoveUnlock(boolean lock) {
    moveUnlock=lock;
  }


  public float getScaleAdj() {
    return (getSizeWithGrid()*scale)/2;
  }

  public int getSizeWithGrid() {
    return size*grid_size;
  }
  public int getSize() {
    return size;
  }


  public int getSizeWindow() {
    return size_window*grid_size;
  }

  public void draw() {
    Room room  = getRoomCurrent();
    pushMatrix();

    stroke(white);
    strokeWeight(1);
    noFill();
    rect(x_window-getSizeWindow()/2-1, y_window-getSizeWindow()/2-1, getSizeWindow()+1, getSizeWindow()+1);
    clip(x_window-getSizeWindow()/2, y_window-getSizeWindow()/2, getSizeWindow(), getSizeWindow());
    translate(x_map-getScaleAdj(), y_map-getScaleAdj());
    scale(scale);
    room.draw();
    noClip();
    popMatrix();



    if (pause) {
      pushStyle();
      fill(white);
      textAlign(CENTER);
      textSize(18);
      text("Пауза", x_window, y_window);
      popStyle();
    }
    if (showStatus) {
      fill(white);
      text("FPS: "+int(frameRate)+"\n"+
        "world_speed: "+getSpeedAbs(tick)+" ("+tick+")\n"+
        "world_scale: х"+scale+"\n"+ 
        "room_name: "+room.getName()+"\n"+
        "mouse X: "+getMouseMapX()+" Y:"+getMouseMapY()+"\n"+
        "mouse_abs X: "+mouseX+" Y:"+mouseY, x_window-getSizeWindow()/2+10, y_window-getSizeWindow()/2+24);
    }
  }

  public void update() {
    if (currentRoom!=null) {
      if (currentRoom.currentObject!=null) {
        if (currentRoom.currentObject.hp<=0 && !(currentRoom.currentObject instanceof Build))  //если выбран объект и он не уничтожен
          currentRoom.currentObject=null;
      }
      if (currentRoom.currentObject instanceof Build) {
        if (((Build)currentRoom.currentObject).isComplete())
          currentRoom.currentObject=null;
      }
      if (currentRoom.currentObject instanceof ItemMap) {
        if (((ItemMap)currentRoom.currentObject).count<=0)
          currentRoom.currentObject=null;
      }
      playerFraction.update();
    }
    timerTick.tick();
    if (!timerTick.check() && !pause) {

      tick();
      timerTick.set(tick);
    }
  }

  private void tick () {
    for (Timer part : timers)   //отсчет таймеров
      part.tick();
  }
  float getSpeedAbs(int speed) {
    return map(speed, 0, 200, 10, 1);
  }

  public int getMouseWindowX() {
    return ceil((constrain(mouseX-(x_window-getScaleAdj()), 0, getSizeWindow()))/getGridSize())-1;
  }
  public int getMouseWindowY() {
    return ceil((constrain(mouseY-(y_window-getScaleAdj()), 0, getSizeWindow()))/getGridSize())-1;
  }

  public int getMouseMapX() {
    return ceil((mouseX-(x_map-getScaleAdj()))/getGridSize())-1;
  }
  public int getMouseMapY() {
    return ceil((mouseY-(y_map-getScaleAdj()))/getGridSize())-1;
  }

  public boolean isOverWindow() {
    if (mouseX<x_window+getSizeWindow()/2 && mouseY<y_window+getSizeWindow()/2 && mouseX>x_window-getSizeWindow()/2 && mouseY>y_window-getSizeWindow()/2) 
      return true; 
    else 
    return false;
  }

  public boolean isOverMap() {
    if (mouseX<x_map+getScaleAdj() && mouseY<y_map+getScaleAdj() && mouseX>x_map-getScaleAdj() && mouseY>y_map-getScaleAdj()) 
      return true; 
    else 
    return false;
  }

  public float getScale() {
    return constrain(scale, 0.5, 1);
  }

  public float getGridSize() {
    return grid_size*getScale();
  }

  public void setScaleUp() {
    if (scale<=0.9) {
      scale+=0.1;
      x_map=getConstrain(x_map-getGridSize(), "x");
      y_map=getConstrain(y_map-getGridSize(), "y");
    }
  }
  public void setScaleDown() {
    if (scale>=0.5) {
      scale-=0.1;
      x_map=getConstrain(x_map+getGridSize(), "x");
      y_map=getConstrain(y_map+getGridSize(), "y");
    }
  }
  private int getConstrain(float value, String axis) {
    if (axis.equals("x")) 
      return constrain(int(value), x_window-getSizeWindow()/2, x_window+getSizeWindow()/2);
    else if (axis.equals("y")) 
      return constrain(int(value), y_window-getSizeWindow()/2, y_window+getSizeWindow()/2);
    else 
    return 0;
  }
}


public class Room {
  private int x, y, grid_size;
  private ArrayList <Sector> map;
  public ObjectList objects, items, layers, flags;
  private Object currentObject;
  private Graph [][] node;
  private String name; 
  Room (int x, int y, int size, int grid_size) {
    this.x=x;
    this.y=y;
    this.grid_size=grid_size;
    map = new ArrayList <Sector>();
    node = new Graph [size][size];
    for (int ix=0; ix<size; ix++) {
      for (int iy=0; iy<size; iy++) {
        map.add(new Sector(ix, iy, tile));
        node[ix][iy]=new Graph(ix, iy, false);
      }
    }
    objects = new ObjectList();
    items = new ObjectList ();
    layers = new ObjectList ();
    flags = new ObjectList ();
    currentObject=null;
  }
  public void setName(int n) {
    name= "location "+n;
  }
  public String getName() {
    return name;
  }

  ObjectList getObjects(Fraction fraction) {
    ObjectList list = new ObjectList ();
    for (Object object : getAllObjects()) {
      if (object.fraction!=null)
        if (object.fraction.equals(fraction)) 
          list.add(object);
    }
    return list;
  }

  public void draw() {
    for (Sector sector : map) 
      sector.draw();

    for (Object object : getAllObjects()) 
      object.control();

    if (getCurrentActor()!=null) {
      getCurrentActor().drawView();
      getCurrentActor().drawPath();
    }
    if (currentObject!=null) 
      currentObject.drawSelected();
  }

  public void add(Object object) {
    if (object instanceof Flag)
      flags.add(object);
    if ((object instanceof Layer) && !(object instanceof Wall)) 
      layers.add(object);
    else if (object instanceof ItemMap) 
      items.add(object);
    else  
    objects.add(object);
  }

  public void remove(Object object) {
    if (object instanceof Flag) 
      flags.remove(object);
    if (object instanceof Layer && !(object instanceof Wall)) 
      layers.remove(object);
    else if (object instanceof ItemMap) 
      items.remove(object);
    else  
    objects.remove(object);
  }

  public Sector getSector(int x, int y) {
    for (Sector sector : map) {
      if (x==sector.x && y==sector.y)
        return sector;
    }
    return null;
  }
  public Object getObject(int x, int y) {
    for (Object object : getAllObjects()) {
      if (x==object.x && y==object.y)
        return object;
    }
    return null;
  }






  public ArrayList <listened> getActorsList() {
    ArrayList <listened> list = new ArrayList <listened> ();
    for (Object object : objects) {
      if (object instanceof Actor && object instanceof listened)
        list.add(object);
    }
    return list;
  }

  public ArrayList <Storage> getStorageList() {
    ArrayList <Storage> list = new ArrayList <Storage> ();
    for (Object object : objects) {
      if (object instanceof Storage)
        list.add((Storage)object);
    }
    return list;
  }
  public ArrayList <Object> getEnviromentList() {
    ArrayList <Object> list = new ArrayList <Object> ();
    for (Object object : getAllObjects()) {
      if (object instanceof Layer && !(object instanceof Storage))
        list.add(object);
    }
    return list;
  }


  public ItemList getItemsList() {
    ItemList list = new ItemList ();
    for (Storage object : getStorageList()) {
      if (!object.items.isEmpty())
        list.addAll(object.items);
    }
    return list;
  }


  public ArrayList <listened> getFabricsList() {
    ArrayList <listened> list = new ArrayList <listened> ();
    for (Object object : objects) {
      if (object instanceof Miner && object instanceof listened)
        list.add(object);
    }
    return list;
  }




  public void addItemOrder(int tx, int ty, Item item0, int count) {
    int ix, iy;
    Item item=(Item) item0.clone();
    for (int i=0; i<121; i++) {
      ix=tx+matrixShearch[matrixRadius[i]][0];
      iy=ty+matrixShearch[matrixRadius[i]][1];
      if (ix<0 || iy<0)
        continue;
      ObjectList objectsList = getObjectsNoActors(ix, iy);
      if (objectsList.isEmpty()) {
        addItem(ix, iy, item, count);
        return;
      } else {
        for (Object object : objectsList) { 
          if (object instanceof ItemMap) {
            ItemMap itemM = (ItemMap)object;
            itemM.x=ix;
            itemM.y=iy;
            itemM.count+=count;
            count=0;
            return;
          }
        }
      }
    }
  }

  public void addItemHere(int tx, int ty, Item item0, int count) {
    Item item=(Item) item0.clone();
    ObjectList objectsList = getObjectsNoActors(tx, ty);
    if (objectsList.isEmpty()) {
      addItem(tx, ty, item, count);
      return;
    } else {
      for (Object object : objectsList) { 
        if (object instanceof ItemMap) {
          ItemMap itemM = (ItemMap)object;
          itemM.count+=count;
          count=0;
          return;
        } else if (object instanceof Storage) {
          for (int i=0; i<count; i++)
            ((Storage)object).add(new Item(item.id));
          break;
        }
      }
    }
  }

  public void addItem(int tx, int ty, Item item, int count) {
    ObjectList objectsList = getObjectsNoActors(tx, ty);
    if (objectsList.isEmpty()) { //если нет ни одного объекта в координатах
      ItemMap itemMap =  new ItemMap(tx, ty, item, count);
      this.items.add(itemMap);
    } else {   //если объекты присутствуют
      for (Object object : objectsList) {
        if (object instanceof Storage) {
          ((Storage)object).add(item);
          break;
        }
      }
    }
  }

  public ObjectList getAllObjects() {
    ObjectList all = new ObjectList ();
    all.addAll(layers);
    all.addAll(flags);
    all.addAll(items);
    all.addAll(objects);
    return all;
  }

  public ObjectList getObjectsNoItems() {
    ObjectList all = new ObjectList ();
    all.addAll(objects);
    all.addAll(flags);
    all.addAll(layers);    
    return all;
  }
  public ObjectList getObjectsNoActors(int x, int y) {
    ObjectList list = new ObjectList ();
    for (Object object : getAllObjects()) {
      if (x==object.x && y==object.y && !(object instanceof Actor))
        list.add(object);
    }
    return list;
  }

  public ObjectList getObjectsActors(int x, int y) {
    ObjectList list = new ObjectList ();
    for (Object object : objects) {
      if (x==object.x && y==object.y && object instanceof Actor)
        list.add(object);
    }
    return list;
  }

  public ObjectList getObjects(int x, int y) {
    ObjectList list = new ObjectList ();
    for (Object object : getAllObjects()) {
      if (x==object.x && y==object.y)
        list.add(object);
    }
    return list;
  }

  public Actor getCurrentActor() { //возвращает текущего выбранного дроида
    if (currentObject==null)
      return null;
    for (Object object : objects) {
      if (currentObject.equals(object) && object instanceof Actor)
        return (Actor)object;
    }
    return null;
  }

  public void setCurrentObject(int x, int y) {
    ObjectList objectList = getObjects(x, y);
    setCurrent(objectList.get(objectList.size()-1));
  }

  public void setNextCurrentObject(int x, int y) { 
    ObjectList layerList = new ObjectList();
    ObjectList flagList = new ObjectList();
    ObjectList itemList = new ObjectList();
    ObjectList objectList = new ObjectList();
    for (Object current : getObjects(x, y)) {
      if (layers.contains(current))
        layerList.add(current);
      else if (flags.contains(current)) 
        flagList.add(current);
      else if (items.contains(current))
        itemList.add(current);
      else if (objects.contains(current)) 
        objectList.add(current);
    }
    ObjectList objectsInSector = new ObjectList ();
    objectsInSector.addAll(objectList);
    objectsInSector.addAll(itemList);
    objectsInSector.addAll(flagList);
    objectsInSector.addAll(layerList);
    int next = 0;
    for (int i=0; i<objectsInSector.size(); i++) {
      Object object = objectsInSector.get(i);
      if (currentObject.equals(object)) {
        if (i<objectsInSector.size()-1) 
          next=i+1;
        else 
        next=0;
      }
    }
    setCurrent(objectsInSector.get(next));
  }

  private void setCurrent(Object object) {
    currentObject=object;
  }

  public void resetSelect() {
    currentObject=null;
  }

  public class Sector {
    private int x, y, resource, count;
    private PImage sprite;

    Sector (int x, int y, PImage sprite) {
      this.x=x;
      this.y=y;
      this.sprite=sprite;
      resource=int(random(4));
      count=10+int(random(20));
    }
    public void draw() {
      image(sprite, x*grid_size, y*grid_size);
    }
  }
}
