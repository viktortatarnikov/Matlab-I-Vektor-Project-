function [TrainStruct, TrainList] = FileInitialization(Name)
% тут мы делаем красивую структуру где все разбито по папкам и вообще
% выглядит охуенно (пока не знаю зачем, но почему бы и нет)
slash = '\';
GSM = dir(Name);
L1 = length(GSM);
for ii = 3 : L1
    Langwitch = GSM(ii).name;
    Lengw(ii-2) = convertCharsToStrings(Langwitch);%Перевод в строковую переменную 
    NameNew = strcat(Name,slash,Langwitch);
    audio = dir(NameNew);
    L2 = length(audio);
    for jj = 3 : L2
        disp('Читаем Файл ');disp(ii);disp(' ');disp(jj);
        sempl = audio(jj).name; %На этом этапе мы можем вытащить и загрузить каждый отдельный аудофайл
        file = convertCharsToStrings(sempl);
        NameOfFile = strcat(NameNew,slash,file);
        TrainStruct(ii-2).File(jj-2) = NameOfFile; %Запись в %Struct итогового пути
    end
end

% Тут мы делаем ущербный список где все имена файлов из папок свалены в
% кучу
TRAINdimenson = size (TrainStruct, 2);
cnt = 1;
for ii = 1:TRAINdimenson
    Filedimenson = size (TrainStruct(ii).File,2);
    for jj = 1:Filedimenson
        disp('Запсиь файла ');disp(ii);disp(' ');disp(jj);
        a = TrainStruct(ii).File(jj); %счетчик вылета для проверки  %File could not be read due to an unexpected error. Reason: Error in WAV file. No 'data' chunk marker.
%         TrainDop = audioread(a);
%         MiniSize = size(TrainDop,1);
        TrainList{cnt,1} = a;
        cnt = cnt + 1;
    end
end

end

