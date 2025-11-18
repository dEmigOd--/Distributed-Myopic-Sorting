classdef PrinterParameters < handle
    %PRINTERPARAMETERS Parameter Bag
    
    properties (Constant)
        % Data type
        INT = 0;
        DOUBLE = 1;
        INT_STR = 2;
        DOUBLE_STR = 3;
    end
    
    properties (Access = private)
        parameterBag;
    end
    
    methods
        function obj = PrinterParameters()
            obj.parameterBag = cell(0);
        end
        
        function [] = AddIntParameter(obj, parameterName, parameterValue)
            obj.parameterBag{size(obj.parameterBag, 1) + 1, 1} = {obj.INT, parameterName, parameterValue};
        end
        
        function [] = AddIntParameterFromString(obj, parameterName, parameterValue)
            obj.parameterBag{size(obj.parameterBag, 1) + 1, 1} = {obj.INT_STR, parameterName, parameterValue};
        end
        
        function [] = AddDoubleParameter(obj, parameterName, parameterValue, parameterSignificantDigits)
            obj.parameterBag{size(obj.parameterBag, 1) + 1, 1} = {obj.DOUBLE, parameterName, parameterValue, parameterSignificantDigits};
        end
        
        function [] = AddDoubleParameterFromString(obj, parameterName, parameterValue)
            obj.parameterBag{size(obj.parameterBag, 1) + 1, 1} = {obj.DOUBLE_STR, parameterName, parameterValue};
        end
        
        function [parameters] = GetParameters(obj)
            parameters = obj.parameterBag;
        end
    end
end

