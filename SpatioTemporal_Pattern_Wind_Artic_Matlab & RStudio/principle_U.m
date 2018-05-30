clc
clear all
close all

%
[U_1980, txt]= xlsread('PCA_Prep.xlsx','A1:A7920');
[U_1987, txt]= xlsread('PCA_Prep.xlsx','B1:B7920');
[U_1992, txt]= xlsread('PCA_Prep.xlsx','C1:C7920');
[U_2002, txt]= xlsread('PCA_Prep.xlsx','D1:D7920');
[U_2009, txt]= xlsread('PCA_Prep.xlsx','E1:E7920');

U=[U_1980 U_1987 U_1992 U_2002 U_2009];
%Clusterring for 11 Latitudes
% Group of latitude of 90
U_90_1980=U_1980(1:144,1)
U_90_1987=U_1987(1:144,1)
U_90_1992=U_1992(1:144,1)
U_90_2002=U_1980(1:144,1)
U_90_2009=U_2009(1:144,1)
U_90=[U_90_1980 U_90_1987 U_90_1992 U_90_2002 U_90_2009];
[coeff_90,score_90,latent_90,tsquare_90] = princomp(U_90);
cumsum(latent_90)./sum(latent_90)
CS=varycolor(60);
s_90=scatter(score_90(:,1), score_90(:,2))
set(s_90,'LineWidth',3,'MarkerFaceColor',CS(10,:),'MarkerEdgeColor',CS(10,:))
% biplot(coeff_65(:,1:2),'Scores',score_65(:,1:2),'VarLabels',...
%    {'1980' '1987' '1992' '2002' '2009'})
hold all

% % Group of latitude of 67.5
% U_67_5_1980=U_1980(145:288,1)
% U_67_5_1987=U_1987(145:288,1)
% U_67_5_1992=U_1992(145:288,1)
% U_67_5_2002=U_1980(145:288,1)
% U_67_5_2009=U_2009(145:288,1)
% U_67_5=[U_67_5_1980 U_67_5_1987 U_67_5_1992 U_67_5_2002 U_67_5_2009];
% [coeff_67_5,score_67_5,latent_67_5,tsquare_67_5] = princomp(U_67_5);
% cumsum(latent_67_5)./sum(latent_67_5)
% scatter(score_67_5(:,1), score_67_5(:,2),'gx')
% % biplot(coeff_65(:,1:2),'Scores',score_65(:,1:2),'VarLabels',...
% %    {'1980' '1987' '1992' '2002' '2009'})
% hold all

% Group of latitude of 85
U_85_1980=U_1980(289:432,1)
U_85_1987=U_1987(289:432,1)
U_85_1992=U_1992(289:432,1)
U_85_2002=U_1980(289:432,1)
U_85_2009=U_2009(289:432,1)
U_85=[U_85_1980 U_85_1987 U_85_1992 U_85_2002 U_85_2009];
[coeff_85,score_85,latent_85,tsquare_85] = princomp(U_85);
cumsum(latent_85)./sum(latent_85)
s_85=scatter(score_85(:,1), score_85(:,2));
set(s_85,'LineWidth',3,'MarkerFaceColor',CS(20,:),'MarkerEdgeColor',CS(20,:))


% biplot(coeff_65(:,1:2),'Scores',score_65(:,1:2),'VarLabels',...
%    {'1980' '1987' '1992' '2002' '2009'})
hold all

% % Group of latitude of 72.5
% U_72_5_1980=U_1980(433:576,1)
% U_72_5_1987=U_1987(433:576,1)
% U_72_5_1992=U_1992(433:576,1)
% U_72_5_2002=U_1980(433:576,1)
% U_72_5_2009=U_2009(433:576,1)
% U_72_5=[U_72_5_1980 U_72_5_1987 U_72_5_1992 U_72_5_2002 U_72_5_2009];
% [coeff_72_5,score_72_5,latent_72_5,tsquare_72_5] = princomp(U_72_5);
% cumsum(latent_72_5)./sum(latent_72_5)
% scatter(score_72_5(:,1), score_72_5(:,2),'cs')
% % biplot(coeff_65(:,1:2),'Scores',score_65(:,1:2),'VarLabels',...
% %    {'1980' '1987' '1992' '2002' '2009'})
% hold all

% Group of latitude of 80
U_80_1980=U_1980(577:720,1)
U_80_1987=U_1987(577:720,1)
U_80_1992=U_1992(577:720,1)
U_80_2002=U_1980(577:720,1)
U_80_2009=U_2009(577:720,1)
U_80=[U_80_1980 U_80_1987 U_80_1992 U_80_2002 U_80_2009];
[coeff_80,score_80,latent_80,tsquare_80] = princomp(U_80);
cumsum(latent_80)./sum(latent_80)
s_80=scatter(score_80(:,1), score_80(:,2));
set(s_80,'LineWidth',3,'MarkerFaceColor',CS(30,:),'MarkerEdgeColor',CS(30,:))
% biplot(coeff_65(:,1:2),'Scores',score_65(:,1:2),'VarLabels',...
%    {'1980' '1987' '1992' '2002' '2009'})
hold all

% % Group of latitude of 77.5
% U_77_5_1980=U_1980(721:864,1)
% U_77_5_1987=U_1987(721:864,1)
% U_77_5_1992=U_1992(721:864,1)
% U_77_5_2002=U_1980(721:864,1)
% U_77_5_2009=U_2009(721:864,1)
% U_77_5=[U_77_5_1980 U_77_5_1987 U_77_5_1992 U_77_5_2002 U_77_5_2009];
% [coeff_77_5,score_77_5,latent_77_5,tsquare_77_5] = princomp(U_77_5);
% cumsum(latent_77_5)./sum(latent_77_5)
% scatter(score_77_5(:,1), score_77_5(:,2),'yv')
% % biplot(coeff_65(:,1:2),'Scores',score_65(:,1:2),'VarLabels',...
% %    {'1980' '1987' '1992' '2002' '2009'})
% hold all

%  Group of latitude of 75
U_75_1980=U_1980(865:1008,1)
U_75_1987=U_1987(865:1008,1)
U_75_1992=U_1992(865:1008,1)
U_75_2002=U_1980(865:1008,1)
U_75_2009=U_2009(865:1008,1)
U_75=[U_75_1980 U_75_1987 U_75_1992 U_75_2002 U_75_2009];
[coeff_75,score_75,latent_75,tsquare_75] = princomp(U_75);
cumsum(latent_75)./sum(latent_75)
s_75=scatter(score_75(:,1), score_75(:,2));
set(s_75,'LineWidth',3,'MarkerFaceColor',CS(40,:),'MarkerEdgeColor',CS(40,:))
% biplot(coeff_65(:,1:2),'Scores',score_65(:,1:2),'VarLabels',...
%    {'1980' '1987' '1992' '2002' '2009'})
hold all

% %  Group of latitude of 82.5
% U_82_5_1980=U_1980(1009:1152,1)
% U_82_5_1987=U_1987(1009:1152,1)
% U_82_5_1992=U_1992(1009:1152,1)
% U_82_5_2002=U_1980(1009:1152,1)
% U_82_5_2009=U_2009(1009:1152,1)
% U_82_5=[U_82_5_1980 U_82_5_1987 U_82_5_1992 U_82_5_2002 U_82_5_2009];
% [coeff_82_5,score_82_5,latent_82_5,tsquare_82_5] = princomp(U_82_5);
% cumsum(latent_82_5)./sum(latent_82_5)
% scatter(score_82_5(:,1), score_82_5(:,2),'bp')
% % biplot(coeff_65(:,1:2),'Scores',score_65(:,1:2),'VarLabels',...
% %    {'1980' '1987' '1992' '2002' '2009'})
% hold all

%  Group of latitude of 70
U_70_1980=U_1980(1153:1296,1)
U_70_1987=U_1987(1153:1296,1)
U_70_1992=U_1992(1153:1296,1)
U_70_2002=U_1980(1153:1296,1)
U_70_2009=U_2009(1153:1296,1)
U_70=[U_70_1980 U_70_1987 U_70_1992 U_70_2002 U_70_2009];
[coeff_70,score_70,latent_70,tsquare_70] = princomp(U_70);
cumsum(latent_70)./sum(latent_70)
s_70=scatter(score_70(:,1), score_70(:,2));
set(s_70,'LineWidth',3,'MarkerFaceColor',CS(50,:),'MarkerEdgeColor',CS(50,:))
% biplot(coeff_65(:,1:2),'Scores',score_65(:,1:2),'VarLabels',...
%    {'1980' '1987' '1992' '2002' '2009'})
hold all

% %  Group of latitude of 87.5
% U_87_5_1980=U_1980(1297:1440,1)
% U_87_5_1987=U_1987(1297:1440,1)
% U_87_5_1992=U_1992(1297:1440,1)
% U_87_5_2002=U_1980(1297:1440,1)
% U_87_5_2009=U_2009(1297:1440,1)
% U_87_5=[U_87_5_1980 U_87_5_1987 U_87_5_1992 U_87_5_2002 U_87_5_2009];
% [coeff_87_5,score_87_5,latent_87_5,tsquare_87_5] = princomp(U_87_5);
% cumsum(latent_87_5)./sum(latent_87_5)
% scatter(score_87_5(:,1), score_87_5(:,2),'r*')
% % biplot(coeff_65(:,1:2),'Scores',score_65(:,1:2),'VarLabels',...
% %    {'1980' '1987' '1992' '2002' '2009'})
% hold all

% Group of latitude of 65
U_65_1980=U_1980(1441:1584,1)
U_65_1987=U_1987(1441:1584,1)
U_65_1992=U_1992(1441:1584,1)
U_65_2002=U_1980(1441:1584,1)
U_65_2009=U_2009(1441:1584,1)
U_65=[U_65_1980 U_65_1987 U_65_1992 U_65_2002 U_65_2009];
 
[coeff_65,score_65,latent_65,tsquare_65] = princomp(U_65);
cumsum(latent_65)./sum(latent_65)
s_65=scatter(score_65(:,1), score_65(:,2))
set(s_65,'LineWidth',3,'MarkerFaceColor',CS(60,:))

legend('Lat=90N', 'Lat=85N','Lat=80N', 'Lat=75N', 'Lat=70N', 'Lat=65N')
% xlabel('Axis1')
% ylabel('Axis2')
% zlabel('Axis3')
grid on


% Variable of years
%  Coeff_year=[coeff_65, coeff_70 coeff_90];


%

% percent_explained = 100*latent/sum(latent)
% 
% figure,
% bar(percent_explained)
% % bar(percent_explained(1:20,1))
% 
% xlabel('Principal Component')
% ylabel('Variance Explained (%)')
% 
%year=[1980
%       1987
%       1992
%       2002
%       2009];
%   
% figure, 
% plot(year, coeff(:,1),'-r', year, coeff(:,2),'b')
% h= legend('Mode1','Mode2');
% 
% xlabel('year')
% ylabel('Principle Component Coefficient')
% 
% 


%% Plotting the PCA vectors of 1 and 2 versus year
figure, 

Y=[1980
      1987
      1992
      2002
      2009];% years
  

ColorSet=varycolor(600);
% subplot(3,3,1); bar(Year_17_31_1_88502_3, Required_Days_IL_31_1_88502_3,'FaceColor',ColorSet(10,:),'LineWidth',3)
% hleg200=legend('17-31-1-88502-3'); 


% 90
p90_1=plot (Y, coeff_90(:,1),'Color',ColorSet(100,:));
set(p90_1, 'LineWidth',3)


hold on
p90_2=plot (Y, coeff_90(:,2),'^','Color',ColorSet(100,:));
set(p90_2, 'LineWidth',3)

hold on

% 85
p85_1=plot (Y, coeff_85(:,1),'Color',ColorSet(200,:));
set(p85_1, 'LineWidth',3)
hold on
p85_2=plot (Y, coeff_85(:,2),'^','Color',ColorSet(200,:));
set(p85_2, 'LineWidth',3)
hold on

% 80
p80_1=plot (Y, coeff_80(:,1),'Color',ColorSet(300,:));
set(p80_1, 'LineWidth',3)

hold on
p80_2=plot (Y, coeff_80(:,2),'^','Color',ColorSet(300,:));
set(p80_2, 'LineWidth',3)
hold on
% 75
p75_1=plot (Y, coeff_75(:,1),'Color',ColorSet(400,:));
set(p75_1, 'LineWidth',3)
hold on

p75_2=plot (Y, coeff_75(:,2),'^','Color',ColorSet(400,:));
set(p75_2, 'LineWidth',3)
hold on
% 70
p70_1=plot (Y, coeff_70(:,1),'Color',ColorSet(500,:));
set(p70_1, 'LineWidth',3)
hold on

p70_2=plot (Y, coeff_70(:,2),'^','Color',ColorSet(500,:));
set(p70_2, 'LineWidth',3)
hold on

%65
p65_1=plot (Y, coeff_65(:,1),'Color',ColorSet(600,:));
set(p65_1, 'LineWidth',3)
hold on

p65_2=plot (Y, coeff_65(:,2),'^','Color',ColorSet(600,:));
set(p65_2, 'LineWidth',3)

hleg1=legend(' Mode 1 at Lat=90N',  'Mode 2 at Lat=90N', 'Mode 1 at Lat=85N','Mode 2 at Lat=85N','Mode 1 at Lat=80N', 'Mode 2 at Lat=80N', 'Mode 1 at Lat=75N', 'Mode 2 at Lat=75N', 'Mode 1 at Lat=70N', 'Mode 2 at Lat=70N', 'Mode 1 at Lat=65N' ,'Mode 2 at Lat=65N');

xlabel('year')
ylabel('Principle Component Coefficient')

box on
set(gca,'FontSize',18)
xlabel('{\it Year} ','FontSize', 25,'FontName', 'Times New Roman','LineWidth',100)
ylabel('{\it Principle Component Coefficient} ','FontSize', 25,'FontName','Times New Roman','LineWidth',100)
title('{\it Modal Analysis for zonal wind speed} ','FontSize', 25,'FontName','Times New Roman','LineWidth',100)
set(hleg1,  'Location','Best');
set(hleg1,'FontSize', 10,'FontName', 'Times New Roman','LineWidth',3,'FontAngle','italic','TextColor',[.3,.2,.1])

grid minor

% %  PCA vectors over year all latitudes together, 
%  figure, 
% 
%  % PCA vector #1
%  Coeff_year_1=[coeff_90(:,1), coeff_85(:,1) coeff_80(:,1) coeff_75(:,1) coeff_70(:,1) coeff_65(:,1)];
% 
% xlabel('year')
% ylabel('Principle Component Coefficient')
