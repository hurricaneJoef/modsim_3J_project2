function [T_hour, M, cost] = HouseEnergy(AreaofWindow)

TotalHouseArea = 442; %(m^2)

%AreaofWindow = 10; %(m^2) will eventually sweep

AreaofWall = TotalHouseArea - AreaofWindow; %(m^2)

cost = 40.82*AreaofWall + 500*AreaofWindow; %material cost of wall + window

MassofAir = 910.175; %(kg)

SpecificHeatAir = 1000; %(J/(K*kg)) 

MassofWood = 500; % estimate of how much wood is on the inside of the house

WoodSpecificHeat = 2300; %(J/(K*kg))  https://material-properties.org/pine-wood-density-strength-melting-point-thermal-conductivity/

WaterMass = (0.012065^2*pi())*50 * 997; %total water mass inside the radiant floor heating

SpecificHeatWater =  4186;  %(J/K/kg)

insideThermalMass = MassofAir * SpecificHeatAir + WaterMass * SpecificHeatWater + WoodSpecificHeat * MassofWood;% total thermal mass inside the house(air + in floor heating)

DensityofWall = 139;%22; %(kg/m^3)

SpecificHeatWall = 1620;%700; %(J/K/kg)

DensityofWindow = 2500; %(kg/m^3)

SpecificHeatWindow = 840; %(J/K/kg)

ThicknessofWall = .1651; %(m)

ThicknessofWindow = .006; %(m)

InsideInitialTemperature = 298.15; %(K)

OutsideInitialTemperature = 288.706; %(K)

OutsideAirTemp = 288.706; %(K)

WindowResistance = .63; %(d/k)

WallResistance = 19.93; %(d/k)

Inside2InnerWindowh = 13.5; %(W/m^2K)

Inside2InnerWallh = 13.5; %(W/m^2K)

Outer2AirWindowh = 137.5; %(W/m^2K)

Outer2AirWallh = 137.5; %(W/m^2K)

floorabsorptionefficiency = .32; %ratio so no units (directly from the sticker on the windows)

Insolation = 187.5; %(W/m^2)

MassofWall = DensityofWall * AreaofWall * (ThicknessofWall/2); %(kg) accounts for half the wall

MassofWindow = DensityofWindow * AreaofWindow * (ThicknessofWindow/2); %(kg) accounts for half the window

InsideInitialEnergy = InsideInitialTemperature*insideThermalMass; %(J)

InnerWallInitialEnergy = MassofWall * SpecificHeatWall * InsideInitialTemperature; %(J)

InnerWindowInitialEnergy = MassofWindow * SpecificHeatWindow * InsideInitialTemperature; %(J)

OuterWindowInitialEnergy = MassofWindow * SpecificHeatWindow * OutsideInitialTemperature; %(J)

OuterWallInitialEnergy = MassofWall * SpecificHeatWall * OutsideInitialTemperature; %(J)






InitialValues = [InsideInitialEnergy, InnerWallInitialEnergy, InnerWindowInitialEnergy, OuterWindowInitialEnergy, OuterWallInitialEnergy]';

TimeSpan = [0 (24*100*60*60)];

[T_sec, M] = ode45(@rate_func, TimeSpan, InitialValues);

T_hour = (T_sec/60)/60;

M(:,1) = M(:,1) ./ insideThermalMass; %converts our energy to temperature

M(:,2) = M(:,2) ./ (MassofWall * SpecificHeatWall);

M(:,3) = M(:,3) ./ (MassofWindow * SpecificHeatWindow);

M(:,4) = M(:,4) ./ (MassofWindow * SpecificHeatWindow);

M(:,5) = M(:,5) ./ (MassofWall * SpecificHeatWall);





   function res = rate_func(t, U)
       
       InsideAirEnergy = U(1);
       
       InteriorWallEnergy = U(2);
       
       InteriorWindowEnergy = U(3);
       
       OuterWindowEnergy = U(4);
       
       OuterWallEnergy = U(5);
       
       Insolation = max(0,.23*(-361*cos(pi*t/(12*3600)) + 224*cos(pi*t/(6*3600)) + 210)); %q in W/m^2, t in seconds
    
       AirTemp = InsideAirEnergy / insideThermalMass; %updates temperature of Inside Air based on Energy
       
       InteriorWallTemp = InteriorWallEnergy / (MassofWall * SpecificHeatWall); %updates temperature of inner wall
       
       InteriorWindowTemp = InteriorWindowEnergy / (MassofWindow * SpecificHeatWindow); %updates temperature of inner Window
       
       OuterWindowTemp = OuterWindowEnergy / (MassofWindow * SpecificHeatWindow); %updates temperature of outer window
       
       OuterWallTemp = OuterWallEnergy / (MassofWall * SpecificHeatWall); %updates the temperature of outer wall
       
              

       
       
       Solar = floorabsorptionefficiency * Insolation * AreaofWindow; %Solar Energy coming in
       
       ConvInside2InnerWindow = Inside2InnerWindowh * AreaofWindow * (AirTemp - InteriorWindowTemp); %convection from inside air to inner window
       
       ConvInside2InnerWall = Inside2InnerWallh * AreaofWall * (AirTemp - InteriorWallTemp); %convection from inside air to inside wall
       
       ConvOuterWindow2Air = Outer2AirWindowh * AreaofWindow * (OutsideAirTemp - OuterWindowTemp); %convection from outside window to outside air
       
       ConvOuterWall2Air = Outer2AirWallh * AreaofWall * (OutsideAirTemp - OuterWallTemp); %convection from outside wall to outside air
       
       CondInner2OuterWall = - (1/WallResistance) * AreaofWall * (InteriorWallTemp - OuterWallTemp); %Conduction through the wall
       
       CondInner2OuterWindow = - (1/WindowResistance) * AreaofWindow * (InteriorWindowTemp - OuterWindowTemp); %Conduction through the Window
       
       
        InsideAirWatts = Solar +  -ConvInside2InnerWindow + -ConvInside2InnerWall; %net flow of the interior of the house
       
       InteriorWallWatts = ConvInside2InnerWall + CondInner2OuterWall;       %net flow of the interior wall of the house
       
       InteriorWindowWatts =  ConvInside2InnerWindow + CondInner2OuterWindow;%net flow of the interior window of the house
       
       OuterWindowWatts =  -(CondInner2OuterWindow) + ConvOuterWindow2Air;%net flow of the exterior window of the house
       
       OuterWallWatts =  -(CondInner2OuterWall) + ConvOuterWall2Air;%net flow of the exterior wall of the house

       
       res = [InsideAirWatts, InteriorWallWatts,InteriorWindowWatts, OuterWindowWatts, OuterWallWatts]';%output it all
       
   end

end

