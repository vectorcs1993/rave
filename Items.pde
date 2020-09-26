
class Item implements cloneable {
  private final String name;
  protected final int id;
  protected int stack;
  protected final int weight;
  public final PImage sprite;
  static final int STEEL=0, COPPER=1, OIL=2, STONE=3, WOOD=4, PLATE_STEEL=5, PLATE_COPPER=6, RUBBER=7, BLOCK_STONE=8, BLOCK_STEEL=9, 
   BLOCK_PLASTIC=10, KIT_REPAIR=11;
  protected ItemIntList reciept;

  Item (int id) {
    this.id=id;
    name = getNameDatabase();
    sprite= getSpriteDatabase();
    weight=getWeightDatabase();
    stack=getStackDatabase();
    reciept=getRecieptDatabase();
  }

  protected PImage getSpriteDatabase() {
    return data.items.getObjectDatabase(id).sprite;
  }
  protected String getNameDatabase() {
    return data.items.getObjectDatabase(id).name;
  }
  public ItemIntList  getRecieptDatabase() {
    return data.items.getObjectDatabase(id).reciept;
  } 
  public cloneable clone() {
    return new Item (id);
  }
  public String getName() {
    return name;
  }
   private int getWeightDatabase() {  //стэк предмета, сколько в одной клетке может находиться одинаковых предметов
  return data.items.getObjectDatabase(id).weight;
  }
  private int getStackDatabase() {  //стэк предмета, сколько в одной клетке может находиться одинаковых предметов
  return data.items.getObjectDatabase(id).stack;
  }
    private int getOutputDatabase() {  //стэк предмета, сколько в одной клетке может находиться одинаковых предметов
  return data.items.getObjectDatabase(id).output;
  }
  private int getItemProgressMaxDatabase() {  //скорость создания предмета
    if (id==PLATE_STEEL || id==PLATE_COPPER) 
      return 100;
    else if (id==BLOCK_STONE)
      return 200;
    else
      return 10;
  }
}

void setComponent(ItemIntList items, int id, int count) {
  for (int i=0; i<count; i++)
    items.append(id);
}




class ItemIntList extends IntList {

  public String getNames(Database.DatabaseItemList data) {  //сортирует по наименованию и возвращает список имен
    if (this.size()==0)
      return text_empty+"\n";
    else {
      String names="";
      IntList inv = this.sortItem();
      for (int k=0; k<inv.size(); k++) {
        int i=inv.get(k);
        names+=data.getObjectDatabase(i).name+" ("+this.calculationItem(i)+")";
        if (k!=inv.size()-1)
          names+=",\n";
        else 
        names+="\n";
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
  public void addItemCount (int id, int count) {
    if (id!=-1) {
      for (int i=0; i<count; i++)
          this.append(id);
    }
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
  
  public int getWeight() {
    int itemsWeight = 0; 
    for (Item part : this) 
        itemsWeight+=part.weight;
    return itemsWeight;
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
    if (this.isEmpty())
      return text_empty+"\n";
    else {
      String names="";
      IntList inv = this.sortItem();
      for (int k=0; k<inv.size(); k++) {
        int i=inv.get(k);
        names+=this.getItem(i).getName()+" ("+this.calculationItem(i)+")";
        if (k!=inv.size()-1)
          names+=",\n";
        else 
        names+="\n";
      }
      return names;
    }
  }
  public void addItemCount (Item item, int count) {
    if (item!=null) {
      for (int i=0; i<count; i++)
          this.add(item);
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
