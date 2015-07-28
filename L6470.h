#define CSpin       10
#define SDIpin      11
#define SDOpin      12
#define CKpin       13
#define BUSYpin     14
#define RESETpin    15

#define REG_FSspeed     0b00010101 // 0x15
#define REG_StepMode    0b00010110 // 0x16
#define REG_Config      0b00011000 // 0x18
#define REG_Acc         0b00000101 // 0x05
#define REG_Dec         0b00000110 // 0x06
#define REG_Max_Speed   0b00000111 // 0x07
#define REG_Min_Speed   0b00001000 // 0x08

#define CMD_SetParam    0b00000000
#define CMD_Move        0b01000000
#define CMD_GetParam    0b00100000
#define CMD_ResetDevice 0b11000000
#define CMD_GetStatus   0b11010000

//#include <SPI.h>

class l6470 {
  public:
    l6470();
    void Move(float angle);
    //void HardStop();
    //void SoftStop();

    uint16_t GetConfig();
    uint16_t GetStatus();

    void SetAcc(float degreePerSec2);
    void SetDec(float degreePerSec2);
    void SetMaxSpeed(float degreePerSec);
    void SetMinSpeed(float degreePerSec);
    
    bool isBusy();
    
  private:
    byte io(byte data_out); 
    uint16_t DecCalc(uint16_t stepsPerSecPerSec);
    uint16_t AccCalc(uint16_t stepsPerSecPerSec);
    uint16_t MaxSpdCalc(uint16_t stepsPerSec);
    uint16_t MinSpdCalc(uint16_t stepsPerSec);
    long angleToSteps(float angle);
    
    //void GetParam();
    //void SetParam();
    
};

l6470::l6470(){
  pinMode(CSpin, OUTPUT);
  digitalWriteFast(CSpin,HIGH);
  pinMode(SDIpin, OUTPUT);
  pinMode(SDOpin, INPUT);
  pinMode(CKpin, OUTPUT);
  pinMode(RESETpin, OUTPUT);
  pinMode(RESETpin, OUTPUT);
  
  digitalWriteFast(RESETpin, HIGH); delay(1);
  digitalWriteFast(RESETpin, LOW); delay(1);
  digitalWriteFast(RESETpin, HIGH); delay(1);

  SPI.begin();
  SPI.setBitOrder(MSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV16);
  SPI.setDataMode(SPI_MODE3);
  io(CMD_ResetDevice);
  GetStatus();
  io(CMD_SetParam | REG_StepMode);
  io((byte) 0b01110111); //SYNC_EN, SYN_SEL(3), 0, STEP_SEL(3) 
  //Use Busy/Sync pin as Busy, 1/128 microstepping (3), 0, SYNC frequency set to f_{FS}
  io(CMD_SetParam | REG_FSspeed);
  io(0x03);io(0xff); // Do not switch to full steps.
  /*******************************************************************
  Over current threshold, Stall detection, BackEMF? need to be added
  /*******************************************************************/
  
}

byte l6470::io(byte data_out){
  byte data_in;
  digitalWriteFast(CSpin, LOW);
  data_in = SPI.transfer(data_out);
  digitalWriteFast(CSpin, HIGH);
  return data_in;
}

void l6470::Move(float angle){
  long n_steps = angleToSteps(angle);
  byte dir = 0;
  if (n_steps > 0) { dir = 1; }
  else { dir = 0; n_steps = 0 - n_steps; }
  io(CMD_Move | dir);
  io((byte)(n_steps >> 16));
  io((byte)(n_steps >> 8));
  io((byte)(n_steps));
}

uint16_t l6470::GetConfig(){
  uint16_t Config = 0;
  io(CMD_GetParam | REG_Config);
  Config = io((byte)0)<<8;
  Config |= io((byte)0);
  return Config;
}

uint16_t l6470::GetStatus(){
  uint16_t Status = 0;
  io(CMD_GetStatus);
  Status = io((byte)0) << 8;
  Status |= io((byte)0);
  return Status;
}

void l6470::SetAcc(float degreePerSec2){
  uint16_t acc = AccCalc(long(angleToSteps(degreePerSec2)));
  Serial.print("\nAcc: ");
  Serial.print(acc,DEC);
  io(CMD_SetParam | REG_Acc);
  io((byte) acc << 8);
  io((byte) acc);
}

void l6470::SetDec(float degreePerSec2){
  uint16_t dec = DecCalc(long(angleToSteps(degreePerSec2)));
  Serial.print("\nDec: ");
  Serial.print(dec,DEC);
  io(CMD_SetParam | REG_Dec);
  io((byte) dec << 8);
  io((byte) dec);
}

void l6470::SetMaxSpeed(float degreePerSec){
  uint16_t max_speed = MaxSpdCalc(long(angleToSteps(degreePerSec)));
  Serial.print("\nmax speed: ");
  Serial.print(max_speed,DEC);
  io(CMD_SetParam | REG_Max_Speed);
  io((byte)max_speed << 8);
  io((byte)max_speed);
}

void l6470::SetMinSpeed(float degreePerSec){
  uint16_t min_speed = MinSpdCalc(long(angleToSteps(degreePerSec)));
  Serial.print("\nmin speed: ");
  Serial.print(min_speed,DEC);
  io(CMD_SetParam | REG_Min_Speed);
  io((byte) min_speed << 8);
  io((byte) min_speed);
}

uint16_t l6470::AccCalc(uint16_t stepsPerSecPerSec)
{
  float temp = stepsPerSecPerSec * 0.137438;
  return (uint16_t) long(temp);
}

uint16_t l6470::DecCalc(uint16_t stepsPerSecPerSec)
{
  float temp = stepsPerSecPerSec * 0.137438;
  return (uint16_t) long(temp);
}

uint16_t l6470::MaxSpdCalc(uint16_t stepsPerSec)
{
  float temp = stepsPerSec * .065536;
  return (uint16_t) long(temp);
}

uint16_t l6470::MinSpdCalc(uint16_t stepsPerSec)
{
  float temp = stepsPerSec * 4.1943;
  return (uint16_t) long(temp);
}

bool l6470::isBusy()
{
  bool temp = digitalReadFast(BUSYpin);
  return !temp;
}

long l6470::angleToSteps(float angle)
{
  return long(angle*71);
}

uint16_t SpdCalc(uint16_t stepsPerSec)
{
  float temp = stepsPerSec * .065536;
  return (uint16_t) long(temp);
}

