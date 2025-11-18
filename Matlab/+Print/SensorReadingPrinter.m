classdef SensorReadingPrinter < Print.VisibilityBasedPrinterBase
    %SENSORREADINGPRINTER Printer to print a standalone Sensor Reading Neighborhood
    
    methods
        function obj = SensorReadingPrinter(visibility)
            obj = obj@Print.VisibilityBasedPrinterBase(visibility);
        end
        
		function [] = PrintSensorReadingFile(this, work_directory, handleable_states, stateId, state, states_in, drop_do_not_care)
            drawing_printer = Print.TabbedPrinter();
			
%% Standalone drawings
			drawing_printer.OpenFile(work_directory, sprintf('State_%d.Readings_%d', stateId, states_in)); 
			this.Print3_Preamble(drawing_printer);
			drawing_printer.PrintEndLine();

			drawing_printer.BeginSection('document', '', '');	
				drawing_printer.PrintEndLine();

				this.Print3_ModelParameters(drawing_printer, -1);
				drawing_printer.PrintEndLine();

				this.Print3_GetNeighborhoodSizesShort(drawing_printer);               
				drawing_printer.PrintEndLine();

				this.Print3_DrawNeighborhoodFunction(drawing_printer);                
				drawing_printer.PrintEndLine();

				this.Print3_CommonDrawingParametersFunction(drawing_printer);
				drawing_printer.PrintEndLine();

				drawing_printer.BeginSection('tikzpicture', '', '');

					[rows, ~] = this.Print2_CalculateSensorFunction(drawing_printer, stateId, state);
					drawing_printer.PrintEndLine();

					this.Print2_WriteOnlyReading(drawing_printer, handleable_states, rows, stateId, states_in, drop_do_not_care);
				drawing_printer.EndSection();
			drawing_printer.EndSection();

			drawing_printer.CloseFile();
		end
    end
end

