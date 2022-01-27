function [ubm, MFCC_list] = UBMcalculationBIG(TrainList, numFeatures)
% На входе: 
% TRAIN - тренировочный набор на котором обьучается наша система
% Fs - чистота дискритизации
% numFeatures - количесвто выделяемых признаков
Frames = [];
MFCC = [];
MFCC_list = {};

load MFCC_list;
g = size(TrainList,1);
cnt = size(MFCC_list,1);
for k = 1:size(TrainList,1)
    
    disp('Чтение дорожки ');disp(k);
    [Speech, Fs] = audioread(TrainList{k,1});
   
    Centers = getFrameCenters(Speech, Fs);
    frameLen = floor(Fs*0.03);
    
    if(~isempty(Centers))
        % если центры выделить не получилось, используется один кадр длиной в сигнал
        tmp_frames = getFramesMex(Speech, length(Speech), Centers, length(Centers), frameLen, 0);
    else
        continue;
    end
    
    % по каждому кадру считаем признаки
    disp('Расчёт MFCC '); disp(k);
    mfcc = melcepstrum(tmp_frames, Fs, 'M', numFeatures, frameLen);  
    MFCC_list{cnt+1,1} = mfcc';
   
    %Сохраняем на будущее наши мфсс
    %для этогго разделяем их на 4 части (иначе будет слишком большой объем)
    if k == floor(g/4)
        MFCC_list1 = MFCC_list;
        save('MFCC_list1.mat');
        index = k;
    end
    if k == 2*(floor(g/4))
        for ii = 1:(k-index)
            Y(ii) = MFCC_list(ii+index);
        end
        MFCC_list2 = Y;
        save('MFCC_list2.mat');
        index = k;
    end
    if k == 3*(floor(g/4))
        for ii = 1:(k-index)
            Y(ii) = MFCC_list(ii+index);
        end
        MFCC_list3 = Y;
        save('MFCC_list3.mat');
        index = k;
    end
    if k == g
        for ii = 1:(k-index)
            Y(ii) = MFCC_list(ii+index);
        end
        MFCC_list4 = Y;
        save('MFCC_list4.mat');
    end
    
    cnt = cnt + 1;
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
            disp('расчёт UBM ');
            disp(iter);disp(ii);
            % Compute a posteriori log-liklihood
              % Вычислить апостериорную логарифмическую вероятность
            logLikelihood = helperGMMLogLikelihood(MFCC_list,ubm);

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