#include <SPI.h>
#include <L6470.h>
#include <LiquidCrystal.h>

//sets pins buttons are connected to

#define home_button 17  
#define theta_max_button 18  
#define minus_theta_button 19 
#define plus_theta_button 20
#define speed_plus_button 21
#define speed_minus_button 22
#define start_button= 23

int t_max= 50; // number of steps
int t_speed=111; //number of steps per second
volatile int state1 = LOW;
volatile int state2 = LOW;
volatile int state3 = LOW;
volatile int state4 = LOW;
volatile int state5 = LOW;
volatile int state6 = LOW;
volatile int state7 = LOW;

LiquidCrystal lcd(0, 1, 2, 3, 4, 5); //sets pins lcd is connected to, running in 4 bit mode, RW pin tied to gnd
L6470 stepper(10);


void setup(){
  Serial.begin(9600);
  
  pinMode(home_button, INPUT);  //assigns button pins as inputs
  pinMode(theta_max_button, INPUT);
  pinMode(minus_theta_button, INPUT);
  pinMode(plus_theta_button, INPUT);
  pinMode(speed_plus_button, INPUT);
  pinMode(speed_minus_button, INPUT);
  pinMode(start_button, INPUT);

  digitalWrite(home_button, LOW);  //sets internal pulldown resistors
  digitalWrite(theta_max_button, LOW);
  digitalWrite(minus_theta_button, LOW);
  digitalWrite(plus_theta_button, LOW);
  digitalWrite(speed_plus_button, LOW);
  digitalWrite(speed_minus_button, LOW);
  digitalWrite(start_button, LOW);

  lcd.begin(20, 1);   //lcd size
  lcd.print("Stepper Motor");
  lcd.print("Control"); //welcome text
  delay(2000);  //displays for 2 secs
  lcd.clear();  //clears display
  
  stepper.init();
  stepper.setAcc(100); //set acceleration
  stepper.setMaxSpeed(t_speed); 
  stepper.setMinSpeed(1);
  stepper.setMicroSteps(128); //1,2,4,8,16,32,64 or 128
  stepper.setThresholdSpeed(1000);
  stepper.setOverCurrent(6000); //set overcurrent protection
  stepper.setStallCurrent(3000);
  
  attachInterrupt(home_button, interrupt_handler1, RISING);  
  attachInterrupt(theta_max_button, interrupt_handler2, RISING);
  attachInterrupt(minus_theta_button, interrupt_handler3, RISING);
  attachInterrupt(plus_theta_button, interrupt_handler4, RISING);
  attachInterrupt(speed_plus_button, interrupt_handler5, RISING);
  attachInterrupt(speed_minus_button, interrupt_handler6, RISING);
  attachInterrupt(start_button, interrupt_handler7, CHANGE);
  
}

void loop(){  
  
  if(state1 == HIGH){  //button pressed
    lcd.setCursor(0,0);  //clears display
    lcd.print("Set as Home");
    stepper.setAsHome();
    state1 == LOW
  }
  
  if(state2== HIGH){  //button pressed
    lcd.setCursor(0,0);  //clears display
    lcd.print("
    
    state2 == LOW
  }
  
  if(state3== HIGH){  //button pressed
    lcd.setCursor(0,0);  //clears display
    lcd.print("Move Clockwise");
    stepper.goTo(1);
    state3 == LOW
  }
  
  if(state4== HIGH){  //button pressed
    lcd.setCursor(0,0);  //clears display
    lcd.print("Move Counter-");
    lcd.print("Clockwise");
    stepper.goTo(-1);
    state4 == LOW
  }
  
  if(state5== HIGH){  //button pressed
    lcd.setCursor(0,0);  //clears display
    lcd.print("Increase Speed");
    stepper.goTo(-1);
    state5 == LOW
  }
  
  if(state6== HIGH){  //button pressed
    lcd.setCursor(0,0);  //clears display
    lcd.print("Decrease Speed");
    stepper.goTo(-1);
    state6 == LOW
  }
  
  if(state7== HIGH){  //button pressed
    cli();
    lcd.setCursor(0,0);  //clears display
    lcd.print("Start");
    while(1<2){
      stepper.goTo(t_max);
      stepper.goTo(-t_max);
      if(state7 == LOW){  //button pressed
        lcd.setCursor(0,0);  //clears display
        lcd.print("Stop");
        break;
      }
    }
    stepper.goHome();
    stepper.softStop();
    sei()
  }

}
volatile unsigned long last_interrupt_time1 = 0;
volatile unsigned long last_interrupt_time2 = 0;
volatile unsigned long last_interrupt_time3 = 0;
volatile unsigned long last_interrupt_time4 = 0;
volatile unsigned long last_interrupt_time5 = 0;
volatile unsigned long last_interrupt_time6 = 0;
volatile unsigned long last_interrupt_time7 = 0;

void interrupt_handler1(){
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time1 > 200){
   state1 = HIGH;}
  last_interrupt_time1 = interrupt_time;
}
void interrupt_handler2(){
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time2 > 200){
   state2 = HIGH;}
  last_interrupt_time2 = interrupt_time;
}
void interrupt_handler3(){
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time3 > 200){
   state13= HIGH;}
  last_interrupt_time3 = interrupt_time;
}
void interrupt_handler4(){
  
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time4 > 200){
   state4 = HIGH;}
  last_interrupt_time4 = interrupt_time;
}
void interrupt_handler5(){

  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time5 > 200){
   state5 = HIGH;}
  last_interrupt_time5 = interrupt_time;
}
void interrupt_handler6(){

  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time6 > 200){
   state6 = HIGH;}
  last_interrupt_time6 = interrupt_time;
}
void interrupt_handler7(){

  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time7 > 200){
   state7 = HIGH;}
  last_interrupt_time7 = interrupt_time;
}


