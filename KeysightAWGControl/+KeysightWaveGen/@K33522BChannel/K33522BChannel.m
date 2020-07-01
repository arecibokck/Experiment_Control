classdef K33522BChannel < handle
    
   properties
       Parent
       ChannelNumber
       Waveform % arbitrary waveform container
       Rescaled % data normalized to [-1,+1]
   end
   
   methods
       function this =  K33522BChannel(Parent, Channel) %Constructor and initialization 
           % - input handling
           this.Parent=Parent;
           this.ChannelNumber = Channel; 
           disp('K33522BChannel object constructed.');
       end 
   end  % - Lifecycle functions 
   methods
        % set the sample rate
        function setSRate(this, rate)
            if ~ischar(rate)
                if rate > 30
                    error('Sample rate larger 30 MHz not supported!')
                end
                rate = num2str(rate);
            end
            this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary:SRATe %s',this.ChannelNumber, rate));
        end
        % set the impedance
        function setImpedance(this, impedance)
            if impedance == 10000
                this.Parent.send(sprintf('OUTP%d:LOAD INF',this.ChannelNumber))
            elseif impedance == 50
                this.Parent.send(sprintf('OUTP%d:LOAD 50',this.ChannelNumber));
            else
                error('Impedance can only be 50 Ohm or 10000 Ohm!')
            end
        end
        % set the Frequency List
        function setFrequencyList(this, list, voltage)
            if(voltage<=1)
               d=sprintf(' %gE+06',list(1));
               d= [d sprintf(', %gE+06',list(2:end))];
               this.Parent.send(sprintf('SOURce%d:FREQ:MODE LIST',this.ChannelNumber)); 
               this.Parent.send(sprintf('SOURce%d:LIST:DWEL %d',this.ChannelNumber,5.43)); 
               this.Parent.send(sprintf(['SOURce%d:LIST:FREQ' d],this.ChannelNumber));
               this.Parent.send(sprintf('TRIG%d:SOUR IMM',this.ChannelNumber));
            else
               error('Voltage is too high, bring it below 1 Volt');
            end
        end
        % set the waveform
        function setWaveformList(this, val)
            if length(val)<8
                error('At least eight data!')
            end
            if length(val) > 1e6
                error('At most one million data!')
            end
            if (min(val) < -10 ) || (max(val) > 10)
                error('Permitted interval [-10,10] V exceeded!')
            end
            this.Waveform = val;
            this.Rescaled = ((val-min(val))./(max(val)-min(val)) - 0.5) * 2;
        end 
   end  % - Set parameters for arbitrary waveforms
   methods
       function ret = getList(this)
            ret = this.Parent.query('SOUR2:LIST:FREQ:POIN?');
        end
   end  % - Get parameters for arbitrary waveforms
   methods
       function upload(this)
            if length(this.data)<2
                error('Need at least two data')
            end
            if(this.ChannelNumber ~= 1 && this.ChannelNumber ~= 2)
                error('this.ChannelNumber must be either Ch 1 or Ch 2');
            end
            
            % transmit the data using SCPI commands
            this.Parent.send(sprintf('SOUR%d:DATA:VOL:CLE', this.ChannelNumber));
            % set to LSB first
            this.Parent.send('FORM:BORD SWAP');
            % upload a binary block in Agilent format, thankfully
            % supported in matlab
            binblockwrite(this.vi, this.rescaled, 'float32', sprintf('SOUR%d:DATA:ARB ARB_1, ', this.ChannelNumber));
            this.Parent.send('*WAI'); % wait for upload to be processed


            this.Parent.send(sprintf('SOUR%d:FUNC:ARB ARB_1', this.ChannelNumber));   %select ARB_1 as current arbitrary waveform
            this.Parent.send(sprintf('SOUR%d:FUNC ARB', this.ChannelNumber)); % set generator to arbitrary waveform
            this.Parent.send(sprintf('SOUR%d:FUNC:ARB:SRAT %.7f', this.ChannelNumber, this.Rate*1e6));
            this.Parent.send(sprintf('SOUR%d:FUNC:ARB:ADV SRAT', this.ChannelNumber));

            % set signal parameters
            if(this.Impedance == 10000)
                this.Parent.send(sprintf('OUTP%d:LOAD INF',this.ChannelNumber));
            else
                this.Parent.send(sprintf('OUTP%d:LOAD 50',this.ChannelNumber));
            end

            this.Parent.send(sprintf('SOUR%d:VOLT %.5f', this.ChannelNumber, max(this.data)-min(this.data)));
            this.Parent.send(sprintf('SOUR%d:VOLT:OFFS %.5f', this.ChannelNumber, 0.5*(max(this.data)+min(this.data))));

            % set triggering
            if this.Burst
                this.Parent.send(sprintf('SOUR%d:BURS:MODE TRIG', this.ChannelNumber));
                this.Parent.send(sprintf('SOUR%d:BURS:NCYC %d', this.ChannelNumber, this.BurstCyc));
                this.Parent.send(sprintf('SOUR%d:BURS:STAT ON', this.ChannelNumber));
                this.Parent.send(sprintf('TRIG%d:SOUR EXT', this.ChannelNumber));
            else
                this.Parent.send(sprintf('SOUR%d:BURS:STAT OFF', this.ChannelNumber));
                this.Parent.send(sprintf('TRIG%d:SOUR IMM', this.ChannelNumber));
            end

            this.Parent.send(sprintf('OUTP%d ON', this.ChannelNumber));
            this.getError();
        end% upload the arbitrary data
       function preview(this)
            if length(this.data)<2
                error('Need at least two data')
            end
            clf;
            t = (1:length(this.data))/this.Rate;
            stem(t, this.data);
            title(sprintf('Preview of data for channel #%d', this.ChannelNumber));
            xlabel('Time [us]');
            ylabel('Voltage [V]');
        end
   end  % - Upload arbitrary waveforms
   methods
       function setFrequency(this, varargin) 
          p = inputParser;
          addRequired(p, 'Child', @isobject);
          addOptional(p, 'frequency', 'DEF', @isnumeric);
          parse(p, this, varargin{:}); 
          frequency = num2str(p.Results.frequency);
          this.Parent.send(sprintf('SOURce%d:FREQuency %s',this.ChannelNumber, frequency)); 
      end      % - set the Frequency
       function setAmplitude(this, varargin)
          p = inputParser;
          addRequired(p, 'Child', @isobject);
          addOptional(p, 'amplitude', 'DEF', @isnumeric);
          addOptional(p, 'high', 'DEF', @isnumeric);
          addOptional(p, 'low', 'DEF', @isnumeric);
          addOptional(p, 'offset', 'DEF', @isnumeric);
          parse(p, this, varargin{:});
          amplitude = num2str(p.Results.amplitude);
          high = num2str(p.Results.high);
          low = num2str(p.Results.low);  
          offset = num2str(p.Results.offset);  
          if ~strcmp(amplitude, 'DEF')
              this.Parent.send(sprintf('SOURce%d:VOLTage %s',this.ChannelNumber, amplitude));   
          elseif ~strcmp(high, 'DEF')
              if strcmp(low, 'DEF')
                  warning('Low set to default');
              end
              this.Parent.send(sprintf('SOURce%d:VOLTage:HIGH %s',this.ChannelNumber, high));     
              this.Parent.send(sprintf('SOURce%d:VOLTage:HIGH %s',this.ChannelNumber, low));     
          elseif ~strcmp(low, 'DEF')
              if strcmp(high, 'DEF')
                  warning('High set to default');
              end
              this.Parent.send(sprintf('SOURce%d:VOLTage:HIGH %d',this.ChannelNumber, high));     
              this.Parent.send(sprintf('SOURce%d:VOLTage:HIGH %d',this.ChannelNumber, low));
          end
          this.Parent.send(sprintf('SOURce%d:VOLTage:OFFSet %s',this.ChannelNumber, offset));   
      end       % - set the Amplitude
   end  % - Set parameters for generic waveforms
   methods
   
   end  % - Get parameters for generic waveforms
   methods
      function applyDCVoltage(this, varargin)
        p = inputParser;
        addRequired(p, 'Child', @isobject);
        addOptional(p, 'offset', 'DEF', @isnumeric);
        parse(p, this, varargin{:});
        offset = num2str(p.Results.offset);
        this.Parent.send(sprintf('SOURce%d:APPLy:DC DEF,DEF,%s', this.ChannelNumber, offset));
      end     % - apply DC offset Voltage
      function applyNoise(this, varargin)
        p = inputParser;
        addRequired(p, 'Child', @isobject);
        addOptional(p, 'frequency', 'DEF', @isnumeric);
        addOptional(p, 'amplitude', 'DEF', @isnumeric);
        addOptional(p, 'offset', 'DEF', @isnumeric);
        parse(p, this, varargin{:});
        frequency = num2str(p.Results.frequency);
        amplitude = num2str(p.Results.amplitude);
        offset = num2str(p.Results.offset);
        this.Parent.send(sprintf('SOURce%d:APPLy:NOISe %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
      end         % - apply Noise
      function applyPRBS(this, varargin)
        p = inputParser;
        addRequired(p, 'Child', @isobject);
        addOptional(p, 'frequency', 'DEF', @isnumeric);
        addOptional(p, 'amplitude', 'DEF', @isnumeric);
        addOptional(p, 'offset', 'DEF', @isnumeric);
        parse(p, this, varargin{:});
        frequency = num2str(p.Results.frequency);
        amplitude = num2str(p.Results.amplitude);
        offset = num2str(p.Results.offset);
        this.Parent.send(sprintf('SOURce%d:APPLy:PRBS %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
      end          % - apply PRBS
      function applyPulse(this, varargin)
        p = inputParser;
        addRequired(p, 'Child', @isobject);
        addOptional(p, 'frequency', 'DEF', @isnumeric);
        addOptional(p, 'amplitude', 'DEF', @isnumeric);
        addOptional(p, 'offset', 'DEF', @isnumeric);
        parse(p, this, varargin{:});
        frequency = num2str(p.Results.frequency);
        amplitude = num2str(p.Results.amplitude);
        offset = num2str(p.Results.offset);
        this.Parent.send(sprintf('SOURce%d:APPLy:PULSe %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
      end         % - apply Pulse
      function applyRamp(this, varargin)
        p = inputParser;
        addRequired(p, 'Child', @isobject);
        addOptional(p, 'frequency', 'DEF', @isnumeric);
        addOptional(p, 'amplitude', 'DEF', @isnumeric);
        addOptional(p, 'offset', 'DEF', @isnumeric);
        parse(p, this, varargin{:});
        frequency = num2str(p.Results.frequency);
        amplitude = num2str(p.Results.amplitude);
        offset = num2str(p.Results.offset);
        this.Parent.send(sprintf('SOURce%d:APPLy:RAMP %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
      end          % - apply Ramp
      function applySineWave(this, varargin)
        p = inputParser;
        addRequired(p, 'Child', @isobject);
        addOptional(p, 'frequency', 'DEF', @isnumeric);
        addOptional(p, 'amplitude', 'DEF', @isnumeric);
        addOptional(p, 'offset', 'DEF', @isnumeric);
        parse(p, this, varargin{:});
        frequency = num2str(p.Results.frequency);
        amplitude = num2str(p.Results.amplitude);
        offset = num2str(p.Results.offset);
        this.Parent.send(sprintf('SOURce%d:APPLy:SINusoid %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
      end      % - apply Sine wave
      function applySquareWave(this, varargin)
        p = inputParser;
        addRequired(p, 'Child', @isobject);
        addOptional(p, 'frequency', 'DEF', @isnumeric);
        addOptional(p, 'amplitude', 'DEF', @isnumeric);
        addOptional(p, 'offset', 'DEF', @isnumeric);
        parse(p, this, varargin{:});
        frequency = num2str(p.Results.frequency);
        amplitude = num2str(p.Results.amplitude);
        offset = num2str(p.Results.offset);
        this.Parent.send(sprintf('SOURce%d:APPLy:SQUare %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
      end    % - apply Square wave
      function applyTriangleWave(this, varargin)
        p = inputParser;
        addRequired(p, 'Child', @isobject);
        addOptional(p, 'frequency', 'DEF', @isnumeric);
        addOptional(p, 'amplitude', 'DEF', @isnumeric);
        addOptional(p, 'offset', 'DEF', @isnumeric);
        parse(p, this, varargin{:});
        frequency = num2str(p.Results.frequency);
        amplitude = num2str(p.Results.amplitude);
        offset = num2str(p.Results.offset);
        this.Parent.send(sprintf('SOURce%d:APPLy:TRIangle %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
      end  % - apply Triangle wave
   end  % - Apply generic functions 
   methods
       function setOutput(this, varargin)
          p = inputParser;
          addRequired(p, 'Child', @isobject);
          addRequired(p, 'state', @ischar);
          parse(p, this, varargin{:}); 
          state = p.Results.state;
          this.Parent.send(sprintf('OUTPut%d %s',this.ChannelNumber, state)); 
       end 
   end  % - Basic
end    