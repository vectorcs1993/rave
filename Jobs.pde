


abstract class Job {   //работа по перемещению 
  protected final int id;
  protected String name;
  protected Actor worker;
  public final static int OTHER=-1, CARRY=0, BUILD=1, GUARD=2, REPAIR=3, MINE=4, CRAFT=5, CHARGE=6, MAINTENANCE=7;
  protected int skill;

  Job () {
    id=playerFraction.getNewId();
    worker=null;
    skill = OTHER;
  }

  abstract public boolean isComplete();  //проверка условия выполнения работы
  abstract protected String getNameDatabase(); //инициализация наименование работы
  public void update() { //обновления процесса выполнения работы
    name = getNameDatabase();
  }
  public String getDescript() { //возвращает текущее описание работы включая отслеживаемые параметры
    return name;
  }
  public void setWorker(Actor worker) {
    this.worker=worker;
  }
  public String getTextSkillDatabase() {
    switch (skill) {
    case CARRY: 
      return text_carry;
    default: 
      return text_no;
    }
  }
}





class JobMove extends Job {   //работа по перемещению 
  protected Graph target;

  JobMove (Graph target) {
    super();
    this.target=target;
    name = getNameDatabase();
  }

  public boolean isComplete() {
    if (worker!=null) {
      if (worker.x==target.x && worker.y==target.y) {
        return true;
      } else 
      return false;
    } else 
    return false;
  }
  public int getProcess() {
    if (!worker.path.isEmpty()) 
      return (int)map(worker.path.size(), 0, worker.pathFull, 100, 0);
    else
      return 100;
  }
  protected String getNameDatabase() {
    return text_worker_move+" "+target.x+","+target.y;
  }
  public void update() {
    super.update();
    if (target.solid)
      target= getNeighboring(world.currentRoom.node[target.x][target.y], null).get(0);
    if (worker!=null) {
      if (!worker.path.isEmpty()) 
        worker.moveNextPoint();
      else 
      worker.moveTo(target.x, target.y);
    }
  }
}

class JobPutItemMap extends Job {
  int process, processMax;
  ItemMap itemMap;

  JobPutItemMap(ItemMap itemMap) {
    super();
    this.itemMap = itemMap;
    process = 0;
    processMax= itemMap.item.weight*20;
    name = getNameDatabase();
  }

  protected String getNameDatabase() {
    return text_worker_put+" "+itemMap.item.getName();
  }

  public String getDescript() {
    return name+" "+getProcess()+" %";
  }

  public boolean isComplete() {
    if (process>=processMax) 
      return true;
    else 
    return false;
  }
  public int getProcess() {
    return (int)map(process, 0, processMax, 0, 100);
  }

  protected void action() {
    for (int i=0; i<worker.carryingCapacity; i++) {
      worker.items.add(itemMap.item);
      itemMap.count--;
      if (itemMap.count<=0) {
        world.currentRoom.remove(itemMap);
        break;
      }
    }
    itemMap.job=null;
  }
  public void update() {
    super.update();
    if (process<processMax) {
      process++;
      worker.setEnergy();
      if (process>=processMax) 
        action();
    }
  }
}

class JobPutItem extends Job {
  int process, processMax;
  Item item;
  Object object;

  JobPutItem(Object object, Item item) {
    super();
    this.item = item;
    this.object = object;
    process = 0;
    processMax= item.weight*20;
    name = getNameDatabase();
  }
  protected String getNameDatabase() {
    return text_worker_put+" "+item.getName();
  }
  public String getDescript() {
    return name+" "+getProcess()+" %";
  }
  public boolean isComplete() {
    if (process>=processMax) 
      return true;
    else 
    return false;
  }
  public int getProcess() {
    return (int)map(process, 0, processMax, 0, 100);
  }

  protected void action() {
    if (object instanceof Storage) {
      for (int i=0; i<worker.carryingCapacity; i++) {
        worker.items.add(item);
        ((Storage)object).items.remove(item);
      }
    }
    object.job=null;
  }

  public void update() {
    super.update();
    if (process<processMax) {
      process++;
      worker.setEnergy();
      if (process>=processMax) 
        action();
    }
  }
}



class JobGetItemMap extends JobPutItemMap {   //работа по выгрузке предмета 
  Storage storage;

  JobGetItemMap(Storage storage, ItemMap itemMap) {
    super(itemMap);
    this.storage=storage;
  }

  protected String getNameDatabase() {
    return text_worker_get+" "+itemMap.item.getName();
  }
  public void update() {
    super.update();
    if (!isComplete())
      worker.setDirection(storage.x, storage.y);
  }

  protected void action() {
    int freeCapacity = storage.getFreeCapacity();
    Item newItem = itemMap.item;
    int countItemWorker = worker.items.calculationItem(newItem.id);
    for (int i=0; i<countItemWorker; i++) {
      worker.items.removeItemCount(newItem, 1);
      if (i<freeCapacity) 
        storage.items.add(newItem);
      else {
        world.currentRoom.addItemOrder(worker.x, worker.y, newItem.id, 1);
      }
    }
    if (!worker.items.isEmpty()) {
      for (int i=worker.items.size()-1; i>=0; i--) {
        Item item = worker.items.get(i);
        worker.items.removeItemCount(item, 1);
        world.currentRoom.addItemOrder(worker.x, worker.y, item.id, 1);
      }
    }
  }
}

class JobGetItem extends JobPutItem {   //работа по выгрузке предмета 

  JobGetItem(Object object, Item item) {
    super(object, item);
  }

  protected String getNameDatabase() {
    return text_worker_get+" "+item.getName();
  }

  public void update() {
    super.update();
    if (!isComplete())
      worker.setDirection(object.x, object.y);
  }

  protected void action() {
    int count = worker.items.calculationItem(item.id);
    for (int i=0; i<count; i++) {
      worker.items.remove(item);
      if (object instanceof Storage) {
        ((Storage)object).items.add(item);
      } else if  (object instanceof Build) {
        ((Build)object).items.append(item.id);
      } else if  (object instanceof Fabrica) { 
        ((Fabrica)object).components.append(item.id);
      }
    }
    object.job=null;
  }
}

class JobPatrol extends Job {   //работа по патрулировании местности
  JobList path = new JobList ();
  Job currentJob;

  JobPatrol () {
    super(); 
    currentJob=null;
    name = getNameDatabase();
  }

  private void addPoint(int x, int y) {
    int rx = constrain(x, 0, world.getSize()-1);
    int ry = constrain(y, 0, world.getSize()-1);
    for (Job point : path) {
      JobMove move = (JobMove)point; 
      if (move.target.x==rx && move.target.y==ry) 
        return;
    } 
    JobMove curJob = new JobMove(world.currentRoom.node[rx][ry]);
    curJob.setWorker(worker);
    path.add(curJob);
  }



  private boolean addPointRandom() {
    ObjectList flags = world.currentRoom.flags.getFlagGuardList();
    Flag flag = (Flag)flags.get((int)random(flags.size()));
    int rx = constrain(flag.x, 0, world.getSize()-1);
    int ry = constrain(flag.y, 0, world.getSize()-1);
    if (!world.currentRoom.node[rx][ry].solid) {
      addPoint(rx, ry);
      return true;
    } else 
    return false;
  }

  public void setWorker(Actor worker) {
    super.setWorker(worker);
    for (Job job : path)
      job.setWorker(worker);
  }
  public boolean isComplete() {
    if (path.isEmpty())
      return true;
    else
      return false;
  }
  protected String getNameDatabase() {
    return text_job_patrol;
  }
  public String getDescript() {
    if (currentJob!=null)
      return currentJob.name;
    else
      return text_job_wait;
  }

  public void update () {
    if (currentJob!=null) {
      currentJob.update();
      if (currentJob.isComplete()) {
        path.remove(currentJob);
        currentJob=null;
      }
    } else {
      for (Job job : path) {
        if (!job.isComplete()) {
          currentJob=job;
          break;
        }
      }
    }
  }
}

class JobSupportPrimary extends Job {
  Support support;
  int type;
  JobSupportPrimary (int type, Support support) {
    super(); 
    this.type=type;
    this.support = support;
    name = getNameDatabase();
  }
  public void setWorker(Actor worker) {
    super.setWorker(worker);
    support.user=worker;
  }
  protected String getNameDatabase() {
    switch (type) {
    case Job.CHARGE:
      return text_worker_support_charge;
    case Job.REPAIR:
      return text_worker_support_repair;
    default:
      return text_no;
    }
  }

  public boolean isComplete() {
    if (support.isComplete())
      return true;
    else
      return false;
  }
  public void update () {
    if (worker!=null) 
      support.user=worker;
  }
}
class JobRepair extends Job {   //работа по восстановлению состояния
  Object object;

  JobRepair (Object object) {
    super(); 
    this.object=object;
    name = getNameDatabase();
  }
  protected String getNameDatabase() {
    return text_worker_repair+" "+object.name;
  }
  public boolean isComplete() {
    if (object.hp>=object.hpMax)
      return true;
    else
      return false;
  }
  public void update () {
    object.hp++;
    worker.setEnergy();
    if (isComplete()) 
      object.job=null;
  }
}

class JobMinePrimary extends Job {
  Enviroment enviroment;

  JobMinePrimary(Enviroment enviroment) {
    super();
    this.enviroment = enviroment;
    name = getNameDatabase();
  }
  protected String getNameDatabase() {
    return text_job_mine;
  }
  public String getDescript() {
    return name+" "+getProcess()+" %";
  }
  public boolean isComplete() {
    if (enviroment.hp<=0) 
      return true;
    else 
    return false;
  }
  public int getProcess() {
    return (int)map(enviroment.hp, 0, enviroment.hpMax, 100, 0);
  }
  protected void action() {
    enviroment.job=null;
    world.currentRoom.remove(enviroment);
    enviroment.delete();
  }
  public void update() {
    super.update();
    if (enviroment.hp>0) {
      enviroment.hp--;
      worker.setEnergy();
      if (enviroment.hp<=0) 
        action();
    }
  }
}


class JobBuildPrimary extends Job {
  Build object;

  JobBuildPrimary(Build object) {
    super();
    this.object = object;
    name = getNameDatabase();
  }

  protected String getNameDatabase() {
    return text_worker_build+" "+object.getBuildDescript();
  }

  public String getDescript() {
    return name+" "+getProcess()+" %";
  }

  public boolean isComplete() {
    if (object.hp>=object.hpMax) 
      return true;
    else 
    return false;
  }
  public int getProcess() {
    return (int)map(object.hp, 0, object.hpMax, 0, 100);
  }

  protected void action() {
    object.job=null;
    object.build.hp=object.build.hpMax;
    world.currentRoom.add(object.build);
    world.currentRoom.remove(object);
    object.getSurpluses();
  }

  public void update() {
    super.update();
    if (object.hp<object.hpMax) {
      object.hp++;
      worker.setEnergy();
      if (object.hp>=object.hpMax) 
        action();
    }
  }
}

class JobCraftPrimary extends Job {
  Bench bench;

  JobCraftPrimary (Bench bench) {
    super(); 
    this.bench = bench;
    bench.progress=0;
    name = getNameDatabase();
  }

  protected String getNameDatabase() {
    return text_worker_craft;
  }
  public String getDescript() {
    return name+" "+bench.product.name+" "+getProcess()+" %";
  }
  public int getProcess() {
    return (int)map(bench.progress, 0, bench.progressMax, 0, 100);
  }
  public boolean isComplete() {
    if (bench.progress>=bench.progressMax) {
      return true;
    } else
      return false;
  }

  protected void action() {
    bench.job=null;
    bench.placeProduct();
  }

  public void update () {
    super.update();
    if (bench.isPlaceWorker()) {
      if (bench.progress<bench.progressMax) {
        bench.progress++;
        worker.setEnergy();
        if (isComplete()) 
          action();
      }
    }
  }
}


class JobMoveObject extends Job {
  Object moveObject, targetObject;
  JobMove move, moveTo, moveBack;

  JobMoveObject (Object moveObject, Object targetObject) {
    super();
    this.moveObject=moveObject;
    this.targetObject=targetObject;
    move=moveTo= new JobMove(getNeighboring(world.currentRoom.node[moveObject.x][moveObject.y], null).get(0));
    moveBack= new JobMove(getNeighboring(world.currentRoom.node[targetObject.x][targetObject.y], null).get(0));
    name = getNameDatabase();
  }
  public boolean isComplete() {
    if (moveBack.isComplete() && moveObject.x==targetObject.x && moveObject.y==targetObject.y)
      return true;
    else
      return false;
  }
  protected String getNameDatabase() {
    return text_worker_move_object+" "+moveObject.getName();
  }
  public void setWorker(Actor worker) {
    super.setWorker(worker);
    moveTo.setWorker(worker);
    moveBack.setWorker(worker);
    moveObject.job=targetObject.job=this;
  }
  public String getDescript() {
    if (!moveTo.isComplete())
      return moveTo.name;
    else if (moveTo.isComplete() && !moveBack.isComplete())
      return moveBack.getDescript();
    else
      return text_job_wait;
  }
  public void update () {
    if (move==moveTo) {
      //переключатель
      if (!moveTo.isComplete()) 
        moveTo.update();
      else
        move=moveBack;
    } else if (move==moveBack) {
      if (!moveBack.isComplete()) {
        int x = worker.x;
        int y = worker.y;
        moveBack.update();
        moveObject.x=x;
        moveObject.y=y;
      } else {
        moveObject.x=targetObject.x;
        moveObject.y=targetObject.y;
      }
    }
    if (isComplete()) 
      moveObject.job=targetObject.job=null;
  }
}

class JobList extends ArrayList <Job> {
  public Job getJobFree() {
    if (this.isEmpty())
      return null;
    for (Job job : this) {
      if (job.worker==null) 
        return job;
    }
    return null;
  }
}
