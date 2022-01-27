function T = TmatrixCalculating(numFeatures,numComponents,numTdim,gmm,numSpeakers,N,Nc,F)
% На входе 
% numFeatures - количесвто выделяемых признаков
% numComponents - Определяем количество компонентов массива для статистики Баума-Уэльха
% numTdim - размерность Т матрицы
% gmm - ubm - Универсальная фоновая модель
% numSpeakers - Определяем количество спикеров (Количество спикеров =
% количество файлов )
% N,Nc,F -коэфиценты статистики Баума-уэльха 

Sigma = gmm.sigma(:);

T = randn(numel(gmm.sigma),numTdim);
T = T/norm(T);

I = eye(numTdim);

Ey = cell(numSpeakers,1);
Eyy = cell(numSpeakers,1);
Linv = cell(numSpeakers,1);

numIterations = 5;

for iterIdx = 1:numIterations
    % 1. Calculate the posterior distribution of the hidden variable
      % Рассчитайте апостериорное распределение скрытой переменной
    TtimesInverseSSdiag = (T./Sigma)';
    for s = 1:numSpeakers
        L = (I + TtimesInverseSSdiag.*N{s}*T);
        Linv{s} = pinv(L); %"pinv" - вычисляет матрицу псевдоподобную матрицу 
        Ey{s} = Linv{s}*TtimesInverseSSdiag*F{s};
        Eyy{s} = Linv{s} + Ey{s}*Ey{s}';
    end
    
    % 2. Accumlate statistics across the speakers
      % Сбор статистики со спикеров
    Eymat = cat(2,Ey{:});
    FFmat = cat(2,F{:});
    Kt = FFmat*Eymat';
    K = mat2cell(Kt',numTdim,repelem(numFeatures,numComponents));
    
    newT = cell(numComponents,1);
    for c = 1:numComponents
        AcLocal = zeros(numTdim);
        for s = 1:numSpeakers
            AcLocal = AcLocal + Nc{s}(:,:,c)*Eyy{s};
        end
        
    % 3. Update the Total Variability Space
      % Обновить общее пространство вариабильности
        newT{c} = (pinv(AcLocal)*K{c})';
    end
    T = cat(1,newT{:});
end
end

