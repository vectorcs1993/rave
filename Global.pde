World world;

public final class World extends ActiveElement {
  private int x_window, y_window, x_map, y_map, global_id;
  private ArrayList<Room> rooms;
  private Room currentRoom;
  private int size, size_window, grid_size;
  private int tick;
  private Timer timerTick;
  private float scale;
  private int deltaX, deltaY;
  public boolean pause, showStatus, input;
  Database.ObjectData newObj;

  private World (int x, int y, int size_window, int size, int grid_size) {
    super(x, y, size_window*grid_size, size_window*grid_size);
    tick=50;
    this.size_window=size_window;
    this.grid_size=grid_size;
    x_map=this.x_window=x+getCenterWindow();
    y_map=this.y_window=y+getCenterWindow();
    this.size=size;
    scale=1;
    global_id=0;
    timerTick=new Timer();
    rooms = new ArrayList<Room>(size);
    input=true;

    newObj=null;
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

  public boolean isAllowInput() {   //запрещает или разрешает любой ВВОД от пользователя
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

  public void mouseDragged(float x, float y) {
    if (isAllowInput()) {
      if (mouseButton==RIGHT) 
        mouseMove();
    }
  }
  public void mouseScrolled(float e) {
    if (isAllowInput()) {
      if (hover) {
        if (e==-1) 
          setScaleUp();
        else if (e==1) 
          setScaleDown();
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

  void mousePressed(float x, float y) {
    Room room=world.getRoomCurrent();
    int _x=getMouseMapX();
    int _y=getMouseMapY();

    if (isAllowInput()) {
      if (hover) {
        if (mouseButton==LEFT) {
          if (isOverMap()) {
            if (menuColony.select.event.equals("getMenuObjects")) {
              if (room.getObject(_x, _y)!=null) {
                if (room.currentObject!=null ) 
                  room.setNextCurrentObject(_x, _y);
                else 
                room.setCurrentObject(_x, _y);
              } else 
              room.resetSelect();
            } else if (menuColony.select.event.equals("getMenuBuildings")) {
              if (buildings.select!=null) {
                Database.ObjectData newObj = data.objects.getObjectDatabase(buildings.select.id);
                Object newObject = data.getNewObject(_x, _y, newObj);
                if (newObject!=null)
                  world.getRoomCurrent().add(new Build(Object.BUILD, newObject));
              }
            }
          } else 
          room.resetSelect();
        } else if (mouseButton==RIGHT) 
          beginMove();
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



  public float getScaleAdj() {
    return (getSizeWithGrid()*scale)/2;
  }

  public int getSizeWithGrid() {
    return size*grid_size;
  }
  public int getSize() {
    return size;
  }

  public int [] getPlace(int x, int y, int direction) {
    if (direction==0)
      return new int [] {x, y-1};
    else if (direction==1)
      return new int [] {x+1, y};
    else if (direction==2)
      return new int [] {x, y+1};
    else 
    return new int [] {x-1, y};
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

    if (!buildings.isActive()) 
      newObj=null;
    if (newObj!=null) {
      pushStyle();
      tint(white, 100);
      newObj.draw();
      popStyle();
    }
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
      pushStyle();
      fill(white);

      text("FPS: "+int(frameRate)+"\n"+
        "world_speed: "+getSpeedAbs(tick)+" ("+tick+")\n"+
        "world_scale: х"+scale+"\n"+ 
        "room_name: "+room.getName()+"\n"+
        "mouse X: "+getMouseMapX()+" Y:"+getMouseMapY()+"\n"+
        "mouse_abs X: "+mouseX+" Y:"+mouseY, x_window-getSizeWindow()/2+10, y_window-getSizeWindow()/2+24);
      popStyle();
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
  public ObjectList objects, items, layers, flags, buildings;
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
    buildings = new ObjectList ();
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
    else if (object instanceof Build) 
      buildings.add(object);
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
    else if (object instanceof Build) 
      buildings.remove(object);
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

  public boolean isPlaceItem(int x, int y, int id, int count) {
    ObjectList objectsList = getObjectsNoActors(x, y);
    if (objectsList.isEmpty()) {
      return true;
    } else {
      Storage storage = objectsList.getStorageFree();
      if (storage!=null)
        return true;
      if (node[x][y].solid)
        return false;
      for (Object object : objectsList) {
        if (object instanceof ItemMap) 
          return true;
        else if (object.id==Object.LAYER_STEEL || object.id==Object.LAYER_STONE) {
          return true;
        }
      }
      return false;
    }
  }
  //метод размещающий предметы на поверхности и возвращающий количество неразмещенных предметов 
  int addItemMap(int x, int y, Item item, int count) {          //размещение объекта с обратным вызовом, возвращает количество предметов которое осталось после размещения
    if (count>item.stack) {                                      //проверяем удается ли разместить все количество count на одной клетке
      items.add(new ItemMap(x, y, item, item.stack));          //размещаем объект с переполненным стэком        
      return count-item.stack;                                  //возвращаем количество размещенных предметов
    } else {                                                    //если количество count не превышает стэк предмета тогда
      items.add(new ItemMap(x, y, item, count));                //размещаем объект с количеством count
      return 0;                                                  //возвращаем 0 т.к. все предметы успешно размещены
    }
  }

  //метод размещающий предметы в контейнере и возвращающий количество неразмещенных предметов 
  int addItemToStorage(Storage storage, Item item, int count) {    //размещение объекта с обратным вызовом, возвращает количество предметов которое осталось после размещения
    int item_add=0;                                                //инициализация счетчика размещенных предметов
    for (int b=0; b<count; b++) {                                  //цикл соответствующий количеству размещаемых предметов
      if (storage.isFreeCapacity()) {                              //каждый такт проверка на свободное место в контейнере, если место есть то
        storage.add(new Item(item.id));                            //размещаем предмет  
        item_add++;                                                //обновляем счетчик размещения  
        if (item_add==count)                                        //проверяет размещены ли все предметы    
          return 0;                                                  //если да, то возвращает 0
      }
    }
    return count-item_add; //возвращает количество не размещенных предметов
  }


  public void addItemOrder(int tx, int ty, int id, int count) {
    int ix, iy;
    Item item = new Item(id);
    for (int i=-1; i<121; i++) {  //цикл перебирает все соседник клетки в соответствией с матрицей размещения
      if (i==-1) { 
        ix=tx;
        iy=ty;
      } else {
        ix=tx+matrixShearch[matrixRadius[i]][0]; //корректировка координаты х
        iy=ty+matrixShearch[matrixRadius[i]][1]; //корректировка координаты у
      }
      if (ix<0 || iy<0)
        continue;
      ObjectList objects = getObjectsNoActors(ix, iy);       //получаем список объектов без учета дронов
      if (objects.isEmpty()) {            //если в клетке нет объектом (дроны не учитываются)
        if (count>item.stack) {          //проверяем удается ли разместить все количество count на одной клетке
          items.add(new ItemMap(ix, iy, item, item.stack));  //размещаем объект с переполненным стэком
          count=count-item.stack;          //уменьшаем количество размещаемых предметов
          continue;            //продолжаем поиск
        } else {
          items.add(new ItemMap(ix, iy, item, count));    //размещаем объект с количеством count
          break;              //прекращаем поиск, объект размещен
        }
      } else {                //если клетка не свободна и объекты уже присутствуют
        Storage storage = objects.getStorageFree();      //запрос на свободный контейнер (т.е. в котором достаточно места для размещения хотя бы одной единицы предмета)
        if (storage!=null) {            //если он обнаружен
          int resultAdd = addItemToStorage(storage, item, count);  //размещает предметы, и запрашивает разместилось ли все количество
          if (resultAdd==0)               //если все предметы успешно разместились 
            return;              //завершение алгоритма
          else {                //если остались предметы после размещения              
            count=resultAdd;          //устанавливает значение count
            continue;            //продолжает поиск что бы разместить оставшиеся предметы
          }
        } else {              //если контейнер не обнаружен в списке объектов
          if (node[ix][iy].solid)          //если проверка показала что клетка твердая, то
            continue;          //перейти на след. клетку в матрице размещения
          else {              //если клетка не твердая, то
            for (Object object : objects) {      //перебор объектов
              if (object instanceof Layer) {            //если объект класса Layer
                int resultAdd = addItemMap(ix, iy, item, count);  //размещает предметы, и запрашивает разместилось ли все количество
                if (resultAdd==0)               //если все предметы успешно разместились 
                  return;              //завершение алгоритма
                else {                //если остались предметы после размещения              
                  count=resultAdd;          //устанавливает значение count
                  break;              //продолжает поиск что бы разместить оставшиеся предметы
                }
              } else if (object instanceof ItemMap) {        //если объект класса ItemMap
                ItemMap itemMap = (ItemMap)object;        //определяет объект класса ItemMap для работы с ним
                int newCount = count+itemMap.count;
                if (newCount>itemMap.item.stack) {        //проверяем не переполнен ли стэк объекта itemMap, если да, то
                  itemMap.count=itemMap.item.stack;      //устанавливаем значение itemMap.count равным значению стэка вложенного предмета
                  count=newCount-itemMap.item.stack;      //вычисляем сколько предметов осталось после размещения
                  break;              //продолжаем поиск что бы разместить оставшиеся предметы
                } else {              //если стэк объекта itemMap не переполнен
                  itemMap.count=newCount;          //устанавливает значение count
                  return;              //продолжает поиск что бы разместить оставшиеся предметы
                }
              }
            }
          }
        }
      }
    }
  }
  /*
  public void addItemOrder(int tx, int ty, Item item0, int count) {
   int ix, iy;
   Item item=(Item) item0.clone();
   for (int i=-1; i<121; i++) {
   if (i==-1) {
   ix=tx;
   iy=ty;
   } else {
   ix=tx+matrixShearch[matrixRadius[i]][0];
   iy=ty+matrixShearch[matrixRadius[i]][1];
   }
   if (ix<0 || iy<0)
   continue;
   ObjectList objectsList = getObjectsNoActors(ix, iy);
   if (objectsList.isEmpty()) {
   addItem(ix, iy, item, count);
   return;
   } else {
   Storage storage = objectsList.getStorageFree();
   if (storage!=null) {
   storage.add(item);
   return;
   }
   for (Object object : objectsList) { 
   if (object instanceof ItemMap) {
   ItemMap itemMap = (ItemMap)object;
   if (item.id==itemMap.item.id) {
   if (itemMap.count>itemMap.item.stack) {
   count=itemMap.count-itemMap.item.stack;
   itemMap.count=itemMap.item.stack;
   continue;
   }
   itemMap.count+=count;
   count=0;
   return;
   }
   } else if (object.id==Object.LAYER_STEEL || object.id==Object.LAYER_STONE) {
   ItemMap itemMap =  new ItemMap(ix, iy, item, count);
   items.add(itemMap);
   return;
   }
   }
   }
   }
   }
   
   public void addItem(int tx, int ty, Item item, int count) {
   ObjectList objectsList = getObjectsNoActors(tx, ty);
   ItemMap itemMap =  new ItemMap(tx, ty, item, count);
   if (objectsList.isEmpty()) { //если нет ни одного объекта в координатах
   this.items.add(itemMap);
   } else {   //если объекты присутствуют
   for (Object object : objectsList) {
   if (object instanceof Storage) {
   ((Storage)object).add(item);
   break;
   } else if (object instanceof Layer) {
   this.items.add(itemMap);
   break;
   }
   }
   }
   }
   */
  public ObjectList getAllObjects() {
    ObjectList all = new ObjectList ();
    all.addAll(layers);
    all.addAll(buildings);
    all.addAll(flags);
    all.addAll(items);
    all.addAll(objects);
    return all;
  }

  public ObjectList getObjectsNoItems() {
    ObjectList all = new ObjectList ();
    all.addAll(objects);
    all.addAll(flags);
    all.addAll(buildings);
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
    ObjectList buildList = new ObjectList();
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
      else if (buildings.contains(current)) 
        buildList.add(current);
    }
    ObjectList objectsInSector = new ObjectList ();
    objectsInSector.addAll(objectList);
    objectsInSector.addAll(itemList);
    objectsInSector.addAll(flagList);
    objectsInSector.addAll(buildList);
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
      count=600+int(random(20));
    }
    public void draw() {
      image(sprite, x*grid_size, y*grid_size);
    }
  }
}
