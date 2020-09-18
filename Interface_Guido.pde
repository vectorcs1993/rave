Listbox buildings, items;

class Listbox extends ActiveElement {
  ArrayList <ListItem> items;
  int itemHeight = 30, entry=30;
  int listStartAt = 0;
  int hoverItem = -1;
  ListItem select=null;
  float valueY = 0;
  boolean hasSlider = false;
  static final int ITEMS=0, OBJECTS=1;

  Listbox (float x, float y, float w, float h, int entry) {
    super(x, y, w, h);
    this.entry=entry;
    valueY = y;
  }

  class ListItem {
    int id;
    String label;
    ListItem (int id, String label) {
      this.id=id;
      this.label=label;
    }
  }
  public void addItem ( String item, int id) {
    if ( items == null ) items = new ArrayList <ListItem> ();
    items.add(new ListItem (id, item));
    hasSlider = items.size() * itemHeight > this.height;
  }

  public void mouseMoved ( float mx, float my ) {
    if (hasSlider && mx > x+this.width-20) return;
    if (hover)
      hoverItem = listStartAt + int((my-y) / itemHeight);
  }
  public void mouseExited ( float mx, float my ) {
    hoverItem = -1;
  }
  void mouseDragged (float mx, float my) {
    if (!hasSlider ) return;
    if (mx < x+this.width-20) return;
    valueY = my-itemHeight;
    valueY = constrain(valueY, y, y+this.height-itemHeight);
    update();
  }
  void mouseScrolled (float step) {
    if (items.size()*itemHeight>height && hover) {
      valueY += step*itemHeight;
      valueY = constrain(valueY, y, y+this.height-itemHeight);
      update();
    }
  }
  void update () {
    float totalHeight = items.size() * itemHeight;
    float itemsInView = this.height / itemHeight;
    float listOffset = map(valueY, y, y+this.height-itemHeight, 0, totalHeight-this.height);
    listStartAt = int( listOffset / itemHeight );
  }
  public void mousePressed ( float mx, float my ) { 
    if ( hasSlider && mx > x+this.width-20) return;
    int pressed=listStartAt + int((my-y)/itemHeight);
    if (pressed<=items.size()-1)
      select = items.get(pressed);
  }
  void draw () { 
    noStroke();
    fill( 100 );
    rect(x, y, this.width, this.height);
    if ( items != null ) {
      for ( int i = 0; i < int(this.height/itemHeight) && i < items.size(); i++) {
        stroke( 80 );
        if (i+listStartAt==items.indexOf(select))
          fill(gray);
        else 
        fill((i+listStartAt) == hoverItem ? white : black);
        rect(x, y + (i*itemHeight), this.width, itemHeight);
        noStroke();
        if (i+listStartAt==items.indexOf(select))
          fill(black);
        else 
        fill((i+listStartAt) == hoverItem ? black : white);
        text(items.get(i+listStartAt).label, x+5, y+(i+1)*itemHeight-5 );
      }
    }
    if (hasSlider) {
      stroke(80);
      fill(100);
      rect(x+this.width-20, y, 20, this.height);
      fill(120);
      rect(x+this.width-20, valueY, 20, 20);
    }
    if (select!=null) {
      ItemIntList reciept = new ItemIntList();
      PImage sprite = none;
      String description ="";
      if (entry==OBJECTS) {
        reciept = data.objects.getObjectDatabase(select.id).reciept;
        sprite = data.objects.getObjectDatabase(select.id).sprite;
        description = data.objects.getObjectDatabase(select.id).description;
      } else if (entry==ITEMS) {
        reciept = data.items.getObjectDatabase(select.id).reciept;
        sprite = data.items.getObjectDatabase(select.id).sprite;
        description = data.items.getObjectDatabase(select.id).description;
      }
      image(sprite, 500, 420);
      fill(255);
      text("Вид:", 400, 450);
      text("Описание: " +description, 400, 540);
      if (reciept.size()>0)       
        text(text_reciept+": "+reciept.getNames(data.items), 400, 480);
    }
  }
}
