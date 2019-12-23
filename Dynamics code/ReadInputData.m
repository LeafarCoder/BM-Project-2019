%Function to read an input file (written as txt)
%for the biomechanical system to be studied


%global memory assignment
global

%load input file name
[FileName,PathName]=uigetfile('*.txt','Select the dynamic model file');


%Read the input file
H=dlmread(FileName)

%store the general dimensions of system

NBody=H(1,1);
NRevolute=H(1,2);
NGround=H(1,3);
NDriver=H(1,4);
NSimple=H(1,5);
NPoint=H(1,6);
NSpringDamper=H(1,7);


NConst=2*NRevolute+3*NGround+NDriver+NSimple
line=1;


%store data for the rigid body information

for i=1:NBody
    line=line+1;
    Body(i).mass=H(line,2);
    Body(i).inertia=H(line,3);
    Body(i).r=H(line,4:5)';
    Body(i).theta=H(line,6);
    Body(i).rd=H(line,7:8)';
    Body(i).thetad=H(line,9);
end


%store the data for the revolute joints information

for k=1:NRevolute
    line=line+1;
    JntRevolute(k).i=H(line,2);
    JntRevolute(k).j=H(line,3);
    JntRevolute(k).sPpi=H(line,4:5)';
    JntRevolute(k).sPpj=H(line,6:7)';
end

    


