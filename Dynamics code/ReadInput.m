function [q,qd,qdd] = ReadInput(ModelFile)
% Function to read the input for the biomechanical model

% global memory assignment
global NBody NCoord Body;
global NConstraints NSteps;
global NRevolute JntRevolute;
global NGround Ground;
global NDriver Driver;
global tstart tstep tend;
global removeVar read_progress;
global NFPlate FPlate; 

% Read input file
waitbar(0, read_progress, {'Reading Biomechanical Model input file...','Opening input file'});
file = fopen(ModelFile);

% Store the general dimensions of the model
waitbar(0, read_progress, {'Reading Biomechanical Model input file...','Reading number of Bodies, Joints and Drivers'});
t_line = fgetl(file);
H = sscanf(t_line, "%i %i %i %i");
NBody = H(1);
NRevolute = H(2);
NGround = H(3);
NDriver = H(4);
NFPlate = H(5);
NCoord = 3 * NBody;
NConstraints = 2*NRevolute + NDriver + 3*NGround;
total_progress_iter = NBody + NRevolute + NGround + NDriver;
num_progress_iter = 0;

% Store the body position information
for k = 1:NBody
    num_progress_iter = num_progress_iter + 1;
    updateProgressBar(num_progress_iter, total_progress_iter, 'Body', k);
    
    t_line = fgetl(file);
    H = sscanf(t_line, "%i %f %f %f %f %f %f %f");
    Body(k).mass = H(2);
    Body(k).J = H(3);
    Body(k).r = H(4:5);
    Body(k).theta = H(6);
    Body(k).Length = H(7);
    Body(k).PCoM = H(8);
    Body(k).Name = char(sscanf(t_line, "%*i %*f %*f %*f %*f %*f %*f %*f %s"))';
end

% Store the Revolute Joint Information
for k = 1:NRevolute
    num_progress_iter = num_progress_iter + 1;
    updateProgressBar(num_progress_iter, total_progress_iter, 'Revolute', k);
    
    t_line = fgetl(file);
    H = sscanf(t_line, "%i %i %i %f %f %f %f");
    JntRevolute(k).i = H(2);
    JntRevolute(k).j = H(3);
    JntRevolute(k).spi = H(4:5);
    JntRevolute(k).spj = H(6:7);
end

for k=1:NGround
    num_progress_iter = num_progress_iter + 1;
    updateProgressBar(num_progress_iter, total_progress_iter, 'Ground', k);
    
    t_line = fgetl(file);
    H = sscanf(t_line, "%i %i %f %f %f");
    Ground(k).i = H(2);
    Ground(k).rP0 = H(3:4);
    Ground(k).theta0 = H(5);
end

%Does the splines for every drivers
for k = 1:NDriver
    num_progress_iter = num_progress_iter + 1;
    updateProgressBar(num_progress_iter, total_progress_iter, 'Driver', k);
    
    t_line = fgetl(file);
    H = sscanf(t_line, "%i %i %i %i %i %i %i");
    Driver(k).type = H(2);    % Driver type (1, 2, 3, 4)
    Driver(k).i = H(3);       % Body i
    Driver(k).coordi = H(4);
    Driver(k).j = H(5);   % Body j (revolute with Body i)
    Driver(k).coordj = H(6);
    Driver(k).filename = H(7);
    
    filename = sprintf('Driver_%d.txt', Driver(k).filename);
    driver_info = dlmread(filename);
    
    if(Driver(k).type == 1 || Driver(k).type == 3)
        [spl, spl_d, spl_dd] = DriverGetSplines(driver_info);
        Driver(k).spline = spl;
        Driver(k).spline_d = spl_d;
        Driver(k).spline_dd = spl_dd;
    end
    
end

for k = 1:NFPlate
        
    t_line = fgetl(file);
    H = sscanf(t_line, "%i %i %i %f %f %f %f %i");
    FPlate(k).i = H(2);
    FPlate(k).j = H(3);
    FPlate(k).spi = H(4:5);
    FPlate(k).spj = H(6:7);
    FPlate(k).filename = H(8);
    
    filename = sprintf('FPlates_%d.txt', FPlate(k).filename);
    FPlate_info = dlmread(filename);
    
    %getting splines for forces and centers of pressure
    
    FPlate(k).Fxy_spline   = spline(FPlate_info(:,1),FPlate_info(:,2));
    FPlate(k).Fz_spline    = spline(FPlate_info(:,1),FPlate_info(:,3));
    FPlate(k).COPxy_spline = spline(FPlate_info(:,1),FPlate_info(:,4));
    FPlate(k).COPz_spline  = spline(FPlate_info(:,1),FPlate_info(:,5));
        
end

% Read the Analysis Time
t_line = fgetl(file);
H = sscanf(t_line, "%f %f %f");
tstart = H(1);
tstep = H(2);
tend = H(3);
NSteps = (tend - tstart) / tstep;

% Variable that has been removed from analysis (X=1, Y=2, Z=3)
t_line = fgetl(file);
H = sscanf(t_line, "%i");
removeVar = H(1);

%Initializes q, qd and qdd
q = zeros(NCoord, NSteps);
q(:,1) = reshape([reshape([Body.r],[2,NBody]); Body.theta],[NCoord,1]);
qd = zeros(NCoord,NSteps);
qdd = zeros(NCoord,NSteps);

end

function updateProgressBar(num_progress_iter, total_progress_iter, type, num)
global read_progress
num_progress_iter = num_progress_iter + 1;
perc = num_progress_iter / total_progress_iter;
waitbar(perc, read_progress, {'Reading Biomechanical Model input file...',[type,' ',num2str(num)]});
end