

class Item implements cloneable {
  private final String name;
  protected final int id;
  protected int stack;
  protected final int weight;
  public PImage sprite;
  static final int STEEL=0, COPPER=1, OIL=2, STONE=3, WOOD=4, PLATE_STEEL=5, PLATE_COPPER=6, RUBBER=7;
  protected ItemIntList reciept;

  Item (int id) {
    this.id=id;
    this.name = getItemNameDatabase(id);
    sprite= getSpriteDatabase();
    weight=1;
    stack=getStackDatabase();
    reciept=getRecieptDatabase();
  }


  public ItemIntList getRecieptDatabase() {
    ItemIntList items = new ItemIntList();
    if (id==PLATE_STEEL) {
      for (int i=0; i<2; i++)
        items.append(Item.STEEL);
    } else if (id==PLATE_COPPER) {
      for (int i=0; i<3; i++)
        items.append(Item.COPPER);
    } 
    return items;
  } 



  public cloneable clone() {
    return new Item (id);
  }

  public String getName() {
    return name;
  }

  private PImage getSpriteDatabase() {
    switch (id) {
    case STEEL: 
      return sprite_item_steel;
    case WOOD: 
      return sprite_item_wood;
    case COPPER: 
      return sprite_item_copper;
    case OIL: 
      return sprite_item_oil;
    case PLATE_STEEL: 
      return sprite_item_plate_steel;
    case PLATE_COPPER: 
      return sprite_item_plate_copper;
    case RUBBER: 
      return sprite_item_rubber;
    default: 
      return none;
    }
  }
  private int getStackDatabase() {
    switch (id) {
    case STEEL: 
      return 10;
    case WOOD: 
      return 15;
    case COPPER: 
      return 10;
    case OIL: 
      return 5;
    case PLATE_STEEL: 
      return 15;
    case PLATE_COPPER: 
      return 20;
        case RUBBER: 
      return 10;
    default: 
      return 1;
    }
  }
  private int getItemProgressMaxDatabase() {
    if (id==PLATE_STEEL || id==PLATE_COPPER) 
      return 100;
    else
      return 10;
  }
  private int getItemStackDatabase() {
    if (id==PLATE_COPPER) 
      return 2;
    else
      return 1;
  }
}


class ItemIntList extends IntList {

  public String getNames() {  //сортирует по наименованию и возвращает список имен
    if (this.size()==0)
      return text_empty;
    else {
      String names="";
      IntList inv = this.sortItem();
      for (int k=0; k<inv.size(); k++) {
        int i=inv.get(k);
        names+=getItemNameDatabase(i)+" ("+this.calculationItem(i)+")";
        if (k!=inv.size()-1)
          names+=",\n";
      }
      return names;
    }
  }
  public IntList sortItem() { //сортирует и возвращает множество отсортированное
    IntList itemsList= new IntList(); 
    for (int part : this) {
      if (!itemsList.hasValue(part)) 
        itemsList.append(part);
    }
    return itemsList;
  }
  public int calculationItem(int id) {   //пересчет количества одинаковых предметов в списке
    int total=0;
    for (int part : this) {
      if (part==id) 
        total++;
    }
    return total;
  }
}


String getItemNameDatabase(int id) {
  switch (id) {
  case Item.STEEL: 
    return text_item_steel;
  case Item.WOOD: 
    return text_item_wood;
  case Item.COPPER: 
    return text_item_copper;
  case Item.STONE: 
    return text_item_stone;
  case Item.OIL: 
    return text_item_oil;
  case Item.PLATE_STEEL: 
    return text_item_plate_steel;
  case Item.PLATE_COPPER: 
    return text_item_plate_copper;
    case Item.RUBBER: 
    return text_item_rubber;
  default: 
    return text_no_name;
  }
}

class Project {
  Item item;
  int process, processMax;
  String name;

  Project (Item item) {
    name = "Проект";
    this.item=item;
    processMax = 100;
    process=0;
  }
}


class ItemList extends ArrayList <Item> {

  public IntList sortItem() { //сортирует и возвращает множество отсортированное
    IntList itemsList= new IntList(); 
    for (Item part : this) {
      if (!itemsList.hasValue(part.id)) 
        itemsList.append(part.id);
    }
    return itemsList;
  }

  public int calculationItem(int id) {   //пересчет количества одинаковых предметов в списке
    int total=0;
    for (Item part : this) {
      if (part.id==id) 
        total++;
    }
    return total;
  }

  public Item getItem(int id) {      //возвращает экземпляр объекта по id
    for (Item part : this) {
      if (part.id==id) 
        return part;
    }
    return null;
  }

  public void removeItem(int id) {      //возвращает экземпляр объекта по id
    for (Item part : this) {
      if (part.id==id) 
        this.remove(part);
    }
  }
  public String getNames() {
    if (this.size()==0)
      return text_empty;
    else {
      String names="";
      IntList inv = this.sortItem();
      for (int k=0; k<inv.size(); k++) {
        int i=inv.get(k);
        names+=this.getItem(i).name+" ("+this.calculationItem(i)+")";
        if (k!=inv.size()-1)
          names+=",\n";
      }
      return names;
    }
  }



  public void removeItemCount (Item item, int count) {
    if (item!=null) {
      for (int i=0; i<count; i++)
        if (this.contains(item))
          this.remove(item);
    }
  }
}
