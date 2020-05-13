classdef Calibration
    %Calibration    Class for storing calibration data
    
    properties (SetAccess = private)
        name = '';  % description of x-data: e.g. 'voltage'
        unit = '';  % unit of x-data: e.g. '(V)'
        interpolant = [];
        inverseInterpolant = [];
    end % properties
    
    methods
        function obj = Calibration(f, s, u)
            %Calibration  Default constructur
            %
            %   Input
            %       f    array with calibration data or input filename
            %       s    Name of calibration
            %       u    Unit of calibration
            
            %test input data
            if isnumeric(f)         % load from array
                obj = obj.loadFromArray(f);
            elseif isa(f,'char')    % load from file
                obj = obj.loadFromFile(f);
            else
                error('unknown parameter type'); 
            end
            
            %test calibration name
            assert( isa(s,'char'), ...
                    'unknown parameter type'); 
            assert( isa(u,'char'), ...
                    'unknown parameter type'); 
            
            obj.name = s;
            obj.unit = u;
                
            %plot calibration data and interpolation curve
            %plot(obj);
        end % Calibration
        
        function plot(obj)
            %plot   Plots calibration data
            clf;
            plot(obj.interpolant.GridVectors{1},obj.interpolant.Values,'+b');
            hold on
            xx = linspace(obj.interpolant.GridVectors{1}(1), obj.interpolant.GridVectors{1}(end), length(obj.interpolant.GridVectors{1})*100);    %10-fold oversampling
            xx = [xx(:); obj.interpolant.GridVectors{1}(:)];
            xx = unique(xx);
            xx = sort(xx);
            yy = obj.interpolate(xx);
            plot(xx,yy,'g.-');
            hold off
            legend('datapoints','interpolation');
            title('calibration curve');
            xlabel([obj.name ' (' obj.unit ')']);
            ylabel('voltage (V)');
        end % plot
        
        
        %% methods for loading new data
        
        function obj = loadFromFile(obj, s)
            %loadFromFile  Reads calibration data from file
            %
            %   Input
            %       s  Filename
            assert( isa(s,'char'), ...
                    'string as filename needed');
                        
            tmp = load(s);
            if isempty(tmp)
                error('file empty or non-existent');
            end
            
            obj = obj.loadFromArray(tmp);
        end %loadFromFile
        
        function obj = loadFromArray(obj, a)
            %loadFromArray  Reads calibration data from input array
            %
            %   Input
            %       a  Array containing calibration data with two columns
            if size(a,1)==2
                a = a';
            elseif size(a,2)==2
                %a = a;
            else
                error('wrong size of array');
            end
            
            %sorting
            a = sortrows(a,1);
            
            inverseA = sortrows(a,2);
            
            %check for monotonical values
            if any(diff(a(:,1))<=0) || any(diff(inverseA(:,2))<=0)
               error('monotonically values required'); 
            end
            
            obj.interpolant = griddedInterpolant(a(:,1),a(:,2),'linear','none');
            obj.inverseInterpolant = griddedInterpolant(inverseA(:,2),inverseA(:,1),'linear','none');
        end % loadFromArray
        
        
        %% methods for interpolation
        
        function val = interpolate(obj, x)
            %interpolate    This function converts data from user-defined calibration to voltage
            %
            %   Input
            %       x   Numeric values to be converted to voltages
            if ~isnumeric(x)
                error('value vector/scalar needed');
            end
            
            val = obj.interpolant(x);
            
            if any(isnan(val))
                error('extrapolation required');
            end
        end % interpolate
        
        function val = inverseInterpolate(obj, x)
            %inverseInterpolate   Undos the effect of interpolate: user-calibration value from given voltage
            %
            %   Input
            %       x   Numeric values to be converted to voltages
            if ~isnumeric(x)
                error('value vector/scalar needed');
            end
            
            val = obj.inverseInterpolant(x);
            
            if any(isnan(val))
                error('extrapolation required');
            end
        end % inverseInterpolate

    end % methods
    
end % classdef
