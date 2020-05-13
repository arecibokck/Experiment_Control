classdef DigitalOut < Pin
    %DigitalOut   Class for digital output pins
    
    methods
        function obj = DigitalOut(c, varargin)
            %DigitalOut   Default constructor
            %
            %   Inputs:
            %         c    Pin name (default constructor)
            %              or existing pin (copy constructor)
            %  userName   (optional) user defined name, set in default
            %              constructor mode
            obj = obj@Pin(c, varargin{:});
        end % DigitalOut
        
        function val = eq(obj1, obj2)
            %eq  This function checks whether two pin objects refer to the same pin
            %
            %   Inputs:
            %      obj2  Pin object
            val = eq@Pin(obj1,obj2) && isa(obj2,'DigitalOut');
        end % eq
        
        
        %% methods related to setting states
        
        function obj = horzcat(varargin)
            %horzcat   This function concatenates the time evolution of a given pin
            %
            %    Note:  Time offsets syncronized. Function is NOT commutative!
            %
            %    Inputs
            %      varying number of pin objects to be concatenated
            if nargin<2
               error('insufficient number of parameters'); 
            end
            for k = 1:length(varargin)
                assert( isa(varargin{k},'DigitalOut'), ...
                        'DigitalOut objects needed');
            end
            
            obj = horzcat@Pin(varargin{:});
        end % horzcat
        
        function obj = state(obj, x, varargin)
            %state   Set a new state in time evolution of this pin
            %
            %   Inputs
            %       x            state value or array of states to be added
            %       t(optional)  corresponding time vector with time differences
            %                    to earlier state / time offset
            assert( ~any(~(x==0 | x==1)), ...
                    'need logical input');
                
            assert( isvector(x), 'logical scalar/vector needed');
            obj = state@Pin(obj, x, varargin{:});
        end % state
        
        function obj = pulse(obj, delay, duration)
            %pulse   This function add a pulse to the time evolution after 
            %
            %   Inputs
            %      delay  Time before pulse in s
            %   duration  Duration of puls ein s
            assert( isnumeric(duration) && isscalar(duration) && duration>0, ...
                     'need positive input for pulse duration');
            assert( isnumeric(duration) && isscalar(delay) && delay>0, ...
                     'need positive input for delay');
            obj = obj.state([1 0],[delay duration]);
        end % pulse
        
        function t = getEdges(obj, direction)
            %getEdges   Determines times when edges occur in pin time sequence
            %
            % Inputs
            % direction  'rising', 'Falling', or 'either'
%             assert( validatestring(direction, {'rising', 'falling', 'either'}), ...
%                     'valid edge type required');
            validatestring(direction, {'rising', 'falling', 'either'}) ; 
            switch direction
                case 'rising'
                    idx = diff(obj.values)>eps;
                case 'falling'
                    idx = diff(obj.values)<-eps;
                case 'either'
                    idx = (diff(obj.values)>eps) || (diff(obj.values)<eps);
            end
            
            % add first value
            idx = [0 idx]>0;
            
            t = obj.times(idx);
        end % getEdges
        
        function [y,x] = getLastState(obj)
            %getFirstState   This function returns the first state of the
            %                time evolution
            if isempty(obj.values)
                y = 0;
                x = 0;
                return;
            end
            y = obj.values(end);
%             y = obj.allvalues(:,end);
            x = obj.timeOffset;
            return
        end % getLastState
    end % methods
    
end  %classdef

