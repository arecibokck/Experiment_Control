%% Connect to oscilloscope
OsciID = 'DQSIMOsci3ID'; %DSO-X 2004A
Osci = KeysightOscilloscope.KeysightOscilloscope(OsciID);
Osci.connect();

