function [dispNet] = LoadNetworks(isTraining)

if(~exist('isTraining', 'var') || isempty(isTraining))
    isTraining = false;
end

global param;
global IN;

if (isTraining)
    netFolder = param.trainNet;
    [netName, ~, ~] = GetFolderContent(netFolder, '.mat');
    
    if (param.continue && ~isempty(netName))
        load([netFolder,netName{1}]);
        if(exist('testError'))
            IN.error= testError;
        else
            IN.error=[];
        end
        if(exist('totalTrainedBatch'))
            IN.totalTrainedBatch= totalTrainedBatch;
        else
            IN.totalTrainedBatch=[];
        end
        tokens = regexp(netName{1}, 'Net-e([\d]+)-d([\d]+)-b([\d]+)', 'tokens');
        param.startEpoch = str2double(tokens{1}{1});
        param.startData = str2double(tokens{1}{2});
        param.startBatch = str2double(tokens{1}{3});
        % load([netFolder, '/', netName{1}]);
    else
        param.continue = false;
        dispNet = CreateNet();
        IN.error=[];
        IN.totalTrainedBatch=0;
        param.startEpoch = 1;
        param.startData = 1;
        param.startBatch = 1;
    end
else
    netFolder = param.testNet;
    load([netFolder, '/Net']);
end

if (param.useGPU)
    dispNet = vl_simplenn_move(dispNet, 'gpu');
    dispNet = ConvertLayers(dispNet, 'gpu');
else
    dispNet = vl_simplenn_move(dispNet, 'cpu');
    dispNet = ConvertLayers(dispNet, 'cpu');
end