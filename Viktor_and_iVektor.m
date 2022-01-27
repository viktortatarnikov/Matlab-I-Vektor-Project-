clc;  clear;
%% ОБЩИЕ ПАРАМЕТРЫ
% Выбираем количество выделяемых признаков
numFeatures = 20;

%Определяем количество компонентов массива для статистики Баума-Уэльха
numComponents = 512;

%Размерность будущей Т матрицы
numTdim = 75;

%% 1. ПОДГОТОВКА UBM МОДЕЛИ И Т МАТРИЦЫ

% Загружаем тестовый сигнал для расчета i-векторов
[Test,Fs] = audioread('test.wav');

% Загружаем сигналы для расчета UBM, T-матрицы.
[Train1, fs1]  = audioread('test.wav');
[Train2, fs2] = audioread('test.wav');
[Train3, fs3]  = audioread('test.wav');



% Объединяем тренировочные записи в один список
TRAIN = {Train1, Train2(1:end-10000), Train3(1:end-20000)};

%Определяем количество спикеров
%Количество спикеров = количество файлов 
numSpeakers = size(TRAIN,2);

% Получаем параметры UBM
gmm = UBMcalculation(TRAIN,Fs,numFeatures);

% Расчет статистик Баума-Уэльха
[N,Nc,F,Fc] = BaumVelhCalculation(TRAIN,Fs,numFeatures,gmm,numSpeakers,numComponents);

% Расчет Т матрицы
T = TmatrixCalculating(numFeatures,numComponents,numTdim,gmm,numSpeakers,N,Nc,F);

%% 2. ВЫЧИСЛЕНИЕ I ВЕКТОРОВ

ivectorTRUE = IVectorCalculation(gmm,numTdim,T,Test,Fs,numFeatures);

%% 3. Расчитываем I-вектора по ИСХОДНИКУ МАШИ
iVector = iVectorExtractorForViktorWithLove(Test, Fs);
