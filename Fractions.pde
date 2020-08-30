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

  public void update() { 
    ObjectList objectsFraction = world.currentRoom.getObjects(this);

    //главный алгоритм распределение работ
    for (Object currentDroid : world.currentRoom.objects.getDroidList()) {
      Droid droid = (Droid) currentDroid;

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
          Object objectDamage = world.currentRoom.getObjectsNoItems().getObjectsPermissionRepair().getObjectDamaged();
          if (objectDamage!=null) {
            droid.addJob(new JobMaintenance(objectDamage));
            continue;
          }
        } 
        if (droid.skills.hasValue(Job.MINE)) {  //работа по добыче ресурсов

          ObjectList objectsMine = world.currentRoom.objects.getEnviroments().getObjectsPermissionMine();

          if (!objectsMine.isEmpty()) {
            Object objectMine=objectsMine.getNearestObject(droid.x, droid.y);
            droid.addJob(new JobMine((Enviroment)objectMine));
            continue;
          }
        } 
        if (droid.skills.hasValue(Job.BUILD)) {  //работа по созданию построек
          if (!(world.currentRoom.objects.getObjectsBuild().isEmpty())) {
            Object objectBuild = world.currentRoom.objects.getObjectsBuild().get(0);
            if (objectBuild!=null) {
              if (((Build)objectBuild).isPermissionBuild()) {
                droid.addJob(new JobBuild((Build)objectBuild));
                continue;
              }
            }
          }
        } 
        if (droid.skills.hasValue(Job.CARRY)) { //работа по переноске предметов
          ObjectList objectsBuild = world.currentRoom.objects.getObjectsBuild();  //поиск объекта незавершенной постройки
          for (Object object : objectsBuild) {
            Build objectBuild = (Build)object;
            if (!objectBuild.isPermissionBuild()) { //проверяем нужны ли ей ресурсы, если да, то
              Item itemCarry=null;  //инициализируем объект предмет
              Object storageIsItemFree=null; //инициализируем объект хранилище из которого мы намерены взять ресурсы
              int needId = -1;
              for (int part : objectBuild.getNeedItems()) { //поиск предмета в контейнере
                if (world.currentRoom.getItemsList().getItem(part)!=null) { //если нужный предмет находится в каком либо контейнере, то
                  needId=part; //переменной needId присваивается значение нужного предмета
                  break;  //и останавливает поиск
                }
              }
              if (needId!=-1) {
                ObjectList storageIsItem = world.currentRoom.objects.getIsItem(needId); //ищем объект хранилища содержащий предмет
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
          ObjectList objectsFabrica = world.currentRoom.objects.getObjectsFabrica();  //поиск объектов фабрик
          for (Object object : objectsFabrica) {
            Fabrica objectFabrica = (Fabrica)object;
            
            if (objectFabrica.product!=null) { //проверяем запущено ли производство предметов, если да, то
              if (!objectFabrica.isPermissionCreate()) {
                Item itemCarry=null;  //инициализируем объект предмет
                Object storageIsItemFree=null; //инициализируем объект хранилище из которого мы намерены взять ресурсы
                int needId = -1;
                for (int part : objectFabrica.getNeedItems()) { //поиск предмета в контейнере
                  if (world.currentRoom.getItemsList().getItem(part)!=null) { //если нужный предмет находится в каком либо контейнере, то
                    needId=part; //переменной needId присваивается значение нужного предмета
                    break;  //и останавливает поиск
                  }
                }
                if (needId!=-1) {
                  ObjectList storageIsItem = world.currentRoom.objects.getIsItem(needId); //ищем объект хранилища содержащий предмет
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
          }
          if (droid.job!=null) //если работа определена то
            continue;  //перейти к следующему дрону
          //=========================================если нет работы по перноске предметов к фабрикам и заводам то
          Object objectCarry=null;
          ObjectList itemsFree = world.currentRoom.items.getItemNoLock();
          if (!itemsFree.isEmpty())
            objectCarry=itemsFree.getNearestObject(droid.x, droid.y);

          Object objectStorage=null;
          ObjectList storagesFree = world.currentRoom.objects.getStorageListFree();
          if (!storagesFree.isEmpty())
            objectStorage = storagesFree.getNearestObject(droid.x, droid.y); 

          if (objectCarry!=null && objectStorage!=null) {
            JobCarryItemMap job = new JobCarryItemMap ((ItemMap)objectCarry);
            job.setStorage((Storage)objectStorage);
            droid.addJob(job);
            continue;
          }
        }
        if (droid.skills.hasValue(Job.GUARD)) {  //работа по охране территории
          JobPatrol patrol = new JobPatrol();
          patrol.addPointRandom();
          if (!patrol.path.isEmpty())
            droid.addJob(patrol);
          continue;
        }
      }
    }
  }
}
