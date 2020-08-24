


abstract class Job {   //работа по перемещению 
  protected final int id;
  protected String name;
  protected Droid worker;
  public final static int OTHER=-1, CARRY=0, BUILD=1, GUARD=2, REPAIR=3, MINE=4, CRAFT=5, CHARGE=6, MAINTENANCE=7;
  protected int skill;

  Job () {
    id=playerFraction.getNewId();
    worker=null;
    skill = OTHER;
  }

  abstract public boolean isComplete();  //проверка условия выполнения работы
  abstract protected String getNameDatabase(); //инициализация наименование работы
  abstract public void update();  //обновления процесса выполнения работы
  public String getDescript() { //возвращает текущее описание работы включая отслеживаемые параметры
    return name;
  }
  public void setWorker(Droid worker) {
    this.worker=worker;
  }
  public void reset() {
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
      if (worker.x==target.x && worker.y==target.y) 
        return true;
      else 
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
    return "Перемещается в "+target.x+","+target.y;
  }
  public void update() {
    name = getNameDatabase();
    if (worker!=null) {
      if (!worker.path.isEmpty()) 
        worker.moveNextPoint();
      else 
      worker.moveTo(target.x, target.y);
    }
  }
}

class JobPutItem extends Job {
  int process, processMax;
  ItemMap itemMap;

  JobPutItem(ItemMap itemMap) {
    super();
    this.itemMap = itemMap;
    process = 0;
    processMax= itemMap.count*itemMap.item.weight*3;
    name = getNameDatabase();
  }

  protected String getNameDatabase() {
    return "Берет "+itemMap.item.getName();
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
  }

  public void update() {
    if (process<processMax) {
      process++;
      worker.setEnergy();
      if (process>=processMax) 
        action();
    }
  }
}


class JobGetItem extends JobPutItem {   //работа по выгрузке предмета 
  Storage storage;

  JobGetItem(Storage storage, ItemMap itemMap) {
    super(itemMap);
    this.storage=storage;
  }

  protected String getNameDatabase() {
    return "Кладет "+itemMap.item.getName();
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
        world.currentRoom.addItemOrder(worker.x, worker.y, newItem, 1);
      }
    }
    if (!worker.items.isEmpty()) {
      for (int i=worker.items.size()-1; i>=0; i--) {
        Item item = worker.items.get(i);
        worker.items.removeItemCount(item, 1);
        world.currentRoom.addItemOrder(worker.x, worker.y, item, 1);
      }
    }
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
    curJob.worker=worker;
    path.add(curJob);
  }

  private boolean addPointRandom() {
    int rx = constrain((int)random(world.getSize()), 0, world.getSize()-1);
    int ry = constrain((int)random(world.getSize()), 0, world.getSize()-1);
    if (!world.currentRoom.node[rx][ry].solid) {
      addPoint(rx, ry);
      return true;
    } else 
    return false;
  }

  public void setWorker(Droid worker) {
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
  public void setWorker(Droid worker) {
    super.setWorker(worker);
    support.user=worker;
  }
  protected String getNameDatabase() {
    switch (type) {
    case Job.CHARGE:
      return "Заряжает аккумулятор";
    case Job.REPAIR:
      return "Ремонтируется";
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
    return "Ремонтирует "+object.name;
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
    world.currentRoom.remove(enviroment);
    enviroment.delete();
  }
  public void update() {
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
    return "Cтроит "+object.getNameShort();
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
    object.build.hp=object.build.hpMax;
    world.currentRoom.add(object.build);
    world.currentRoom.remove(object);
  }

  public void update() {
    if (object.hp<object.hpMax) {
      object.hp++;
      worker.setEnergy();
      if (object.hp>=object.hpMax) 
        action();
    }
  }
}
/*
class JobEvacuation extends Job {
 JobMove moveTo, moveBack;
 Droid droid;
 Support support;
 JobEvacuation (Droid droid) {
 this.droid=droid;
 moveTo,
 }
 
 }
 */





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
