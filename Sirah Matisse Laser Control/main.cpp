#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>

/*
The VISA header must be included to define the VISA related commands. This header is usually in the
"C:/Program Files/IVI Foundation/VISA/WinNT/include/" You also need to point to visa library, which is platform dependent.
The .lib-file is usually in "C:/Program Files/IVI Foundation/VISA/WinNT/lib/msc/".
*/

#include "C:/Program Files/IVI Foundation/VISA/Win64/Include/visa.h"

// #pragma comment is a compiler directive which indicates C++ to leave a comment in the generated object file. The comment can then be read by the linker when it processes object files.
// #pragma comment(lib, libname) tells the linker to add the 'libname' library to the list of library dependencies, as if you had added it in the project properties at Linker->Input->Additional dependencies

#pragma comment( lib, "C:/Program Files/IVI Foundation/VISA/Win64/Lib_x64/msc/visa64")

using namespace std;

static char instrDescriptor[VI_FIND_BUFLEN];
static ViUInt32 numInstrs;
static ViFindList findList;
static ViSession defaultRM, instr;
static ViStatus openDRMStatus, FRsrcStatus, openVIStatus, setAttrStatus, readStatus, writeStatus, closeStatus;
static ViUInt32 retCount;
static ViUInt32 writeCount;
static unsigned char buffer[100];
static char stringinput[512];

static char crlbl[] = "USB0::0x17E7::0x0101::19-05-02::INSTR"; //CR: USB0::0x17E7::0x0101::19-05-02::INSTR
static char cslbl[] = "USB0::0x17E7::0x0102::19-05-31::INSTR"; //CS: USB0::0x17E7::0x0102::19-05-31::INSTR


int close()
{
	closeStatus = viClose(findList);
	closeStatus = viClose(defaultRM);
	printf("\nHit enter to close.");
	fflush(stdin);
	getchar();
	return 0;
}

void init()
{
	/*
	First we will need to open the default resource manager. Check the status, if an error occured. VISA status codes above 0 are warnings,
	below 0 errors and just 0 means everything is okay.
	*/

	openDRMStatus = viOpenDefaultRM(&defaultRM);

	if (openDRMStatus < VI_SUCCESS)
	{
		printf("Could not open a session to the VISA Resource Manager!\n");
		exit(EXIT_FAILURE);
	}

	/*
	Now we search for Sirah laser devices. VISA Test and Measurment USB devices have resource format like
	USBn::0xvvvv::0xdddd::ssssss::INSTR where n is a rising integer, numbering each USB Test and Measurment USB device.
	vvvv stands for the vendor id in hexadecimal, which identifies the production company of this device. dddd is
	the hexadecimal code for the device id and ssssss is the device's serial number. 

	A Sirah Matisse TR laser must have the format: USB[0-9]*::0x17E7::0x0101::??-??-??::INSTR with a unique serial number.
	A Sirah Matisse TS laser must have the format: USB[0-9]*::0x17E7::0x0102::??-??-??::INSTR with a unique serial number.
	*/

	FRsrcStatus = viFindRsrc(defaultRM, "USB[0-9]*::0x17E7::0x010?::??-??-??::INSTR", &findList, &numInstrs, instrDescriptor);

	if (FRsrcStatus; VI_SUCCESS)
	{
		printf("Error: %d: An error occurred while finding resources. A Sirah VISA device could not be found.\n", FRsrcStatus);
		close();
	}
	else if (strcmp(instrDescriptor, crlbl) == 0)
	{
		printf("CR Laser Found!\n");
	}
	else if (strcmp(instrDescriptor, cslbl) == 0)
	{
		printf("CS Laser Found!\n");
	}


	printf("VISA Resource Name: %s \n", instrDescriptor);
	//printf("%d Number Sirah devices found:\n\n", numInstrs);
	//status = viFindNext(findList, instrDescriptor);

	/*
	If you have more than Sirah device, you can check the number of found lasers:
		printf("%d Number Sirah devices found:\n\n",numInstrs);
	You may use
		status = viFindNext (findList, instrDescriptor); // find next device to toggle findList to the VISA resource (or laser device) you want to use.
	*/

	//Now we will open a session to the first instrument we just found.
	openVIStatus = viOpen(defaultRM, instrDescriptor, VI_NULL, VI_NULL, &instr);

}

void writeCommand(const char* cmd)
{
	if (openVIStatus < VI_SUCCESS)
	{
		printf("Error: %d: An error occurred opening a session to %s \n", openVIStatus, instrDescriptor);
	}
	else
	{
		//Set timeout value to 5000 milliseconds (5000 milliseconds).
		setAttrStatus = viSetAttribute(instr, VI_ATTR_TMO_VALUE, 5000);
		strcpy_s(stringinput, cmd);
		/*
		stringinput is the VISA command for the laser. You may also ask
		the laser for the current Thin Etalon motor position with "MOTTE:POS?"
		instead of "IDN?" or send it to a Thin Etalon motor position with
		"MOTTE:POS 15000".
		*/
		writeStatus = viWrite(instr, (ViBuf)stringinput, (ViUInt32)strlen(stringinput), &writeCount);
		if (writeStatus < VI_SUCCESS)
		{
			printf("Error: %d: Error writing to the device\n", writeStatus);
			close();
		}
	}
}

void readCommand()
{
	/*
	Now we will attempt to read back a response from the device to the
	identification query that was sent. We will use the viRead function to
	acquire the data. We will try to read back 100 bytes. After the data has
	been read the response is displayed.
	*/
	readStatus = viRead(instr, buffer, 100, &retCount);
	if (readStatus < VI_SUCCESS)
	{
		printf("Error: %d: Error reading a response from the device \n", readStatus);
	}
	else
	{
		printf("Data read: %s\n", buffer);
	}
	viClose(instr);

}

void main()
{
	/*
		PID:PROTOCOL
		Set the identifier number of the pid - loop to protocol.

		PID:PROTOCOL?
		Get the ID number of the PID loop which is currently written into the protocol.

		PID ID Usage
		0 none
		1 Thin Etalon
		2 Thick Etalon
		3 Slow Piezo
		4 Fast Piezo

		ERROR:CODE?
		Get all error codes raised since last ERROR:CLEAR command (or system startup).
		
		ERROR:CLEAR
		Clears error conditions and information. This command does not effect error conditions from the motor controller.

		DIODEPOWER:DCVALUE?
		Get the DC-part of the integral laser output. The value is given in volts at the controller input. This is a read-only value.

		DIODEPOWER:LOW?
		Get the current waveform of the AC-part of the integral laser output. The values are normalized to be in the range [-1,1]. The number of values is determined by the setting of PIEZOETALON:OVERSAMPLING.

		DIODEPOWER:LOW?
		Get the current value of the low power level. When the signal at the integral power diode drops below this level all control loops are deactivated. Setting the level to 0 (zero) de-activates this function.

		DIODEPOWER:LOW
		Set the low power level. When the signal at the integral power diode drops below this level all control loops are deactivated. Setting the level to 0 (zero) de-activates this function.

		Birefringent Filter Motor
		These commands are used to control the setting of the Birefringent Filter.
		Motor commands need noticeable time to execute (10 ms .. 100 ms) due to communication overhead.

			MOTORBIREFRINGENT:POSITION?
			Get the current position of the birefringent filter's stepper motor position.

			MOTORBIREFRINGENT:POSITION
			Move the stepper motor of the birefringent filter to an absolute position. The command does not wait for completion of the motor movement.

			MOTORBIREFRINGENT:STATUS?
			Retrieve the status and setting of the birefringent filter's motor controller. The status is binary coded into a single 16-bit integer value. The bits have the following meaning:

			Bit				Usage
            0 .. 6          current status of the controller
			7				set in case of an error status of the controller
			8				indicates that the motor is running
			9				indicates the motor current is switched off
			10				indicates an invalid motor position after hold was switched off
			11				status of limit switch 1
			12				status of limit switch 2
			13				status of home switch
			14				manual control enable / disable
		
			MOTORBIREFRINGENT:MAXIMUM?
			Get the maximum position of the birefringent filter's stepper motor.

			MOTORBIREFRINGENT:RELATIVE
			Move the birefringent filter's stepper motor the given number of steps relative to it's current position. The command does not wait for completion of the motor movement.

			MOTORBIREFRINGENT:HOME
			Move the birefringent filter's stepper motor to its home position. The home position is defined by the home switch. The controller positions the stepper motor at the point where 
			the home switch is actuated and resets the motor position to zero (0). The command does not wait for completion of the motor movement. 

			MOTORBIREFRINGENT:CLEAR
			Clear pending errors at the birefringent filter motor controller.

			MOTORBIREFRINGENT:INCREMENT
			Set the number of motor steps made by the Birefringent Filter when the manual control button is pressed for a short time.

			MOTORBIREFRINGENT:INCREMENT?
			Retrieve the number of steps the birefringent filter motor makes when the manual control button is pressed for a short time.

			MOTORBIREFRINGENT:CONSTANTABSOLUTE
			Move the stepper motor of the birefringent filter to an absolute position using the constant speed defined by MOTBI:FREQ. The command does not wait for completion of the motor movement. 
			This commands requires stepper motor driver firmware version R25, or higher.

			MOTORBIREFRINGENT:CONSTANTRELATIVE
			Move the stepper motor of the birefringent filter relative to its current position using the constant speed defined by MOTBI:FREQ. The command does not wait for completion of the motor movement. 
			This commands requires stepper motor driver firmware version R25, or higher.

			MOTORBIREFRINGENT:FREQUENCY
			Set the step frequency used for the Birefringent Filter motor when using constant speed scan commands (MOTBI:CABS, MOTBI:CREL). The lowest step frequency supported by the firmware of the stepper motor
			driver is about 60 Steps / sec. If a lower frequency is requested the motor will use the lowest possible frequency without extra warning or notice.

			MOTORBIREFRINGENT:FREQUENCY?
			Get the step frequency used for the Birefringent Filter motor when using constant speed scan commands (MOTBI:CABS, MOTBI:CREL). The lowest step frequency supported by the firmware of the stepper motor
			driver is about 60 Steps / sec. If a lower frequency is requested the motor will use the lowest possible frequency without extra warning or notice.

			MOTORBIREFRINGENT:WAVELENGTH
			Move the birefringent filter to a wavelength position. The position is passed as nanometers. The resulting motor position needs to be in between 0 and the maximum motor position, as given by the
			MOTORBIREFRINGENT:MAXIMUM command.

			MOTORBIREFRINGENT:WAVELENGTH?
			Get the current position of the birefringent filter in terms of a wavelength. The result is given in nanometers.

			MOTORBIREFRINGENT:REFERENCESCAN
			Set the proportional factor that controls how a scan of the reference cell piezo influences the position of the birefringent filter motor. If a reference cell piezo amplifier with variable gain
			is installed, this value will be changed according to the selcted gain.

			MOTORBIREFRINGENT:REFERENCESCAN?
			Get the proportional factor that controls how a scan of the reference cell piezo influences the position of the birefringent filter motor. If a reference cell piezo amplifier with variable gain 
			is installed, this value will be changed according to the selcted gain.

		Thin Etalon Motor
		These commands are used to control the setting of the thin Etalon.

			MOTORTHINETALON:POSITION
			Move the stepper motor of the thin etalon to an absolute position. The command does not wait for completion of the motor movement.

			MOTORTHINETALON:POSITION?
			Get the absolute position of the stepper motor of the thin etalon to an absolute position.

			MOTORTHINETALON:STATUS?
			Get the status of the thin etalon's stepper motor controller. The status is binary coded into a single 16-bit value. The bits have the following meaning:
			
			Bit				Usage
			0 .. 6			current status of the controller
			7				set in case of an error status of the controller
			8				indicates that the motor is running
			9				indicates the motor current is switched off
			10				indicates an invalid motor position after hold was switched off
			11				status of limit switch 1
			12				status of limit switch 2
			13				status of home switch
			14				manual control enable / disable

			MOTORTHINETALON:MAXIMUM?
			Get the maximum position of the thin etalon's stepper motor.

			MOTORTHINETALON:HOME
			Move the thin etalon's stepper motor to its home position. The home position is defined by the home switch. The controller positions the stepper motor at the point where the home switch is actuated
			and resets the motor position to zero (0). The command does not wait for completion of the motor movement.

			MOTORTHINETALON:HALT
			Stop a motion of the thin etalon's stepper motor. The command will use a smooth deceleration to maintain accurate step tracking.

			MOTORTHINETALON:CLEAR
			Clear pending errors at the motor controller.

		Piezo Etalon Control

			PIEZOETALON:OVERSAMPLING
			Set the number of sample points for sine interpolation. The minium value is 8, the maximum value is 64 samples per period.

			PIEZOETALON:OVERSAMPLING?
			Get the number of sample points used for sine interpolation.

			PIEZOETALON:BASELINE
			Set the baseline of the modulation waveform to a new value. The value needs to be within the interval [-1,1].

			PIEZOETALON:BASELINE?
			Get the baseline of the modulation waveform.

			PIEZOETALON:AMPLITUDE
			Set the amplitude of the modulation of the thick etalon.

			PIEZOETALON:AMPLITUDE?
			Get the amplitude of the modulation of the thick etalon.

			PIEZOETALON:CONTROLSTATUS
			Start or stop the P (see PID Loops) control loop that controls the baseline value of the modulation.

			PIEZOETALON:CONTROLPROPORTIONAL
			Get the status of the P (see PID Loops) control loop that controls the baseline value of the modulation.

			PIEZOETALON:CONTROLPROPORTIONAL?
			Get the proportional gain of the P (see PID Loops) control loop that controls the spacing of the thick etalon.
			
			PIEZOETALON:CONTROLAVERAGE
			Set the number of waveforms averaged before a P (see PID Loops) control loop iteration is performed.

			PIEZOETALON:CONTROLSTATUS
			Get the number of waveforms averaged before a P (see PID Loops) control loop iteration is performed.

			PIEZOETALON:CONTROLPHASESHIFT
			Set the phaseshift that is used for the PLL calculation.

			PIEZOETALON:CONTROLPHASESHIFT?
			Get the phaseshift value used for the pll calculation.

			PIEZOETALON:CAVITYSCAN
			Set the proportional factor that controls how a scan of the slow cavity piezo influences the position of the thick piezo etalon. The factor results in an immediate piezo movement, even without
			the P (see PID Loops) control loop enabled.

			PIEZOETALON:CAVITYSCAN?
			Get the proportional factor that controls how a scan of the slow cavity piezo influences the position of the thin etalon. The factor results in an immediate stepper motor movement, even without 
			the P (see PID Loops) control loop enabled.

			PIEZOETALON:REFERENCESCAN
			Set the proportional factor that controls how a scan of the reference cell piezo influences the position of the thick piezo etalon. The factor results in an immediate piezo movement, even without 
			the P control loop enabled. On the other hand, a value of 0 for this parameter corresponds to a control loop only operation of the piezo etalon. If a reference cell piezo amplifier with variable 
			gain is installed, this value will be changed according to the selcted gain.

			PIEZOETALON:REFERENCESCAN?
			Get the proportional factor that controls how a scan of the slow cavity piezo influences the position of the thin etalon. The factor results in an immediate stepper motor movement, even without 
			the P (see PID Loops) control loop enabled.

			PIEZOETALON:SAMPLERATE
			Set the sample rate for the piezo etalon control loop. The product of samplerate and oversampling determines the modulation frequency of the etalon. 

			PIEZOETALON:SAMPLERATE
			Get the sample rate for the piezo etalon control loop. The product of samplerate and oversampling determines the modulation frequency of the etalon.

			The samplerate parameter uses the following codes:
			Code	Sample Rate
			0		8 kHz	
			1		32 kHz
			2		48 kHz
			3		96 kHz

			FEEDFORWARD:AMPLITUDE
			Set the amplitude for the feed forward of the piezo etalon's modulation to the fast stabilization piezo. Negative values for the amplitude will result in a feed forward signal with twice the frequency
			of the piezo modulation. This behaviour is useful for setting the feedforward parameters. The parameter is only available when the piezo etalon is installed and configured.

			FEEDFORWARD:AMPLITUDE?
			Get the amplitude for the feed forward of the piezo etalon's modulation to the fast stabilization piezo. Negative values for the amplitude result in a feed forward signal with twice the frequency 
			of the piezo modulation. This behaviour is useful for setting the feedforward parameters. The parameter is only available when the piezo etalon is installed and configured.

			FEEDFORWARD:PHASESHIFT
			Set the phase shift for the feed forward of the piezo etalon's modulation to the fast stabilization piezo. Useful values for this parameter range from 0 to the OVERSAMPLING of the piezo etalon's modulation
			signal. The parameter is only available when the piezo etalon is installed and configured.

			FEEDFORWARD:PHASESHIFT?
			Get the phase shift for the feed forward of the piezo etalon's modulation to the fast stabilization piezo. Useful values for this parameter range from 0 to the OVERSAMPLING of the piezo etalon's modulation 
			signal. The parameter is only available when the piezo etalon is installed and configured.

		Thin Etalon Control
			
			THINETALON:DCVALUE?
			Get the DC-part of the reflex of the thin etalon. The value is given in volts at the controller input.

			THINETALON:CONTROLSTATUS
			Set the status of the thin Etalon PI control loop.

			THINETALON:CONTROLSTATUS
			Get the status of the thin Etalon PI control loop.

			THINETALON:CONTROLPROPORTIONAL
			Set the proportional gain of the thin Etalon PI control loop.

			THINETALON:CONTROLPROPORTIONAL?
			Get the proportional gain of the thin Etalon PI control loop.

			THINETALON:CONTROLERROR?
			Get the current error value of the thin Etalon control loop.
			
			THINETALON:CONTROLAVERAGE
			Set the number of measurements averaged of the thin Etalon PI control loop.

			THINETALON:CONTROLAVERAGE?
			Get the number of measurements averaged of the thin Etalon PI control loop.

			THINETALON:CONTROLSETPOINT
			Set the control goal of the thin etalon control loop.

			THINETALON:CONTROLSETPOINT?
			Get the control goal of the thin etalon PI control loop.

			THINETALON:CONTROLINTEGRAL
			Set the integral gain of the thin Etalon PI control loop.

			THINETALON:CONTROLINTEGRAL?
			Get the integral gain of the thin Etalon PI control loop.

			THINETALON:CAVITYSCAN
			Set the proportional factor that controls how a scan of the slow cavity piezo influences the position of the thin etalon. The factor results in an immediate stepper motor movement, even without
			the PI control loop enabled.

			THINETALON:REFERENCESCAN
			Set the proportional factor that controls how a scan of the reference cell piezo influences the position of the thin etalon. The factor results in an immediate stepper motor movement, even without 
			the PI control loop enabled. On the other hand, a value of 0 for this parameter corresponds to a control loop only operation of the piezo etalon. If a reference cell piezo amplifier with variable gain
			is installed, this value will be changed according to the selected gain.

			THINETALON:REFERENCESCAN?
			Get the proportional factor that controls how a scan of the reference cell piezo influences the position of the thin etalon. The factor results in an immediate stepper motor movement, even without 
			the PI control loop enabled. On the other hand, a value of 0 for this parameter corresponds to a control loop only operation of the piezo etalon. If a reference cell piezo amplifier with variable gain 
			is installed, this value will be changed according to the selected gain.

		Scan Control
		These commands control the scanning mirror, or if used, the reference cell. 
			
			SCAN:STATUS
			Start or stop a scan.
			
			SCAN:STATUS?
			Get current status of the scan

			SCAN:LOWERLIMIT
			Set the lower limit of the scan pattern. Scan positions are within the interval [0,0.7].

			SCAN:LOWERLIMIT?
			Get the lower limit of the scan pattern. Scan positions are within the interval [0,0.7].

			SCAN:UPPERLIMIT
			Set the upper limit of the scan pattern. Scan positions are within the interval [0,0.7].

			SCAN:UPPERLIMIT?
			Get the upper limit of the scan pattern. Scan positions are within the interval [0,0.7].

			SCAN:NOW
			Set the current scan position. Scan positions are within the interval [0,0.7].

			SCAN:NOW?
			Get the current scan position.

			SCAN:MODE
			Set the current scan mode. The scan mode determines the direction of the scan and whether it stops at one of the limits. The behaviour is coded into the bits of this variable. When the scan device 
			reaches one of the limit values, the direction is inverted. As a next step the scan is stopped at the limit, if the appropriate control bit is set. 

			SCAN:MODE?
			Get the current scan mode. The scan mode determines the direction of the scan and whether it stops at one of the limits. The behaviour is coded into the bits of this variable. When the scan device 
			reaches one of the limit values, the direction is inverted. As a next step the scan is stopped at the limit, if the appropriate control bit is set.
			
			Bit			Action if bit is set
			0			increase voltage, stop at neither limit
			1			decrease voltage, stop at neither limit
			2			increase voltage, stop at lower limit
			3			decrease voltage, stop at lower limit
			4			increase voltage, stop at upper limit
			5			decrease voltage, stop at upper limit
			6			increase voltage, stop at either limit
			7			decrease voltage, stop at either limit

			SCAN:DEVICE
			Set the device that controls the scan of the Matisse laser. This device is the master that controls the tuning of the system, all other devices follow the master device either by open-loop 
			(e. g. birefringent filter) or closed- loop control (e. g. thick etalon). If the specified device is already used by another command e.g. the SLOWPIEZO control loop, an error message will be returned.

			SCAN:DEVICE?
			Get the device that controls the scan of the Matisse Commander laser. This device is the master that controls the tuning of the system, all other devices follow the master device either by open-loop 
			(e. g. birefringent filter) or closed- loop control (e. g. thick etalon)

			Code	Device
			0		no device
			1		slow cavity piezo
			2		reference cell piezo

			SCAN:RISINGSPEED
			Set the speed of the voltage ramp-up of the scan mirror.

			SCAN:RISINGSPEED?
			Get the speed of the voltage ramp-up of the scan mirror.

			SCAN:FALLINGSPEED
			Set the speed of the voltage ramp-down of the scan mirror.

			SCAN:FALLINGSPEED?
			Get the speed of the voltage ramp-down of the scan mirror.

			SCAN:REFERENCECALIBRATION
			Set the scan device calibration factor for reference cell controlled scans. The value is stored into the laser's flash memory but has no further influence on the operation.

			SCAN:REFERENCECALIBRATION?
			Get the scan device calibration factor for reference cell controlled scans. The value is stored into the laser's flash memory but has no further influence on the operation.

			SCAN:CAVITYCALIBRATION
			Set the scan device calibration factor for cavity scans. The value is stored into the laser's flash memory but has no further influence on the operation.

			SCAN:CAVITYCALIBRATION?
			Get the scan device calibration factor for cavity scans. The value is stored into the laser's flash memory but has no further influence on the operation.
		
		Fast Piezo Control

		Reference Cell Control

		Slow Piezo Control

		Misc
	*/

	init();
/*
	const char setpidprotcmd[] = "PID:PROT 1";
	const char getpidprotcmd[] = "PID:PROT?";
	const char geterrcdcmd[] = "ERR:CODE?";
	const char errclrcmd[] = "ERR:CL";
	const char getpddccmd[] = "DPOW:DC?";
	const char getacwvcmd[] = "DPOW:WAVTAB?";
	const char getpdlowcmd[] = "DPOW:LOW?";
	const char setpdlowcmd[] = "DPOW:LOW 0.34";
	const char getmotbiposcmd[] = "MOTBI:POS?";
	const char setmotbiposcmd[] = "MOTBI:POS 120400";
	const char getmotbistatcmd[] = "MOTBI:STA?";
	const char getmotbimaxposcmd[] = "MOTBI:MAX?";
	const char setmotbirelposcmd[] = "MOTBI:REL -150";
	const char setmotbihomecmd[] = "MOTBI:HOME";
	const char motbiclrcmd[] = "MOTBI:CLEAR";
	const char setmotbiincrcmd[] = "MOTBI:INC 25";
	const char getmotbiincrcmd[] = "MOTBI:INC?";
	const char setmotbicabscmd[] = "MOTBI:CABS 120400";
	const char setmotbicrcmd[] = "MOTBI:CREL -1000";
	const char setmotbifreqcmd[] = "MOTBI:FREQ 200";
	const char getmotbifreqcmd[] = "MOTBI:FREQ?";
	const char setmotbiwposcmd[] = "MOTBI:POS 760.1";
	const char getmotbiwposcmd[] = "MOTBI:WL?";
	const char setmotbirefcmd[] = "REFCELL:GNC 1";
	const char getmotbirefcmd[] = "MOTBI:REFSCN?";
	const char setteposcmd[] = "MOTTE:POS 12000";
	const char getteposcmd[] = "MOTTE:POS?";
	const char gettestatcmd[] = "MOTTE:STA?";
	const char gettemaxposcmd[] = "MOTTE:MAX?";
	const char settehomecmd[] = "MOTTE:HOME";
	const char testopcmd[] = "MOTTE:HALT";
	const char teclrcmd[] = "MOTTE:CL";
	const char setpeovscmd[] = "PZETL:OVER 8";
	const char getpeovscmd[] = "PZETL:OVER?";
	const char setpebslcmd[] = "PZETL:BASE 0.3";
	const char getpebslcmd[] = "PZETL:BASE?";
	const char setpeampcmd[] = "PZETL:AMP 23.23";
	const char getpeampcmd[] = "PZETL:AMP?";
	const char setpepidcscmd[] = "PZETL:CNTRSTA RUN"; //"PZETL : CNTRSTA STOP"
	const char getpepidcscmd[] = "PZETL:CNTRSTA?";
	const char setpepgaincmd[] = "PZETL:CNTRPROP 1.5";
	const char getpepgaincmd[] = "PZETL:CNTRPROP?";
	const char setpecavgcmd[] = "PZETL:CNTRAVG 10";
	const char getpecavgcmd[] = "PZETL:CNTRAVG?";
	const char setpecpscmd[] = "PZETL:CNTRPHSF 2";
	const char getpecpscmd[] = "PZETL:CNTRPHSF?";
	const char setpecscmd[] = "PZTEL:CAVSCN 2.5";
	const char getpecscmd[] = "PZTEL:CAVSCN?";
	const char setperefscmd[] = "PZETL:REFSCN -1.700378";
	const char getperefscmd[] = "PZETL:REFSCN?";
	const char setpesrcmd[] = "PZETL:SRATE 3";
	const char getpesrcmd[] = "PZETL:SRATE?";
	const char setpeffacmd[] = "FEF:AMP 1.5";
	const char getpeffacmd[] = "FEF:AMP?";
	const char setpeffpscmd[] = "FEF:PHSF 14";
	const char getpeffpscmd[] = "FEF:PHSF?";
	const char gettepddccmd[] = "TE:DC?";
	const char settecscmd[] = "TE:CNTRSTA RUN";
	const char gettecscmd[] = "TE:CNTRSTA?";
	const char settepgaincmd[] = "TE:CNTRPROP 100";
	const char gettepgaincmd[] = "TE:CNTRPROP?";
	const char gettecerrcmd[] = "TE:CNTRERR?";
	const char settecavgcmd[] = "TE:CNTRAVG 3";
	const char gettecavgcmd[] = "TE:CNTRAVG?";
	const char settecspcmd[] = "TE:CNTRSP 10.3";
	const char gettecspcmd[] = "TE:CNTRSP?";
	const char settecintcmd[] = "TE:CNTRINT 2.5";
	const char gettecintcmd[] = "TE:CNTRINT?";
	const char settecavscmd[] = "TE:CAVSCN 4.7";
	const char gettecavscmd[] = "TE:CAVSCN?";
	const char setterefscmd[] = "TE:REFSCN 2670";
	const char getterefscmd[] = "TE:REFSCN?";
*/
	const char setscanstatcmd[] = "SCAN:STA RUN";
	const char getscanstatcmd[] = "SCAN:STA?";
	const char setscanlowerlimcmd[] = "SCAN:LLM 10.5";
	const char getscanlowerlimcmd[] = "SCAN:LLM?";
	const char setscanupperlimcmd[] = "SCAN:ULM 20";
	const char getscanupperlimcmd[] = "SCAN:ULM?";
	const char setscanposcmd[] = "SCAN:NOW 0.5";
	const char getscanposcmd[] = "SCAN:NOW?";
	const char setscanmodecmd[] = "SCAN:MODE 2";
	const char getscanmodecmd[] = "SCAN:MODE?";
	const char setscandevcmd[] = "SCAN:DEV 2";
	const char getscandevcmd[] = "SCAN:DEV?";
	const char setscanrscmd[] = "SCAN:RSPD 0.01";
	const char getscanrscmd[] = "SCAN:RSPD?";
	const char setscanfscmd[] = "SCAN:FSPD 0.01";
	const char getscanfscmd[] = "SCAN:FSPD?";
	const char setscanrefcalcmd[] = "SCAN:REFCAL 1525.3";
	const char getscanrefcalcmd[] = "SCAN:REFCAL?";
	const char setscancavcalcmd[] = "SCAN:CAVCAL 1546.5";
	const char getscancavcalcmd[] = "SCAN:CAVCAL?";

	const char idcmd[] = "IDN?";

	writeCommand(getscandevcmd);
	readCommand();
	close();
}

