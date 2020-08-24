
Button getListDroids;
RadioButton menuColony, menuColonyObjects, menuColonyFraction;
Text textLabel;
void createInterface() {
  Interface.level=Interface.id=0;
  textLabel = new Text (391, 259, 400, 160, 0, white, black);
  menuColony = new RadioButton (5, 5, width-10, 32, 0, RadioButton.HORIZONTAL);
  menuColony.addButtons(new Button [] {new Button(text_objects, "getMenuObjects"), 
    new Button(text_buildings, "getListFabrics"), 
    new Button(text_world, "getListDroids"), 
    new Button(text_fraction, "getMenuFraction"), 
    new Button(text_zone, "getListZone"), 
    new Button(text_menu, "getListDroids")});
  menuColonyObjects = new RadioButton (391, 42, 405, 128, 0, RadioButton.VERTICAL);
  menuColonyObjects.addButtons(new Button [] {new Button(text_droids, "getListDroids"), 
    new Button(text_miners, "getListFabrics"), 
    new Button(text_storages, "getListStorages"), 
    new Button(text_enviroments, "getListOther")});
  menuColonyFraction = new RadioButton (391, 42, 405, 128, 0, RadioButton.VERTICAL);
  menuColonyFraction.addButtons(new Button [] {new Button(text_info, "getFractionInfo"), 
    new Button(text_job, "getListJobs"), 
    new Button(text_zone, "getListFabrics"), 
    new Button(text_resources, "getListResources")});
}

public void drawInterface() {
  menuColony.control();
  if (menuColony.select.script.equals("getMenuObjects")) {
    menuColonyObjects.control();
    textLabel.draw();
  } else if (menuColony.select.script.equals("getMenuFraction")) {
    menuColonyFraction.control();
    textLabel.draw();
  }
}


interface mouseOvered {
  public boolean isMouseOver();
}



interface scrollable extends mouseOvered {
  public void scrollUp(); 
  public void scrollDown();
}

static class Interface {
  static public int id;
  static public int level;
  static private ArrayList <ObjectGui> objects= new ArrayList <ObjectGui>();
  static public PFont font;

  static public int getNewId() {
    id++; 
    return id;
  }

  static public void update() {
    for (ObjectGui part : objects) {
      if (part instanceof Button) {
        ((Button)part).check(); 
        break;
      } else if (part instanceof RadioButton) {
        ((RadioButton)part).check();
        break;
      }
    }
  }

  static public void add(ObjectGui object ) {
    objects.add(object);
  }

  static public void add(ObjectGui [] objectsList) {
    for (ObjectGui object : objectsList)
      objects.add(object);
  }
  static public ArrayList <scrollable> getScrollObjects () {
    ArrayList <scrollable> scrollList= new ArrayList <scrollable>();
    for (ObjectGui part : objects) {
      if (part instanceof scrollable) 
        scrollList.add((scrollable)part);
    }
    return scrollList;
  }
}






abstract class ObjectGui implements mouseOvered {
  protected int x, y, level, id, widthObj, heightObj;
  ObjectGui (int x, int y, int widthObj, int  heightObj, int level) {
    this.x=x;
    this.y=y;
    this.widthObj=widthObj;
    this.heightObj=heightObj;
    this.level=level;
    Interface.add(this);
    id=Interface.getNewId();
  }
  ObjectGui () {
    x=y=widthObj=heightObj=level=-1;
  }
  public void control() {
    draw();
  }
  public boolean isMouseOver() {
    if ((mouseX>=x && mouseX<x+widthObj) && (mouseY>=y && mouseY<y+heightObj))
      return true;
    else 
    return false;
  }
  protected boolean isClick () {
    if (mousePressed==true && isMouseOver() && level==Interface.level) return true;
    else return false;
  }

  abstract protected void draw();
}




class Button extends ObjectGui {
  protected String text, script;
  protected boolean switchButton, flag;
  private boolean pressedButton;

  Button (int x, int y, int widthObj, int  heightObj, int level, String text, String script, boolean switchButton, boolean pressedButton) { //универсальный
    super(x, y, widthObj, heightObj, level);
    this.text=text;
    this.script=script;
    this.pressedButton=pressedButton;
    this.switchButton=switchButton;
    flag=false;
  }
  Button (String text, String script) {
    super();  
    this.text=text;
    this.script=script;
    pressedButton=switchButton=false;
  }

  public void control () {
    check();
    draw();
  }

  protected void check() {
    if (!pressedButton && isClick()) 
      event();
  }

  protected void draw() {
    if (pressedButton && isClick())
      event();
    pushStyle();
    pushMatrix();
    strokeWeight(1);
    textAlign(CENTER, CENTER);
    color text_color, rect_color;
    if (isClick() || flag) {
      text_color=black;
      rect_color=white;
    } else {
      text_color=white;
      rect_color=black;
    }
    fill(rect_color);
    rect(x, y, widthObj, heightObj);
    fill(text_color);
    textSize(14);
    clip(x, y, widthObj+1, heightObj+1);
    text(text, x+widthObj/2, y+heightObj/2-textDescent());
    noClip();
    popStyle();
    popMatrix();
  }

  protected void event () {
    if (switchButton) {
      flag=!flag;
    }
    if (script!=null) {
      String text="";
      switch (script) {
      case "getListDroids" :
        for (listened part : world.currentRoom.getDroidsList()) 
          text+=((Droid)part).getName()+"\n";
        textLabel.loadText(text, true);
        break;
      case "getListFabrics" :
        for (listened part : world.currentRoom.getFabricsList()) 
          text+=((Miner)part).getName()+"\n";
        if (text.isEmpty())
          textLabel.loadText(text_empty, false);
        else
          textLabel.loadText(text, false);
        break;
      case "getListStorages" :
        for (listened part : world.currentRoom.getStorageList()) 
          text+=((Storage)part).getName()+"\n";
        if (text.isEmpty())
          textLabel.loadText(text_empty, false);
        else
          textLabel.loadText(text, false);
        break;
      case "getListResources" :
          text=world.currentRoom.getItemsList().getNames();
        if (text.isEmpty())
          textLabel.loadText(text_empty, false);
        else
          textLabel.loadText(text, false);
        break;
      case "getListOther" :
        for (Object part : world.currentRoom.getEnviromentList()) 
          text+=part.getName()+"\n";
        if (text.isEmpty())
          textLabel.loadText(text_empty,true);
        else
          textLabel.loadText(text, true);
        break;
      case "getFractionInfo" :
        text = text_nikname+": "+ playerFraction.name+"\n"+
        text_count_droids+": "+world.currentRoom.objects.getDroidList().size()+"\n"+
        text_free_droids+": "+world.currentRoom.objects.getDroidListJobFree().size()+"\n";
        textLabel.loadText(text, false);
        break;
      case "getListJobs" :
        for (Job part : playerFraction.jobs) 
        if (part.worker!=null)
        text+=part.name+" ("+part.worker.name+")\n";
        else
          text+=part.name+" (не назначено)\n";
        if (text.isEmpty())
          textLabel.loadText(text_empty, false);
        else
          textLabel.loadText(text, true);
        break;
      }
    }
  }
}

class RadioButton extends ObjectGui {
  int orientation;
  Button select;
  ArrayList <Button> buttons= new ArrayList <Button>();
  final static int HORIZONTAL = 0;
  final static int VERTICAL= 1;

  RadioButton  (int x, int y, int widthObj, int  heightObj, int level, int orientation) {
    super(x, y, widthObj, heightObj, level);
    this.orientation = constrain(orientation, 0, 1);
  }

  public void addButton(Button button) {
    buttons.add(button);
    update();
  }

  public void control () {
    check();
    draw();
  }

  public void addButtons(Button [] buttons) {
    this.buttons.clear();
    for (Button button : buttons)
      this.buttons.add(button);
    update();
  }

  protected void draw() {
    for (Button button : buttons)
      button.draw();
  }

  private void update() {
    for (int i=0; i<buttons.size(); i++) {
      Button button = buttons.get(i);
      button.id=i;
      button.switchButton=false;
      button.pressedButton=false;
      button.level=0;
      if (orientation==HORIZONTAL) {
        int widthButton =  widthObj/buttons.size();
        button.widthObj=widthButton;
        button.heightObj=heightObj;
        button.y=y;
        button.x=x+i*widthButton;
      } else if (orientation==VERTICAL) {
        int heightButton =  heightObj/buttons.size();
        button.heightObj=heightButton;
        button.widthObj=widthObj;
        button.x=x;
        button.y=y+i*heightButton;
      }
    }
    setSelect(buttons.get(0));
  }

  protected void setSelect(Button button) {
    select=button;
    for (Button part : buttons) {
      if (part.equals(select)) 
        part.flag=true;
      else 
      part.flag=false;
    }
    select.event();
  }

  protected void check() {
    if (isClick()) {
      for (Button button : buttons) {
        if (button.isClick()) 
          setSelect(button);
      }
    }
  }
}




class Text extends ObjectGui implements scrollable {
  String text;
  color text_color, background_color;
  int yT, grid_size;
  StringList texts = new StringList ();

  Text (int x, int y, int widthObj, int  heightObj, int level, color text_color, color background_color) {
    super(x, y, widthObj, heightObj, level);
    this.text=null;
    this.background_color=background_color;
    this.text_color=text_color;
    yT=0;
    grid_size=30;
  }
  public void clear() {
    text=null;
    texts.clear();
  }

  public void loadText(String text, boolean lineOne) {
    int prevLine = getTextNumStr();
    this.text=text;
    texts.clear();
    String [] str= split(text, '\n');
    if (str.length==1) 
      texts.append(text);
    int current_str=0;
    for (int i=0; i<str.length-1; i++) {
      String part = str[i], current, newStr;
      if (texts.size()>0 && current_str<texts.size()) {
        current = texts.get(current_str);
        newStr = current+" "+part;
      } else {
        current = "";
        newStr = part;
      }
      if (textWidth(newStr)<widthObj && !lineOne) 
        texts.set(current_str, newStr);
      else {
        texts.append(part);
        current_str++;
      }
    }
    if (current_str<prevLine) 
      yT=0;
  }
  protected int getTextHeight() {
    return getTextNumStr()*grid_size;
  }
  protected int getTextNumStr() {
    return texts.size();
  }

  protected void draw() {
    pushStyle();
    strokeWeight(1);
    stroke(text_color);
    fill(background_color);
    rect(x, y, widthObj, heightObj);
    fill(text_color);
    textLeading(grid_size);
    clip(x, y, widthObj+1, heightObj+1);
    if (text!=null) {
      if (getTextHeight()>heightObj) 
        rect(x+widthObj-3, y-map(yT, 0, getTextHeight(), 0, heightObj), 3, map(heightObj/getTextNumStr(), 0, getTextHeight(), 0, heightObj)*getTextNumStr());
      int yt=y+grid_size+yT;
      for (int i=0; i<texts.size(); i++) {
        String current = texts.get(i);
        if (current!=null) {       
          text(current, x+8, yt);
          yt+=grid_size;
        }
      }
    }
    noClip();
    popStyle();
  }

  public void scrollDown() {
    if (getTextHeight()>=heightObj)
      yT=constrain(yT-=10, -(getTextHeight()-heightObj)-10, 0);
  }
  public void scrollUp() {
    if (getTextHeight()>=heightObj)
      yT=constrain(yT+=10, -getTextHeight(), 0);
  }
}
