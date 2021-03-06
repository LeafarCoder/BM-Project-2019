function ReadGRF(force_file, samplingFreq)
%Reads and filters the data from the force plates

global FPlate

% Transforms the data from the local reference frame to the global
% reference frame of the laboratory. The output includes the magnitude of
% the forces in x, y, and z and the position of the center of pressure in
% x, y, z

[fp1, fp2, fp3] = tsv2mat(force_file);

% time frame
Time = 0: 1/samplingFreq : (size(fp1,1)-1)/samplingFreq;

%saves the data into a structure
RawData(1).fp = fp1;
RawData(2).fp = fp2;
RawData(3).fp = fp3;

%goes through all force plates and processes results
for i = 1:3
    %saves only the data relevant for 2D analysis - the data eliminated
    %from the positions is eliminated here as well
    FPData = [  RawData(i).fp(:,1), RawData(i).fp(:,3),...
                RawData(i).fp(:,4), RawData(i).fp(:,6)]...
                .* [1, 1, 1e-3, 1e-3];
        
     %filters the data
     FilteredData = FilterForcePlateData(FPData, samplingFreq);
     
     %saves data in an output structure
     FPlate(i).Data = [Time', FilteredData'];
end

end