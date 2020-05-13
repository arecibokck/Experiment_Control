classdef LaserControl < handle
    %% Properties
    properties (Constant)
        CRLaserID = 'USB0::0x17E7::0x0101::19-05-02::INSTR';
        CSLaserID = 'USB0::0x17E7::0x0102::19-05-31::INSTR';
    end
    
    properties (SetAccess = immutable)
    	% VISA ID of this device
        deviceID;
    end
    
    properties % Public
        % VISA Object for this device
	    vi;
    end
    
    properties (SetAccess = private)   
        %{
        List of Commands

        PID:PROTOCOL
        Set the identifier number of the PID - loop to protocol.

        PID:PROTOCOL?
        Get the ID number of the PID loop which is currently written into the protocol.

        PID ID Usage
        0 none
        1 Thin Etalon
        2 Thick Etalon
        3 Slow Piezo
        4 Fast Piezo
        
        PID:PROCESSSTATISTICS?
        Evaluate some statistics for the process values stored in the PID protocol array. The values are calculated using
        the current contents of the 256 entry ring buffer. During the evaluation the recording of new PID protocol data is
        disabled.
        Each request returns the following values: Minimal process value, maximal process value, average process value,
        root mean square deviation from the average value.
        
        PID:ORDINAL?
        Get the current value of the counter for the ordinal number of the protocol entries.
        %}
        setPIDprotcmd = 'PID:PROT';
        getPIDprotcmd = 'PID:PROT?';
        getPIDprocstatcmd = 'PID:PSTAT?';
        getPIDordinalcmd = 'PID:ORD?';

        %{
        ERROR:CODE?
        Get all error codes raised since last ERROR:CLEAR command (or system startup).

        ERROR:CLEAR
        Clears error conditions and information. This command does not effect error conditions from the motor controller.
        %}
        geterrcdcmd = 'ERR:CODE?';
        errclrcmd = 'ERR:CL';

        %{
        DIODEPOWER:DCVALUE?
        Get the DC-part of the integral laser output. The value is given in volts at the controller input. This is a read-only value.

        DIODEPOWER:LOW?
        Get the current waveform of the AC-part of the integral laser output. The values are normalized to be in the range [-1,1]. The number of values is determined by the setting of PIEZOETALON:OVERSAMPLING.

        DIODEPOWER:LOW?
        Get the current value of the low power level. When the signal at the integral power diode drops below this level all control loops are deactivated. Setting the level to 0 (zero) de-activates this function.

        DIODEPOWER:LOW
        Set the low power level. When the signal at the integral power diode drops below this level all control loops are deactivated. Setting the level to 0 (zero) de-activates this function.
        %}
        getpddccmd = 'DPOW:DC?';
        getacwvcmd = 'DPOW:WAVTAB?';
        setpdlowcmd = 'DPOW:LOW';
        getpdlowcmd = 'DPOW:LOW?';
        
        %{
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
            Set the step frequency used for the Birefringent Filter motor when using ant speed scan commands (MOTBI:CABS, MOTBI:CREL). The lowest step frequency supported by the firmware of the stepper motor
            driver is about 60 Steps / sec. If a lower frequency is requested the motor will use the lowest possible frequency without extra warning or notice.

            MOTORBIREFRINGENT:FREQUENCY?
            Get the step frequency used for the Birefringent Filter motor when using ant speed scan commands (MOTBI:CABS, MOTBI:CREL). The lowest step frequency supported by the firmware of the stepper motor
            driver is about 60 Steps / sec. If a lower frequency is requested the motor will use the lowest possible frequency without extra warning or notice.

            MOTORBIREFRINGENT:WAVELENGTH
            Move the birefringent filter to a wavelength position. The position is passed as nanometers. The resulting motor position needs to be in between 0 and the maximum motor position, as given by the
            MOTORBIREFRINGENT:MAXIMUM command.

            MOTORBIREFRINGENT:WAVELENGTH?
            Get the current position of the birefringent filter in terms of a wavelength. The result is given in nanometers.
        
            MOTORBIREFRINGENT:CAVITYSCAN
            Set the proportional factor that controls how a scan of the slow cavity piezo influences the position of the
            birefringent filter motor.
        
            MOTORBIREFRINGENT:CAVITYSCAN?
            Get the proportional factor that controls how a scan of the slow cavity piezo influences the position of the
            birefringent filter motor.

            MOTORBIREFRINGENT:REFERENCESCAN
            Set the proportional factor that controls how a scan of the reference cell piezo influences the position of the birefringent filter motor. If a reference cell piezo amplifier with variable gain
            is installed, this value will be changed according to the selcted gain.

            MOTORBIREFRINGENT:REFERENCESCAN?
            Get the proportional factor that controls how a scan of the reference cell piezo influences the position of the birefringent filter motor. If a reference cell piezo amplifier with variable gain 
            is installed, this value will be changed according to the selcted gain.
        
            MOTORBIREFRINGENT:MOTOROFFSET
            Set the calibration parameter WavelengthOffset for the step motor position to wavelength conversion.
        
            MOTORBIREFRINGENT:MOTOROFFSET?
            Get the calibration parameter WavelengthOffset for the step motor position to wavelength conversion.
        
            MOTORBIREFRINGENT:MOTORFACTOR
            Set the calibration parameter WavelengthFactor for the step motor position to wavelength conversion.
        
            MOTORBIREFRINGENT:MOTORFACTOR?
            Get the calibration parameter WavelengthFactor for the step motor position to wavelength conversion.
        
            MOTORBIREFRINGENT:THICKNESS
            Set the calibration parameter Leverlength for the step motor position to wavelength conversion.
        
            MOTORBIREFRINGENT:THICKNESS?
            Get the calibration parameter Leverlength for the step motor position to wavelength conversion.
        
            MOTORBIREFRINGENT:ORDER
            Set the calibration parameter LinearOffset for the step motor position to wavelength conversion.
        
            MOTORBIREFRINGENT:ORDER?
            Get the calibration parameter LinearOffset for the step motor position to wavelength conversion.
        
            
        %}

        getmotbiposcmd = 'MOTBI:POS?';
        setmotbiposcmd = 'MOTBI:POS';
        getmotbistatcmd = 'MOTBI:STA?';
        getmotbimaxposcmd = 'MOTBI:MAX?';
        setmotbirelposcmd = 'MOTBI:REL';
        setmotbihomecmd = 'MOTBI:HOME';
        motbiclrcmd = 'MOTBI:CLEAR';
        setmotbiincrcmd = 'MOTBI:INC';
        getmotbiincrcmd = 'MOTBI:INC?';
        setmotbicabscmd = 'MOTBI:CABS';
        setmotbicrcmd = 'MOTBI:CREL';
        setmotbifreqcmd = 'MOTBI:FREQ';
        getmotbifreqcmd = 'MOTBI:FREQ?';
        setmotbiwposcmd = 'MOTBI:WL';
        getmotbiwposcmd = 'MOTBI:WL?';
        setmotbicscmd = 'MOTBI:CAVSCN';
        getmotbicscmd = 'MOTBI:CAVSCN?';
        setmotbirefscancmd = 'MOTBI:REFSCN';
        getmotbirefscancmd = 'MOTBI:REFSCN?';
        setmotbimotoroffsetcmd = 'MOTBI:MOTOFF';
        getmotbimotoroffsetcmd = 'MOTBI:MOTOFF?';
        setmotbimotorfactorcmd = 'MOTBI:MOTFAC';
        getmotbimotorfactorcmd = 'MOTBI:MOTFAC?';
        setmotbithicknesscmd = 'MOTBI:THNS';
        getmotbithicknesscmd = 'MOTBI:THNS?';
        setmotbiordercmd = 'MOTBI:ORDER';
        getmotbiordercmd = 'MOTBI:ORDER?';

        %{
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
        
            MOTORTHINETALON:INCREMENT
            Set the number of steps the thin etalon's stepper motor makes when the manual control button is pressed for a
            short period of time.
        
            MOTORTHINETALON:INCREMENT?
            Get the number of steps the thin etalon's stepper motor makes when the manual control button is pressed for a
            short period of time.
        %}
        setteposcmd = 'MOTTE:POS';
        getteposcmd = 'MOTTE:POS?';
        gettestatcmd = 'MOTTE:STA?';
        gettemaxposcmd = 'MOTTE:MAX?';
        settehomecmd = 'MOTTE:HOME';
        testopcmd = 'MOTTE:HALT';
        teclrcmd = 'MOTTE:CL';
        setteinccmd = 'MOTTE:INC';
        getteinccmd = 'MOTTE:INC?';

        %{
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
        %}

        setpeovscmd = 'PZETL:OVER';
        getpeovscmd = 'PZETL:OVER?';
        setpebslcmd = 'PZETL:BASE';
        getpebslcmd = 'PZETL:BASE?';
        setpeampcmd = 'PZETL:AMP';
        getpeampcmd = 'PZETL:AMP?';
        setpectrlstatcmd = 'PZETL:CNTRSTA';
        getpectrlstatcmd = 'PZETL:CNTRSTA?';
        setpepgaincmd = 'PZETL:CNTRPROP';
        getpepgaincmd = 'PZETL:CNTRPROP?';
        setpecavgcmd = 'PZETL:CNTRAVG';
        getpecavgcmd = 'PZETL:CNTRAVG?';
        setpectrlpscmd = 'PZETL:CNTRPHSF';
        getpectrlpscmd = 'PZETL:CNTRPHSF?';
        setpecscmd = 'PZTEL:CAVSCN';
        getpecscmd = 'PZTEL:CAVSCN?';
        setperefscancmd = 'PZETL:REFSCN';
        getperefscancmd = 'PZETL:REFSCN?';
        setpesrcmd = 'PZETL:SRATE';
        getpesrcmd = 'PZETL:SRATE?';
        setpeffacmd = 'FEF:AMP';
        getpeffacmd = 'FEF:AMP?';
        setpeffpscmd = 'FEF:PHSF';
        getpeffpscmd = 'FEF:PHSF?';

        %{
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
        %}
        gettepddccmd = 'TE:DC?';
        settectrlstatcmd = 'TE:CNTRSTA';
        gettectrlstatcmd = 'TE:CNTRSTA?';
        settepgaincmd = 'TE:CNTRPROP';
        gettepgaincmd = 'TE:CNTRPROP?';
        gettecerrcmd = 'TE:CNTRERR?';
        settectrlavgcmd = 'TE:CNTRAVG';
        gettectrlavgcmd = 'TE:CNTRAVG?';
        settectrlspcmd = 'TE:CNTRSP';
        gettectrlspcmd = 'TE:CNTRSP?';
        settecintcmd = 'TE:CNTRINT';
        gettecintcmd = 'TE:CNTRINT?';
        settecavscmd = 'TE:CAVSCN';
        gettecavscmd = 'TE:CAVSCN?';
        setterefscancmd = 'TE:REFSCN';
        getterefscancmd = 'TE:REFSCN?';

        %{
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
        %}
        setscanstatcmd = 'SCAN:STA';
        getscanstatcmd = 'SCAN:STA?';
        setscanlowerlimcmd = 'SCAN:LLM';
        getscanlowerlimcmd = 'SCAN:LLM?';
        setscanupperlimcmd = 'SCAN:ULM';
        getscanupperlimcmd = 'SCAN:ULM?';
        setscanposcmd = 'SCAN:NOW';
        getscanposcmd = 'SCAN:NOW?';
        setscanmodecmd = 'SCAN:MODE';
        getscanmodecmd = 'SCAN:MODE?';
        setscandevcmd = 'SCAN:DEV';
        getscandevcmd = 'SCAN:DEV?';
        setscanrscmd = 'SCAN:RSPD';
        getscanrscmd = 'SCAN:RSPD?';
        setscanfscmd = 'SCAN:FSPD';
        getscanfscmd = 'SCAN:FSPD?';
        setscanrefcalcmd = 'SCAN:REFCAL';
        getscanrefcalcmd = 'SCAN:REFCAL?';
        setscancavcalcmd = 'SCAN:CAVCAL';
        getscancavcalcmd = 'SCAN:CAVCAL?';

        %{
        Fast Piezo Control
            FASTPIEZO:LOCK?
            This variable tracks whether the laser was locked. The laser is considered to be locked whenever the tweeter is
            within 5%...95% of its tuning range.
            The concept behind that criteria is the following: if the laser is not locked, it will not react to the tweeter. So any
            error will be integrated until the tweeter is on the lower or upper end of its tuning range. Retrieving this value
            automatically reset the variable value to TRUE. Whenever the tweeter is within the last 5% of it's tuning range the
            variable is set FALSE.

            FASTPIEZO:CONTROLSETPOINT
            Set the control goal of the fast piezo control loop.

            FASTPIEZO:CONTROLSETPOINT?
            Get the control goal of the fast piezo control loop.

            FASTPIEZO:CONTROLSTATUS
            Start or stop the PID loop that controls the fast piezo (tweeter).

            FASTPIEZO:CONTROLSTATUS?
            Get the status of the PID loop that controls the fast piezo (tweeter).

            FASTPIEZO:INPUT?
            Get the current value of the diode at the reference cell (or the current voltage at the external input of the DSP
            board). The value is normalized to be in the range -1..1. This is a read only value.

            FASTPIEZO:CONTROLINTEGRAL
            Set the integral gain of the fast piezo control loop.

            FASTPIEZO:CONTROLINTEGRAL?
            Get the integral gain of the fast piezo control loop.

            FASTPIEZO:LOCKPOINT
            Set the value for the initial control goal value. When the laser needs to perform an initial lock or a relocking,
            the control loop will lock the laser to the value given by FASTPIEZO:LOCKPOINT. After the
            laser is stabilized to the FASTPIEZO:LOCKPOINT value, the control loop will change its control goal to
            FASTPIEZO:CONTROLSETPOINT after a while. The change will be smooth.

            FASTPIEZO:LOCKPOINT
            Get the value to which the fast piezo control locks the laser before it smoothly moves the fastpiezo control from
            the lockpoint to the setpoint.

            FASTPIEZO:NOW
            Set the current position of the fast piezo. The value should be in the range 0..1. An active control loop
            (FASTPIEZO:CONTROLSTATUS = RUN) will overwrite the value after a short time.

            FASTPIEZO:NOW?
            Get the current position of the fast piezo. The value is in the range 0..1
        %}

        getfzptlockstatcmd = 'FPZT:LOCK?';
        setfzptcspcmd = 'FPZT:CNTRSP';
        getfzptcspcmd = 'FPZT:CNTRSP?';
        setfzptctrlstatcmd = 'FPZT:CNTRSTA';    
        getfzptctrlstatcmd = 'FPZT:CNTRSTA?';    
        getfzptdiodecmd = 'FPZT:INPUT?';
        setfzptctrlintcmd = 'FPZT:CNTRINT';
        getfzptctrlintcmd = 'FPZT:CNTRINT?';
        setfzptlockptcmd = 'FPZT:LKP';
        getfzptlockptcmd = 'FPZT:LKP?';
        setfzptposcmd = 'FPZT:NOW';
        getfzptposcmd = 'FPZT:NOW?';

        %{
        Reference Cell Control
        
            REFERENCECELL:TABLE?
            This command starts the process to perform a reference cell scan and measure the intensity on the reference
            diode at the same time. The scan will start at the position defined by REFERENCECELL:LOWERLIMIT and end
            at the position defined by REFERENCECELL:UPPERLIMIT. The intensity will be measured at a number of
            intermediate positions, the number being defined by REFERENCECELL:OVERSAMPLING.
            At the end of the measurement the scan piezo will be reset to the lower limit position. If the reference cell piezo is
            already used by another command e.g. the SCAN command, an error message is returned.
        
            REFERENCECELL:OVERSAMPLING
            Set the number of points sampled during the REFERENCECELL:TABLE? command. The minimum value is 4
            the maximum value is 512 samples.
        
            REFERENCECELL:OVERSAMPLING?
            Get the number of points sampled during the REFERENCECELL:TABLE? command.

            REFERENCECELL:LOWERLIMIT
            Set the lower limit for the scan that is performed during the REFERENCECELL:TABLE? command.

            REFERENCECELL:LOWERLIMIT?
            Get the lower limit for the scan that is performed during the REFERENCECELL:TABLE? command.

            REFERENCECELL:UPPERLIMIT
            Set the upper limit for the scan that is performed during the REFERENCECELL:TABLE? command.

            REFERENCECELL:UPPERLIMIT?
            Get the upper limit for the scan that is performed during the REFERENCECELL:TABLE? command.
        
            REFERENCECELL:MODE
            Set the measurement mode for the data acquisition during the scan that is performed during the REFERENCECELL:TABLE? command.
        
            REFERENCECELL:MODE?
            Get the measurement mode for the data acquisition during the scan that is performed during the REFERENCECELL:TABLE? command.
        
            Code    Mode
            0       None
            1       Average
            2       Minimum
            3       Maximum

            REFERENCECELL:NOW
            Set the position of the reference cell piezo.
        
            REFERENCECELL:NOW?
            Get the position of the reference cell piezo.

            REFERENCECELL:GAINCODE
            Set the gaincode of a variable gain reference cell piezo amplifier. The reference cell piezo amplifier is optionally
            equiped with a gain select. Different codes select different gains for this amplifier. Lower gains result in higher
            resolution of the reference cell. Higher gains result in an increased scan range.

            REFERENCECELL:GAINCODE?
            Get the gaincode of a variable gain reference cell piezo amplifier.

            Code        Gain
            -1          invalid / not defined
             0          0 / grounded
             1          2
             2          5
             3          10
             4          32

            REFERENCECELL:GAIN?
            Get the current gain of the reference cell amplifier.

        %}

        refcellTableScancmd = 'REFCELL:TABLE?';
        setrefceloversamplingcmd = 'REFCELL:OVER';
        getrefceloversamplingcmd = 'REFCELL:OVER?';
        setrefcellowerlimcmd = 'REFCELL:LLM';
        getrefcellowerlimcmd = 'REFCELL:LLM?';
        setrefcelupperlimcmd = 'REFCELL:ULM';
        getrefcelupperlimcmd = 'REFCELL:ULM?';
        setrefcelmodecmd = 'REFCELL:MODE';
        getrefcelmodecmd = 'REFCELL:MODE?';
        setrefcelposcmd = 'REFCELL:NOW';
        getrefcelposcmd = 'REFCELL:NOW?';
        setrefcelgaincodecmd = 'REFCELL:GNC';
        getrefcelgaincodecmd = 'REFCELL:GNC?';
        getrefcelampgaincmd = 'REFCELL:GAIN?';

        %{
        Slow Piezo Control

            SLOWPIEZO:LOCKPROPORTIONAL
            Set the proportional gain of the slow piezo (cavity scan piezo) control loop. This value is used when the control
            loop detects that the laser is locked to the reference cell.

            SLOWPIEZO:LOCKPROPORTIONAL?
            Get the proportional gain of the slow piezo (cavity scan piezo) control loop. This value is used when the control
            loop detects the laser is locked to the reference cell.

            SLOWPIEZO:LOCKLINTEGRAL
            Set the integral gain of the slow piezo (cavity scan piezo) control loop. This value is used when the control loop
            detects that the laser is locked to the reference cell.

            SLOWPIEZO:LOCKLINTEGRAL?
            Get the integral gain of the slow piezo (cavity scan piezo) control loop.

            SLOWPIEZO:FREESPEED
            Set the speed of the slow piezo (cavity scan piezo) control loop. This value is used when the control loop detects
            that the laser is not locked to the reference cell.

            SLOWPIEZO:FREESPEED?
            Get the speed of the slow piezo (cavity scan piezo) control loop. This value is used when the control loop detects
            the laser is not locked to the reference cell.

            SLOWPIEZO:CONTROLSETPOINT
            Set the control goal of the slow piezo (cavity scan piezo) control loop.

            SLOWPIEZO:CONTROLSETPOINT?
            Get the control goal of the slow piezo (cavity scan piezo) control loop.

            SLOWPIEZO:CONTROLSTATUS
            Start or stop the PID loop that controls the slow piezo (cavity scan piezo). The slow piezo control will only be
            active when the fast piezo control is running at the same time. If the slow cavity piezo is already used by another
            command e.g. the SCAN command, an error message is returned.

            SLOWPIEZO:CONTROLSTATUS?
            Get the status of the PID loop that controls the slow piezo (cavity scan piezo).

            SLOWPIEZO:NOW
            Set the position of the slow piezo (cavity scan piezo).

            SLOWPIEZO:NOW?
            Get the current position of the slow piezo (cavity scan piezo).

            SLOWPIEZO:REFERENCESCAN
            Set the proportional factor that controls how a scan of the reference cell piezo influences the position of the slow
            piezo. The factor results in an immediate piezo movement, even without the PID loop enabled. On the other hand,
            a value of 0 for this parameter corresponds to a control loop only operation of the piezo etalon. If a reference cell
            piezo amplifier with variable gain is installed, this value will be changed according to the selcted gain.

            SLOWPIEZO:REFERENCESCAN?
            Get the proportional factor that controls how a scan of the reference cell piezo influences the position of the slow
            piezo. 

        %}

        setspztpgaincmd = 'SPZT:LPROP';
        getspztpgaincmd = 'SPZT:LPROP?';
        setspztigaincmd = 'SPZT:LINT';
        getspztigaincmd = 'SPZT:LINT?';
        setspztfspdcmd = 'SPZT:FRSP';
        getspztfspdcmd = 'SPZT:FRSP?';
        setspztctrlspcmd = 'SPZT:CNTRSP';
        getspztctrlspcmd = 'SPZT:CNTRSP?';
        setspztctrlstatcmd = 'SPZT:CNTRSTA';
        getspztctrlstatcmd = 'SPZT:CNTRSTA?';
        setspztposcmd = 'SPZT:NOW';
        getspztposcmd = 'SPZT:NOW?';
        setspztrefscancmd = 'SPZT:REFSCN';
        getspztrefscancmd = 'SPZT:REFSCN?';

        %{
        Misc
            IDENTIFICATION?
            Return the identification string of the device. The identification string consists of the following components:
            model name, serial number, board version, firmware version, and version date.

            UPDATE:RESET
            Reset the update procedure. Clear the internal software image.

            UPDATE:DATA
            Read a data line for the firmware update. The data consists of a stream of 16-bit words in ASCII-Hex format.
            Each of the byte is stored at successive address locations in a buffer memory. The data is not written to the actual
            program memory until the command UPDATE:EXECUTE is performed.
        
            UPDATE:EXECUTE
            Load the firmware update into the flash memory. A cold start of the system is required to ensure proper operation
            of the device.

            UPDATE:CHECKSUM?
            Read the checksum of the firmware update loaded into memory. The checksum is calculated using a 32-bit
            unsigned integer accumulator. Please note that the checksum is returned in decimal notation.

            RESET
            Initiate a restart of the entire controller unit. Note, that the USB connection will be lost during that process.

        %}
        idcmd = 'IDN?';
        upresetcmd = 'UPD:RESET';
        updatcmd = 'UPD:DATA';
        upexecmd = 'UPD:EXE';
        upchksumcmd = 'UPD:CHS?';
        resetcmd = 'RESET';
    end
    %% Methods
    methods % Lifecycle functions
        % Lifecycle functions
        function this=LaserControl(nid)
            
            switch nid
                case 'CRLaserID'
                    this.deviceID = this.CRLaserID;
                case 'CSLaserID'
                    this.deviceID = this.CSLaserID;
                otherwise
                    this.deviceID = nid;
            end
            
            this.vi = visa('ni', this.deviceID);
            this.vi.InputBufferSize = 100;
            this.vi.Timeout = 1000;
            this.vi.ByteOrder = 'littleEndian';
            
        end
            
        % Connect to the VISA object specified in deviceID
        function connect(this)
            fopen(this.vi);
        end
        
		% Disconnect from the VISA object
        function disconnect(this)
            fclose(this.vi);
        end
        
		% Send a string to the VISA object
        function send(this, data)
            fprintf(this.vi, [data '\n']);
        end
        
        % Communication functions
        function ret=read(this)
            ret=fgetl(this.vi);
        end
        
		% Send a query to the VISA object and return the result
        function ret=query(this, query)
            this.send(query);
            ret=this.read();
        end
        
        % Queries for Errors 
        function ret=getErrors(this)
           ret=this.query(this.geterrcdcmd);
        end
        
        % Clear all errors
        function clearErrors(this)
            this.send(this.errclrcmd);
        end
    end
    
    methods % Action Handlers
        
        function setPIDLoopProtID(this, pidprot)
            this.send([this.setPIDprotcmd ' ' num2str(pidprot)]);
        end
        
        function pidprot=getPIDLoopProtID(this)
            pidprot = deblank(extractAfter(this.query(this.getPIDprotcmd), ' '));
        end
        
        function pidprocstat=getPIDProcStatistics(this)
            pidprocstat = deblank(extractAfter(this.query(this.getPIDprocstatcmd), ' '));
        end
        
        function pidordnum=getPIDOrdinalNumber(this)
            pidordnum = deblank(extractAfter(this.query(this.getPIDordinalcmd), ' '));
        end
        
        function diodedc=getIntegralPowerDC(this)
            diodedc = deblank(extractAfter(this.query(this.getpddccmd), ' '));
        end
        
        function diodeac=getIntegralPowerACWaveform(this)
            diodeac = deblank(extractAfter(this.query(this.getacwvcmd), ' '));
        end
        
        function setIntegralPowerLowLevel(this, diodelow)
            this.send([this.setpdlowcmd ' ' num2str(diodelow)]);
        end
        
        function diodelow=getIntegralPowerLowLevel(this)
            diodelow = deblank(extractAfter(this.query(this.getpdlowcmd), ' '));
        end
        
        function setBiRefMotorPosition(this, pos)
            this.send([this.setmotbiposcmd ' ' num2str(pos)]);
        end
        
        function pos=getBiRefMotorPosition(this)
            pos = deblank(extractAfter(this.query(this.getmotbiposcmd), ' '));
        end
        
        function stat=getBiRefMotorStatus(this)
            stat = deblank(extractAfter(this.query(this.getmotbistatcmd), ' '));
        end
        
        function maxpos=getBiRefMotorMaxPosition(this)
            maxpos = deblank(extractAfter(this.query(this.getmotbimaxposcmd), ' '));
        end
        
        function setBiRefMotorRelativePosition(this, rpos)
            this.send([this.setmotbirelposcmd ' ' num2str(rpos)]);
        end
        
        function setBiRefMotorHome(this)
            this.send(this.setmotbihomecmd);
        end
        
        function clearBiRefMotorErrors(this)
            this.send(this.motbiclrcmd);
        end
        
        function setBiRefMotorIncrement(this, incr)
            this.send([this.setmotbiincrcmd ' ' num2str(incr)]);
        end
        
        function incr=getBiRefMotorIncrement(this)
            incr = deblank(extractAfter(this.query(this.getmotbiincrcmd), ' '));
        end
        
        function setBiRefMotorConsAbsPosition(this, capos)
            this.send([this.setmotbicabscmd ' ' num2str(capos)]);
        end
        
        function setBiRefMotorConsRelPosition(this, crpos)
            this.send([this.setmotbicrcmd ' ' num2str(crpos)]);
        end
        
        function setBiRefMotorFrequency(this, f)
            this.send([this.setmotbifreqcmd ' ' num2str(f)]);
        end
        
        function f=getBiRefMotorFrequency(this)
            f = deblank(extractAfter(this.query(this.getmotbifreqcmd), ' '));
        end
        
        function setBiRefMotorWavelengthPosition(this, wpos)
            this.send([this.setmotbiwposcmd ' ' num2str(wpos)]);
        end
        
        function wpos=getBiRefMotorWavelengthPosition(this)
            wpos = deblank(extractAfter(this.query(this.getmotbiwposcmd), ' '));
        end
        
        function setBiRefMotorPropToCavityScan(this, pf)
            this.send([this.setmotbicscmd ' ' num2str(pf)]);
        end
        
        function pf=getBiRefMotorPropToCavityScan(this)
            pf = deblank(extractAfter(this.query(this.getmotbicscmd), ' '));
        end
        
        function setBiRefMotorPropToRefScan(this, pf)
            this.send([this.setmotbirefscancmd ' ' num2str(pf)]);
        end
        
        function pf=getBiRefMotorPropToRefScan(this)
            pf = deblank(extractAfter(this.query(this.getmotbirefscancmd), ' '));
        end
        
        function setBiRefMotorOffset(this, moff)
            this.send([this.setmotbimotoroffsetcmd ' ' num2str(moff)]);
        end
        
        function moff=getBiRefMotorOffset(this)
            moff = deblank(extractAfter(this.query(this.getmotbimotoroffsetcmd), ' '));
        end
        
        function setBiRefMotorFactor(this, mfac)
            this.send([this.setmotbimotorfactorcmd ' ' num2str(mfac)]);
        end
        
        function mfac=getBiRefMotorFactor(this)
            mfac = deblank(extractAfter(this.query(this.getmotbimotorfactorcmd), ' '));
        end
        
        function setBiRefMotorThickness(this, th)
            this.send([this.setmotbithicknesscmd ' ' num2str(th)]);
        end
        
        function th=getBiRefMotorThickness(this)
            th = deblank(extractAfter(this.query(this.getmotbithicknesscmd), ' '));
        end
        
        function setBiRefMotorOrder(this, o)
            this.send([this.setmotbiordercmd ' ' num2str(o)]);
        end
        
        function o=getBiRefMotorOrder(this)
            o = deblank(extractAfter(this.query(this.getmotbiordercmd), ' '));
        end
        
        function setThinEtalonMotorPosition(this, pos)
            this.send([this.setteposcmd ' ' num2str(pos)]);
        end
        
        function pos=getThinEtalonMotorPosition(this)
            pos = deblank(extractAfter(this.query(this.getteposcmd), ' '));
        end
        
        function mstat=getThinEtalonMotorStatus(this)
            mstat = deblank(extractAfter(this.query(this.gettestatcmd), ' '));
        end
        
        function maxpos=getThinEtalonMotorMaxPosition(this)
            maxpos = deblank(extractAfter(this.query(this.gettemaxposcmd), ' '));
        end
        
        function setThinEtalonMotorHome(this)
            this.send(this.settehomecmd);
        end
        
        function stopThinEtalonMotor(this)
            this.send(this.testopcmd);
        end
        
        function clearThinEtalonMotorErrors(this)
            this.send(this.teclrcmd);
        end
        
        function setThinEtalonMotorIncrement(this, inc)
            this.send([this.setteinccmd ' ' num2str(inc)]);
        end
        
        function inc=getThinEtalonMotorIncrement(this)
            inc = deblank(extractAfter(this.query(this.getteinccmd), ' '));
        end
        
        function setPiezoEtalonOversampling(this, p)
            this.send([this.setpeovscmd ' ' num2str(p)]);
        end
        
        function ovs=getPiezoEtalonOversampling(this)
            ovs = deblank(extractAfter(this.query(this.getpeovscmd), ' '));
        end
        
        function setPiezoEtalonBaseline(this, bsl)
            this.send([this.setpebslcmd ' ' num2str(bsl)]);
        end
        
        function bsl=getPiezoEtalonBaseline(this)
            bsl = deblank(extractAfter(this.query(this.getpebslcmd), ' '));
        end
        
        function setPiezoEtalonAmplitude(this, amp)
            this.send([this.setpeampcmd ' ' num2str(amp)]);
        end
        
        function amp=getPiezoEtalonAmplitude(this)
            amp = deblank(extractAfter(this.query(this.getpeampcmd), ' '));
        end
        
        function setPiezoEtalonControlStatus(this, ctrlstat)
            this.send([this.setpectrlstatcmd ' ' ctrlstat]);
        end
        
        function ctrlstat=getPiezoEtalonControlStatus(this)
            ctrlstat = deblank(extractAfter(this.query(this.getpectrlstatcmd), ' '));
        end
        
        function setPiezoEtalonPGain(this, p)
            this.send([this.setpepgaincmd ' ' num2str(p)]);
        end
        
        function p=getPiezoEtalonPGain(this)
            p = deblank(extractAfter(this.query(this.getpepgaincmd), ' '));
        end
        
        function setPiezoEtalonControlAveraging(this, ctrlavg)
            this.send([this.setpecavgcmd ' ' num2str(ctrlavg)]);
        end
        
        function ctrlavg=getPiezoEtalonControlAveraging(this)
            ctrlavg = deblank(extractAfter(this.query(this.getpecavgcmd), ' '));
        end
        
        function setPiezoEtalonPhaseShift(this, ps)
            this.send([this.setpectrlpscmd ' ' num2str(ps)]);
        end
        
        function ps=getPiezoEtalonPhaseShift(this)
            ps = deblank(extractAfter(this.query(this.getpectrlpscmd), ' '));
        end
        
        function setPiezoEtalonPropToCavityScan(this, pf)
            this.send([this.setpecscmd ' ' num2str(pf)]);
        end
        
        function pf=getPiezoEtalonPropToCavityScan(this)
            pf = deblank(extractAfter(this.query(this.getpecscmd), ' '));
        end
        
        function setPiezoEtalonPropToRefScan(this, pf)
            this.send([this.setperefscancmd ' ' num2str(pf)]);
        end
        
        function pf=getPiezoEtalonPropToRefScan(this)
            pf = deblank(extractAfter(this.query(this.getperefscancmd), ' '));
        end
        
        function setPiezoEtalonSampleRate(this, sr)
            this.send([this.setpesrcmd ' ' num2str(sr)]);
        end
        
        function sr=getPiezoEtalonSampleRate(this)
            sr = deblank(extractAfter(this.query(this.getpesrcmd), ' '));
        end
        
        function setPiezoEtalonFFAmplitude(this, amp)
            this.send([this.setpeffacmd ' ' num2str(amp)]);
        end
        
        function amp=getPiezoEtalonFFAmplitude(this)
            amp = deblank(extractAfter(this.query(this.getpeffacmd), ' '));
        end
        
        function setPiezoEtalonFFPhaseShift(this, ps)
            this.send([this.setpeffpscmd ' ' num2str(ps)]);
        end
        
        function ps=getPiezoEtalonFFPhaseShift(this)
            ps = deblank(extractAfter(this.query(this.getpeffpscmd), ' '));
        end
        
        function dcval=getThinEtalonReflexDCValue(this)
            dcval = deblank(extractAfter(this.query(this.gettepddccmd), ' '));
        end
        
        function setThinEtalonControlStatus(this, ctrlstat)
            this.send([this.settectrlstatcmd ' ' ctrlstat]);
        end
        
        function ctrlstat=getThinEtalonControlStatus(this)
            ctrlstat = deblank(extractAfter(this.query(this.gettectrlstatcmd), ' '));
        end
        
        function setThinEtalonPGain(this, p)
            this.send([this.settepgaincmd ' ' num2str(p)]);
        end
        
        function p=getThinEtalonPGain(this)
            p = deblank(extractAfter(this.query(this.gettepgaincmd), ' '));
        end
        
        function ctrlerr=getThinEtalonControlError(this)
            ctrlerr = deblank(extractAfter(this.query(this.gettecerrcmd), ' '));
        end
        
        function setThinEtalonControlAveraging(this, ctrlavg)
            this.send([this.settectrlavgcmd ' ' num2str(ctrlavg)]);
        end
        
        function ctrlavg=getThinEtalonControlAveraging(this)
            ctrlavg = deblank(extractAfter(this.query(this.gettectrlavgcmd), ' '));
        end
        
        function setThinEtalonControlSetPoint(this, ctrlsp)
            this.send([this.settectrlspcmd ' ' num2str(ctrlsp)]);
        end
        
        function ctrlsp=getThinEtalonControlSetPoint(this)
            ctrlsp = deblank(extractAfter(this.query(this.gettectrlspcmd), ' '));
        end
        
        function setThinEtalonIGain(this, i)
            this.send([this.settecintcmd ' ' num2str(i)]);
        end
        
        function igain=getThinEtalonIGain(this)
            igain = deblank(extractAfter(this.query(this.gettecintcmd), ' '));
        end
        
        function setThinEtalonPropToCavityScan(this, pf)
            this.send([this.settecavscmd ' ' num2str(pf)]);
        end
        
        function pf=getThinEtalonPropToCavityScan(this)
            pf = deblank(extractAfter(this.query(this.gettecavscmd), ' '));
        end
        
        function setThinEtalonPropToRefScan(this, pf)
            this.send([this.setterefscancmd ' ' num2str(pf)]);
        end
        
        function pf=getThinEtalonPropToRefScan(this)
            pf = deblank(extractAfter(this.query(this.getterefscancmd), ' '));
        end
        
        function setScanStatus(this, scanstat)
            this.send([this.setscanstatcmd ' ' scanstat]);
            if ~strcmp(this.getScanStatus(), scanstat)
                this.disconnect();
                error("Could not change Scan status. Check and try again!");
            end
        end
        
        function scanstat=getScanStatus(this)
            scanstat = deblank(extractAfter(this.query(this.getscanstatcmd), ' '));
        end
        
        function setScanLowerLimit(this, lowerlim)
            this.send([this.setscanlowerlimcmd ' ' num2str(lowerlim)]);
        end
        
        function lowerlim=getScanLowerLimit(this)
            lowerlim = deblank(extractAfter(this.query(this.getscanlowerlimcmd), ' '));
        end
        
        function setScanUpperLimit(this, upperlim)
            this.send([this.setscanupperlimcmd ' ' num2str(upperlim)]);
        end
        
        function lowerlim=getScanUpperLimit(this)
            lowerlim = deblank(extractAfter(this.query(this.getscanupperlimcmd), ' '));
        end
        
        function setScanPosition(this, pos)
            this.send([this.setscanposcmd ' ' num2str(pos)]);
        end
        
        function pos=getScanPosition(this)
            pos = deblank(extractAfter(this.query(this.getscanposcmd), ' '));
        end
        
        function setScanMode(this, mode)
            this.send([this.setscanmodecmd ' ' num2str(mode)]);
        end
        
        function mode=getScanMode(this)
            mode = deblank(extractAfter(this.query(this.getscanmodecmd), ' '));
        end
        
        function setScanDevice(this, dev)
            this.send([this.setscandevcmd ' ' num2str(dev)]);
            if ~strcmp(this.getScanDevice(), num2str(dev))
                this.disconnect();
                error("Could not change Scan device. Check and try again!");
            end
        end
        
        function dev=getScanDevice(this)
            dev = deblank(extractAfter(this.query(this.getscandevcmd), ' '));
        end
        
        function setScanRisingSpeed(this, rspd)
            this.send([this.setscanrscmd ' ' num2str(rspd)]);
        end
        
        function rspd=getScanRisingSpeed(this)
            rspd = deblank(extractAfter(this.query(this.getscanrscmd), ' '));
        end
        
        function setScanFallingSpeed(this, fspd)
            this.send([this.setscanfscmd ' ' num2str(fspd)]);
        end
        
        function fspd=getScanFallingSpeed(this)
            fspd = deblank(extractAfter(this.query(this.getscanfscmd), ' '));
        end
        
        function setScanReferenceCalibration(this, rcal)
            this.send([this.setscanrefcalcmd ' ' num2str(rcal)]);
        end
        
        function rcal=getScanReferenceCalibration(this)
            rcal = deblank(extractAfter(this.query(this.getscanrefcalcmd), ' '));
        end
        
        function setScanCavityCalibration(this, ccal)
            this.send([this.setscancavcalcmd ' ' num2str(ccal)]);
        end
        
        function ccal=getScanCavityCalibration(this)
            ccal = deblank(extractAfter(this.query(this.getscancavcalcmd), ' '));
        end
        
        function lockstat=getFastPiezoLockStatus(this)
            lockstat = deblank(extractAfter(this.query(this.getfzptlockstatcmd), ' '));
        end
        
        function setFastPiezoControlSetPoint(this, sp)
            this.send([this.setfzptcspcmd ' ' num2str(sp)]);
        end
        
        function sp=getFastPiezoControlSetPoint(this)
            sp = deblank(extractAfter(this.query(this.getfzptcspcmd), ' '));
        end
        
        function setFastPiezoControlStatus(this, ctrlstat)
            this.send([this.setfzptctrlstatcmd ' ' num2str(ctrlstat)]);
        end
        
        function  ctrlstat=getFastPiezoControlStatus(this)
             ctrlstat = deblank(extractAfter(this.query(this.getfzptctrlstatcmd), ' '));
        end
        
        function  diodeval=getFastPiezoToRefCellInputPower(this)
             diodeval = deblank(extractAfter(this.query(this.getfzptdiodecmd), ' '));
        end
        
        function setFastPiezoIGain(this, i)
            this.send([this.setfzptctrlintcmd ' ' num2str(i)]);
        end
        
        function  igain=getFastPiezoIGain(this)
             igain = deblank(extractAfter(this.query(this.getfzptctrlintcmd), ' '));
        end
        
        function setFastPiezoLockPoint(this, lp)
            this.send([this.setfzptlockptcmd ' ' num2str(lp)]);
        end
        
        function  lp=getFastPiezoLockPoint(this)
             lp = deblank(extractAfter(this.query(this.getfzptlockptcmd), ' '));
        end
        
        function setFastPiezoPosition(this, pos)
            this.send([this.setfzptposcmd ' ' num2str(pos)]);
        end
        
        function  pos=getFastPiezoPosition(this)
             pos = deblank(extractAfter(this.query(this.getfzptposcmd), ' '));
        end
        
        function ReferenceCellPiezoTableScan(this)
            this.send(this.refcellTableScancmd);
        end
        
        function setReferenceCellPiezoOversampling(this, over)
            this.send([this.setrefceloversamplingcmd ' ' num2str(over)]);
        end
        
        function over=getReferenceCellPiezoOversampling(this)
            over = deblank(extractAfter(this.query(this.getrefceloversamplingcmd), ' '));
        end
        
        function setReferenceCellPiezoLowerLimit(this, lowerlim)
            this.send([this.setrefcellowerlimcmd ' ' num2str(lowerlim)]);
        end
        
        function lowerlim=getReferenceCellPiezoLowerLimit(this)
            lowerlim = deblank(extractAfter(this.query(this.getrefcellowerlimcmd), ' '));
        end
        
        function setReferenceCellPiezoUpperLimit(this, upperlim)
            this.send([this.setrefcelupperlimcmd ' ' num2str(upperlim)]);
        end
        
        function upperlim=getReferenceCellPiezoUpperLimit(this)
            upperlim = deblank(extractAfter(this.query(this.getrefcelupperlimcmd), ' '));
        end
        
        function setReferenceCellPiezoMode(this, mode)
            this.send([this.setrefcelmodecmd ' ' num2str(mode)]);
        end
        
        function mode=getReferenceCellPiezoMode(this)
            mode = deblank(extractAfter(this.query(this.getrefcelmodecmd), ' '));
        end
        
        function setReferenceCellPiezoPosition(this, pos)
            this.send([this.setrefcelposcmd ' ' num2str(pos)]);
        end
        
        function pos=getReferenceCellPiezoPosition(this)
            pos = deblank(extractAfter(this.query(this.getrefcelposcmd), ' '));
        end
        
        function setReferenceCellGainCode(this, gc)
            this.send([this.setrefcelgaincodecmd ' ' num2str(gc)]);
        end
        
        function gc=getReferenceCellGainCode(this)
            gc = deblank(extractAfter(this.query(this.getrefcelgaincodecmd), ' '));
        end
        
        function ampg=getReferenceCellAmplifierGain(this)
            ampg = deblank(extractAfter(this.query(this.getrefcelampgaincmd), ' '));
        end
        
        function setSlowPiezoPgain(this, p)
            this.send([this.setspztpgaincmd ' ' num2str(p)]);
        end
        
        function pgain=getSlowPiezoPgain(this)
            pgain = deblank(extractAfter(this.query(this.getspztpgaincmd), ' '));
        end
        
        function setSlowPiezoIgain(this, i)
            this.send([this.setspztigaincmd ' ' num2str(i)]);
        end
        
        function igain=getSlowPiezoIgain(this)
            igain = deblank(extractAfter(this.query(this.getspztigaincmd), ' '));
        end
        
        function setSlowPiezoFreeSpeed(this, fs)
            this.send([this.setspztfspdcmd ' ' num2str(fs)]);
        end
        
        function fspeed=getSlowPiezoFreeSpeed(this)
            fspeed = deblank(extractAfter(this.query(this.getspztfspdcmd), ' '));
        end
        
        function setSlowPiezoControlSetPoint(this, csp)
            this.send([this.setspztctrlspcmd ' ' num2str(csp)]);
        end
        
        function setpoint=getSlowPiezoControlSetPoint(this)
            setpoint = deblank(extractAfter(this.query(this.getspztctrlspcmd), ' '));
        end
        
        function setSlowPiezoControlStatus(this, cs)
            this.send([this.setspztctrlstatcmd ' ' cs]);
        end
        
        function cstat=getSlowPiezoControlStatus(this)
            cstat = deblank(extractAfter(this.query(this.getspztctrlstatcmd), ' '));
        end
        
        function setSlowPiezoPosition(this, pos)
            this.send([this.setspztposcmd ' ' num2str(pos)]);
        end
        
        function sppos=getSlowPiezoPosition(this)
            sppos = deblank(extractAfter(this.query(this.getspztposcmd), ' '));
        end
        
        function setSlowPiezoPropToRefScan(this, pf)
            this.send([this.setspztrefscancmd ' ' num2str(pf)]);
        end
        
        function pf=getSlowPiezoPropToRefScan(this)
            pf = deblank(extractAfter(this.query(this.getspztrefscancmd), ' '));
        end
        
        function idString=getID(this)
            temp = strsplit(extractAfter(this.query(this.idcmd), ' '), '"');
            idString = temp{2};
        end
        
        function UpdateReset(this)
            this.send(this.upresetcmd);
        end
        
        function setUpdateData(this, data)
            this.send([this.updatcmd ' ' data]);
        end
        
        function UpdateExecute(this)
            this.send(this.upexecmd);
        end
        
        function chksum=getUpdateCheckSum(this)
            chksum = deblank(extractAfter(this.query(this.upchksumcmd), ' '));
        end
        
        function Reset(this)
            this.send(this.resetcmd);
        end
        
    end
end
        