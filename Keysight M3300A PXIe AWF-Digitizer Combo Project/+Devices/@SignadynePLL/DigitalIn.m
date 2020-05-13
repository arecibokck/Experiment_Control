classdef DigitalIn < Pin
    %DigitalIn   Class for digital input pins
    %
    %TODO integration!!!
    
    methods (Hidden)
        function obj = stateVector(obj, x, t)
            if nargin<2
                error('insufficient number of parameters');
            end
            if ~isa(obj,'DigitalIn')
                error('DigitalIn objects needed');
            end
            if ~islogical(x)
                error('need logical input');
            end
            
            if ~isempty(t) && ~isempty(x) && t(1)>0
                t(2:end+1) = t(:);
                t(1) = 0;
                x(2:end+1) = x(:);
            end
            
            obj = stateVector@Pin(obj,x,t);
        end % stateVector
    end % methods
    
    methods
        function obj = DigitalIn(c, x, t)
            obj = obj@Pin(c);
            
            if nargin>2
                obj = obj.stateVector(x,t);
            end
        end %DigitalIn
    end % methods
    
end % classdef

