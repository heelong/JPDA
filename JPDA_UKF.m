% implementing JPDA
clc
clear
close all

%% setting up the models
dt=0.5;
Tvec=0:dt:30;
NT=length(Tvec);

No=2;
f={@(x)processmodel(dt,x),@(x)processmodel(dt,x)};
fn=[4,4];

Ns=1;
h=@(x)measurementmodel(x) ;
senspos=[0,0];
hn=2;

%% Setting JPDA properties
JPDAprops.PD=0.8;
JPDAprops.PG=0.99;
JPDAprops.Gamma=4^2; % 4 sigma
JPDAprops.lambda=1e-5;
JPDAprops.V=1;

%% setting up the filters
xf=cell(NT,No);
Pf=cell(NT,No);
xtruth=cell(NT,No);

xtruth{1,1}=[ 5,10,0.3,-0.8]';
xtruth{1,2}=[ 13,10,-0.2,-0.8]';

xf{1,1}=xtruth{1,1};
xf{1,2}=xtruth{1,2};

xf{1,1}(1)=xf{1,1}(1)-0.5;
xf{1,1}(3)=xf{1,1}(3)-0.05;

xf{1,2}(1)=xf{1,2}(1)+0.5;
xf{1,2}(3)=xf{1,2}(3)+0.05;

P0=diag([0.5,0.5,0.01,0.01]);
Pf{1,1}=P0;
Pf{1,2}=P0;

% R=diag([(1*pi/180)^2]);
R=diag([0.5^2,(1)^2]);
Q={diag([0.01,0.01,0.0001,0.0001]),diag([0.01,0.01,0.0001,0.0001])};

%% getting the truth
for i=1:No
    for k=2:1:NT
        xtruth{k,i}=f{i}(xtruth{k-1,i});
    end
end

Yhist={};

%% running the filters
for k=2:NT
    
    
   [xf,Pf]=propagate_JPDA(xf,Pf,k-1,k,Q,No,f,fn,'ut');
   
   ymset={h(xtruth{k,1})+sqrtm(R)*randn(hn,1),h(xtruth{k,2})+sqrtm(R)*randn(hn,1) };
   Yhist{k}=ymset;
   [xf,Pf]=MeasurementUpdate_JPDA(xf,Pf,ymset,k,R,No,h,hn,JPDAprops,'ut');
   
   figure(1)
   plot_JPDA(xf,Pf,No,xtruth,Yhist,senspos,1,k,{'r','b'},{'ro-','bo-'})
   
%    hold on
%    ymset{1}
%    for pp=2:k
%       plot(ymset{1}(1),ymset{1}(2),'r*') 
%       plot(ymset{2}(1),ymset{2}(2),'b*') 
%    end
%    hold off
   
%    keyboard
   
   pause(1)
   hold off
   
end















