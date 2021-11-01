function [T,U] = housestep(T,U,dT,OutsideAirTemp,AreaofWall,AreaofWindow,Inside2InnerWallh,Inside2InnerWindowh,HeatCapacityofAir,HeatCapacityofInteriorWall,HeatCapacityofInteriorWindow,HeatCapacityofOuterWall,HeatCapacityofOuterWindow,Inside2OuterWallr,Inside2OuterWindowr)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%
InsideEnergy = U(1);

InteriorWallEnergy = U(2);
InteriorWindowEnergy = U(3);

OuterWindowEnergy = U(4);
OuterWallEnergy = U(5);


en2inwa = Inside2InnerWallh * AreaofWall * ( (HeatCapacityofInteriorWall*InteriorWallEnergy) - (HeatCapacityofAir*InsideEnergy));
en2inwi = Inside2InnerWindowh * AreaofWindow * ( (HeatCapacityofInteriorWindow*InteriorWindowEnergy) - (HeatCapacityofAir*InsideEnergy));

en2ouwa = AreaofWall / Inside2OuterWallr * ( (HeatCapacityofOuterWall*OuterWallEnergy) - (HeatCapacityofInteriorWall*InteriorWallEnergy));
en2ouwi =  AreaofWindow / Inside2OuterWindowr * ( (HeatCapacityofOuterWindow*OuterWindowEnergy) - (HeatCapacityofInteriorWindow*InteriorWindowEnergy)));

en2owasd = Inside2OuterWallh * AreaofWall * ( (HeatCapacityofOuterWall*OuterWallEnergy) - OutsideAirTemp));
en2owisd = Inside2OuterWindowh * AreaofWindow * ( (HeatCapacityofOuterWindow*OuterWindowEnergy) - OutsideAirTemp);

solarinputenergy = floorabsorptionefficiency * Insolation * AreaofWindow;


dInsideEnergy =         solarinputenergy - en2inwa - en2inwi;
dInteriorWallEnergy =   en2inwa - en2ouwa;
dInteriorWindowEnergy = en2inwi - en2ouwi;
dOuterWindowEnergy =    en2ouwa - en2owasd;
dOuterWallEnergy =      en2ouwi - en2owisd;

U = [dInsideEnergy; dInteriorWallEnergy; dInteriorWindowEnergy; dOuterWindowEnergy; dOuterWallEnergy];
U = U*dT;
end



% TotalHouseArea = 442;% (m2)
% AreaofWindow = 10-400;% (m2) will sweep (start at 10)
% AreaofWall = TotalHouseArea - AreaofWindow;% (m2)
% WallThickness = .1651;% (m)
% ThicknessofWindow = 0.006;% (meters)
% HouseVolume = 743 ;%m3
% InsideInitialTemperature = 298.15;% (K)
% MassofAir = 910.175;% (kg)
% SpecificHeatAir = 1000;% (J/K/kg)
% %AirTemp = InsideEnergy/MassofAir*SpecificHeatAir;%
% InsideInitialEnergy = MassofAir * SpecificHeatAir * InsideInitialTemperature;%
% %InsideEnergy = determined by ode (J)
% InnerWallInitialEnergy = MassofWall/2 * SpecificHeatWall * InsideInitialTemperature
% %InteriorWallEnergy = determined by ode (J)
% InnerWindowInitialEnergy = MassofWindow/2 * SpecificHeatWindow * InsideInitialTemperature
% %InteriorWindowEnergy = determined by ode (J)
% OuterWindowInitialEnergy = MassofWindow/2 * SpecificHeatWindow * OutsideInitialTemperature
% %OuterWindowEnergy = determined by ode (J)
% OuterWallInitialEnergy = MassofWindow/2 * SpecificHeatWall * OutsideInitialTemperature
% %OuterWallEnergy = determined by ode (J)
% 
% %InteriorWallTemp = InteriorWallEnergy/MassofWall*SpecificHeatW%all
% ThicknessofWall = 0.1651;% (meters) we divide the wall by 2 as we consider thewall as two stocks for the inner and outer
% DensityofWall = 22;% (kg/m3) based on density of rockwool TODO NOT REAL NUMBER
% SpecificHeatWall = 700;%(J/K/kg)
% OuterWallTemp = OuterWallEnergy/MassofWall*SpecificHeatWall
% MassofWall = DensityofWall * AreaofWall * ThicknessofWall
% %InteriorWindowTemp = InteriorWindowEnergy/MassofWindow*SpecificHeatWindow;
% MassofWindow = DensityofWindow * AreaofWindow * ThicknessofWindow/2;
% DensityofWindow = 2500;% (kg/m3) based on density of rockwool
% SpecificHeatWindow = 840;% (J/K/kg)
% %OuterWindowTemp = OuterWindowEnergy/MassofWindow*SpecificHeatWindow
% %MassofWindow = DensityofWindow * AreaofWindow * ThicknessofWindow/2
% OutsideInitialTemperature = 288.706;% (K)
% WindowResistance = .63;% (d/k)
% WallResistance = 19.93;% (d/k)
% 
% Inside2InnerWindowh = 13.5;% (W/m2K)



