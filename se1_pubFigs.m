
function out  = se1_pubFigs(Dall , what, nowWhat , varargin)

subj_name = {'SZ1','JN2' ,'SP1','AT1','DW1','KL1','JG1','GP1','SK1' ,'NM1','VR1','PB1' , 'All'};
%% Define defaults
subjnum = length(subj_name); % all subjects
Repetition = [1 2];
poolDays = 0;
MaxIter = 100;
%% Deal with inputs
c = 1;
while(c<=length(varargin))
    switch(varargin{c})
        case {'subjnum'}
            % define the subject
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'Repetition'}
            % Repetitions to include
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'poolDays'}
            % pool together days 2,3 and days 4 5
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'MaxIter'}
            % maximum number of iterations for exponential fitting
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'isSymmetric'}
            % gaze filed around a digit symmetric or not(0 no/1 yes);
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        otherwise
            error('Unknown option: %s',varargin{c});
    end
end

%%
% baseDir = '/Users/nedakordjazi/Documents/SeqEye/SeqEye2/analyze';     %macbook
baseDir = '/Users/nkordjazi/Documents/SeqEye/SeqEye2/analyze';          %iMac



if subjnum == length(subj_name)
    %     subjnum = [1 3:length(subj_name)-1];
    subjnum = 1:length(subj_name)-1;
end


if poolDays
    dayz = {1 [2 3] [4]};
else
    dayz = {[1] [2] [3] [4]};
end

clear tempcol
c1 = [255, 153, 179]/255; % Random Red Tones
ce = [153, 0, 51]/255;
for rgb = 1:3
    tempcol(rgb , :) = linspace(c1(rgb),ce(rgb) , 6);
end
for i = 1:length(tempcol)
    colz{i,1} = tempcol(: , i)';
end

clear tempcol
c1 = [153, 194, 255]/255; % structured blue tones
ce = [0, 0, 102]/255;
for rgb = 1:3
    tempcol(rgb , :) = linspace(c1(rgb),ce(rgb) , 6);
end
for i = 1:length(tempcol)
    colz{i,2} = tempcol(: , i)';
    avgCol{i} = mean([colz{i,2} ; colz{i,1}],1);
end


colIPI(:,1) = colz(:,1);    % Random IPIs, same as Random sequences
clear tempcol
c1 = [214, 153, 255]/255;   % Between chunk Fuscia tones
ce = [61, 0, 102]/255;
for rgb = 1:3
    tempcol(rgb , :) = linspace(c1(rgb),ce(rgb) , 6);
end
for i = 1:length(tempcol)
    colIPI{i,2} = tempcol(: , i)';
end
clear tempcol
c1 = [179, 255, 153]/255; % middle chunk green tones
ce = [19, 77, 0]/255;
for rgb = 1:3
    tempcol(rgb , :) = linspace(c1(rgb),ce(rgb) , 6);
end
for i = 1:length(tempcol)
    colIPI{i,3} = tempcol(: , i)';
end

clear tempcol
c1 = [255, 179, 255]/255; % last chunk fuscia tones
ce = [102, 0, 102]/255;
for rgb = 1:3
    tempcol(rgb , :) = linspace(c1(rgb),ce(rgb) , 6);
end
for i = 1:length(tempcol)
    colIPI{i,4} = tempcol(: , i)';
end



out = [];
switch what
    
    case 'MT'
        ANA = getrow(Dall , Dall.isgood & ismember(Dall.seqNumb , [0 1:6]) & ~Dall.isError);
        ANA.seqNumb(ANA.seqNumb >=1) = 1;
        
        ANA = getrow(ANA , ANA.MT <= 9000 );
        
        for d = 1:length(dayz)
            ANA.Day(ismember(ANA.Day , dayz{d})) = d;
        end
        MT = tapply(ANA , {'BN' , 'seqNumb' , 'SN' , 'Day'} , {'MT'});
        MT = normData(MT , {'MT'});
        % segments
        ANA = getrow(Dall , Dall.isgood & ~ismember(Dall.seqNumb , [0 1:6]) & ~Dall.isError);
        ANA.seqNumb(ismember(ANA.seqNumb ,[102 202])) = 2;
        ANA.seqNumb(ismember(ANA.seqNumb ,[103 203])) = 3;
        ANA.seqNumb(ismember(ANA.seqNumb ,[104 204])) = 4;
        
        
        ANA = getrow(ANA , ANA.MT <= 9000 );
        
        for d = 1:length(dayz)
            ANA.Day(ismember(ANA.Day , dayz{d})) = d;
        end
        MTseg = tapply(ANA , {'BN' , 'seqNumb' , 'SN'} , {'MT'});
        MTseg = normData(MTseg , {'MT'});
        
        switch nowWhat
            case 'RandvsStructCommpare'
                figure('color' , 'white');
                colorz = colz(3,1:2);
                lineplot([MT.BN] , MT.normMT , 'plotfcn' , 'nanmean',...
                    'split', MT.seqNumb , 'linecolor' , colorz,...
                    'errorcolor' , colorz , 'errorbars' , repmat({'shade'} , 1 , 2) , 'shadecolor' ,colorz,...
                    'linewidth' , 3 , 'markertype' , repmat({'o'} , 1  , 2) , 'markerfill' , colorz,...
                    'markersize' , 10, 'markercolor' , colorz , 'leg' , {'Random'  , 'Structured'} );
                set(gca,'FontSize' , 18 , ...
                    'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [3500 6000],'YTick' , [4000:500:5500] ,...
                    'YTickLabels' , [4:.5:5.5] , 'YGrid' , 'on');
                xlabel('Training Block')
                ylabel('Execution time [s]')
            case 'Segments'
                figure('color' , 'white');
                colorz = colIPI(3,1:3);
                lineplot([MTseg.BN] , MTseg.normMT , 'plotfcn' , 'nanmean',...
                    'split', MTseg.seqNumb , 'linecolor' , colorz,...
                    'errorcolor' , colorz , 'errorbars' , repmat({'shade'} , 1 , 3) , 'shadecolor' ,colorz,...
                    'linewidth' , 3 , 'markertype' , repmat({'o'} , 1  , 3) , 'markerfill' , colorz,...
                    'markersize' , 10, 'markercolor' , colorz , 'leg' , {'Duoble'  , 'Triplet' , 'Quadruple'});
                set(gca,'FontSize' , 18 , ...
                    'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [100 1200],'YTick' , [200:200:1200] ,...
                    'YTickLabels' , [0.2:.2:1.2] , 'YGrid' , 'on');
                
                xlabel('Training Block')
                ylabel('Execution time [s]')
        end
    case 'IPI'
        structNumb = [1:6];
        out = [];

        
        ANA = getrow(Dall , ismember(Dall.SN , subjnum) & Dall.isgood & ismember(Dall.seqNumb , [0 , structNumb])  & ~Dall.isError);
        ANA.seqNumb(ANA.seqNumb>=2) = 1;
        for tn = 1:length(ANA.TN)
            n = (ANA.AllPressIdx(tn , sum(~isnan(ANA.AllPressIdx(tn , :))))  - ANA.AllPressIdx(tn , 1)) / 1000;
            nIdx(tn , :) = (ANA.AllPressIdx(tn , :) - ANA.AllPressIdx(tn , 1))/n;
            ANA.IPI_norm(tn , :) = diff(nIdx(tn ,:) , 1 , 2);
            if ismember(ANA.seqNumb(tn) , [1:6])
                ANA.ChunkBndry(tn , :) = [1 diff(ANA.ChnkArrang(tn,:))];
                a = find(ANA.ChunkBndry(tn , :));
                ANA.ChunkBndry(tn , a(2:end)-1) = 3;
                ANA.ChunkBndry(tn ,end) = 3;
                ANA.ChunkBndry(tn , ANA.ChunkBndry(tn , :) == 0) = 2;
            else
                ANA.ChunkBndry(tn , :) = zeros(size(ANA.ChnkArrang(tn , :)));
            end
        end
        for tn  = 1:length(ANA.TN)
            ANA.IPI_Horizon(tn , :) = ANA.Horizon(tn)*ones(1,13);
            ANA.IPI_SN(tn , :) = ANA.SN(tn)*ones(1,13);
            ANA.IPI_Day(tn , :) = ANA.Day(tn)*ones(1,13);
            ANA.IPI_prsnumb(tn , :) = [1 :13];
            ANA.IPI_seqNumb(tn , :) = ANA.seqNumb(tn)*ones(1,13);
            ANA.IPI_BN(tn , :) = ANA.BN(tn)*ones(1,13);
        end
        IPItable.IPI = reshape(ANA.IPI , numel(ANA.IPI) , 1);
        IPItable.ChunkBndry = reshape(ANA.ChunkBndry(:,2:end) , numel(ANA.IPI) , 1);
        IPItable.Horizon = reshape(ANA.IPI_Horizon , numel(ANA.IPI) , 1);
        IPItable.SN  = reshape(ANA.IPI_SN , numel(ANA.IPI) , 1);
        IPItable.Day = reshape(ANA.IPI_Day , numel(ANA.IPI) , 1);
        IPItable.prsnumb = reshape(ANA.IPI_prsnumb , numel(ANA.IPI) , 1);
        IPItable.seqNumb = reshape(ANA.IPI_seqNumb , numel(ANA.IPI) , 1);
        IPItable.BN = reshape(ANA.IPI_BN , numel(ANA.IPI) , 1);
        
        
        switch nowWhat
            case 'IPIcompareTypes'
                
                IPIs=  getrow(IPItable,ismember(IPItable.prsnumb , [4:10]));
                % pool last and within
                IPIs.ChunkBndry(IPIs.ChunkBndry == 3) = 2;
                IPIs  = tapply(IPIs , {'BN' ,'SN' , 'ChunkBndry'} , {'IPI' , 'nanmean(x)'});
                IPIs = normData(IPIs , {'IPI'});
                colorz = colIPI(3,1:3);
                figure('color' , 'white');
                lineplot([IPIs.BN] , IPIs.normIPI , 'plotfcn' , 'nanmean',...
                    'split', IPIs.ChunkBndry , 'linecolor' , colorz,...
                    'errorcolor' , colorz , 'errorbars' , {'shade'}  , 'shadecolor' ,colorz,...
                    'linewidth' , 3 , 'markertype' , repmat({'o'} , 1  , 2) , 'markerfill' , colorz,...
                    'markersize' , 10, 'markercolor' , colorz , 'leg' , {'Random'  , 'First' , 'Middle'});
                set(gca,'FontSize' , 18 , ...
                    'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [270 460],'YTick' , [290:30:460] ,...
                    'YTickLabels' , [0.29:.03:0.46] , 'YGrid' , 'on');
                xlabel('Training Block')
                ylabel('Inter-press interval time [s]')
            case 'IPIFullDisp'
                IPIs  = tapply(IPItable , {'Day' ,'SN' , 'prsnumb' , 'seqNumb'} , {'IPI' , 'nanmean(x)'});
                IPIs = normData(IPIs , {'IPI'});
                figure('color' , 'white');
                for sqn = 0:1
                    subplot(1,2,sqn+1)
                    colorz = colz(1:length(dayz),sqn+1);
                    lineplot([IPIs.prsnumb] , IPIs.normIPI , 'plotfcn' , 'nanmean',...
                        'split', IPIs.Day , 'subset' , IPIs.seqNumb == sqn , 'linecolor' , colorz,...
                        'errorcolor' , colorz , 'errorbars' , {'shade'}  , 'shadecolor' ,colorz,...
                        'linewidth' , 3 , 'markertype' , repmat({'o'} , 1  , 2) , 'markerfill' , colorz,...
                        'markersize' , 10, 'markercolor' , colorz , 'leg' , {'Day1' , 'Day2' , 'Day3' , 'Day4'});
                    set(gca,'FontSize' , 18 , ...
                        'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [180 440],'YTick' , [200:40:440] ,...
                        'YTickLabels' , [0.2:.04:0.44] , 'YGrid' , 'on');
                    xlabel('IPI number')
                    ylabel('Inter-press interval time [s]')
                    if sqn>0
                        set(gca,'YColor' , 'none');
                    end
                end
        end
    case 'RT'
        ANA = getrow(Dall , Dall.isgood & ismember(Dall.seqNumb , [0 1:6]) & ~Dall.isError);
        ANA.seqNumb(ANA.seqNumb >=1) = 1;
        
        ANA.RT = ANA.AllPressTimes(:,1)-1500;
        
        for d = 1:length(dayz)
            ANA.Day(ismember(ANA.Day , dayz{d})) = d;
        end
        MT = tapply(ANA , {'BN' , 'seqNumb' , 'SN' , 'Day'} , {'RT'});
        MT = normData(MT , {'RT'});
        % segments
        ANA = getrow(Dall , Dall.isgood & ~ismember(Dall.seqNumb , [0 1:6]) & ~Dall.isError);
        ANA.seqNumb(ismember(ANA.seqNumb ,[102 202])) = 2;
        ANA.seqNumb(ismember(ANA.seqNumb ,[103 203])) = 3;
        ANA.seqNumb(ismember(ANA.seqNumb ,[104 204])) = 4;
        ANA.RT = ANA.AllPressTimes(:,1)-1500;
        
        for d = 1:length(dayz)
            ANA.Day(ismember(ANA.Day , dayz{d})) = d;
        end
        RTseg = tapply(ANA , {'BN' , 'seqNumb' , 'SN'} , {'RT'});
        RTseg = normData(RTseg , {'RT'});
        
        switch nowWhat
            case 'RandvsStructCommpare'
                figure('color' , 'white');
                colorz = colz(3,1:2);
                lineplot([MT.BN] , MT.normRT , 'plotfcn' , 'nanmean',...
                    'split', MT.seqNumb , 'linecolor' , colorz,...
                    'errorcolor' , colorz , 'errorbars' , repmat({'shade'} , 1 , 2) , 'shadecolor' ,colorz,...
                    'linewidth' , 3 , 'markertype' , repmat({'o'} , 1  , 2) , 'markerfill' , colorz,...
                    'markersize' , 10, 'markercolor' , colorz , 'leg' , {'Random'  , 'Structured'} );
                set(gca,'FontSize' , 18 , ...
                    'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [550 1000],'YTick' , [600:50:1000] ,...
                    'YTickLabels' , [0.6:.05:1] , 'YGrid' , 'on');
                xlabel('Training Block')
                ylabel('Initial reaction time [s]')
            case 'Segments'
                figure('color' , 'white');
                colorz = colIPI(3,1:3);
                lineplot([RTseg.BN] , RTseg.normRT , 'plotfcn' , 'nanmean',...
                    'split', RTseg.seqNumb , 'linecolor' , colorz,...
                    'errorcolor' , colorz , 'errorbars' , repmat({'shade'} , 1 , 3) , 'shadecolor' ,colorz,...
                    'linewidth' , 3 , 'markertype' , repmat({'o'} , 1  , 3) , 'markerfill' , colorz,...
                    'markersize' , 10, 'markercolor' , colorz , 'leg' , {'Duoble'  , 'Triplet' , 'Quadruple'});
                set(gca,'FontSize' , 18 , ...
                    'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [500 950],'YTick' , [550:50:900] ,...
                    'YTickLabels' , [0.55:.05:0.9] , 'YGrid' , 'on');
                
                xlabel('Training Block')
                ylabel('Initial reaction time [s]')
        end
    case 'Eye'
        calc = 1;
        if isSymmetric
            filename = 'se1_eyeInfo.mat';
        else
            filename = 'se1_eyeInfo_asym.mat';
        end
        if calc
            eyeinfo.PB         = [];   % preview benefit
            eyeinfo.CB         = [];   % chunk boundry
            eyeinfo.Horizon    = [];
            eyeinfo.sn         = [];
            eyeinfo.Day        = [];
            eyeinfo.BN         = [];
            eyeinfo.TN         = [];
            eyeinfo.sacPerSec  = [];
            eyeinfo.sacDur     = [];
            eyeinfo.sacPeakVel = [];
            eyeinfo.sacAmp     = [];
            eyeinfo.seqNumb    = [];
            eyeinfo.DigFixDur  = [];
            eyeinfo.prsnumb    = [];
            eyeinfo.prstimepos = [];
            ANA = getrow(Dall ,ismember(Dall.seqNumb , [0:6]) & ismember(Dall.SN , subjnum) & Dall.isgood & ~Dall.isError & cellfun(@length , Dall.xEyePosDigit)>1);
            
            for tn  = 1:length(ANA.TN)
                if ismember(ANA.seqNumb(tn) , [1:2])
                    ANA.ChunkBndry(tn , :) = [1 diff(ANA.ChnkArrang(tn,:))];
                    a = find(ANA.ChunkBndry(tn , :));
                    ANA.ChunkBndry(tn , a(2:end)-1) = 3;
                    ANA.ChunkBndry(tn ,end) = 3;
                    ANA.ChunkBndry(tn , ANA.ChunkBndry(tn , :) == 0) = 2;
                else
                    ANA.ChunkBndry(tn , :) = zeros(size(ANA.ChnkArrang(tn , :)));
                end
                ANA.DigFixWeighted(tn , :) = zeros(1 ,14);
                window = 50;
                if isSymmetric
                    for p = 1:14
                        id = ANA.xEyePosDigit{tn , 1}<=p+.5 & ANA.xEyePosDigit{tn , 1}>p-.5;
                        if sum(id)
                            ANA.DigFixWeighted(tn , p) = mean(abs(ANA.xEyePosDigit{tn , 1}(id) - p))*(sum(id)/500)*1000;
                        else
                            ANA.DigFixWeighted(tn , p) = 0;
                        end
                    end
                else
                    for p = 1:14
                        id = ANA.xEyePosDigit{tn , 1}<=p+.3 & ANA.xEyePosDigit{tn , 1}>p-.7;
                        if sum(id)
                            ANA.DigFixWeighted(tn , p) = mean(abs(ANA.xEyePosDigit{tn , 1}(id) - p))*(sum(id)/500)*1000;
                        else
                            ANA.DigFixWeighted(tn , p) = 0;
                        end
                    end
                    
                end
                
                for p = 1:14
                    id = [ANA.AllPressIdx(tn , p) - window/2 :ANA.AllPressIdx(tn , p) + window/2];
                    if id(1) > length(ANA.xEyePosDigit{tn}) | sum(id<0)>0
                        ANA.EyePressTimePos(tn , p) = NaN;
                    elseif id(end)>length(ANA.xEyePosDigit{tn})
                        ANA.EyePressTimePos(tn , p) = nanmedian(ANA.xEyePosDigit{tn}(id(1):end));
                    else
                        ANA.EyePressTimePos(tn , p) = nanmedian(ANA.xEyePosDigit{tn}(id));
                    end
                end
                perv_Ben           = [1:14] - ANA.EyePressTimePos(tn , :);
                goodid             = ~(abs(perv_Ben)>=3.5);
                prsnumb            = find(goodid);
                count              = sum(goodid);
                eyeinfo.PB         = [eyeinfo.PB ;perv_Ben(goodid)'];
                eyeinfo.prsnumb    = [eyeinfo.prsnumb ;find(goodid')];
                eyeinfo.CB         = [eyeinfo.CB ;ANA.ChunkBndry(tn ,goodid)'];
                eyeinfo.Horizon    = [eyeinfo.Horizon ; ANA.Horizon(tn)*ones(count , 1)];
                eyeinfo.sn         = [eyeinfo.sn ; ANA.SN(tn)*ones(count , 1)];
                eyeinfo.Day        = [eyeinfo.Day ; ANA.Day(tn)*ones(count , 1)];
                eyeinfo.BN         = [eyeinfo.BN ; ANA.BN(tn)*ones(count , 1)];
                eyeinfo.TN         = [eyeinfo.TN ; ANA.TN(tn)*ones(count , 1)];
                eyeinfo.sacPerSec  = [eyeinfo.sacPerSec ; ANA.SaccPerSec(tn)*ones(count , 1)];
                eyeinfo.sacDur     = [eyeinfo.sacDur ; mean(ANA.SaccDuration{tn})*ones(count , 1)];
                eyeinfo.sacPeakVel = [eyeinfo.sacPeakVel ; mean(ANA.SaccPeakVel{tn})*ones(count , 1)];
                eyeinfo.sacAmp     = [eyeinfo.sacAmp ; mean(ANA.SaccAmplitude{tn})*ones(count , 1)];
                eyeinfo.seqNumb    = [eyeinfo.seqNumb ; ANA.seqNumb(tn)*ones(count , 1)];
                eyeinfo.DigFixDur  = [eyeinfo.DigFixDur ;ANA.DigFixWeighted(tn ,goodid)'];
                eyeinfo.prstimepos = [eyeinfo.prstimepos ;ANA.EyePressTimePos(tn ,goodid)'];
            end
            
            save([baseDir , '/' , filename] , 'eyeinfo','-v7.3')
        else
            load([baseDir , '/', filename])
        end
        out = [];
        switch nowWhat
            case 'sacDurSplitDay'
                
                K = tapply(eyeinfo , {'Day', 'sn','seqNumb'} , {'sacDur' , 'nanmean'} , ...
                    'subset' , ismember(eyeinfo.prsnumb , [4:10]));
                K.seqNumb(K.seqNumb>1) = 1;
                K = normData(K , {'sacDur'});
                figure('color' , 'white')
                colorz = avgCol(1:2:6);
                lineplot([K.seqNumb] , K.normsacDur , 'plotfcn' , 'nanmean',...
                    'split', K.Day , 'subset' , ismember(K.Day , [2:4]) , 'leg' , 'auto' , 'linecolor' , colorz,...
                    'errorcolor' , colorz , 'errorbars' , repmat({'shade'} , 1 , length(dayz)) , 'shadecolor' ,colorz,...
                    'linewidth' , 3 , 'markertype' , repmat({'o'} , 1  , length(dayz)) , 'markerfill' , colorz,...
                    'markersize' , 10, 'markercolor' , colorz);
                ylabel('Mean Saccade duration per trial [ms]' )
                xlabel('Sequence Type' )
                set(gca,'FontSize' , 18 ,'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [53  57] ,...
                    'YGrid' , 'on' , 'XTick' , [0:1] , 'XTickLabels' , {'Random' , 'Structured'});
            case 'sacAmpSplitDay'
                K = tapply(eyeinfo , {'Day', 'sn','seqNumb'} , {'sacAmp' , 'nanmean'} , ...
                    'subset' , ismember(eyeinfo.prsnumb , [4:10]));
                K.seqNumb(K.seqNumb>1) = 1;
                K = normData(K , {'sacAmp'});
                figure('color' , 'white')
                colorz = avgCol(1:2:6);
                lineplot([K.seqNumb] , K.normsacAmp , 'plotfcn' , 'nanmean',...
                    'split', K.Day , 'subset' , ismember(K.Day , [2:4]) , 'leg' , 'auto' , 'linecolor' , colorz,...
                    'errorcolor' , colorz , 'errorbars' , repmat({'shade'} , 1 , length(dayz)) , 'shadecolor' ,colorz,...
                    'linewidth' , 3 , 'markertype' , repmat({'o'} , 1  , length(dayz)) , 'markerfill' , colorz,...
                    'markersize' , 10, 'markercolor' , colorz);
                ylabel('Mean Saccade Amplitude per trial [deg]' )
                xlabel('Sequence Type' )
                set(gca,'FontSize' , 18 ,'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [1.8 3.8 ] ,...
                    'YGrid' , 'on' , 'XTick' , [0:1] , 'XTickLabels' , {'Random' , 'Structured'});
            case 'sacFreqSplitDay'
                K = tapply(eyeinfo , {'Day', 'sn','seqNumb'} , {'sacPerSec' , 'nanmean'} , ...
                    'subset' , ismember(eyeinfo.prsnumb , [4:10]));
                K.seqNumb(K.seqNumb>1) = 1;
                K = normData(K , {'sacPerSec'});
                figure('color' , 'white')
                colorz = avgCol(1:2:6);
                lineplot([K.seqNumb] , K.normsacPerSec , 'plotfcn' , 'nanmean',...
                    'split', K.Day , 'subset' , ismember(K.Day , [2:4]) , 'leg' , 'auto' , 'linecolor' , colorz,...
                    'errorcolor' , colorz , 'errorbars' , repmat({'shade'} , 1 , length(dayz)) , 'shadecolor' ,colorz,...
                    'linewidth' , 3 , 'markertype' , repmat({'o'} , 1  , length(dayz)) , 'markerfill' , colorz,...
                    'markersize' , 10, 'markercolor' , colorz);
                ylabel('Mean Saccade frequency [Hz]' )
                xlabel('Viewing window Size' )
                title('Random Sequences')
                set(gca,'FontSize' , 18 ,'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [1.9 2.6] ,...
                    'YGrid' , 'on');
            case 'FixDurSplitipitype'
                K = tapply(eyeinfo , {'Day' , 'sn','CB'} , {'DigFixDur' , 'nanmean'} , ...
                    'subset' , ismember(eyeinfo.prsnumb , [4:10]));
                K = normData(K , {'DigFixDur'});
                colorz = avgCol(1:2:6);
                figure('color' , 'white')
                lineplot([K.CB] , K.normDigFixDur , 'plotfcn' , 'nanmean',...
                    'split', K.Day , 'subset' , ismember(K.Day , [2 3 4]) , 'leg' , {'Day2' , 'Day3' , 'Day4' } , 'linecolor' , colorz,...
                    'errorcolor' , colorz , 'errorbars' , repmat({'shade'} , 1 , 2) , 'shadecolor' ,colorz,...
                    'linewidth' , 3 , 'markertype' , repmat({'o'} , 1  , 2) , 'markerfill' , colorz,...
                    'markersize' , 10, 'markercolor' , colorz);
                ylabel('Mean digit fixation Duration [ms]' )
                xlabel('Viewing window Size' )
                title('Digit fixation duration')
                set(gca,'FontSize' , 18 ,'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [65 90],'YTick' , [70:5:90] ,...
                    'YGrid' , 'on' , 'XTickLabel' , {'Random' , 'First' , 'Middle' , 'Last'});
            case 'previewSplitipitype'
                K = tapply(eyeinfo , {'Day' , 'sn','CB'} , {'PB' , 'nanmean'} , ...
                    'subset' , ismember(eyeinfo.prsnumb , [4:10]));
                K = normData(K , {'PB'});
                colorz = avgCol(1:2:6);
                figure('color' , 'white')
                lineplot([K.CB] , -K.normPB , 'plotfcn' , 'nanmean',...
                    'split', K.Day , 'subset' , ismember(K.Day , [2:4]) , 'leg' , {'Day2' , 'Day3' , 'Day4' } , 'linecolor' , colorz,...
                    'errorcolor' , colorz , 'errorbars' , repmat({'shade'} , 1 , 2) , 'shadecolor' ,colorz,...
                    'linewidth' , 3 , 'markertype' , repmat({'o'} , 1  , 2) , 'markerfill' , colorz,...
                    'markersize' , 10, 'markercolor' , colorz);
                ylabel('Mean preview [digits]' )
                xlabel('IPI type' )
                title(['Look-ahead'])
                set(gca,'FontSize' , 18 ,'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [.5 1.1],'YTick' , [.6:.1:1.1] ,...
                    'YGrid' , 'on', 'XTickLabel' , {'Random' , 'First' , 'Middle' , 'Last'});
            case 'EyePrsTimePos'
                K = tapply(eyeinfo , {'Day' , 'sn','seqNumb' , 'prsnumb'} , {'prstimepos' , 'nanmean'});
                K = normData(K , {'prstimepos'});
                colorz = avgCol(1:2:6);
                figure('color' , 'white')
                for sqn = 0:6
                    subplot(1,7 , sqn+1)
                    lineplot([K.prsnumb] , K.normprstimepos , 'plotfcn' , 'nanmean',...
                        'split', K.Day , 'subset' , ismember(K.seqNumb , sqn) & ismember(K.Day , [2:4]) , 'linecolor' , colorz,...
                        'errorcolor' , colorz , 'errorbars' , repmat({'shade'} , 1 , length(dayz)) , 'shadecolor' ,colorz,...
                        'linewidth' , 3 , 'markertype' , repmat({'o'} , 1  , length(dayz)) , 'markerfill' , colorz,...
                        'markersize' , 10, 'markercolor' , colorz);
                    ylabel('Eye position [digits]' )
                    xlabel('Press position' )
                    title(['seqNum = ' , num2str(sqn) ])
                    axis square
                    set(gca,'FontSize' , 18 ,'GridAlpha' , .2 , 'Box' , 'off' , 'YLim' , [1 14],'YTick' , [1 : 14] ,...
                        'XLim' , [1 14],'XTick' , [1 : 14],'YGrid' , 'on' , 'XGrid' , 'on');
                    if sqn<6
                        set(gca,'YColor' , 'none');
                    end
                end
        end
end


