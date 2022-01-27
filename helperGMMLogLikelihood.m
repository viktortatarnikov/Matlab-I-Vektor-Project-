function L = helperGMMLogLikelihood(x,gmm)
 xMinusMu = repmat(x,1,1,numel(gmm.ComponentProportion)) - permute(gmm.mu,[1,3,2]);%permute-
 %перестановка размерности массивов, repmat -дублирование?? numel -количество элеентов массива 
 %Операция выше расчитывает разность матриц 
    
 permuteSigma = permute(gmm.sigma,[1,3,2]);
    
    Lunweighted = -0.5*(sum(log(permuteSigma),1) + sum(xMinusMu.*(xMinusMu./permuteSigma),1) + size(gmm.mu,1)*log(2*pi));
    
    temp = squeeze(permute(Lunweighted,[1,3,2])); 
    if size(temp,1)==1
    % Если есть только один фрейм, конечное одиночное измерение было
    % удалено в перестановке.
        temp = temp';
    end
    
    L = temp + log(gmm.ComponentProportion)';
end

