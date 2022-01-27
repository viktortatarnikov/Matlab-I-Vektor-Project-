function [features,numFrames] = helperFeatureExtraction(audioData,afe,normFactors)
    % На входе:
    % audioData   - Аудиоданные
    % afe         - Откуда мы выделяем фичи 
    % normFactors - Среднее и стандартное отклонение фунции для
    % нормалтзации (если его нет, то нормализация не применяется) 
    %
    % На выходе:
    % features    - матрица полученных фич (особенностей) 
    % numFrames   - количество кадров (векторов признаков)
    
    % Normalize
    audioData = audioData/max(abs(audioData(:)));
    
    % Protect against NaNs
    audioData(isnan(audioData)) = 0;
    
    % Isolate speech segment
    idx = detectSpeech(audioData,afe.SampleRate);
    features = [];
    for ii = 1:size(idx,1)
        f = extract(afe,audioData(idx(ii,1):idx(ii,2)));
        features = [features;f]; %#ok<AGROW> 
    end

    % Feature normalization
    if ~isempty(normFactors)
        features = (features-normFactors.Mean')./normFactors.STD';
    end
    features = features';
    
    % Cepstral mean subtraction (for channel noise)
    if ~isempty(normFactors)
        features = features - mean(features,'all');
    end
    
    numFrames = size(features,2);
end