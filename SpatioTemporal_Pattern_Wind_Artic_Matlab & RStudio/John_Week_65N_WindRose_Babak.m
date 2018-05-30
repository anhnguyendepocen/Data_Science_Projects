% Combining the Coastline Drawing, Annual SLP drawing and Annual Wind
% Vector Drawing,April 15, by Babak

% Cleaning the screen, clearing all variables and closing all active graphs
clc;
clear all;
close all;

bkid = netcdf.open('SLP_09_65N.nc', 'NC_NOWRITE');

% Latitude
LAT = netcdf.getVar(bkid,0);

% Longitude
LNG = netcdf.getVar(bkid,1);

%  Winds`
ufid = netcdf.open('U_09_65N.nc', 'NC_NOWRITE');

% Getting the number of dimensions, variables, attributes and unlimeted
% dimensions
[ndims,nvars,natts,unlimdimid] = netcdf.inq(ufid);
% Finding the values of asscociated variable

% Get name and the value(length) of first dimension
%Dimension ID=0
% Getting the Dimension Name and and length of Dimension ID=0
[dimname0, dimlen0] = netcdf.inqDim(ufid,0);
% Get name and the value(length) of second dimension
%Dimension ID=1
[dimname1, dimlen1] = netcdf.inqDim(ufid,1);
% Get name and the value(length) of the third dimension
%Dimension ID=2
[dimname2, dimlen2] = netcdf.inqDim(ufid,2);

%Dimension ID=3
[dimname3, dimlen3] = netcdf.inqDim(ufid,2);

% Finding the values(lengths) of asscociated variables
% Getting the variable name, type, associated Dimension ID, number of
% attributes (Associated with the variable ID)

%Variable ID=0 (The Latitudes)

[varname0, xtype0, dimids0, numatts0] = netcdf.inqVar(ufid,0);
% Getting the value of the variable
LAT2 = netcdf.getVar(ufid,0);

%Varible ID=1 (The Longitudes)
[varname1, xtype1, dimids1, numatts1] = netcdf.inqVar(ufid,1);
LNG2 = netcdf.getVar(ufid,1);

%Variable ID=2 (The Times)
[varname2, xtype2, dimids2, numatt2] = netcdf.inqVar(ufid,2);
TIME = netcdf.getVar(ufid,2);

%Variable ID=3 (The Sea-Level Pressures)
[varname3, xtype3, dimids3, numatt3] = netcdf.inqVar(ufid,3);
U = netcdf.getVar(ufid,3);
U=cast(U,'double');
U=0.00999999977648258.*U(:,:,:)+225.449996948242;

% Needs to be double-checked
% U_Jan_1=0.00999999977648258.*U(:,:,1)+225.449996948242;

%Reading in the V field 
% Returns an ID into  vfid as a read-only file
vfid = netcdf.open('V_09_65N.nc', 'NC_NOWRITE');

% Getting the number of dimensions, variables, attributes and unlimeted
% dimensions
[ndims,nvars,natts,unlimdimid] = netcdf.inq(vfid);
% Finding the values of asscociated variable

% Get name and the value(length) of first dimension
%Dimension ID=0
% Getting the Dimension Name and and length of Dimension ID=0
[dimname0, dimlen0] = netcdf.inqDim(vfid,0);
% Get name and the value(length) of second dimension
%Dimension ID=1
[dimname1, dimlen1] = netcdf.inqDim(vfid,1);
% Get name and the value(length) of the third dimension
%Dimension ID=2
[dimname2, dimlen2] = netcdf.inqDim(vfid,2);

%Dimension ID=3
[dimname3, dimlen3] = netcdf.inqDim(vfid,2);

% Finding the values(lengths) of asscociated variables
% Getting the variable name, type, associated Dimension ID, number of
% attributes (Associated with the variable ID)

%Variable ID=0 (The Latitudes)

[varname0, xtype0, dimids0, numatts0] = netcdf.inqVar(vfid,0);
% Getting the value of the variable
LAT2 = netcdf.getVar(vfid,0);

%Varible ID=1 (The Longitudes)
[varname1, xtype1, dimids1, numatts1] = netcdf.inqVar(vfid,1);
LNG2 = netcdf.getVar(vfid,1);

%Variable ID=2 (The Times)
[varname2, xtype2, dimids2, numatt2] = netcdf.inqVar(vfid,2);
TIME = netcdf.getVar(vfid,2);

%Variable ID=3 (The Sea-Level Pressures)
[varname3, xtype3, dimids3, numatt3] = netcdf.inqVar(vfid,3);
V = netcdf.getVar(vfid,3);
V=cast(V,'double');

V=0.00999999977648258.*V(:,:,:)+225.449996948242;


% Drawing the Wind-Rose, by Babak, July 26, 2011
% Updated by Babak, August 14,2012

U_A=U(105,7,:); % 365 Days U component at Point A at Lat=75 and Lon=260
V_A=V(105,7,:); % 365 Days V component at Point A at Lant=75 and Lon=260

U_A= reshape(U_A, 365,1);
V_A= reshape(V_A, 365,1);

Wind_Angle_A=atan2(V_A, U_A).*180/pi;        % Wind Direction
Wind_Speed_A=((U_A).^2+(V_A).^2).^(0.5); % Wind Speed 

D_A=Wind_Angle_A;
V_A=Wind_Speed_A;

% subplot(2,2,1)
figure, 
[HANDLES_A,DATA_A]=wind_rose(D_A,V_A)


U_B=U(95,7,:); % 365 Days U component at Point B at Lat=75 (n=7) and Lon=235 (n=95)
V_B=V(95,7,:); % 365 Days V component at Point B at Lant=75 (n=7)and Lon=235 (n=95)

U_B= reshape(U_B, 365,1);
V_B= reshape(V_B, 365,1);


Wind_Angle_B=atan2(V_B, U_B).*180/pi;        % Wind Direction
Wind_Speed_B=((U_B).^2+(V_B).^2).^(0.5); % Wind Speed 

D_B=Wind_Angle_B;
V_B=Wind_Speed_B;

% subplot(2,2,2)
figure, 
wind_rose(D_B,V_B)

U_C=U(85,7,:); % 365 Days U component at Point B at Lat=75 (n=7) and Lon=210 (n=85)
V_C=V(85,7,:); % 365 Days V component at Point B at Lant=75 (n=7)and Lon=210 (n=85)

U_C= reshape(U_C, 365,1);
V_C= reshape(V_C, 365,1);


Wind_Angle_C=atan2(V_C, U_C).*180/pi;        % Wind Direction
Wind_Speed_C=((U_C).^2+(V_C).^2).^(0.5); % Wind Speed 

D_C=Wind_Angle_C;
V_C=Wind_Speed_C;

% subplot(2,2,3)
figure, 
wind_rose(D_C,V_C)

U_D=U(75,7,:); % 365 Days U component at Point B at Lat=75 (n=7) and Lon=185 (n=75)
V_D=V(75,7,:); % 365 Days V component at Point B at Lat=75 (n=7)and Lon=185 (n=75)

U_D= reshape(U_D, 365,1);
V_D= reshape(V_D, 365,1);


Wind_Angle_D=atan2(V_D, U_D).*180/pi;        % Wind Direction
Wind_Speed_D=((U_D).^2+(V_D).^2).^(0.5); % Wind Speed 

D_D=Wind_Angle_D;
V_D=Wind_Speed_D;

% subplot(2,2,4)
figure, 
wind_rose(D_D,V_D)


%% lat =65N

U_A2=U(105,11,:); % 365 Days U component at Point A at Lat=65 (n=11)and Lon=260 (n=105)
V_A2=V(105,11,:); % 365 Days V component at Point A at Lat=65 (n=11)and Lon=260 (n=105)

U_A2= reshape(U_A2, 365,1);
V_A2= reshape(V_A2, 365,1);

Wind_Angle_A2=atan2(V_A2, U_A2).*180/pi;        % Wind Direction
Wind_Speed_A2=((U_A2).^2+(V_A2).^2).^(0.5); % Wind Speed 

D_A2=Wind_Angle_A2;
V_A2=Wind_Speed_A2;

figure,
[HANDLES_A2,DATA_A2]=wind_rose(D_A2,V_A2)


U_B2=U(95,11,:); % 365 Days U component at Point B at Lat=65 (n=11)and Lon=235 (n=95)
V_B2=V(95,11,:); % 365 Days V component at Point B at Lat=65 (n=11)and Lon=235 (n=95)

U_B2= reshape(U_B2, 365,1);
V_B2= reshape(V_B2, 365,1);

Wind_Angle_B2=atan2(V_B2, U_B2).*180/pi;        % Wind Direction
Wind_Speed_B2=((U_B2).^2+(V_B2).^2).^(0.5); % Wind Speed 

D_B2=Wind_Angle_B2;
V_B2=Wind_Speed_B2;

figure,
[HANDLES_B2,DATA_B2]=wind_rose(D_B2,V_B2)

U_C2=U(85,11,:); % 365 Days U component at Point B at Lat=65 (n=11)and Lon=210 (n=85)
V_C2=V(85,11,:); % 365 Days V component at Point B at Lat=65 (n=11)and Lon=210 (n=85)

U_C2= reshape(U_C2, 365,1);
V_C2= reshape(V_C2, 365,1);

Wind_Angle_C2=atan2(V_C2, U_C2).*180/pi;        % Wind Direction
Wind_Speed_C2=((U_C2).^2+(V_C2).^2).^(0.5); % Wind Speed 

D_C2=Wind_Angle_C2;
V_C2=Wind_Speed_C2;

figure,
[HANDLES_C2,DATA_C2]=wind_rose(D_C2,V_C2)

U_D2=U(75,11,:); % 365 Days U component at Point B at Lat=65 (n=11)and Lon=185 (n=75)
V_D2=V(75,11,:); % 365 Days V component at Point B at Lat=65 (n=11)and Lon=185 (n=75)

U_D2= reshape(U_D2, 365,1);
V_D2= reshape(V_D2, 365,1);

Wind_Angle_D2=atan2(V_D2, U_D2).*180/pi;        % Wind Direction
Wind_Speed_D2=((U_D2).^2+(V_D2).^2).^(0.5); % Wind Speed 

D_D2=Wind_Angle_D2;
V_D2=Wind_Speed_D2;

figure,
[HANDLES_D2,DATA_D2]=wind_rose(D_D2,V_D2)
