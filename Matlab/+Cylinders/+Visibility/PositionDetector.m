classdef PositionDetector < handle
    %POSITIONDETECTOR Current implementation of 9 position detector
    
    properties (Constant)
        AvailableSensorReadings = 4;
        PossibleReadingsOfSingleSensor = 2;
    end
    
    properties
        positions;
        sensor_mask;
    end
    
    methods(Access = private, Static)
        function required_readings_are_available = PositionDetectionPossible(sensor_readings)
            required_readings_are_available = ~all(sensor_readings == Cylinders.Visibility.Constants.Unspecified, 'all');
        end
    end
    
    methods
        function obj = PositionDetector(sensor_mask)
            obj.sensor_mask = sensor_mask;
            
            % readings are in that order N E S W, therefore
            unsupported_position = 0;
            % 1 - occupied, 0 - empty
            obj.positions = unsupported_position * ones(obj.PossibleReadingsOfSingleSensor ^ obj.AvailableSensorReadings, 1);
            obj.positions(bin2dec('0000') + 1) = 9;
            obj.positions(bin2dec('0001') + 1) = 6;
            obj.positions(bin2dec('0010') + 1) = 5;
            obj.positions(bin2dec('0011') + 1) = 2;
            obj.positions(bin2dec('0100') + 1) = 8;
            obj.positions(bin2dec('0110') + 1) = 1;
            obj.positions(bin2dec('1000') + 1) = 7;
            obj.positions(bin2dec('1001') + 1) = 3;
            obj.positions(bin2dec('1100') + 1) = 4;
        end
        
        function [position_on_grid] = DetectPosition(this, neighborhood)
            sensor_readings = this.sensor_mask.GetReadings(neighborhood);
            
            if(~Cylinders.Visibility.PositionDetector.PositionDetectionPossible(sensor_readings))
                error('Unable to detect position. Part of the sensor range is obscured');
            end
            
            readings = sensor_readings == Cylinders.Visibility.Constants.Wall;
            position_on_grid = this.positions(this.PossibleReadingsOfSingleSensor .^ ((this.AvailableSensorReadings - 1):-1:0) * readings' + 1);
        end
    end
end

