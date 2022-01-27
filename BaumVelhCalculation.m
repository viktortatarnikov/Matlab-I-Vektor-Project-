function [N,Nc,F,Fc] = BaumVelhCalculation(TRAIN,Fs,numFeatures,gmm,numSpeakers,numComponents)
% Расчет статистик Баума-Уэльха
% На входе 
% TRAIN - тренировочный набор на котором обьучается наша система
% Fs - чистота дискритизации
% numFeatures - количесвто выделяемых признаков
% gmm - ubm - Универсальная фоновая модель
% numSpeakers - Определяем количество спикеров (Количество спикеров =
% количество файлов )
% numComponents - Определяем количество компонентов массива для статистики Баума-Уэльха

Nc = {};
Fc = {};%создание массива ячеек (пустых)

numFiles = numSpeakers;

Npart = cell(1,numFiles);
Fpart = cell(1,numFiles);

for jj = 1:numFiles
    audioData = TRAIN{1,jj};
    % Теперь для каждого сигнала сделаем нарезку из кадров  
    Centers = getFrameCentersMex(audioData, length(audioData), Fs);
    frameLen = floor(Fs*0.03);

    % если центры выделить не получилось, используется один кадр длиной в сигнал
    Frames = getFramesMex(audioData, length(audioData), Centers, length(Centers), frameLen, 1);

    % Extract features (Выделение фичей)
    MFCC = melcepstrum(Frames, Fs, 'M', numFeatures, frameLen); 
    MFCC = MFCC';

    % Compute a posteriori log-likelihood
      % Вычислить апостериорную логарифмическую вероятность
    logLikelihood = helperGMMLogLikelihood(MFCC,gmm);

    % Compute a posteriori normalized probability
      % Вычислить апостериорную нормированную вероятность
    amax = max(logLikelihood,[],1);
    logLikelihoodSum = amax + log(sum(exp(logLikelihood-amax),1));
    gamma = exp(logLikelihood - logLikelihoodSum)';

    % Compute Baum-Welch statistics
      % Вычислить статистику Баума-Велча
    n = sum(gamma,1);
    f = MFCC * gamma;

    Npart{jj} = reshape(n,1,1,numComponents); %Изменение формата матрицы  
    Fpart{jj} = reshape(f,numFeatures,1,numComponents); %Изменение формата матрицы  
end
Nc = [Nc,Npart];
Fc = [Fc,Fpart];

N = Nc;
F = Fc;
muc = reshape(gmm.mu,numFeatures,1,[]);
for s = 1:numSpeakers
    N{s} = repelem(reshape(Nc{s},1,[]),numFeatures);
    % Изменеие формата путём копирования отдельных ячеек 
    F{s} = reshape(Fc{s} - Nc{s}.*muc,[],1);
end
end

