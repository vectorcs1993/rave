

class Item implements cloneable {
  private final String name;
  protected final int id;
  protected int stack;
  protected final int weight;
  public PImage sprite;
  static final int STEEL=0, WOOD=3, STONE=2, COOPER=1;

  Item (int id) {
    this.id=id;
    this.name = getItemNameDatabase(id);
    sprite= getSpriteDatabase();
    weight=1;
    stack=getStackDatabase();
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
    case COOPER: 
      return sprite_item_cooper;
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
    case COOPER: 
      return 10;
    default: 
      return 1;
    }
  }
}


class ItemIntList extends IntList {

  public String getNames() {  //сортирует по наименованию и возвращает список имен
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
    return text_res_steel;
  case Item.WOOD: 
    return text_res_wood;
  case Item.COOPER: 
    return text_res_cooper;
  case Item.STONE: 
    return text_res_stone;
  default: 
    return text_no_name;
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



  public void removeItemCount (Item item, int count) {
    if (item!=null) {
      for (int i=0; i<count; i++)
        if (this.contains(item))
          this.remove(item);
    }
  }
}
