import de.bezier.guido.*;

SimpleButton buttonLock, buttonRename, buttonRotate;

WindowLabel windowInput;
SimpleButton getListActors;
RadioButton menuColony, menuColonyObjects, menuColonyFraction;
Text textLabel, consoleLabel;
void createInterface() {
  Interactive.make( this );
  Interface.level=Interface.id=Interface.GAME;
  textLabel = new Text (391, 182, 400, 400, 0, white, color(60));
  consoleLabel = new Text (world.x_map-world.getCenterWindow(), world.y_map+world.getCenterWindow()+5, world.x_map+world.getCenterWindow()-5, 160, 0, white, black);
  menuColony = new RadioButton (5, 5, width-10, 32, RadioButton.HORIZONTAL);
  menuColony.addButtons(new SimpleRadioButton [] {new SimpleRadioButton(text_objects, "getMenuObjects"), 
    new SimpleRadioButton(text_buildings, ""), 
    new SimpleRadioButton(text_world, ""), 
    new SimpleRadioButton(text_fraction, "getMenuFraction"), 
    new SimpleRadioButton(text_zone, ""), 
    new SimpleRadioButton(text_menu, "")});
  menuColonyObjects = new RadioButton (391, 42, 405, 128, RadioButton.VERTICAL);
  menuColonyObjects.addButtons(new SimpleRadioButton [] {new SimpleRadioButton(text_button_manager, "getObjectManager"), 
    new SimpleRadioButton(text_info, "getObjectInfo"), 
    new SimpleRadioButton(text_diagnostic, ""), 
    new SimpleRadioButton(text_button_tasks, "")});
  menuColonyFraction = new RadioButton (391, 42, 405, 128, RadioButton.VERTICAL);
  menuColonyFraction.addButtons(new SimpleRadioButton [] {new SimpleRadioButton(text_info, "getFractionInfo"), 
    new SimpleRadioButton(text_job, "getListJobs"), 
    new SimpleRadioButton(text_actors, "getListActors"), 
    new SimpleRadioButton(text_resources, "getListResources")});

  windowInput = null;




  buttonRename = new SimpleButton(400, 206, 192, 32, text_button_rename, new Runnable() {
    public void run() {
      windowInput=new WindowLabel(text_input_value+":", (renamed)world.currentRoom.currentObject);
    }
  }
  );
  buttonLock = new SimpleButton(400, 206, 256, 32, text_button_lock_unlock, new Runnable() {
    public void run() {
      ItemMap itemMap = (ItemMap)world.currentRoom.currentObject;
      itemMap.lock=!itemMap.lock;
    }
  }
  );

  buttonRotate = new SimpleButton(400, 239, 192, 32, text_button_rotate, new Runnable() {
    public void run() {
      rotated object = (rotated)world.currentRoom.currentObject;
      object.setDirectionNext();
    }
  }
  );
}

public void drawInterface() {
  buttonLock.setActive(false);
  buttonRename.setActive(false);
  buttonRotate.setActive(false);
  menuColonyObjects.setActive(false);
  menuColonyFraction.setActive(false);
  menuColony.control();
  consoleLabel.draw();

  if (menuColony.select.event.equals("getMenuObjects")) {
    menuColonyObjects.setActive(true);
    menuColonyObjects.control();
    if (world.currentRoom.currentObject!=null) {
      if (menuColonyObjects.select.event.equals("getObjectInfo")) {
        textLabel.draw();
        textLabel.loadText(world.currentRoom.currentObject.getDescript(), true);
      } else if (menuColonyObjects.select.event.equals("getObjectManager")) {
        if (world.currentRoom.currentObject.id==Object.ACTOR || world.currentRoom.currentObject.id==Object.STORAGE) 
          buttonRename.setActive(true);     
        if (world.currentRoom.currentObject.id==Object.ITEM)
          buttonLock.setActive(true);
        if (world.currentRoom.currentObject instanceof rotated) 
          buttonRotate.setActive(true);
      }
    } else {
      textLabel.draw();
      textLabel.loadText(text_selected_objects, false);
    }
  } else if (menuColony.select.event.equals("getMenuFraction")) {
    menuColonyFraction.setActive(true);
    menuColonyFraction.control();
    String text="";
    if (menuColonyFraction.select.event.equals("getFractionInfo")) {
      text = text_nikname+": "+ playerFraction.name+"\n"+
        text_count_actors+": "+world.currentRoom.objects.getActorList().size()+"\n"+
        text_free_droids+": "+world.currentRoom.objects.getActorListJobFree().size()+"\n";
      textLabel.loadText(text, true);
    } else if (menuColonyFraction.select.event.equals("getListJobs")) {
      for (Job part : playerFraction.jobs) 
        if (part.worker!=null)
          text+=part.name+" ("+part.worker.name+")\n";
        else
          text+=part.name+" (не назначено)\n";
      if (text.isEmpty())
        textLabel.loadText(text_empty, false);
      else
        textLabel.loadText(text, true);
    } else if (menuColonyFraction.select.event.equals("getListResources")) {
      text=world.currentRoom.getItemsList().getNames();
      if (text.isEmpty())
        textLabel.loadText(text_empty, true);
      else 
      textLabel.loadText(text, true);
    } else if (menuColonyFraction.select.event.equals("getListActors")) {
      for (listened part : world.currentRoom.getActorsList()) 
        text+=((Actor)part).getName()+"\n";
      textLabel.loadText(text, true);
    }
    textLabel.draw();
  }
  if (windowInput!=null)
    windowInput.control();
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
  static final public int GAME=0, PAUSE=1, INPUT=2; 

  static public int getNewId() {
    id++; 
    return id;
  }

  static public void update() {
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
  public void setPositionDown(ObjectGui object) {
    x=object.x;
    y=object.y+object.heightObj+2;
  }

  public boolean isMouseOver() {
    if (mouseButton!=RIGHT && world.isPermissionInput() && (mouseX>=x && mouseX<x+widthObj) && (mouseY>=y && mouseY<y+heightObj))
      return true;
    else 
    return false;
  }
  protected boolean isClick () {
    if (mousePressed==true && isMouseOver() && level==Interface.level) return true;
    else return false;
  }
}






class RadioButton extends ActiveElement {
  int orientation;
  SimpleRadioButton select;
  ArrayList <SimpleRadioButton> buttons= new ArrayList <SimpleRadioButton>();
  final static int HORIZONTAL = 0;
  final static int VERTICAL= 1;

  RadioButton  (int x, int y, int widthObj, int  heightObj, int orientation) {
    super(x, y, widthObj, heightObj);
    this.orientation = constrain(orientation, 0, 1);
  }

  public void addButton(SimpleRadioButton button) {
    buttons.add(button);
    update();
  }

  public void control () {
    for (SimpleRadioButton button : buttons) {
      if (button.pressed) 
        setSelect(button);
    }
  }
  public void setActive(boolean active) {
    super.setActive(active);
    for (SimpleRadioButton button : buttons)
      button.setActive(active);
  }

  public void addButtons(SimpleRadioButton [] buttons) {
    this.buttons.clear();
    for (SimpleRadioButton button : buttons)
      this.buttons.add(button);
    update();
  }

  private void update() {
    for (int i=0; i<buttons.size(); i++) {
      SimpleRadioButton button = buttons.get(i);
      if (orientation==HORIZONTAL) {
        int widthButton = (int)width/buttons.size();
        button.width=widthButton;
        button.height=height;
        button.y=y;
        button.x=x+i*(widthButton+1);
      } else if (orientation==VERTICAL) {
        int heightButton =  (int)height/buttons.size();
        button.height=heightButton;
        button.width=width;
        button.x=x;
        button.y=y+i*(heightButton+1);
      }
    }
    setSelect(buttons.get(0));
  }

  protected void setSelect(SimpleRadioButton button) {
    select=button;
    for (SimpleRadioButton part : buttons) {
      if (part.equals(select)) 
        part.on=true;
      else 
      part.on=false;
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


class WindowLabel {
  String message, input;
  renamed object;
  SimpleButton buttonOk;

  WindowLabel (String message, renamed object) {
    this.message=message;
    this.object=object;
    this.input=object.getName();
    world.input=false;
    world.pause=true;
    buttonOk = new SimpleButton(100, 150, 128, 32, "Ok", new Runnable() {
      public void run() {
        windowInput.close();
        windowInput=null;
      }
    }
    );
  }
  public void close() {
    world.input=true;
    world.pause=false;
    object.setName(input);
    buttonOk.setActive(false);
    buttonOk=null;
  }
  void control() {
    pushMatrix();
    pushStyle();
    rectMode(CENTER);
    translate(width/2, height/2);
    fill(black);
    rect(0, 0, 400, 300);
    fill(white);
    text(message, -150, -100);
    text(">"+input+"<", -150, -50);
    popStyle();
    popMatrix();
    buttonOk.setActive(true);
  }
}


class SimpleButton extends ActiveElement {
  boolean on;
  String text;
  Runnable script;

  SimpleButton (float x, float y, float w, float h, String text, Runnable script) {
    super(x, y, w, h);
    this.text=text;
    this.script=script;
  }

  void mousePressed () {
    if (script!=null)
      script.run();
  }

  void draw () {
    pushStyle();
    if ( hover )    
      if (mousePressed ) 
        stroke(color(90));
      else 
      stroke(white);
    else noStroke();
    if ( on ) fill( white );
    else fill( color(60));
    rect(x, y, width, height);
    strokeWeight(1);
    textAlign(CENTER, CENTER);
    if ( on ) fill( color(60) );
    else fill( white);
    textSize(18);
    text(text, x+this.width/2, y+this.height/2-textDescent());
    popStyle();
  }
}

class SimpleRadioButton extends SimpleButton {
  String event;

  SimpleRadioButton (String text, String event) {
    super(133, 9, 1, 1, text, null);  
    this.event=event;
  }
  void mouseClicked () {
    if (mouseButton==LEFT)
      on=!on;
  }
}
