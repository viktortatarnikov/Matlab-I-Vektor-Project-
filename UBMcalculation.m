function ubm = UBMcalculation(TRAIN,Fs,numFeatures)
% На входе: 
% TRAIN - тренировочный набор на котором обьучается наша система
% Fs - чистота дискритизации
% numFeatures - количесвто выделяемых признаков
Frames = [];
for k = 1:size(TRAIN,2)
    Signal = TRAIN{1,k};
    %Centers = getFrameCentersMex(Signal, length(Signal), Fs);
    Centers = getFrameCenters(Signal, Fs);   
    frameLen = floor(Fs*0.03);
    
    % если центры выделить не получилось, используется один кадр длиной в сигнал
    tmp_frames = getFramesMex(Signal, length(Signal), Centers, length(Centers), frameLen, 1);
    Frames = [Frames, tmp_frames];
end
%% gmm (UBM) расчет

numComponents = 512;
numPar =1;

alpha = ones(1,numComponents)/numComponents;
mu = randn(numFeatures,numComponents);
vari = rand(numFeatures,numComponents) + eps;
ubm = struct('ComponentProportion',alpha,'mu',mu,'sigma',vari);
% запись вышеназванных массивов под одну структуру

% А теперь тренеруем UBM?, используя "алгортм максимизации ожидания"
maxIter = 10;

tic
for iter = 1:maxIter
    tic
    % EXPECTATION(ожидания) 
    N = zeros(1,numComponents);
    F = zeros(numFeatures,numComponents);
    S = zeros(numFeatures,numComponents);
    L = 0;
    for ii = 1:numPar
          
            % Extract features
            MFCC = melcepstrum(Frames, Fs, 'M', numFeatures, frameLen); 
            MFCC = MFCC';
 
            
            % Compute a posteriori log-liklihood
              % Вычислить апостериорную логарифмическую вероятность
            logLikelihood = helperGMMLogLikelihood(MFCC,ubm);

            % Compute a posteriori normalized probability
              % Вычислить апостериорную нормированную вероятность
            amax = max(logLikelihood,[],1);
            logLikelihoodSum = amax + log(sum(exp(logLikelihood-amax),1));
            gamma = exp(logLikelihood - logLikelihoodSum)';
            
            % Compute Baum-Welch statistics
              % Вычислить статистику Баума-Велча
            n = sum(gamma,1);
            f = MFCC * gamma;
            s = (MFCC.*MFCC) * gamma;
            
            % Update the sufficient statistics over utterances
              %Обновить достаточную статистику по высказываниям!??!?
            N = N + n;
            F = F + f;
            S = S + s;
            
            % Update the log-likelihood
              % Обновить логарифмическую вероятность
            L = L + sum(logLikelihoodSum);
        
    end
    
    
    % MAXIMIZATION
    N = max(N,eps);
    ubm.ComponentProportion = max(N/sum(N),eps);
    ubm.ComponentProportion = ubm.ComponentProportion/sum(ubm.ComponentProportion);
    ubm.mu = F./N;
    ubm.sigma = max(S./N - ubm.mu.^2,eps);
end
end

