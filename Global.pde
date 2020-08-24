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
  public boolean pause, showStatus;
  public Text selectedLabel;

  private World (int x, int y, int size_window, int size, int grid_size) {
    this.tick=50;
    this.size_window=size_window;
    this.grid_size=grid_size;
    this.x_map=this.x_window=x+getCenterWindow();
    this.y_map=this.y_window=y+getCenterWindow();
    this.size=size;
    this.scale=1;
    this.moveUnlock=false;
    global_id=0;
    this.timerTick=new Timer();
    rooms = new ArrayList<Room>(size);

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
    selectedLabel = new Text (x_map-getCenterWindow(), y_map+getCenterWindow()+5, x_map+getCenterWindow()-5, 160, 0, white, black);
  }

  public int getNewId() {
    global_id++;
    return global_id;
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
    selectedLabel.control();
  }

  public void update() {
    if (currentRoom!=null) {
      if (currentRoom.currentObject!=null && (currentRoom.currentObject.hp>0 || currentRoom.currentObject instanceof Build))  //если выбран объект и он не уничтожен
        world.selectedLabel.loadText(currentRoom.currentObject.getDescript(), true);
      else {
        currentRoom.currentObject=null;
        world.selectedLabel.loadText(text_selected_objects, false);
      }
      currentRoom.update();
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
  public ObjectList objects, items, layers;
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
    currentObject=null;
  }
  public void setName(int n) {
    name= "location "+n;
  }
  public String getName() {
    return name;
  }

  public void update() {
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


    if (getCurrentDroid()!=null) {
      getCurrentDroid().drawView();
      getCurrentDroid().drawPath();
    }
    if (currentObject!=null) 
      currentObject.drawSelected();
  }

  public void add(Object object) {
    if (object instanceof Layer && !(object instanceof Wall)) 
      layers.add(object);
    else if (object instanceof ItemMap) 
      items.add(object);
    else  
    objects.add(object);
  }

  public void remove(Object object) {
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






  public ArrayList <listened> getDroidsList() {
    ArrayList <listened> list = new ArrayList <listened> ();
    for (Object object : objects) {
      if (object instanceof Droid && object instanceof listened)
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
      ObjectList objectsList = getObjectsNoDroids(ix, iy);
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
    ObjectList objectsList = getObjectsNoDroids(tx, ty);
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
        }
      }
    }
  }

  public void addItem(int tx, int ty, Item item, int count) {
    ObjectList objectsList = getObjectsNoDroids(tx, ty);
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
    all.addAll(items);
    all.addAll(objects);
    return all;
  }

  public ObjectList getObjectsNoItems() {
    ObjectList all = new ObjectList ();
    all.addAll(layers);
    all.addAll(objects);
    return all;
  }
  public ObjectList getObjectsNoDroids(int x, int y) {
    ObjectList list = new ObjectList ();
    for (Object object : getAllObjects()) {
      if (x==object.x && y==object.y && !(object instanceof Droid))
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
    Object selectedBottom = list.getEntryBottom();
    if (selectedBottom!=null) {
      list.remove(selectedBottom);
      list.add(0, selectedBottom);
    }
    return list;
  }

  public Droid getCurrentDroid() { //возвращает текущего выбранного дроида
    if (currentObject==null)
      return null;
    for (Object object : objects) {
      if (currentObject.equals(object) && object instanceof Droid)
        return (Droid)object;
    }
    return null;
  }
  public void setCurrentObject(int x, int y) {
    setCurrent(getObjects(x, y).get(0));
  }

  public void setNextCurrentObject(int x, int y) {
    int next = 0;
    ObjectList objects= getObjects(x, y);
    for (int i=0; i<objects.size()-1; i++) {
      Object object = objects.get(i);
      if (currentObject.equals(object))
        if (i==objects.size()-1) 
          next=0;
        else 
        next=i+1;
    }
    setCurrent(objects.get(next));
  }


  private void setCurrent(Object object) {
    currentObject=object;
  }
  public void resetSelect() {
    currentObject=null;
  }

  public class Sector {
    private int x, y;
    private PImage sprite;

    Sector (int x, int y, PImage sprite) {
      this.x=x;
      this.y=y;
      this.sprite=sprite;
    }

    public void draw() {
      image(sprite, x*grid_size, y*grid_size);
    }
  }
}
