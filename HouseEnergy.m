function [T_hour,M] = HouseEnergy()

TotalHouseArea = 442; %(m^2)

AreaofWindow = 10; %(m^2) will eventually sweep

AreaofWall = TotalHouseArea - AreaofWindow; %(m^2)

MassofAir = 910.175; %(kg)

SpecificHeatAir = 1000; %(J/K/kg)

InsideInitialEnergy = 271368676.3; %(J)

DensityofWall = 22; %(kg/m^3)

SpecificHeatWall = 700; %(J/K/kg)

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

floorabsorptionefficiency = .7; %ratio so no units

Insolation = 187.5; %(W/m^2)

MassofWall = DensityofWall * AreaofWall * (ThicknessofWall/2); %(kg) accounts for half the wall

MassofWindow = DensityofWindow * AreaofWindow * (ThicknessofWindow/2); %(kg) accounts for half the window

InnerWallInitialEnergy = MassofWall * SpecificHeatWall * InsideInitialTemperature; %(J)

InnerWindowInitialEnergy = MassofWindow * SpecificHeatWindow * InsideInitialTemperature; %(J)

OuterWindowInitialEnergy = MassofWindow * SpecificHeatWindow * OutsideInitialTemperature; %(J)

OuterWallInitialEnergy = MassofWall * SpecificHeatWall * OutsideInitialTemperature; %(J)

InitialValues = [InsideInitialEnergy, InnerWallInitialEnergy, InnerWindowInitialEnergy, OuterWindowInitialEnergy, OuterWallInitialEnergy];

TimeSpan = [0 30*60*60];

[T_sec, M] = ode45(@rate_func, TimeSpan, InitialValues);

T_hour = (T_sec/60)/60;

   function res = rate_func(~, U)
       
       InsideAirEnergy = U(1);
       
       InteriorWallEnergy = U(2);
       
       InteriorWindowEnergy = U(3);
       
       OuterWindowEnergy = U(4);
       
       OuterWallEnergy = U(5);
    
       AirTemp = InsideAirEnergy / (MassofAir * SpecificHeatAir); %updates temperature of Inside Air based on Energy
       
       InteriorWallTemp = InteriorWallEnergy / (MassofWall * SpecificHeatWall); %updates temperature of inner wall
       
       InteriorWindowTemp = InteriorWindowEnergy / (MassofWindow * SpecificHeatWindow); %updates temperature of inner Window
       
       OuterWindowTemp = OuterWindowEnergy / (MassofWindow * SpecificHeatWindow); %updates temperature of outer window
       
       OuterWallTemp = OuterWallEnergy / (MassofWall * SpecificHeatWall); %updates the temperature of outer wall
       
       Solar = floorabsorptionefficiency * Insolation * AreaofWindow; %Solar Energy coming in
       
       ConvInside2InnerWindow = Inside2InnerWindowh * AreaofWindow * (AirTemp - InteriorWindowTemp); %convection from inside air to inner window
       
       ConvInside2InnerWall = Inside2InnerWallh * AreaofWall * (AirTemp - InteriorWallTemp); %convection from inside air to inside wall
       
       ConvOuterWindow2Air = Outer2AirWindowh * AreaofWindow * (OutsideAirTemp - OuterWindowTemp); %convection from outside window to outside air
       
       ConvOuterWall2Air = Outer2AirWallh * AreaofWall * (OutsideAirTemp - OuterWallTemp); %convection from outside wall to outside air
       
       CondInner2OuterWall = - (1/WallResistance) * AreaofWall * (InteriorWallTemp - OutsideWallTemp); %Conduction through the wall
       
       CondInner2OuterWindow = - (1/WindowResistance) * AreaofWindow * (InteriorWindowTemp - OuterWindowTemp); %Conduction through the Window
       
       InsideAirEnergy = InsideInitialEnergy + Solar +  ConvInside2InnerWindow + ConvInside2InnerWall;
       
       InteriorWallEnergy = InnerWallInitialEnergy + -(ConvInside2InnerWall) + CondInner2OuterWall;
       
       InteriorWindowEnergy = InnerWindowInitialEnergy + -(ConvInside2InnerWindow) + CondInner2OuterWindow;
       
       OuterWindowEnergy = OuterWindowInitialEnergy + -(CondInner2OuterWindow) + ConvOuterWindow2Air;
       
       OuterWallEnergy = OuterWallInitialEnergy + -(CondInner2OuterWall) + ConvOuterWall2Air;
       
       res = [InsideAirEnergy];
       
   end

end

