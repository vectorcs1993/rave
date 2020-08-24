ArrayList <Timer> timers = new ArrayList <Timer>();

class Timer {
  boolean flag;
  long timing;
  int set;
  
  Timer(){  
    flag=false;
  }
  
  void set(int tempSet) {
    timing=millis();
    flag=true;
    set=tempSet;
  }
  int getProcess() {
    return (int)map(millis() - timing,0,set,0,world.grid_size);
    
  }
  
  void tick() {
     if (millis() - timing > set) {                                                               // таймер прерывания на движение игрока 
      flag=false;
    }
  }
  
  boolean check() {
    return flag;
  }
}
