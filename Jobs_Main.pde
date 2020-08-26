class JobCarry extends Job {  //работа по транспортировке предметов
  JobMove move, moveTo, moveBack;
  JobPutItem putItem;
  JobGetItem getItem;
  Storage storage;
  ItemMap itemMap;

  JobCarry(ItemMap itemMap) {
    super();
    this.storage=null;
    this.itemMap= itemMap;
    move = moveTo = new JobMove (world.currentRoom.node[itemMap.x][itemMap.y]);
    putItem = new JobPutItem (itemMap);
    moveBack = null;
    getItem = null;
    name = getNameDatabase();
    skill = Job.CARRY;
  }
  public void setWorker(Droid worker) {
    super.setWorker(worker);
    itemMap.job=this;
    moveTo.setWorker(worker);
    putItem.setWorker(worker);
    if (moveBack!=null) 
      moveBack.setWorker(worker);
    if (getItem!=null) {
      getItem.setWorker(worker);
    }
  }
  public void setStorage(Storage storage) {
    this.storage=storage;
    moveTo = move = null;
    move = moveTo = new JobMove (world.currentRoom.node[itemMap.x][itemMap.y]);
    putItem = null;
    putItem = new JobPutItem (itemMap);
    getItem = null;
    getItem = new JobGetItem (storage, itemMap);
    moveBack=null;
    moveBack = new JobMove (getNeighboring(world.currentRoom.node[storage.x][storage.y], world.currentRoom.node[storage.x][storage.y]).get(0));
    getItem.storage=storage;
  }
  private boolean isRunnable() {
    if (moveTo!=null && moveBack!=null && putItem!=null && getItem!=null) 
      if (putItem.itemMap!= null && getItem.storage!=null)
        return true;
      else 
      return false;
    else
      return false;
  }
  public boolean isComplete() {
    if (isRunnable()) {
      if (move==moveBack && move.isComplete() && getItem.isComplete() && putItem.isComplete()) 
        return true; 
      else 
      return false;
    } else
      return false;
  }
  protected String getNameDatabase() {
    return text_job_carry+" "+itemMap.item.getName();
  }
  public String getDescript() {
    if (isRunnable()) {
      if (!move.isComplete() && !putItem.isComplete() && !getItem.isComplete() && move==moveTo) 
        return moveTo.name;
      else if (move.isComplete() && !putItem.isComplete() && !getItem.isComplete() && move==moveTo) 
        return putItem.getDescript();
      else if (!move.isComplete() && putItem.isComplete() && !getItem.isComplete() && move==moveBack) 
        return moveBack.name;
      else if (move.isComplete() && putItem.isComplete() && !getItem.isComplete() && move==moveBack) 
        return getItem.getDescript();
      else 
      return text_job_wait;
    } else 
    return text_job_set;
  }
  public void update () {
    if (isRunnable()) {
      if (moveBack.target.solid)
        moveBack.target= getNeighboring(world.currentRoom.node[storage.x][storage.y], world.currentRoom.node[storage.x][storage.y]).get(0);
      if (!move.isComplete())  
        move.update();
      else {
        if (move==moveTo) {
          if (!putItem.isComplete()) 
            putItem.update();
          else 
          move= moveBack;
        } else if (move==moveBack) 
          if (!getItem.isComplete()) 
            getItem.update();
      }
    }
  }
}
class JobSupport extends Job {   //работа по техническому обслуживанию
  JobSupportPrimary support;
  JobMove moveTo;
  Support object;
  
  JobSupport (int type, Support support) {
    super(); 
    object = support;
    this.support = new JobSupportPrimary(type, support);
    moveTo = new JobMove (world.currentRoom.node[getPlace(support.x, support.y, support.direction)[0]][getPlace(support.x, support.y, support.direction)[1]]);
    name = getNameDatabase();
  }
  public void setWorker(Droid worker) {
    super.setWorker(worker);
    moveTo.setWorker(worker);
    support.setWorker(worker);
  }
  public boolean isComplete() {
    if (moveTo.isComplete() && support.isComplete())
      return true;
    else
      return false;
  }
  protected String getNameDatabase() {
    return text_job_support;
  }
  public String getDescript() {
    if (!moveTo.isComplete() && !support.isComplete())
      return moveTo.name;
    else if (moveTo.isComplete() && !support.isComplete())
      return support.name;
    else
      return text_job_wait;
  }
  public void update () {
     moveTo.target=world.currentRoom.node[getPlace(object.x, object.y, object.direction)[0]][getPlace(object.x, object.y, object.direction)[1]];
    if (!moveTo.isComplete()) 
       moveTo.update();
     else {
      worker.setDirection(support.support.x, support.support.y);
      if (!support.isComplete())  
        support.update();
    }
  }
}

class JobMaintenance extends Job {   //работа по обслуживанию построек
  JobRepair repair;
  JobMove moveTo;

  JobMaintenance (Object object) {
    super(); 
    this.repair = new JobRepair(object);
    moveTo = new JobMove (getNeighboring(world.currentRoom.node[object.x][object.y], world.currentRoom.node[object.x][object.y]).get(0));
    name = getNameDatabase();
  }
  public boolean isComplete() {
    if (repair.isComplete() && moveTo.isComplete())
      return true;
    else
      return false;
  }
  protected String getNameDatabase() {
    return text_job_maintenance;
  }
  public void setWorker(Droid worker) {
    super.setWorker(worker);
    moveTo.setWorker(worker);
    repair.setWorker(worker);
  }
  public String getDescript() {
    if (!moveTo.isComplete() && !repair.isComplete())
      return moveTo.name;
    else if (moveTo.isComplete() && !repair.isComplete())
      return repair .name;
    else
      return text_job_wait;
  }
  public void update () {
    if (!moveTo.isComplete())  
      moveTo.update();
    else {
      worker.setDirection(repair.object.x, repair.object.y);
      if (!repair.isComplete())  
        repair.update();
    }
  }
}

class JobMine extends Job {   //работа по добыче ресурсов
  JobMinePrimary mine;
  JobMove moveTo;

  JobMine (Enviroment enviroment) {
    super(); 
    this.mine = new JobMinePrimary(enviroment);
    moveTo = new JobMove (getNeighboring(world.currentRoom.node[enviroment.x][enviroment.y], world.currentRoom.node[enviroment.x][enviroment.y]).get(0));
    name = getNameDatabase();
  }
  public boolean isComplete() {
    if (mine.isComplete() && moveTo.isComplete())
      return true;
    else
      return false;
  }
  protected String getNameDatabase() {
    return text_mine;
  }
  public void setWorker(Droid worker) {
    super.setWorker(worker);
    moveTo.setWorker(worker);
    mine.setWorker(worker);
  }
  public String getDescript() {
    if (!moveTo.isComplete() && !mine.isComplete())
      return moveTo.name;
    else if (moveTo.isComplete() && !mine.isComplete())
      return mine.getDescript();
    else
      return text_job_wait;
  }
  public void update () {
    if (!moveTo.isComplete())  
      moveTo.update();
    else {
      worker.setDirection(mine.enviroment.x, mine.enviroment.y);
      if (!mine.isComplete())  
        mine.update();
    }
  }
}

class JobBuild extends Job {   //работа по строительству объектов
  JobBuildPrimary build;
  JobMove moveTo;

  JobBuild (Build object) {
    super(); 
    this.build = new JobBuildPrimary(object);
    moveTo = new JobMove (getNeighboring(world.currentRoom.node[object.x][object.y], world.currentRoom.node[object.x][object.y]).get(0));
    name = getNameDatabase();
  }
  public boolean isComplete() {
    if (build.isComplete() && moveTo.isComplete())
      return true;
    else
      return false;
  }
  protected String getNameDatabase() {
    return text_job_build;
  }
  public void setWorker(Droid worker) {
    super.setWorker(worker);
    moveTo.setWorker(worker);
    build.setWorker(worker);
  }
  public String getDescript() {
    if (!moveTo.isComplete() && !build.isComplete())
      return moveTo.name;
    else if (moveTo.isComplete() && !build.isComplete())
      return build.getDescript();
    else
      return text_job_wait;
  }
  public void update () {
    if (!moveTo.isComplete())  
      moveTo.update();
    else {
      worker.setDirection(build.object.x, build.object.y);
      if (!build.isComplete())  
        build.update();
    }
  }
}
