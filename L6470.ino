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

volatile int t_max= 50; // number of steps
volatile int t_speed=111; //number of steps per second

//initializes states of all buttons
volatile int state_home_button = LOW;
volatile int state_theta_max = LOW;
volatile int state_minus_theta_button = LOW;
volatile int state_plus_theta_button = LOW;
volatile int state_speed_plus_button = LOW;
volatile int state_speed_minus_button = LOW;
volatile int state_start_button = LOW;

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
  stepper.setMinSpeed(1); //sets minimum speed
  stepper.setMicroSteps(128); //1,2,4,8,16,32,64 or 128
  stepper.setThresholdSpeed(1000);
  stepper.setOverCurrent(6000); //set overcurrent protection
  stepper.setStallCurrent(3000);
  
  //interrupts for each button
  attachInterrupt(home_button, interrupt_handler1, RISING);  
  attachInterrupt(theta_max_button, interrupt_handler2, RISING);
  attachInterrupt(minus_theta_button, interrupt_handler3, RISING);
  attachInterrupt(plus_theta_button, interrupt_handler4, RISING);
  attachInterrupt(speed_plus_button, interrupt_handler5, RISING);
  attachInterrupt(speed_minus_button, interrupt_handler6, RISING);
  attachInterrupt(start_button, interrupt_handler7, CHANGE);
  
}

void loop(){  
  
  stepper.setMaxSpeed(t_speed); //sets maximum speed
  
  if(state_home_button == HIGH){  //button pressed
    lcd.setCursor(0,0);  //clears display
    lcd.print("Set as Home");
    stepper.setAsHome(); //sets current position as Home
    state_home_button == LOW
  }
  
  if(state_theta_max== HIGH){  //button pressed
    lcd.setCursor(0,0);  //clears display
    lcd.print("
    
    state_theta_max == LOW
  }
  
  if(state_minus_theta_button== HIGH){  //button pressed
    lcd.setCursor(0,0);  //clears display
    lcd.print("Move Clockwise");
    stepper.move(1); //moves stepper through one step in the clockwise direction on each button press
    state_minus_theta_button == LOW
  }
  
  if(state_plus_theta_button== HIGH){  //button pressed
    lcd.setCursor(0,0);  //clears display
    lcd.print("Move Counter-");
    lcd.print("Clockwise");
    stepper.move(-1); //moves stepper through one step in the counter clockwise direction on each button press
    state_plus_theta_button == LOW
  }
  
  if(state_speed_plus_button== HIGH){  //button pressed
    lcd.setCursor(0,0);  //clears display
    lcd.print("Increased Speed");
    t_speed = t_speed + 10 //Increases speed by 10 steps per second
    state_speed_plus_button == LOW
  }
  
  if(state_speed_minus_button== HIGH){  //button pressed
    lcd.setCursor(0,0);  //clears display
    lcd.print("Decreased Speed");
    t_speed = t_speed - 10 //Decreases speed by 10 steps per second
    state_speed_minus_button == LOW
  }
  
  if(state_start_button== HIGH){  //button pressed to start motion
    cli();
    lcd.setCursor(0,0);  //clears display
    lcd.print("Start");
    while(1<2){
      stepper.move(t_max); //moves by t_max in the clockwise direction
      stepper.move(-t_max); //moves by t_max in the clockwise direction 
      if(state_start_button == LOW){  //button pressed to stop motion
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

//handles interrupt for home button
void interrupt_handler1(){
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time1 > 200){
   state_home_button = HIGH;}
  last_interrupt_time1 = interrupt_time;
}

//handles interrupt for t_max button
void interrupt_handler2(){
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time2 > 200){
   state_theta_max = HIGH;}
  last_interrupt_time2 = interrupt_time;
}

//handles interrupt for plus_theta_button
void interrupt_handler3(){
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time3 > 200){
   state_home_button3= HIGH;}
  last_interrupt_time3 = interrupt_time;
}

//handles interrupt for minus_theta_button
void interrupt_handler4(){
  
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time4 > 200){
   state_plus_theta_button = HIGH;}
  last_interrupt_time4 = interrupt_time;
}

//handles interrupt for speed_plus_button
void interrupt_handler5(){

  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time5 > 200){
   state_speed_plus_button = HIGH;}
  last_interrupt_time5 = interrupt_time;
}

//handles interrupt for speed_minus_button
void interrupt_handler6(){

  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time6 > 200){
   state_speed_minus_button = HIGH;}
  last_interrupt_time6 = interrupt_time;
}

//handles interrupt for start_button
void interrupt_handler7(){

  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time7 > 200){
   state_start_button = !state_start_button;}
  last_interrupt_time7 = interrupt_time;
}


