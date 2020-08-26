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
          Object objectMine = world.currentRoom.objects.getEnviroments().getObjectsPermissionMine();
          if (objectMine!=null) {
            droid.addJob(new JobMine((Enviroment)objectMine));
            continue;
          }
        } 
           if (droid.skills.hasValue(Job.BUILD)) {  //работа по созданию построек
          Object objectBuild = world.currentRoom.objects.getObjectBuild();
          if (objectBuild!=null) {
            droid.addJob(new JobBuild((Build)objectBuild));
            continue;
          }
        } 
        if (droid.skills.hasValue(Job.CARRY)) { //работа по переноске предметов
          Object objectCarry=null;
          ObjectList itemsFree = world.currentRoom.items.getItemNoLock();
          if (!itemsFree.isEmpty())
            objectCarry=itemsFree.get(0);
          Object objectStorage = world.currentRoom.objects.getStorageFree();
          if (objectCarry!=null && objectStorage!=null) {
            JobCarry job = new JobCarry ((ItemMap)objectCarry);
            job.setStorage((Storage)objectStorage);
            droid.addJob(job);
            continue;
          }
        } 
        if (droid.skills.hasValue(Job.GUARD)) {  //работа по охране территории
          JobPatrol patrol = new JobPatrol();
          patrol.addPointRandom();
          droid.addJob(patrol);
          continue;
        }
      }
    }
  }
}
