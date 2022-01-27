function ivectorTRUE = IVectorCalculation(gmm,numTdim,T,Test,Fs,numFeatures)
% Расчет I вектора по МАТЛАБУ
% На входе: 
% gmm - ubm - Универсальная фоновая модель
% numTdim - размерность Т матрицы
% Т - Т матрица
% Test - тестовый аудиофайл
% Fs - чистота дискритизации
% numFeatures - количесвто выделяемых признаков

numSpeakers = 1; %с учетом того, что выделение "АЙ вектора" происходит по 1 файлу
Sigma = gmm.sigma(:);
TS = T./Sigma;
TSi = TS';
ubmMu = gmm.mu;
I = eye(numTdim);

for speakerIdx = 1:numSpeakers
    
    % Subset the datastore to the speaker you are adapting.
      % Подберите хранилище данных к динамику, который вы адаптируете.

    numFiles = 1; %с учетом того, что выделение "АЙ вектора" происходит по 1 файлу
    
    ivectorPerFile = zeros(numTdim,numFiles);
    for fileIdx = 1:numFiles
        audioData = Test;
        
        % Extract features
        %Теперь для каждого сигнала сделаем нарезку из кадров  
        Centers = getFrameCentersMex(audioData, length(audioData), Fs);
        frameLen = floor(Fs*0.03);

        % если центры выделить не получилось, используется один кадр длиной в сигнал
        Frames = getFramesMex(audioData, length(audioData), Centers, length(Centers), frameLen, 1);

        % Extract features (Выделение фичей)
        MFCC = melcepstrum(Frames, Fs, 'M', numFeatures, frameLen); 
        MFCC = MFCC';
        
        % Compute a posteriori log-likelihood
        logLikelihood = helperGMMLogLikelihood(MFCC,gmm);
        
        % Compute a posteriori normalized probability
        amax = max(logLikelihood,[],1);
        logLikelihoodSum = amax + log(sum(exp(logLikelihood-amax),1));
        gamma = exp(logLikelihood - logLikelihoodSum)';
        
        % Compute Baum-Welch statistics
        n = sum(gamma,1);
        f = MFCC * gamma - n.*(ubmMu);

        ivectorPerFile(:,fileIdx) = pinv(I + (TS.*repelem(n(:),numFeatures))' * T) * TSi * f(:);
    end
    ivectorTRUE = ivectorPerFile;
    
end
ivectorTRUE = single(ivectorTRUE');
end

