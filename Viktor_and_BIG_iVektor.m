clc;  clear;
addpath('D:/Matlab_projects/iDiarizator')  
addpath('D:/Matlab_projects/getFrameCenters') 

% ОБЩИЕ ПАРАМЕТРЫ
% Выбираем количество выделяемых признаков
numFeatures = 20;

%Определяем количество компонентов массива для статистики Баума-Уэльха
numComponents = 512;

%Размерность будущей Т матрицы
numTdim = 75;

%% 1. ПОДГОТОВКА UBM МОДЕЛИ И Т МАТРИЦЫ

% Загружаем тестовый сигнал для расчета i-векторов
disp('Загружаем тестовый сигнал для расчета i-векторов');
[Test,Fs] = audioread('test.wav');

% Загружаем сигналы для расчета UBM, T-матрицы.
disp('Загружаем сигналы для расчета UBM, T-матрицы.');
Name = 'D:\Matlab_projects\Zapisi\GSM';
[TrainStruct, TrainList] = FileInitialization(Name);

% % Объединяем тренировочные записи в один список
% TRAIN = {Train1, Train2(1:end-10000), Train3(1:end-20000)};

%Итоговый ТRAIN - это оцифрованный вид всех аудиодорожек (каждый файл записывается в отдельную строчку(столбик))
%Определяем количество спикеров
%Количество спикеров = количество файлов 
disp('Определяем количество спикеров');
numSpeakers = size(TrainList,1);

% Получаем параметры UBM
disp('Получаем параметры UBM');
[ubm, MFCC] = UBMcalculationBIG(TrainList, numFeatures);

% Расчет статистик Баума-Уэльха
disp('Расчет статистик Баума-Уэльха');
[N,Nc,F,Fc] = BaumVelhCalculationBIG(MFCC,numFeatures,ubm,numSpeakers,numComponents);

% Расчет Т матрицы
disp('Расчет Т матрицы');
T = TmatrixCalculating(numFeatures,numComponents,numTdim,ubm,numSpeakers,N,Nc,F);

%% 2. ВЫЧИСЛЕНИЕ I ВЕКТОРОВ

disp('ВЫЧИСЛЕНИЕ I ВЕКТОРОВ');
ivectorTRUE = IVectorCalculation(ubm,numTdim,T,Test,Fs,numFeatures);

%% 3. Расчитываем I-вектора по ИСХОДНИКУ МАШИ
disp('Расчитываем I-вектора по ИСХОДНИКУ МАШИ');
iVector = iVectorExtractorForViktorWithLove(Test, Fs);
disp('финиш');
save Big_vektor_result.mat
