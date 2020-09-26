import de.bezier.guido.*;
Listbox buildings, itemsList;
SimpleButton buttonLock, buttonRename, buttonRotate, buttonCreate, buttonCreate1, buttonCreate10, buttonCreate100, buttonCancelProduct;
SimpleRadioButton buttonInfo, 
  buttonManager, 
  buttonCargo, 
  buttonTask, buttonFunctions;

CheckList tasks;


WindowLabel windowInput;
SimpleButton getListActors;
RadioButton menuColony, menuColonyActors, menuColonyFabrics, menuColonyItemsMap, menuColonyStorages, menuColonyFraction;
Text textLabel, consoleLabel;
void createInterface() {
  Interface.level=Interface.id=Interface.GAME;

  buildings=new Listbox(400, 40, 390, 360, Listbox.OBJECTS);
  data.loadListBoxFromDBObjects(buildings);
  itemsList = new Listbox(400, 180, 390, 210, Listbox.ITEMS);
  textLabel = new Text (391, 182, 400, 400, 0, white, color(60));
  consoleLabel = new Text (world.x_map-world.getCenterWindow(), world.y_map+world.getCenterWindow()+5, world.x_map+world.getCenterWindow()-5, 160, 0, white, black);
  //кнопки
  buttonInfo = new SimpleRadioButton(data.label.get("button_info"), "getInfo"); 
  buttonManager=new SimpleRadioButton(data.label.get("button_manager"), "getManager");
  buttonCargo=new SimpleRadioButton(data.label.get("button_cargo"), "getCargo");
  buttonTask=new SimpleRadioButton(data.label.get("button_tasks"), "getTasks", new Runnable() { 
    public void run() {
      Fabrica fabrica = (Fabrica) world.currentRoom.currentObject;
      if (fabrica.products!=null)
      data.loadListBoxFromDBProducts(itemsList, fabrica.products);
    }
  }
  );
  buttonFunctions=new SimpleRadioButton(data.label.get("button_functions"), "getFunctions");

  menuColony = new RadioButton (5, 5, width-10, 32, RadioButton.HORIZONTAL);
  menuColony.addButtons(new SimpleRadioButton [] {new SimpleRadioButton(text_object, "getMenuObjects"), 
    new SimpleRadioButton(text_buildings, "getMenuBuildings"), 
    new SimpleRadioButton(text_world, ""), 
    new SimpleRadioButton(data.label.get("menu_fraction"), "getMenuFraction"), 
    new SimpleRadioButton(data.label.get("menu_study"), ""), 
    new SimpleRadioButton(text_menu, "")});
  menuColonyActors = new RadioButton (391, 42, 405, 128, RadioButton.VERTICAL);
  menuColonyActors.addButtons(new SimpleRadioButton [] {buttonManager.clone(), buttonInfo.clone(), 
    new SimpleRadioButton(text_diagnostic, ""), buttonFunctions.clone()});
  menuColonyStorages=new RadioButton (391, 42, 405, 96, RadioButton.VERTICAL);
  menuColonyStorages.addButtons(new SimpleRadioButton [] {buttonManager.clone(), buttonInfo.clone(), buttonCargo.clone()});
  menuColonyFabrics = new RadioButton (391, 42, 405, 96, RadioButton.VERTICAL);
  menuColonyFabrics.addButtons(new SimpleRadioButton [] {buttonManager.clone(), buttonInfo.clone(), buttonTask.clone()});
  menuColonyItemsMap = new RadioButton (391, 42, 405, 64, RadioButton.VERTICAL);
  menuColonyItemsMap.addButtons(new SimpleRadioButton [] {buttonManager.clone(), buttonInfo.clone()});
  menuColonyFraction = new RadioButton (391, 42, 405, 128, RadioButton.VERTICAL);
  menuColonyFraction.addButtons(new SimpleRadioButton [] { buttonInfo.clone(), 
    new SimpleRadioButton(text_job, "getListJobs"), 
    new SimpleRadioButton(text_actors, "getListActors"), buttonCargo.clone()});
  //чек-бокс для определения функций дронов
  tasks= new CheckList(410, 200, 200, 350);
  tasks.add(new CheckBox [] { new CheckBox(text_carry, 410, 220, 10, 10, Job.CARRY, "Переноска предметов"), 
    new CheckBox( text_maintenance, 410, 250, 10, 10, Job.MAINTENANCE, "Обслуживание объектов"), 
    new CheckBox( text_mine, 410, 280, 10, 10, Job.MINE, "Добыча ресурсов"), 
    new CheckBox( text_build, 410, 310, 10, 10, Job.BUILD, "Строительство объектов"), 
    new CheckBox( text_craft, 410, 340, 10, 10, Job.CRAFT, "Создание предметов"), 
    new CheckBox( text_guard, 410, 370, 10, 10, Job.GUARD, "Защита территории от врагов")});




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
  buttonCreate = new SimpleButton(400, 552, 256, 32, text_button_create, new Runnable() {
    public void run() {
      Object object =world.currentRoom.currentObject;
      if (object instanceof Fabrica) {
        Fabrica fabrica = (Fabrica)world.currentRoom.currentObject;
        fabrica.setProduct(itemsList.select.id, 1);
        fabrica.getSurpluses();
        if (object instanceof Bench) {
          Bench bench = (Bench)fabrica;
          if (bench.job!=null)
          bench.job.worker.job=null;
          bench.job=null;
        }
      }
    }
  }
  );
  buttonCreate1 = new SimpleButton(592, 552, 64, 32, "+1", new Runnable() {
    public void run() {
      Object object =world.currentRoom.currentObject;
      if (object instanceof Fabrica) {
        Fabrica fabrica = (Fabrica)world.currentRoom.currentObject;
        fabrica.count+=1;
      }
    }
  }
  );
  buttonCreate10 = new SimpleButton(657, 552, 64, 32, "+10", new Runnable() {
    public void run() {
      Object object =world.currentRoom.currentObject;
      if (object instanceof Fabrica) {
        Fabrica fabrica = (Fabrica)world.currentRoom.currentObject;
        fabrica.count+=10;
      }
    }
  }
  );
  buttonCancelProduct= new SimpleButton(400, 552, 192, 32, "Отмена", new Runnable() {
    public void run() {
      Object object =world.currentRoom.currentObject;
      if (object instanceof Fabrica) {
        Fabrica fabrica = (Fabrica)world.currentRoom.currentObject;
        fabrica.resetProduct();
      }
    }
  }
  );
}



public void drawInterface() {
  buttonLock.setActive(false);
  buttonRename.setActive(false);
  buttonRotate.setActive(false);
  buttonCreate.setActive(false);
  buttonCreate1.setActive(false);
  buttonCreate10.setActive(false);
  buttonCancelProduct.setActive(false);
  menuColonyActors.setActive(false);
  menuColonyStorages.setActive(false);
  menuColonyFabrics.setActive(false);
  menuColonyFraction.setActive(false);
  menuColonyItemsMap.setActive(false);
  tasks.setActive(false);
  buildings.setActive(false);
  itemsList.setActive(false);
  menuColony.control();
  consoleLabel.draw();

  Object object = world.currentRoom.currentObject;
  if (menuColony.select.event.equals("getMenuObjects")) {
    if (object!=null) {

      if (object instanceof Fabrica) {
        menuColonyFabrics.setActive(true);
        menuColonyFabrics.control();
        String event= menuColonyFabrics.select.event;
        if (event.equals("getInfo")) {
          textLabel.draw();
          textLabel.loadText(object.getDescript(), true);
        } else if (event.equals("getManager")) {
          if (object instanceof rotated) 
            buttonRotate.setActive(true);
        } else if (event.equals("getTasks")) {
          Fabrica fabrica = (Fabrica)object;
          if (fabrica.products!=null) 
            itemsList.setActive(true);
          else 
          return;
          String product = text_no;
          if (fabrica.product!=null) 
            product=fabrica.product.name+" ("+fabrica.count+")";
          fill(white);
          text(text_product+": "+product, 395, 172);

          if (itemsList.select!=null) {
            if (fabrica.product!=null) {
              if (fabrica instanceof Bench) 
                 buttonCancelProduct.setActive(true);
              else {
                if (fabrica.product.id!=itemsList.select.id)
                  buttonCreate.setActive(true);
                else {
                   buttonCancelProduct.setActive(true);
                  buttonCreate1.setActive(true);
                  buttonCreate10.setActive(true);
                }
              }
            } else 
            buttonCreate.setActive(true);
          }
        }
      } else if (object instanceof Storage) {
        menuColonyStorages.setActive(true);
        menuColonyStorages.control();
        String event= menuColonyStorages.select.event;
        if (event.equals("getManager")) {
          if (object instanceof rotated) 
            buttonRotate.setActive(true);
        } else if (event.equals("getInfo")) {
          textLabel.draw();
          textLabel.loadText(object.getDescript(), true);
        } else if (event.equals("getCargo")) {
          textLabel.draw();
          textLabel.loadText(((Storage)object).getDescriptStorage(), true);
        }
      } else if (object instanceof ItemMap) {
        menuColonyItemsMap.setActive(true);
        menuColonyItemsMap.control();
        String event= menuColonyItemsMap.select.event;
        if (event.equals("getManager")) 
          buttonLock.setActive(true);
        else if (event.equals("getInfo")) {
          textLabel.draw();
          textLabel.loadText(object.getDescript(), true);
        }
      } else {
        menuColonyActors.setActive(true);
        menuColonyActors.control();
        String event= menuColonyActors.select.event;
        if (event.equals("getInfo")) {
          textLabel.draw();
          textLabel.loadText(object.getDescript(), true);
        } else if (event.equals("getManager")) {
          if (object.id==Object.ACTOR || object instanceof Storage) 
            buttonRename.setActive(true);     
          if (object instanceof rotated) 
            buttonRotate.setActive(true);
        } else if (event.equals("getFunctions")) {
          if (object instanceof Actor) {
            tasks.setActive(true);
            tasks.synhronizedSkills((Actor)object);
          }
        }
      }
    } else {
      text(text_selected_objects, 408, 80);
    }
  } else if (menuColony.select.event.equals("getMenuFraction")) {
    menuColonyFraction.setActive(true);
    menuColonyFraction.control();
    String text="";
    if (menuColonyFraction.select.event.equals("getInfo")) {
      text = text_name+": "+ playerFraction.name+"\n"+
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
    } else if (menuColonyFraction.select.event.equals("getCargo")) {
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
  } else if (menuColony.select.event.equals("getMenuBuildings")) {
    buildings.setActive(true);
    if (buildings.select!=null && world.hover && world.isOverMap()) {
      world.newObj = data.objects.getObjectDatabase(buildings.select.id);
    }
  }

  if (windowInput!=null)
    windowInput.setActive(true);
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
  protected Listbox buildings, items;
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
    if (mouseButton!=RIGHT && world.isAllowInput() && (mouseX>=x && mouseX<x+widthObj) && (mouseY>=y && mouseY<y+heightObj))
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
    select=null;
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


class WindowLabel extends ActiveElement {
  String message, input;
  renamed object;
  SimpleButton buttonOk;

  WindowLabel (String message, renamed object) {
    super(40, 130, 300, 200);
    this.message=message;
    this.object=object;
    this.input=object.getName();
    world.input=false;
    world.pause=true;
    buttonOk = new SimpleButton(x+50, 150, 128, 32, "Ok", new Runnable() {
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
    setActive(false);
  }
  void draw() {
    fill(black);
    rect(x, y, width, height);
    fill(white);
    text(message, 0, -100);
    text(">"+input+"<", -150, -50);
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
    if (hover)    
      if (mousePressed ) 
        stroke(color(90));
      else 
      stroke(white);
    else noStroke();
    if ( on ) fill( white );
    else fill(black);
    rect(x, y, width, height);
    strokeWeight(1);
    textAlign(CENTER, CENTER);
    if ( on ) fill(black);
    else fill(white);
    textSize(18);
    text(text, x+this.width/2, y+this.height/2-textDescent());
    popStyle();
  }
}

class SimpleRadioButton extends SimpleButton {
  String event;

  SimpleRadioButton (String text, String event, Runnable script) {
    this(text, event);
    this.script=script;
  }
  SimpleRadioButton (String text, String event) {
    super(-600, -600, 1, 1, text, null);  
    this.event=event;
  }
  void mouseClicked () {
    if (mouseButton==LEFT)
      on=!on;
  }
  public SimpleRadioButton clone() {
    return new SimpleRadioButton (text, event, script);
  }
}

class CheckList extends ActiveElement {
  ArrayList <CheckBox> list; 
  CheckList (float xx, float yy, float ww, float hh ) {
    super(xx, yy, ww, hh);
    list = new ArrayList <CheckBox>();
  }
  public void add(CheckBox [] list) {
    for (CheckBox part : list)
      this.list.add(part);
  }
  public void setActive(boolean active) {
    for (CheckBox part : list)
      part.setActive(active);
  }
  public void draw() {
    if (hover) {
      for (CheckBox part : list) {
        if (part.hover) {
          fill(white);
          text(part.getDescript(), x, y+height+20);
          break;
        }
      }
    }
  }

  void mouseReleased () {
    Object object = world.currentRoom.currentObject;
    if (object!=null) {
      if (object instanceof Actor) {
        Actor actor = (Actor)object;
        actor.skills.clear();
        for (CheckBox part : list) {
          if (part.pressed)
            part.mouseReleased();
          if (part.checked) 
            actor.skills.append(part.id);
        }

        synhronizedSkills(actor);
      }
    }
  }

  void mouseHover() {
  }


  public void synhronizedSkills(Actor actor) {
    for (CheckBox part : list) {
      part.checked=false;
      for (int i : actor.skills) {
        if (part.id==i) {
          part.checked=true;
          break;
        }
      }
    }
  }
}
public class CheckBox extends ActiveElement {
  int id;
  boolean checked;
  float x, y, width, height;
  String label, descript;
  float padx = 7;

  CheckBox ( String l, float xx, float yy, float ww, float hh, int id, String descript) {
    super(xx, yy, ww, hh);
    label = l;
    x = xx; 
    y = yy; 
    width = ww; 
    height = hh;
    this.id=id;
    this.descript=descript;
    Interactive.add( this );
  }
  public String getDescript() {
    return descript;
  }
  void mouseReleased () {
    checked = !checked;
  }
  void draw () {
    noStroke();
    fill( 200 );
    rect( x, y, width, height );
    if ( checked ) {
      fill(black);
      rect( x+2, y+2, width-4, height-4 );
    } 
    if (hover)
      fill(gray);
    else
      fill(white);
    textAlign( LEFT );
    text(label, x+width+padx, y+height );
  }
  boolean isInside ( float mx, float my ) {
    return Interactive.insideRect( x, y, width+padx+textWidth(label), height, mx, my );
  }
}
