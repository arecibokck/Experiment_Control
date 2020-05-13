%% - get Laser-Object
% LaserID='USB0::0x17E7::0x0101::19-05-02::INSTR'; % CR Laser
LaserID = 'USB0::0x17E7::0x0102::19-05-31::INSTR'; % CS Laser
Laser = Devices.SirahMatisseLasers.LaserControl(LaserID);
%% Connect to Laser
Laser.connect();
%% - Write to and Read from Laser
Laser.query('IDN?');
%% Write to and Read from Laser through Built-In Handlers
% Setters and Getters for use in sequences without requiring explicit command strings
Laser.getID()
Laser.getPIDLoopProtID()
% Laser.setScanStatus()
Laser.getScanStatus()
% Laser.setScanLowerLimit()
Laser.getScanScanLowerLimit()
% Laser.setScanUpperLimit()
Laser.getScanScanUpperLimit()
% Laser.setScanPosition()
Laser.getScanPosition()
% Laser.setScanMode()
Laser.getScanMode()
% Laser.setScanDevice()
Laser.getScanDevice()
% Laser.setScanRisingSpeed()
Laser.getScanRisingSpeed()
% Laser.setScanFallingSpeed()
Laser.getScanFallingSpeed()
Laser.getFastPiezoLockStatus()
% Laser.setFastPiezoControlSetPoint()
Laser.getFastPiezoControlSetPoint()
% Laser.setFastPiezoControlStatus()
Laser.getFastPiezoControlStatus()
% Laser.setFastPiezoIGain()
Laser.getFastPiezoIGain()
% Laser.setFastPiezoLockPoint()
Laser.getFastPiezoLockPoint()
% Laser.setFastPiezoPosition()
Laser.getFastPiezoPosition()
% Laser.setReferenceCellPiezoLowerLimit()
% Laser.getReferenceCellPiezoLowerLimit()
% Laser.setReferenceCellPiezoUpperLimit()
% Laser.getReferenceCellPiezoUpperLimit()
% Laser.getReferenceCellPiezoPosition()
% Laser.setSlowPiezoPgain(-3.100000e-04)
Laser.getSlowPiezoPgain()
% Laser.setSlowPiezoIgain(-3.200000e-04)
Laser.getSlowPiezoIgain()
% Laser.setSlowPiezoControlSetPoint(6.000000e-01)
Laser.getSlowPiezoControlSetPoint()
% Laser.setSlowPiezoControlStatus('STOP')
Laser.getSlowPiezoControlStatus()
% Laser.setSlowPiezoPosition(3.213796e-01)
Laser.getSlowPiezoPosition()
%% Disconnect from Laser
Laser.disconnect();
%% Delete Laser Object
delete(Laser);
%% Clear Workspace
clear all;