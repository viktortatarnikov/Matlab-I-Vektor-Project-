function iVector = iVectorExtractorForViktorWithLove(Signal, Fs, FrameType)
% Функция получения вектора идентичности для входного сигнала
% На входе:
% Signal - исходный сигнал
% Fs - частота дискретизации
% FrameType - тип деления на кадры (0 - фиксированная сетка кадров, 1 - неравномерная по ЧОТ),
% по умолчанию задаётся равномерная сетка кадров
% На выходе:
% iVector - веткор идентичности (строка)

if nargin == 2
    FrameType = 0;
elseif nargin<2
    msgID = 'iVectorExtractor:inputArguments';
    msg = 'Unable to calculate the result. Not enough input arguments.';
    baseException = MException(msgID,msg);
    throw(baseException);
else
    % проверка типа данных для типа деления на кадры
    TF = checkType(FrameType, 'double');
    if ~TF
        TF = checkType(FrameType, 'logical');
        if ~TF
            msgID = 'iVectorExtractor:variableTypes';
            msg = 'Unable to calculate the result. FrameType must be "double" or "logical".';
            baseException = MException(msgID,msg);
            throw(baseException);
        end
    end
end

% проверка типа данных для входного массива
TF = checkType(Signal, 'double');

if ~TF
    msgID = 'iVectorExtractor:variableTypes';
    msg = 'Unable to calculate the result. The input signal must be "double".';
    baseException = MException(msgID,msg);
    throw(baseException);
end

Signal = Signal(:);

% проверка типа данных для частоты дискретизации
TF = checkType(Fs, 'double');

if ~TF
    msgID = 'iVectorExtractor:variableTypes';
    msg = 'Unable to calculate the result. The sample rate must be "double".';
    baseException = MException(msgID,msg);
    throw(baseException);
end

% если выбрана неравномерная сетка кадров, вычисляются границы периодов ЧОТ
if FrameType
    Centers = getFrameCentersMex(Signal, length(Signal), Fs);
    frameLen = floor(Fs*0.03);
else % если сетка равномерная, вычисляются центры для кадра в 30 мс с пееркрытием в 10 мс
    frameShift = floor(Fs*0.01);
    frameLen = frameShift*3;
    Centers = 1:frameShift:length(Signal);
end

% если центры выделить не получилось, используется один кадр длиной в сигнал
if isempty(Centers)
    frameLen = length(Signal);
    Frames = Signal;
else
    Frames = getFramesMex(Signal, length(Signal), Centers, length(Centers), frameLen, 1);
    if isempty(Frames)
        Frames = Signal;
    end
end

nCoefs = 19; % 19 коэффициентов
MFCC = melcepstrum(Frames, Fs, '0', nCoefs, frameLen); % вычисление MFCC

try
    % ВОТ СЮДА ПОДСТАВЬ ФУНКЦИЮ КОТОРАЯ БУДЕТ СЧИТАТЬ ПАРАМЕТРЫ UBM!
    UBM = load('UBM_GMM_TIMIT'); % загрузка универсальной фоновой модели
catch
    msgID = 'iVectorExtractor:UBM';
    msg = 'Unable to calculate the result. The UBM is not found.';
    baseException = MException(msgID,msg);
    throw(baseException);
end

try
    % ВОТ СЮДА - ФУНКЦИЮ КОТОРАЯ СЧИТАЕТ T-матрицу, чем бы это не было!
    variabilitySubspace = load('TIMIT_T_matrix_75', 'T'); % загрузка T-матрицы
catch
    msgID = 'iVectorExtractor:tMatrix';
    msg = 'Unable to calculate the result. The T-matrix is not found.';
    baseException = MException(msgID,msg);
    throw(baseException);
end

[N, F] = compute_bw_stats(MFCC', UBM.gmm); % вычисление статистик Баума-Уэлша
iVector = extract_ivector(N, F, UBM.gmm, variabilitySubspace.T); % извлечение вектора идентичности
iVector = iVector(:)';

end