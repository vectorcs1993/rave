Fraction playerFraction;

class Fraction {
  private final int id; 
  protected String name;
  public color colorFraction;
  private JobList jobs;
  public int id_job;


  Fraction (int id, String name) {
    this.id=id;
    this.name=name;
    jobs= new JobList();
    id_job=0;
  }

  public int getNewId() {
    id_job++;
    return id_job;
  }

  public void removeJob(Job job) {

    jobs.remove(job);
  }
  private int getShearchInItem(IntList items) { //поиск предмета
    for (int part : items) { 
        if (world.currentRoom.getItemsList().getItem(part)!=null) 
          return part;
    }
    return -1;
  }
   private int getShearchInItemMap(IntList items) { //поиск предмета
    for (int part : items) { 
        if (world.currentRoom.items.getItemById(part)!=null) 
          return part;
    }
    return -1;
  }
  public void update() { 
    ObjectList objectsFraction = world.currentRoom.getObjects(this);

    //главный алгоритм распределение работ
    for (Object currentActor : world.currentRoom.objects.getActorList()) {
      Actor droid = (Actor) currentActor;

      if (droid.job==null) {
        if (droid.isAlarmHealth()) {//HP
          Support repairFree = world.currentRoom.objects.getSupportFree(Object.REPAIR);  //ищет свободную станцию технического обслуживания
          if (repairFree!=null) {
            droid.addJob(new JobSupport(Job.REPAIR, repairFree));
            continue;
          }
        } 
        if (droid.isAlarmEnergy()) {//ENERGY
          Support chargeFree = world.currentRoom.objects.getSupportFree(Object.CHARGE);  //ищет свободную зарядную станцию
          if (chargeFree!=null) {
            droid.addJob(new JobSupport(Job.CHARGE, chargeFree)); 
            continue;
          }
        } 
        if (droid.skills.hasValue(Job.MAINTENANCE)) { //работа по техническому обслуживанию построек
          Object objectDamage = world.currentRoom.getObjectsNoItems().getObjectsAllowRepair().getObjectDamaged();
          if (objectDamage!=null) {
            droid.addJob(new JobMaintenance(objectDamage));
            continue;
          }
        } 
        if (droid.skills.hasValue(Job.MINE)) {  //работа по добыче ресурсов
          ObjectList objectsMine = world.currentRoom.objects.getEnviroments().getObjectsAllowMine();
          if (!objectsMine.isEmpty()) {
            Object objectMine=objectsMine.getNearestObject(droid.x, droid.y);
            droid.addJob(new JobMine((Enviroment)objectMine));
            continue;
          }
        } 
        if (droid.skills.hasValue(Job.BUILD)) {  //работа по созданию построек
          if (!(world.currentRoom.buildings.isEmpty())) {
            Object objectBuild = world.currentRoom.buildings.getObjectsAllowBuild().getNearestObject(droid.x, droid.y);
            if (objectBuild!=null) {
              droid.addJob(new JobBuild((Build)objectBuild));
              continue;
            }
          }
        }
        if (droid.skills.hasValue(Job.CRAFT)) {
          Object objectBench = world.currentRoom.objects.getObjectFreeBench();
          if (objectBench!=null) {
            droid.addJob(new JobCraft((Bench)objectBench));
            continue;
          }
        }
        if (droid.skills.hasValue(Job.CARRY)) { //работа по переноске предметов
          ObjectList objectsBuild = world.currentRoom.buildings;  //поиск объекта незавершенной постройки
          for (Object object : objectsBuild) {
            Build objectBuild = (Build)object;
            if (!objectBuild.isAllowBuild() && objectBuild.job==null) { //проверяем нужны ли ей ресурсы, если да, то
              int needId=getShearchInItemMap(objectBuild.getNeedItems());        
              if (needId!=-1) {
                //поиск незаблокированных предметов доступных до переноски
                Object objectCarryBuild=null;
                ObjectList itemsFree = world.currentRoom.items.getItemNoLock().getItemAllowWeight(droid.carryingCapacity).getItemsById(needId);
                if (!itemsFree.isEmpty()) 
                  objectCarryBuild=itemsFree.getNearestObject(droid.x, droid.y);
                if (objectCarryBuild!=null) {
                  JobCarryItemMap job = new JobCarryItemMap ((ItemMap)objectCarryBuild);
                  job.setObject(objectBuild);
                  droid.addJob(job);
                  break;
                }
              }
              needId=getShearchInItem(objectBuild.getNeedItems());
              if (needId!=-1) {
                //поиск предметов доступных из контейнеров
                Item itemCarry=null;  //инициализируем объект предмет
                Object storageIsItemFree=null; //инициализируем объект хранилище из которого мы намерены взять ресурсы
                ObjectList storageIsItem = world.currentRoom.objects.getIsItem(needId, droid.carryingCapacity); //ищем объект хранилища содержащий предмет
                if (!storageIsItem.isEmpty()) { 
                  storageIsItemFree=(Storage)storageIsItem.get(0); //если объект хранилища найден
                  itemCarry=((Storage)storageIsItemFree).items.getItem(needId); //извлекает из него необходимый предмет
                }
                if (storageIsItemFree!=null && itemCarry!=null) {  //если контейнер и необходимый предмет определены то
                  JobCarryItem job = new JobCarryItem (storageIsItemFree, objectBuild, itemCarry); //формирование задания
                  droid.addJob(job);
                  break;
                }
              }
            } //в этом случае ресурсы не нужны, всем спасибо ищем другую работу
          }
          if (droid.job!=null) //если работа определена то
            continue;  //перейти к следующему дрону
          //=========================================если нет работ по переноске предметов к постройкам то
          ObjectList objectsFabrica = world.currentRoom.objects.getObjectsFreeFabrica();  //поиск объектов фабрик
          for (Object object : objectsFabrica) {
            Fabrica objectFabrica = (Fabrica)object;
            if (objectFabrica.product!=null) { //проверяем запущено ли производство предметов, если да, то
             int needId=getShearchInItemMap(objectFabrica.getNeedItems());
              if (needId!=-1) {
                Object objectCarryComponent=null;
                ObjectList itemsFree = world.currentRoom.items.getItemNoLock().getItemAllowWeight(droid.carryingCapacity).getItemsById(needId);
                if (!itemsFree.isEmpty()) 
                  objectCarryComponent=itemsFree.getNearestObject(droid.x, droid.y);
                if (objectCarryComponent!=null) {  
                  JobCarryItemMap job = new JobCarryItemMap ((ItemMap)objectCarryComponent);
                  job.setObject(objectFabrica);
                  droid.addJob(job);
                  break;
                }
              }
            
            
            
            
            
            
              Item itemCarry=null;  //инициализируем объект предмет
              Object storageIsItemFree=null; //инициализируем объект хранилище из которого мы намерены взять ресурсы
              needId = getShearchInItem(objectFabrica.getNeedItems());
              if (needId!=-1) {
                ObjectList storageIsItem = world.currentRoom.objects.getIsItem(needId, droid.carryingCapacity); //ищем объект хранилища содержащий предмет
                if (!storageIsItem.isEmpty()) { 
                  storageIsItemFree=(Storage)storageIsItem.get(0); //если объект хранилища найден
                  itemCarry=((Storage)storageIsItemFree).items.getItem(needId); //извлекает из него необходимый предмет
                }
                if (storageIsItemFree!=null && itemCarry!=null) {  //если контейнер и необходимый предмет определены то
                  JobCarryItem job = new JobCarryItem (storageIsItemFree, objectFabrica, itemCarry); //формирование задания
                  droid.addJob(job);
                  break;
                }
              }
            }
          }
          if (droid.job!=null) //если работа определена то
            continue;  //перейти к следующему дрону
          //=========================================если нет работы по перноске предметов к фабрикам и заводам то
          Object objectCarry=null;
          ObjectList itemsFree = world.currentRoom.items.getItemNoLock().getItemAllowWeight(droid.carryingCapacity);
          if (!itemsFree.isEmpty())
            objectCarry=itemsFree.getNearestObject(droid.x, droid.y);

          Object objectStorage=null;
          ObjectList storagesFree = world.currentRoom.objects.getStorageListFree();
          if (!storagesFree.isEmpty())
            objectStorage = storagesFree.getNearestObject(droid.x, droid.y); 

          if (objectCarry!=null && objectStorage!=null) {
            JobCarryItemMap job = new JobCarryItemMap ((ItemMap)objectCarry);
            job.setObject(objectStorage);
            droid.addJob(job);
            continue;
          }
        }
        if (droid.skills.hasValue(Job.GUARD)) {  //работа по охране территории
          JobPatrol patrol = new JobPatrol();
          ObjectList flags = world.currentRoom.flags.getFlagGuardList();
          for (Object flag : flags) 
            patrol.addPoint(flag.x, flag.y);
          droid.addJob(patrol);
          continue;
        }

        if (world.currentRoom.getObjectsNoActors(droid.x, droid.y).getObjectStand()==null) {  //дрона которому не нашлась работа отправляет на стоянку
          Object objectStand=null;
          ObjectList standFree = world.currentRoom.flags.getFlagStandList();
          if (!standFree.isEmpty()) 
            objectStand=standFree.getNearestObject(droid.x, droid.y);
          if (objectStand!=null) {
            JobMove job = new JobMove(world.currentRoom.node[objectStand.x][objectStand.y]);
            droid.addJob(job);
            ((Flag)objectStand).user=droid;
          }
        }
      }
    }
  }
}
