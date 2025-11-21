classdef ThermalDiffusionApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        LeftPanel                 matlab.ui.container.Panel
        HoleDiameterSliderLabel   matlab.ui.control.Label
        HoleDiameterSlider        matlab.ui.control.Slider
        HoleDiameterValue         matlab.ui.control.Label
        SourceTempSliderLabel     matlab.ui.control.Label
        SourceTempSlider          matlab.ui.control.Slider
        SourceTempValue           matlab.ui.control.Label
        SimulateButton            matlab.ui.control.Button
        RightPanel                matlab.ui.container.Panel
        UIAxes                    matlab.ui.control.UIAxes
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 900 600];
            app.UIFigure.Name = 'Thermal Diffusion Simulation';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '3x'};
            app.GridLayout.RowHeight = {'1x'};

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Title = 'Parameters';
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create HoleDiameterSliderLabel
            app.HoleDiameterSliderLabel = uilabel(app.LeftPanel);
            app.HoleDiameterSliderLabel.Position = [20 480 120 22];
            app.HoleDiameterSliderLabel.Text = 'Hole Diameter (m)';

            % Create HoleDiameterSlider
            app.HoleDiameterSlider = uislider(app.LeftPanel);
            app.HoleDiameterSlider.Limits = [0.05 0.4];
            app.HoleDiameterSlider.Value = 0.2;
            app.HoleDiameterSlider.Position = [20 450 180 3];
            app.HoleDiameterSlider.ValueChangedFcn = createCallbackFcn(app, @HoleDiameterSliderValueChanged, true);

            % Create HoleDiameterValue
            app.HoleDiameterValue = uilabel(app.LeftPanel);
            app.HoleDiameterValue.Position = [20 420 180 22];
            app.HoleDiameterValue.Text = sprintf('Value: %.2f m', app.HoleDiameterSlider.Value);

            % Create SourceTempSliderLabel
            app.SourceTempSliderLabel = uilabel(app.LeftPanel);
            app.SourceTempSliderLabel.Position = [20 370 150 22];
            app.SourceTempSliderLabel.Text = 'Source Temperature (°C)';

            % Create SourceTempSlider
            app.SourceTempSlider = uislider(app.LeftPanel);
            app.SourceTempSlider.Limits = [50 500];
            app.SourceTempSlider.Value = 300;
            app.SourceTempSlider.Position = [20 340 180 3];
            app.SourceTempSlider.ValueChangedFcn = createCallbackFcn(app, @SourceTempSliderValueChanged, true);

            % Create SourceTempValue
            app.SourceTempValue = uilabel(app.LeftPanel);
            app.SourceTempValue.Position = [20 310 180 22];
            app.SourceTempValue.Text = sprintf('Value: %.0f °C', app.SourceTempSlider.Value);

            % Create SimulateButton
            app.SimulateButton = uibutton(app.LeftPanel, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateButtonPushed, true);
            app.SimulateButton.Position = [20 250 180 40];
            app.SimulateButton.Text = 'Run Simulation';
            app.SimulateButton.FontSize = 14;
            app.SimulateButton.FontWeight = 'bold';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Title = 'Thermal Distribution';
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'Temperature Distribution')
            xlabel(app.UIAxes, 'X (m)')
            ylabel(app.UIAxes, 'Y (m)')
            app.UIAxes.Position = [10 10 580 540];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ThermalDiffusionApp

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Run initial simulation
            SimulateButtonPushed(app);
        end

        % Value changed function: HoleDiameterSlider
        function HoleDiameterSliderValueChanged(app, event)
            value = app.HoleDiameterSlider.Value;
            app.HoleDiameterValue.Text = sprintf('Value: %.2f m', value);
        end

        % Value changed function: SourceTempSlider
        function SourceTempSliderValueChanged(app, event)
            value = app.SourceTempSlider.Value;
            app.SourceTempValue.Text = sprintf('Value: %.0f °C', value);
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            % Get parameters
            holeDiameter = app.HoleDiameterSlider.Value;
            sourceTemp = app.SourceTempSlider.Value;
            
            % Simulation parameters
            L = 1.0; % Domain size (1m x 1m)
            nx = 100; % Grid points in x
            ny = 100; % Grid points in y
            dx = L / (nx - 1);
            dy = L / (ny - 1);
            
            % Create mesh
            [X, Y] = meshgrid(linspace(0, L, nx), linspace(0, L, ny));
            
            % Initialize temperature field
            T = ones(ny, nx) * 20; % Ambient temperature 20°C
            
            % Create hole mask (hole at center)
            centerX = L / 2;
            centerY = L / 2;
            radius = holeDiameter / 2;
            holeMask = sqrt((X - centerX).^2 + (Y - centerY).^2) < radius;
            
            % Boundary conditions
            T(1, :) = sourceTemp; % Top edge: heat source
            T(end, :) = 20; % Bottom edge: ambient
            T(:, 1) = 20; % Left edge: ambient
            T(:, end) = 20; % Right edge: ambient
            
            % Thermal diffusion simulation (steady-state using iterative solver)
            alpha = 0.5; % Relaxation factor
            tolerance = 0.01;
            maxIterations = 5000;
            
            for iter = 1:maxIterations
                T_old = T;
                
                % Laplacian stencil (5-point)
                for i = 2:ny-1
                    for j = 2:nx-1
                        if ~holeMask(i, j) % Skip hole region
                            T(i, j) = alpha * 0.25 * (T_old(i+1, j) + T_old(i-1, j) + ...
                                                      T_old(i, j+1) + T_old(i, j-1)) + ...
                                      (1 - alpha) * T_old(i, j);
                        end
                    end
                end
                
                % Reapply boundary conditions
                T(1, :) = sourceTemp;
                T(end, :) = 20;
                T(:, 1) = 20;
                T(:, end) = 20;
                
                % Set hole to ambient (hole doesn't conduct)
                T(holeMask) = 20;
                
                % Check convergence
                if max(abs(T(:) - T_old(:))) < tolerance
                    break;
                end
            end
            
            % Visualize results
            cla(app.UIAxes);
            hold(app.UIAxes, 'on');
            
            % Plot temperature distribution
            contourf(app.UIAxes, X, Y, T, 20, 'LineStyle', 'none');
            
            % Draw hole boundary
            theta = linspace(0, 2*pi, 100);
            holeX = centerX + radius * cos(theta);
            holeY = centerY + radius * sin(theta);
            plot(app.UIAxes, holeX, holeY, 'k-', 'LineWidth', 2);
            
            % Formatting
            colormap(app.UIAxes, 'hot');
            c = colorbar(app.UIAxes);
            c.Label.String = 'Temperature (°C)';
            axis(app.UIAxes, 'equal');
            xlim(app.UIAxes, [0 L]);
            ylim(app.UIAxes, [0 L]);
            title(app.UIAxes, sprintf('Temperature Distribution (Hole: %.2fm, Source: %.0f°C)', ...
                                      holeDiameter, sourceTemp));
            xlabel(app.UIAxes, 'X (m)');
            ylabel(app.UIAxes, 'Y (m)');
            hold(app.UIAxes, 'off');
        end
    end
end
