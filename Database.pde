import de.bezier.data.sql.*;
import java.util.Iterator;
Database data;
PApplet context = this;

class Database {
  public final DatabaseItemList items = new  DatabaseItemList();
  public final DatabaseObjectList objects = new  DatabaseObjectList();
  StringDict label = new StringDict();
  SQLite db;

  Database () {
    JSONArray strings= loadJSONArray("data/languages/ru.json");      //чтение из файла
    for (int i = 0; i < strings.size(); i++) {
      JSONObject part = strings.getJSONObject(i);
      for (java.lang.Object s : part.keys()) {
        String keyIndex = s.toString();
        label.set(keyIndex, part.getString(keyIndex));
      }
    }
    db = new SQLite(context, "data/objects.db" );  //открывает файл базы данных
    db.setDebug(false);
    loadDatabase(items, "items");
    loadDatabase(objects, "objects");
  }

  public Object getNewObject(int x, int y, Database.ObjectData obj) {
    switch(obj.id) {
    case Object.LAYER_STEEL: 
      return new Layer(Object.LAYER_STEEL, obj.material, x, y, 0);
    case Object.LAYER_STONE: 
      return new Layer(Object.LAYER_STONE, obj.material, x, y, 0);
    case Object.WALL_STEEL: 
      return new Wall(Object.WALL_STEEL, obj.material, x, y, 0);
    case Object.WALL_STONE: 
      return new Wall(Object.WALL_STONE, obj.material, x, y, 0);
    case Object.STORAGE_STEEL: 
      return new Storage(Object.STORAGE_STEEL, obj.material, x, y, 0);
    case Object.STORAGE_WOOD: 
      return new Storage(Object.STORAGE_WOOD, obj.material, x, y, 0);
    case Object.REPAIR: 
      return new Support(Object.REPAIR, x, y, 0);
    case Object.CHARGE: 
      return new Support(Object.CHARGE, x, y, 0);
    case Object.DRILL: 
      return new Miner(Object.DRILL, x, y, 0);
    case Object.WELL: 
      return new Miner(Object.WELL, x, y, 0);
    case Object.FABRICA: 
      return new Fabrica (Object.FABRICA, x, y, 0);
    case Object.BENCH: 
      return new Bench (Object.BENCH, x, y, 0);
    case Object.POINT_GUARD: 
      return new Flag (Object.POINT_GUARD, x, y);
    case Object.POINT_STAND: 
      return new Flag (Object.POINT_STAND, x, y);
    default: 
      return null;
    }
  }


  class DatabaseItemList extends ArrayList <ItemData> {
    public ItemData getObjectDatabase(int id) {
      for (ItemData part : this) {
        if (part.id==id)
          return part;
      }
      return null;
    }
  }
  class DatabaseObjectList extends ArrayList <ObjectData> {
    public ObjectData getObjectDatabase(int id) {
      for (ObjectData part : this) {
        if (part.id==id)
          return part;
      }
      return null;
    }
  }
  class ItemData {
    protected final int id;
    protected final PImage sprite;
    protected final String name;
    protected String description;
    protected ItemIntList reciept;
    protected boolean create;
    protected int stack, output, weight;

    ItemData(int id, String name, PImage sprite) {
      this.id=id;
      this.name=name;
      this.sprite=sprite;
      description="";
      stack=output=weight=1;
      reciept=new ItemIntList();
    }
    public void draw() {
      image(sprite, world.getMouseMapX()*world.grid_size, world.getMouseMapY()*world.grid_size);
    }
  }

  class ObjectData extends ItemData {
    final int material;
    ItemIntList products;

    ObjectData(int id, String name, int material, PImage sprite) {
      super(id, name, sprite);
      create=false;
      this.material=material;
      products = null;
    }
    void addProduct(int id) {
      if (products==null) 
        products = new ItemIntList();
      if (!products.hasValue(id))
        products.append(id);
    }
  }
  public String getItemName(int id) {
    return items.getObjectDatabase(id).name;
  }


  private void loadDatabase(ArrayList list, String table) {
    if (db.connect()) {
      db.query("SELECT * FROM "+table);
      while (db.next()) {
        ItemData object = null;
        if (table.equals("objects")) {
          ObjectData obj = new ObjectData(db.getInt("id"), label.get(db.getString("name")), db.getInt("material"), 
            loadImage("data/sprites/"+db.getString("sprite")+".png"));
          object=obj;
          if (db.getString("parameters")!=null) { //расшифровка параметров
            JSONArray parse = parseJSONArray(db.getString("parameters"));
            for (int i = 0; i < parse.size(); i++) {
              JSONObject part = parse.getJSONObject(i);
              if (part.hasKey("products")) {  //загрузка прочих индивидуальных параметров
                if (object instanceof ObjectData) {
                  JSONArray parserProducts = part.getJSONArray("products"); //загрузка изделий
                  for (int ip = 0; ip < parserProducts.size(); ip++) 
                    ((ObjectData)object).addProduct(parserProducts.getInt(ip));
                }
              }
            }
          }
        } else if (table.equals("items")) {
          ItemData obj = new ItemData(db.getInt("id"), label.get(db.getString("name")), 
            loadImage("data/sprites/"+db.getString("sprite")+".png"));
          object=obj;
          object.weight=db.getInt("weight"); //определяет вес предмета
          object.stack=db.getInt("stack"); //определяет максимальный стэк
          object.output=db.getInt("output"); //определяет количество предмета изготовленного за 1 рецепт
        }

        if (object!=null) {  //если объект базы данных создался
          object.create=db.getBoolean("create"); //определяет возможно ли создать предмет рукотворно
          object.description=label.get(db.getString("description")); //загружает краткое описание объекта
          if (db.getString("reciept")!=null) {  //заполнение рецепта
            JSONArray parse = parseJSONArray(db.getString("reciept"));
            for (int i = 0; i < parse.size(); i++) {
              JSONObject part = parse.getJSONObject(i);
              setComponent(object.reciept, part.getInt("id"), part.getInt("count"));
            }
          }
          list.add(object);
        }
      }
    }
  }
  void loadListBoxFromDBItems(Listbox list) {
    for (ItemData part : items) {
      if (part.create) {
        String name=part.name;
        list.addItem(name, part.id);
      }
    }
    list.select=null;
  }
  void loadListBoxFromDBObjects(Listbox list) {
    for (ObjectData part : objects) {
      if (part.create) {
        String name;
        if (part.material!=-1) 
          name=part.name+" ("+items.getObjectDatabase(part.material).name+")";
        else
          name=part.name;
        list.addItem(name, part.id);
      }
    }
    list.select=null;
  }
  void loadListBoxFromDBProducts(Listbox list, ItemIntList items) {
    if (list.items!=null) 
      list.items.clear();
    for (ItemData part : this.items) {
      if (part.create) {
        if (items!=null) {
          if (items.hasValue(part.id)) {
            String name=part.name;
            list.addItem(name, part.id);
          }
        }
      }
    }
    list.select=null;
  }
}


void setupDatabase() {
  data = new Database();
}
