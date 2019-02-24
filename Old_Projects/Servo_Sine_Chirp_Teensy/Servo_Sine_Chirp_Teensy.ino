#include <math.h>
#include <string.h>
#include "digitalWriteFast.h"

#define DIRECTION_PIN 8
#define STEP_PIN 9
 
#define SetMotorDirectionPositive digitalWriteFast(8, LOW)
#define SetMotorDirectionNegative digitalWriteFast(8, HIGH)
 
// Motor: 200 step (fullstep) = 360 degree
// 1/256 microstepping: 200 * 256 step (micro) = 360 degree
//#define degTOstep(deg) (long)(deg * 200 * 128 / 360)
#define degTOstep(deg) (long)(deg * 200 * 128 / 360)

// interval in microsecond for pulse
//#define speedTOinterval(stepPERsec) (long)(500000 / stepPERsec)
#define speedTOinterval(stepPERsec) (long)(500000 / stepPERsec)

#define offset_sine 
#define offset_chirp 

void setup()
{ 
  Serial.begin(115200);
  Serial.setTimeout(1);
  pinMode(DIRECTION_PIN, OUTPUT); 
  pinMode(STEP_PIN, OUTPUT);
} 
 
void loop() 
{ 
  String cmd, args;
  int position_1, position_2, position_3, repeat_;
  float pos = 0, amplitude_ = 10, frequency_ = 1, fstart_ = 1, fend_ = 1, t = 0, duration = 0, speed_= 100.0, deg_ = 0.0;
  if (Serial.available()) { 
    cmd = Serial.readStringUntil('\r');
    if (cmd.startsWith("M")) {
      deg_ = cmd.substring(2,cmd.indexOf(",")).toFloat();
      if(cmd.substring(5,cmd.indexOf(")")) != ")"){speed_ = cmd.substring(5,cmd.indexOf(")")).toFloat();}
      Serial.print("Moving to ");
      Serial.print(deg_);
      Serial.print(" degrees");
      Serial.print(" at ");
      Serial.print(speed_);
      Serial.print(" degrees per sec ");
      move_(degTOstep(deg_), degTOstep(speed_));
    }
    else if (cmd.startsWith("S")) {
      args = cmd.substring(2,cmd.indexOf(")"));
      position_1 = args.indexOf(",");
      position_2 = args.indexOf(",", position_1 + 1);
      amplitude_ = args.substring(0,position_1).toFloat();
      frequency_ = args.substring(position_1 + 1, position_2).toFloat();
      repeat_ = args.substring(position_2 + 1).toInt();
      Serial.println("Moving in sine.");
      Serial.print("Amplitude: ");
      Serial.print(amplitude_);
      Serial.print(", Frequency: ");
      Serial.print(frequency_);
      Serial.print(", Repeats: ");
      Serial.println(repeat_);
      move_sine(amplitude_, frequency_, repeat_);
    }
    else if (cmd.startsWith("C")) {
      args = cmd.substring(2,cmd.indexOf(")"));
      position_1 = args.indexOf(",");
      position_2 = args.indexOf(",", position_1 + 1);
      position_3 = args.indexOf(",", position_2 + 1);
      amplitude_ = args.substring(0,position_1).toFloat();
      fstart_ = args.substring(position_1 + 1, position_2).toFloat();
      fend_ = args.substring(position_2 + 1, position_3).toFloat();
      duration = args.substring(position_3 + 1).toFloat();
      Serial.println("Linear Chirp.");
      Serial.println("Amplitude: "+args.substring(0,position_1));
      Serial.println("Starting Frequency: "+String(fstart_));
      Serial.println("Ending Frequency: "+ String(fend_));
      Serial.println("Time Period: "+String(duration));
      frequency_ = fend_-fstart_;
      move_chirp(amplitude_, frequency_, duration);
    }
  }
}

void move_(long number_of_steps, long speed_) {
  if (number_of_steps < 0) {
    
    SetMotorDirectionNegative;
    number_of_steps = 0 - number_of_steps;
  }
  else {
    
    SetMotorDirectionPositive;
  }
  for (long i = 0; i < number_of_steps; i++) {
    move_step(speedTOinterval(speed_)); 
  }
}

void move_sine(float amplitude_, float frequency_, int n_cycle) {
  long amplitude_in_steps = degTOstep(amplitude_);
  float omega = 2 * M_PI * frequency_;
  long i, dt[amplitude_in_steps];
  for (i = 0; i < amplitude_in_steps; i++) {
    dt[i] = (long)((offset_sine / omega) * (asin( (float)(i + 1) / (float)amplitude_in_steps) - asin((float)i / (float)amplitude_in_steps)));
    Serial.println((asin( (float)(i + 1) / (float)amplitude_in_steps) - asin((float)i / (float)amplitude_in_steps)));
  }
  Serial.println("Sine started...");
  for (int j = 0; j < n_cycle; j++) {
    SetMotorDirectionPositive;
    for (i = 0; i < amplitude_in_steps; i++) {move_step(dt[i]);}
    SetMotorDirectionNegative;
    for (i = amplitude_in_steps - 1; i >= 0; i--) {move_step(dt[i]);}
    for (i = 0; i < amplitude_in_steps; i++) {move_step(dt[i]);}
    SetMotorDirectionPositive;
    for (i = amplitude_in_steps - 1; i >= 0; i--) {move_step(dt[i]);}
  }
  Serial.println("Sine done");
}

void move_chirp(int amplitude_, float frequency_, float duration) {
  long amplitude_in_steps = degTOstep(amplitude_);
  float k = frequency_ / duration, d_angle[amplitude_in_steps], t=0, 
        a = sqrt(duration / (2 * M_PI * frequency_));
  long i, dt[amplitude_in_steps * 21];
  bool direction_[amplitude_in_steps * 50];
  for (i = 0; i < amplitude_in_steps; i++) {
    d_angle[i] = (long)((asin( (float)(i) / (float)(amplitude_in_steps))));
  }
  int j = 0;
  while (t < duration) {
    for (i = 0; i < amplitude_in_steps; i++) {
      if (t>=duration){break;}
      dt[i + (j * amplitude_in_steps)] = (long)((offset_chirp * a) * (sqrt(d_angle[i+1] + (2 * M_PI * j)) - sqrt(d_angle[i] + (2 * M_PI * j))) );
      direction_[i + (j * amplitude_in_steps)] = true;
      t = t + dt[i + (j * amplitude_in_steps)];
    }
    for (i = amplitude_in_steps; i < 2 * amplitude_in_steps; i++) {
      if (t>=duration){break;}
      dt[(j * 2 * amplitude_in_steps) - i] = (long)((offset_chirp * a) * (sqrt(-d_angle[i+1] + (1.5 * M_PI * j)) - sqrt(-d_angle[i] + (1.5 * M_PI *j))) );
      direction_[(j * 2 * amplitude_in_steps) - i] = false;
      t = t + dt[(j * 2 * amplitude_in_steps) - i];
    }
    for (i = 2 * amplitude_in_steps; i < 3 * amplitude_in_steps; i++) {
      if (t>=duration){break;}
      dt[i + (j * 2 * amplitude_in_steps)] = (long)((offset_chirp * a) * (sqrt(d_angle[i+1] + (2.5 * M_PI *j)) - sqrt(d_angle[i] + (2.5 * M_PI *j))) );
      direction_[i + (j * 2 * amplitude_in_steps)] = false;
      t = t + dt[i + (j * 2 * amplitude_in_steps)];
    }
    for (i = 3 * amplitude_in_steps; i < 4 * amplitude_in_steps; i++) {
      if (t>=duration){break;}
      dt[(j * 4 * amplitude_in_steps) - i] = (long)((offset_chirp * a) * (sqrt(-d_angle[i+1] + (1.5 * M_PI * j)) - sqrt(-d_angle[i] + (1.5 * M_PI *j))) );
      direction_[(j * 4 * amplitude_in_steps) - i] = false;
      t = t + dt[(j * 4 * amplitude_in_steps) - i];
    }
    j++;
  }
  Serial.print("Chirp started...");
  SetMotorDirectionPositive;
  for (i = 0; i < amplitude_in_steps; i++) {move_step(dt[i]);}
  SetMotorDirectionNegative;
  for (i = amplitude_in_steps - 1; i >= 0; i--) {move_step(dt[i]);}
  for (i = 0; i < amplitude_in_steps; i++) {move_step(dt[i]);}
  SetMotorDirectionPositive;
  for (i = amplitude_in_steps - 1; i >= 0; i--) {move_step(dt[i]);}
  Serial.println("Chirp done");
}

void move_step(long inter_step_delay) {
  
  digitalWrite(STEP_PIN, HIGH);
  delayMicroseconds(inter_step_delay);
  digitalWriteFast(STEP_PIN, LOW);
  delayMicroseconds(inter_step_delay);
}
