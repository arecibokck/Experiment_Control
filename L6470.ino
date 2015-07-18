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
  attachInterrupt(home_button, interrupt_set_home, CHANGE);  
  attachInterrupt(theta_max_button, interrupt_t_max, CHANGE);
  attachInterrupt(minus_theta_button, interrupt_plus_theta, CHANGE);
  attachInterrupt(plus_theta_button, interrupt_minus_theta, CHANGE);
  attachInterrupt(speed_plus_button, interrupt_speed_plus, CHANGE);
  attachInterrupt(speed_minus_button, interrupt_speed_minus, CHANGE);
  attachInterrupt(start_button, interrupt_start, CHANGE);
  
}

void loop(){  
  
  if (!motor_stopped){
    stepper.move(t_max);
    while(stepper.isBusy()){
     delay(10); 
    }
    stepper.move(-t_max);
    while(stepper.isBusy()){
     delay(10); 
    }
  }

}

volatile unsigned long last_interrupt_time_home = 0;
volatile unsigned long last_interrupt_time_t_max = 0;
volatile unsigned long last_interrupt_time_plus_theta = 0;
volatile unsigned long last_interrupt_time_minus_theta = 0;
volatile unsigned long last_interrupt_time_speed_plus = 0;
volatile unsigned long last_interrupt_time_speed_minus = 0;
volatile unsigned long last_interrupt_time_start = 0;

//handles interrupt for home button
void interrupt_set_home(){
  cli();
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time_home > 200){
    lcd.setCursor(0,0);  //clears display
    lcd.print("Set as Home");
    stepper.setAsHome(); //sets current position as Home
  }
  last_interrupt_time_home = interrupt_time;
  sei();
}

//handles interrupt for t_max button
void interrupt_t_max(){
  cli();
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time_t_max > 200){
    lcd.setCursor(0,0);  //clears display
    lcd.print("Set as Maximum");
    lcd.print("angle");
    t_max = stepper.getPos();
    stepper.goHome(); 
  }
  last_interrupt_time_t_max = interrupt_time;
  sei();
}

//handles interrupt for plus_theta_button
void interrupt_plus_theta(){
  cli();
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time_plus_theta > 200){
    lcd.setCursor(0,0);  //clears display
    lcd.print("Move Clockwise");
    stepper.move(1); //moves stepper through one step in the clockwise direction on each button press 
  }
  last_interrupt_time_plus_theta = interrupt_time;
  sei();
}

//handles interrupt for minus_theta_button
void interrupt_minus_theta(){
  cli();
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time_minus_theta > 200){
    lcd.setCursor(0,0);  //clears display
    lcd.print("Move Counter-");
    lcd.print("Clockwise");
    stepper.move(-1); //moves stepper through one step in the counter clockwise direction on each button press 
  }
  last_interrupt_time_minus_theta = interrupt_time;
  sei();
}

//handles interrupt for speed_plus_button
void interrupt_speed_plus(){
  cli();
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time_speed_plus > 200){
    lcd.setCursor(0,0);  //clears display
    lcd.print("Increased Speed");
    stepper.setMaxSpeed(t_speed + 10); //Increases speed by 10 steps per second
  }
  last_interrupt_time_speed_plus = interrupt_time;
  sei();
}

//handles interrupt for speed_minus_button
void interrupt_speed_minus(){
  cli();
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time_speed_minus > 200){
    lcd.setCursor(0,0);  //clears display
    lcd.print("Decreased Speed");
    stepper.setMaxSpeed(t_speed - 10); //Decreases speed by 10 steps per second
  }
  last_interrupt_time_speed_minus = interrupt_time;
  sei();
}

//handles interrupt for start_button
void interrupt_start(){
  cli();
  unsigned long interrupt_time = millis();
  // If interrupts come faster than 200ms, assume it's a bounce and ignore
  if (interrupt_time - last_interrupt_time_start > 200){
    motor_stopped = !motor_stopped;
    lcd.setCursor(0,0);  //clears display
    lcd.print("Start");
    stepper.goHome();
    stepper.softStop();
  }
  last_interrupt_time_start = interrupt_time;
  sei():
}


