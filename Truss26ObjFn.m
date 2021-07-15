%=========================================================================%
% This is an objective function file for optimizing the weight of 942 bar
% tower truss.
%
% The optimization is done using Grey Wolf Optimizer toolbox
% The toolbox is developed by Seyedali Mirjalili and is available on the 
% website - https://seyedalimirjalili.com/gwo
%
% The lower bound (lb) is the minimum area allowed = 0.000064516
% The upper bound (ub) is the maximum area allowed = 0.0129032
% The number of variables = 59
%=========================================================================%
function z=Truss26ObjFn(Q)
M=importdata(['26StoreyTruss','.xls']); % all values in excel are in ft.
nod=M.data.nodes;
n=max(nod(:,1)); % no of nodes

elem=M.data.elements;
ne=max(elem(:,1)); % no of elements

ndof=3; % no of DOF's
nen=2; % no of nodes for each element
nee=nen*ndof;
Nd=0.381; % Node Displacement Limit in m
Fy=172368.932; % Stress Limit in kN/m2


% area of the elements in sq.m
ar(1,1:2)=Q(1);
ar(1,3:10)=Q(2);
ar(1,11:18)=Q(3);
ar(1,19:34)=Q(4);
ar(1,35:46)=Q(5);
ar(1,47:58)=Q(6);
ar(1,59:82)=Q(7);
ar(1,83:86)=Q(8);
ar(1,87:94)=Q(9);
ar(1,95:98)=Q(10);
ar(1,99:106)=Q(11);
ar(1,107:122)=Q(12);
ar(1,123:130)=Q(13);
ar(1,131:162)=Q(14);
ar(1,163:170)=Q(15);
ar(1,171:186)=Q(16);
ar(1,187:194)=Q(17);
ar(1,195:226)=Q(18);
ar(1,227:234)=Q(19);
ar(1,235:258)=Q(20);
ar(1,259:270)=Q(21);
ar(1,271:318)=Q(22);
ar(1,319:330)=Q(23);
ar(1,331:338)=Q(24);
ar(1,339:342)=Q(25);
ar(1,343:350)=Q(26);
ar(1,351:358)=Q(27);
ar(1,359:366)=Q(28);
ar(1,367:382)=Q(29);
ar(1,383:390)=Q(30);
ar(1,391:398)=Q(31);
ar(1,399:430)=Q(32);
ar(1,431:446)=Q(33);
ar(1,447:462)=Q(34);
ar(1,463:486)=Q(35);
ar(1,487:498)=Q(36);
ar(1,499:510)=Q(37);
ar(1,511:558)=Q(38);
ar(1,559:582)=Q(39);
ar(1,583:606)=Q(40);
ar(1,607:630)=Q(41);
ar(1,631:642)=Q(42);
ar(1,643:654)=Q(43);
ar(1,655:702)=Q(44);
ar(1,703:726)=Q(45);
ar(1,727:750)=Q(46);
ar(1,751:774)=Q(47);
ar(1,775:786)=Q(48);
ar(1,787:798)=Q(49);
ar(1,799:846)=Q(50);
ar(1,847:870)=Q(51);
ar(1,871:894)=Q(52);
ar(1,895:902)=Q(53);
ar(1,903:906)=Q(54);
ar(1,907:910)=Q(55);
ar(1,911:918)=Q(56);
ar(1,919:926)=Q(57);
ar(1,927:934)=Q(58);
ar(1,935:942)=Q(59);

%Fixed Degree of Freedom
fixed_dof=M.data.boundary_conditions(697:732,3);

% Connections
c1=elem(:,2);
c2=elem(:,3);
L1=[c1,c2];

L=L1';

% Coordinates in ft converted to m by dividing by 3.28084
xcoord=nod(:,2);
ycoord=nod(:,3);
zcoord=nod(:,4);

coord1=[xcoord,ycoord,zcoord]; % x, y, z coordinates of all the elements in ft

coord=(1/3.28084)*coord1'; % converting to m.

%Loading
load=4.448*(M.data.external_loads(:,4)); % in kN

E=68947572.93178299; % youngs modulus kN/m2
den=27.1447; % density of material in kN/m3


%% Calculation
%getting the ID matrix from the information given
ID=zeros(ndof,n);
r=size(ID);
c=r(1,2); %no of nodes
r=r(1,1); %dof
number=1;
for c1=1:c
    for r1=1:r
        ID(r1,c1)=number;
        number=number+1;
    end
end

fixed_dof=sort(fixed_dof);
fixed1=fixed_dof;
node=1:1:n*ndof;
free_dof=node;
for i=1:length(fixed_dof)
    free_dof(fixed1(i))=[];
    fixed1=fixed1-1; %to remove fixed dof otherwise will be 2,4,6,...
end
clear fixed1;
free_dof=sort(free_dof);
free_dof=free_dof';
for e=1:ne
    for i=1:nen
        for a=1:ndof
            p=ndof*(i-1)+a;
            LM(p,e)=ID(a,L(i,e));
        end
    end
end
K=zeros(n*ndof);
lambda_vec=[];
h_vec=[];
%assembly
for e=1:ne           %coordinates matrix of each element
    localcoord=[coord(:,L(1,e)) coord(:,L(2,e))];
    h=0;
    for count=1:ndof         %length of member
        temp=(localcoord(count,2)-localcoord(count,1))^2;
        h=h+temp;
    end
    h=sqrt(h);
    h_vec=[h_vec;h];
    lambda=[];
    for count=1:ndof %direction cosines in lambda matrix like cosx
        lambda=[lambda;(localcoord(count,2)-localcoord(count,1))/h];
        %first one is lambda x ans second one is lambda y and so on
    end
    lambda_vec=[lambda_vec lambda];
    A=lambda*lambda';
    k=(E*ar(e))/h*[A -A;-A A];
    for p=1:nee
        P=LM(p,e);
        for q=1:nee
            Q=LM(q,e);
            K(P,Q)=K(P,Q)+k(p,q);  % Global Stiffness matrix
        end
    end
end
lambda_vec=lambda_vec';
K1=K;
%applying boundary conditions
for counter=1:length(fixed_dof)
    K1(fixed_dof(counter),:)=[];
    K1(:,fixed_dof(counter))=[];
    fixed_dof=fixed_dof-1;
end
load1=load(1:696);
d=K1\load1;
disp_vec=zeros(n*ndof,1);
for count=1:length(free_dof)
    disp_vec(free_dof(count))=d(count);
end

%% Weight 
TW=0;
for i=1:ne
    W=den*ar(i)*h_vec(i);
    TW=TW+W; % weight in kN
end

%% post processing
D_big=[];
count=1;
for i=1:n
    D=[];
    for j=1:ndof
        t=disp_vec(count);
        count=count+1;
        D=[D;t];
    end
    D_big=[D_big D];
end
axial_vec=[];
force_vec=[];
for i=1:ne
    d1=lambda_vec(i,:)*D_big(:,L(1,i));
    d2=lambda_vec(i,:)*D_big(:,L(2,i));
    axial=(E/h_vec(i))*(d2-d1);
    axial_vec=[axial_vec;axial];
    force=ar(i)*axial_vec(i);
    force_vec=[force_vec;force];
end
axial_vec;


z=TW+sum(max(abs(disp_vec)-Nd*ones(732,1),zeros(732,1)))+sum(max(axial_vec-(Fy*ones(942,1)),zeros(942,1)));


end

