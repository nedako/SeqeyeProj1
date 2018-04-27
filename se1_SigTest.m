function stats = se1_SigTest(Dall , what , varargin)

c=  1;
PoolSequences = 0;
PoolDays = 1;
PoolHorizons = [];
subjnum = [1:13];
while(c<=length(varargin))
    switch(varargin{c})
        case {'seqNumb'}
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'PoolSequences'}
            % whether to pool together all the sequences
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
            c=c+2;
        case {'Day'}
            % defines the length of the sequence
            % default is 10
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'whatIPI'}
            % required when what = 'IPI'
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'ipiOfInterest'}
            % in the case of 'ipiOfInterest' IPI of interest to test --> Steady State =[4:10]
            % in the case of 'compareLearning' 0 1 2
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'poolIPIs'}
            % in the case of 'compareLearning'
            % 'Pool [Random and Between (1)] , [within and between (2) , [nothing (0)]]
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'subjnum'}
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        case {'isSymmetric'}
            % for EYE gaze filed around a digit symmetric or not(0 no/1 yes);
            eval([varargin{c} '= varargin{c+1};']);
            c=c+2;
        otherwise
            error(sprintf('Unknown option: %s',varargin{c}));
    end
end

% baseDir = '/Users/nedakordjazi/Documents/SeqEye/SeqEye2/analyze';     %macbook
baseDir = '/Users/nkordjazi/Documents/SeqEye/SeqEye2/analyze';          %iMac


ANA = getrow(Dall , Dall.isgood & ~Dall.isError & ...
    ismember(Dall.Day , Day) & ismember(Dall.seqNumb , seqNumb) & ismember(Dall.SN , subjnum));


if ismember(what , {'PercentseqType' , 'PercentIPItype'})
    % day 1 has to be included
    ANA = getrow(Dall , Dall.isgood & ~Dall.isError & ...
        ismember(Dall.Horizon , Horizon) & ...
        ismember(Dall.Day ,[1 Day]) & ismember(Dall.seqNumb , seqNumb) &ismember(Dall.SN , subjnum));
end


ANA.RT = ANA.AllPressTimes(:,1);
ANA.seqNumb(ANA.seqNumb>1) = 1;
if PoolSequences
    ANA.seqNumb = zeros(size(ANA.seqNumb));
end




factors = {'Day' , 'seqNumb'};
facInclude = [length(unique(ANA.Day))>1  , length(unique(ANA.seqNumb))>1];
FCTR =  factors(facInclude);

switch what
    case 'MT'
        var = [];
        for f = 1:length(FCTR)
            eval(['var = [var ANA.',FCTR{f},'];']);
        end
        if length(subjnum) == 1
            stats = anovan(ANA.MT,var,'model','interaction','varnames',FCTR , 'display' , 'off') ; % between subject;
        else
            stats = anovaMixed(ANA.MT  , ANA.SN ,'within',var ,FCTR,'intercept',1) ;
        end
        figure('color' , 'white')
        lineplot(var, ANA.MT , 'style_shade' , 'markertype' , 'o'  , ...
            'markersize' , 10 , 'markerfill' , 'w');
        tAdd = FCTR{1};
        for f =2:length(FCTR)
            tAdd = [tAdd , ' and ' , FCTR{f}];
        end
        title(['Effect of ' , tAdd ,' on Execution Time']);
        grid on
        set(gca , 'FontSize' , 20 , 'Box' , 'off')
        xlabel(FCTR{end})
        ylabel('msec')
    case 'IPI'

        switch whatIPI
            case 'ipiOfInterest'
                ipi = ANA.IPI(:,ipiOfInterest);
                A.IPI = reshape(ipi , numel(ipi) , 1);
                A.Day = repmat(ANA.Day , size(ipi , 2) , 1);
                A.seqNumb = repmat(ANA.seqNumb , size(ipi , 2) , 1);
                A.SN = repmat(ANA.SN , size(ipi , 2) , 1);
                var = [];
                for f = 1:length(FCTR)
                    eval(['var = [var A.',FCTR{f},'];']);
                end
                stats = anovaMixed(A.IPI  , A.SN ,'within',var ,FCTR,'intercept',1) ;
                figure('color' , 'white')
                lineplot(var, A.IPI, 'style_thickline');
                title(['Effect of ' , FCTR , ' on ' , what]);
            case 'ipiOfInterestToSS'
                figure('color' , 'white')
                ANA1 = getrow(Dall , Dall.isgood & ~Dall.isError & ...
                    ismember(Dall.Day , Day) & ismember(Dall.seqNumb , seqNumb));
                subplot(211)
                ipiNum = repmat([1:size(ANA1.AllPress , 2)-1] , size(ANA1.IPI , 1) , 1);
                ipiNum(ismember(ipiNum , [4:10])) = 7 ; % steady state
                
                ipiss = ANA.IPI(:,4:10);
                ipibeg = ANA.IPI(:,ipiOfInterest);
                
                label = [ones(numel(ipibeg) , 1) ;zeros(numel(ipiss) ,1)];
                A.IPI = [reshape(ipibeg , numel(ipibeg) , 1);reshape(ipiss , numel(ipiss) , 1)];
                A.Day = repmat(ANA.Day , size(ipibeg , 2)+size(ipiss , 2) , 1);
                A.seqNumb = repmat(ANA.seqNumb , size(ipibeg , 2)+size(ipiss , 2) , 1);
                A.SN = repmat(ANA.SN , size(ipibeg , 2)+size(ipiss , 2) , 1);
                var = [];
                for f = 1:length(FCTR)
                    eval(['var = [var A.',FCTR{f},'];']);
                end
                var = [var label];
                FCTR = [FCTR , 'beg/end vs SS'];
                tAdd = FCTR{1};
                for f =2:length(FCTR)
                    tAdd = [tAdd , ' and ' , FCTR{f}];
                end
                stats = anovaMixed(A.IPI  , A.SN ,'within',var ,FCTR,'intercept',1) ;
                subplot(212)
                lineplot(var, A.IPI, 'style_thickline');
                title(['Effect of ' , tAdd , ' on ' , what ,' , 0 is steady state']);
            case 'AllToSS'
                calc = 0;
                if calc
                    ipi = [1 2 3 11 12 13];
                    for sn = 0:2
                        for d = 1:length(Day)
                            for p = 1:length(ipi)
                                stats = se2_SigTest(Dall , 'IPI' , 'seqNumb' , [sn] , 'Day' , Day{d} ,'PoolSequences' , 1,...
                                    'whatIPI','ipiOfInterestToSS','ipiOfInterest' , ipi(p));
                                pval{sn+1 , d}(p) = stats.eff(2).p;
                                close all
                                
                            end
                        end
                        
                    end
                    save('/Users/nkordjazi/Documents/SeqEye/SeqEye2/analyze/se2_IPIsigTest.mat' , 'pval')
                else
                    load('/Users/nkordjazi/Documents/SeqEye/SeqEye2/analyze/se2_IPIsigTest.mat')
                end
                i = 1;
                SN = {'Random' , 'Sructure 1,4 4 3 3' , 'Structure 2, 3 4 3 4'};
                Days = {'Day 1' , 'Days 2, 3' , 'Days 4, 5'};
                figure('color' , 'white')
                for d = 1:3
                    for sn = 1:3
                        subplot(3,3,i)
                        A = ones(9,13);
                        A (:,1:3)   = pval{sn , d}(:,1:3);
                        A (:,11:13) = pval{sn , d}(:,4:6);
                        A(A<=0.05) = 2;
                        A(A~=2 & A~=1) = 0;
                        imagesc(A)
                        title([SN{sn} , ' on ' , Days{d}])
                        hold on
                        for h = .5:1:11.5
                            line([h+1 h+1], [.5 9.5] , 'color' , 'k' , 'LineWidth' , 2);
                        end
                        for p = .5:1:7.5
                            line([.5 13.5] ,[p+1 p+1], 'color' , 'k' , 'LineWidth' , 2);
                        end
                        set(gca , 'XTick' , [1:13] , 'YTick' , [1:9] , 'YTickLabel' , [1:8 , 13] , 'FontSize' , 16);
                        xlabel('IPI number')
                        ylabel('Viewing Horizon Size')
                        i = i +1;
                    end
                end
                
                stats = pval;
            case 'WithBetRand'
                ipiss = ANA.IPI(:,4:10);
                FCTR = FCTR(~strcmp(FCTR,'seqNumb'));
                nn= ipiOfInterest;
                mm= poolIPIs;
                ipiLab = {'Random' , 'Between','Within'};
                ipiLab = ipiLab(nn+1);
                L = ipiLab{1};
                for l = 2:length(ipiLab)
                    L = [L,'/',ipiLab{l}];
                end
                A.IPIArr= reshape(ANA.IPIarrangement(:,4:10) , numel(ipiss) , 1);
                
                switch mm
                    case{1}
                        A.IPIArr(A.IPIArr==1) = 0;
                    case {2}
                        A.IPIArr(A.IPIArr==2) = 1;
                end
                A.IPI = reshape(ipiss , numel(ipiss) , 1);
                A.Day = repmat(ANA.Day , size(ipiss , 2) , 1);
                A.seqNumb = repmat(ANA.seqNumb , size(ipiss , 2) , 1);
                A.SN = repmat(ANA.SN , size(ipiss , 2) , 1);
                A = getrow(A , ismember(A.IPIArr , nn));
                %% sig test on the IPIs
                var = [];
                for f = 1:length(FCTR)
                    eval(['var = [var A.',FCTR{f},'];']);
                end
                if length(ipiLab)>1
                    var = [A.IPIArr var];
                    FCTR = [L FCTR];
                end
                stats = anovaMixed(A.IPI  , A.SN ,'within',var ,FCTR,'intercept',1) ;
                %% sig test on the median IPIs
                %                 B = tapply(A , {'Horizon' , 'Day' ,'SN' , 'seqNumb','IPIArr'} , {'IPI' , 'nanmedian(x)'});
                %                 var = [];
                %                 for f = 1:length(FCTR)
                %                     eval(['var = [var B.',FCTR{f},'];']);
                %                 end
                %                 if length(ipiLab)>1
                %                     var = [B.IPIArr var];
                %                     FCTR = [L FCTR];
                %                 end
                %                 stats = anovaMixed(B.IPI  , B.SN ,'within',var ,FCTR,'intercept',1) ;
                %%
                
%                 var = [];
%                 for f = 1:length(FCTR)
%                     eval(['var = [var A.',FCTR{f},'];']);
%                 end
%                 if length(ipiLab)>1
%                     var = [A.IPIArr var];
%                     FCTR = [L FCTR];
%                 end
                A = normData(A, {'IPI'});
                figure('color' , 'white')
                subplot(211)
                lineplot(var, A.IPI , 'style_shade' , 'markertype' , 'o'  , ...
                    'markersize' , 10 , 'markerfill' , 'w');
                tAdd = FCTR{1};
                for f =2:length(FCTR)
                    tAdd = [tAdd , ' and ' , FCTR{f}];
                end
                title(['Effect of ' , tAdd ,' on Execution Time']);
                grid on
                set(gca , 'FontSize' , 20 , 'Box' , 'off')
                xlabel(FCTR{end})
                ylabel('msec')
                A.IPI = A.normIPI;
                subplot(212)
                lineplot(var, A.IPI , 'style_shade' , 'markertype' , 'o'  , ...
                    'markersize' , 10 , 'markerfill' , 'w');
                tAdd = FCTR{1};
                for f =2:length(FCTR)
                    tAdd = [tAdd , ' and ' , FCTR{f}];
                end
                title(['Effect of ' , tAdd ,' on Execution Time']);
                grid on
                set(gca , 'FontSize' , 20 , 'Box' , 'off')
                xlabel(FCTR{end})
                ylabel('msec')
        end
    case 'RT'
        var = [];
        for f = 1:length(FCTR)
            eval(['var = [var ANA.',FCTR{f},'];']);
        end
        stats = anovaMixed(ANA.RT  , ANA.SN ,'within',var ,FCTR,'intercept',1) ;
        figure('color' , 'white')
        lineplot(var, ANA.RT-1500, 'style_thickline');
        title(['Effect of ' , FCTR , ' on ' , what]);
    case 'Eye_seq_sacPerSec'
        if isSymmetric
            filename = 'se2_eyeInfo.mat';
        else
            filename = 'se2_eyeInfo_asym.mat';
        end
        load([baseDir , '/', filename]);
        
            eyeinfo = getrow(eyeinfo , ismember(eyeinfo.Horizon , Horizon) & ...
            ismember(eyeinfo.Day , Day) & ismember(eyeinfo.seqNumb , seqNumb) &ismember(eyeinfo.sn , subjnum));

        
        
      
        eyeinfo.seqNumb(eyeinfo.seqNumb>1) = 1;
        if PoolSequences
            eyeinfo.seqNumb = zeros(size(eyeinfo.seqNumb));
        end
        if PoolDays
            eyeinfo.Day(eyeinfo.Day == 3) = 2;
            eyeinfo.Day(ismember(eyeinfo.Day , [4,5])) = 3;
        end
        if ~isempty(PoolHorizons)
            eyeinfo.Horizon(ismember(eyeinfo.Horizon ,PoolHorizons)) = PoolHorizons(1);
            Horizon = unique(eyeinfo.Horizon);
        end
        
        
        eyeinfo = getrow(eyeinfo , ~isnan(eyeinfo.sacPerSec));
        var = [];
        for f = 1:length(FCTR)
            eval(['var = [var eyeinfo.',FCTR{f},'];']);
        end
        stats = anovaMixed(eyeinfo.sacPerSec  , eyeinfo.sn ,'within',var ,FCTR,'intercept',1) ;
        figure('color' , 'white')
        lineplot(var, eyeinfo.sacPerSec, 'style_thickline');
        title(['Effect of ' , FCTR , ' on ' , what]);
    case 'Eye_seq_sacAmp'
        if isSymmetric
            filename = 'se2_eyeInfo.mat';
        else
            filename = 'se2_eyeInfo_asym.mat';
        end
        load([baseDir , '/', filename]);
        
        eyeinfo = getrow(eyeinfo , ismember(eyeinfo.Horizon , Horizon) & ...
            ismember(eyeinfo.Day , Day) & ismember(eyeinfo.seqNumb , seqNumb) &ismember(eyeinfo.sn , subjnum));
        eyeinfo.seqNumb(eyeinfo.seqNumb>1) = 1;
        if PoolSequences
            eyeinfo.seqNumb = zeros(size(eyeinfo.seqNumb));
        end
        if PoolDays
            eyeinfo.Day(eyeinfo.Day == 3) = 2;
            eyeinfo.Day(ismember(eyeinfo.Day , [4,5])) = 3;
        end
        if ~isempty(PoolHorizons)
            eyeinfo.Horizon(ismember(eyeinfo.Horizon ,PoolHorizons)) = PoolHorizons(1);
            Horizon = unique(eyeinfo.Horizon);
        end
        
        
        eyeinfo = getrow(eyeinfo , ~isnan(eyeinfo.sacAmp));
        var = [];
        for f = 1:length(FCTR)
            eval(['var = [var eyeinfo.',FCTR{f},'];']);
        end
        stats = anovaMixed(eyeinfo.sacAmp  , eyeinfo.sn ,'within',var ,FCTR,'intercept',1) ;
        figure('color' , 'white')
        lineplot(var, eyeinfo.sacAmp, 'style_thickline');
        title(['Effect of ' , FCTR , ' on ' , what]);
    case 'Eye_seq_sacDur'
        if isSymmetric
            filename = 'se2_eyeInfo.mat';
        else
            filename = 'se2_eyeInfo_asym.mat';
        end
        load([baseDir , '/', filename]);
        
        eyeinfo = getrow(eyeinfo , ismember(eyeinfo.Horizon , Horizon) & ...
            ismember(eyeinfo.Day , Day) & ismember(eyeinfo.seqNumb , seqNumb) &ismember(eyeinfo.sn , subjnum));
        eyeinfo.seqNumb(eyeinfo.seqNumb>1) = 1;
        if PoolSequences
            eyeinfo.seqNumb = zeros(size(eyeinfo.seqNumb));
        end
        if PoolDays
            eyeinfo.Day(eyeinfo.Day == 3) = 2;
            eyeinfo.Day(ismember(eyeinfo.Day , [4,5])) = 3;
        end
        if ~isempty(PoolHorizons)
            eyeinfo.Horizon(ismember(eyeinfo.Horizon ,PoolHorizons)) = PoolHorizons(1);
            Horizon = unique(eyeinfo.Horizon);
        end
        
        
        eyeinfo = getrow(eyeinfo , ~isnan(eyeinfo.sacDur));
        var = [];
        for f = 1:length(FCTR)
            eval(['var = [var eyeinfo.',FCTR{f},'];']);
        end
        stats = anovaMixed(eyeinfo.sacDur  , eyeinfo.sn ,'within',var ,FCTR,'intercept',1) ;
        figure('color' , 'white')
        lineplot(var, eyeinfo.sacDur, 'style_thickline');
        title(['Effect of ' , FCTR , ' on ' , what]);
    case 'Eye_ipi_fixDur'
        if isSymmetric
            filename = 'se2_eyeInfo.mat';
        else
            filename = 'se2_eyeInfo_asym.mat';
        end
        load([baseDir , '/', filename]);
        
        eyeinfo = getrow(eyeinfo , ismember(eyeinfo.Horizon , Horizon) & ...
            ismember(eyeinfo.Day , Day) & ismember(eyeinfo.seqNumb , seqNumb) &ismember(eyeinfo.sn , subjnum));
        eyeinfo.seqNumb(eyeinfo.seqNumb>1) = 1;
        if PoolSequences
            eyeinfo.seqNumb = zeros(size(eyeinfo.seqNumb));
        end
        if PoolDays
            eyeinfo.Day(eyeinfo.Day == 3) = 2;
            eyeinfo.Day(ismember(eyeinfo.Day , [4,5])) = 3;
        end
        if ~isempty(PoolHorizons)
            eyeinfo.Horizon(ismember(eyeinfo.Horizon ,PoolHorizons)) = PoolHorizons(1);
            Horizon = unique(eyeinfo.Horizon);
        end
        
        
        eyeinfo = getrow(eyeinfo , ~isnan(eyeinfo.DigFixDur) & ismember(eyeinfo.CB , ipiOfInterest));
        
        
        
        FCTR = FCTR(~strcmp(FCTR,'seqNumb'));
        nn= ipiOfInterest;
        ipiLab = {'Random' , 'Between','Within','Last'};
        ipiLab = ipiLab(nn+1);
        L = ipiLab{1};
        for l = 2:length(ipiLab)
            L = [L,'/',ipiLab{l}];
        end
        
        if length(ipiLab)>1
            
            FCTR = [{'CB'} FCTR];
        end
        var = [];
        for f = 1:length(FCTR)
            eval(['var = [var eyeinfo.',FCTR{f},'];']);
        end
        
        
        stats = anovaMixed(eyeinfo.DigFixDur  , eyeinfo.sn ,'within',var ,FCTR,'intercept',1) ;
        figure('color' , 'white')
        lineplot(var, eyeinfo.DigFixDur, 'style_thickline');
        title(['Effect of ' , FCTR , ' on ' , what]);
    case 'Eye_ipi_lookahead'
        if isSymmetric
            filename = 'se2_eyeInfo.mat';
        else
            filename = 'se2_eyeInfo_asym.mat';
        end
        load([baseDir , '/', filename]);
        
        eyeinfo = getrow(eyeinfo , ismember(eyeinfo.Horizon , Horizon) & ...
            ismember(eyeinfo.Day , Day) & ismember(eyeinfo.seqNumb , seqNumb) &ismember(eyeinfo.sn , subjnum));
        eyeinfo.seqNumb(eyeinfo.seqNumb>1) = 1;
        if PoolSequences
            eyeinfo.seqNumb = zeros(size(eyeinfo.seqNumb));
        end
        if PoolDays
            eyeinfo.Day(eyeinfo.Day == 3) = 2;
            eyeinfo.Day(ismember(eyeinfo.Day , [4,5])) = 3;
        end
        if ~isempty(PoolHorizons)
            eyeinfo.Horizon(ismember(eyeinfo.Horizon ,PoolHorizons)) = PoolHorizons(1);
            Horizon = unique(eyeinfo.Horizon);
        end
        switch poolIPIs
            case{1}
                eyeinfo.CB(ismember(eyeinfo.CB ,[1 2 3])) = 1;
        end

        eyeinfo = getrow(eyeinfo , ~isnan(eyeinfo.PB) & ismember(eyeinfo.CB , ipiOfInterest));

        FCTR = FCTR(~strcmp(FCTR,'seqNumb'));
        nn= ipiOfInterest;
        ipiLab = {'Random' , 'Between','Within','Last'};
        ipiLab = ipiLab(nn+1);
        L = ipiLab{1};
        for l = 2:length(ipiLab)
            L = [L,'/',ipiLab{l}];
        end
        
        if length(ipiLab)>1
            
            FCTR = [{'CB'} FCTR];
        end
        var = [];
        for f = 1:length(FCTR)
            eval(['var = [var eyeinfo.',FCTR{f},'];']);
        end

        stats = anovaMixed(eyeinfo.PB  , eyeinfo.sn ,'within',var ,FCTR,'intercept',1) ;
        figure('color' , 'white')
        lineplot(var, eyeinfo.PB, 'style_thickline');
        title(['Effect of ' , FCTR , ' on ' , what]);
    case 'PerSubjMTHorz'
        clear pval effHorz
        seqN = {[0] , [1 2]};
        allcount = 1;
        for sn = 1:13
            dcount = 1;
            for d  = [1,5]
                for sq = 1:length(seqN)
                    effHorz.Day(allcount,1) = d;
                    effHorz.SN(allcount,1) = sn;
                    effHorz.sq(allcount,1) = sq;
                    for h = [1:8]
                        stats = se2_SigTest(Dall , 'MT' , 'seqNumb' , seqN{sq} , 'Day' , d , 'Horizon' , [h:13],...
                            'PoolDays' , 0,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
                            'PoolHorizons' , [],'ipiOfInterest' , [] , 'poolIPIs' , 0 , 'subjnum' , sn);
                        pval{sq}(sn,h,dcount) = stats(1);
                        close all
                    end
                    temp = squeeze(pval{sq}(sn,:,dcount));
                    effHorz.effH(allcount,1) = find(temp>0.05 ,1 , 'first');
                    allcount = allcount+1;
                end
                dcount = dcount+1;
            end
        end
        
        figure('color' , 'white')
        barplot([effHorz.Day effHorz.sq] ,effHorz.effH);
        set(gca , 'FontSize' , 18 , 'YLim' , [1 4] , 'YTick' , [1 2 3 4])
        title('The Effective Window Size Grows Significantly from First to Last Day in Random Sequences' , 'FontSize' , 24)
        ylabel('Viewing Window Size', 'FontSize' , 21)
    case 'PerSubjMTLearning'
        if PoolDays
            dayz = {[2] [5]};
        else
            dayz = {[2] , [3] , [4] , [5]};
        end
        horz = {[1] [2] [3] [4] [5] [6:13] }
        clear pval effHorz hval stats Learn
        % subject specific learning
        seqN = {[0] , [1 2]};
        allcount = 1;
        for sn = 1:13
            for sq = 1:length(seqN)
                for h = 1:length(horz)
                    for d  = 1:length(dayz)
                        stats = se2_SigTest(Dall , 'MT' , 'seqNumb' , seqN{sq} , 'Day' , [1,dayz{d}] , 'Horizon' , horz{h},...
                            'PoolDays' , 0,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
                            'PoolHorizons' , [6:13],'ipiOfInterest' , [] , 'poolIPIs' , 0 , 'subjnum' , [sn]);
                        Learn.sq(allcount , 1) = sq;
                        Learn.SN(allcount , 1) = sn;
                        Learn.Horizon(allcount , 1) = h;
                        Learn.Day(allcount , 1) = d;
                        Learn.isSig(allcount , 1) = stats<0.05;
                        allcount = allcount +1;
                    end
                end
            end
        end
        %         Learn = tapply(Learn , {'sq' , 'Horizon' , 'Day'} , {'isSig' , 'sum'});
        
        
        for sq = 1:length(seqN)
            figure('color' , 'white')
            barplot([ Learn.Horizon Learn.Day] ,Learn.isSig , 'subset' , Learn.sq == sq  ,'plotfcn' , 'sum','style_rainbow');% , 'split' , Learn.Day);
            set(gca , 'FontSize' , 18 , 'YLim' , [1 13] , 'YTick' , [1 :13])
            title('Number of Particpnats (N) Showing Significant Learning Effect in Different Viewing Window Sizes and Sessions' , 'FontSize' , 24)
            ylabel('N', 'FontSize' , 21)
        end
    case 'PercentseqType'
        
        dayz = unique(ANA.Day);
        D = ANA;
        ANA  = tapply(D , {'Horizon' , 'Day' ,'SN' , 'seqNumb'} , {'MT' , 'nanmean(x)'});
        ANA.percChangeMT = zeros(length(ANA.MT),length(dayz)-1);
        Seqbenefit = [];
        for d = 1:length(dayz)
            Db1= getrow(ANA , ismember(ANA.Day , dayz(d)) & ANA.seqNumb == 1);
            Db = getrow(ANA , ismember(ANA.Day , dayz(d)) & ANA.seqNumb == 0);
            Db1.percChangeMT = 100*abs((Db.MT - Db1.MT)./Db.MT);
            Seqbenefit = addstruct(Seqbenefit , Db1);
        end
        if ~isempty(find(ismember(FCTR  , 'seqNumb')))
            FCTR = FCTR(~ismember(FCTR  , 'seqNumb'));
        end
        var = [];
        for f = 1:length(FCTR)
            eval(['var = [var Seqbenefit.',FCTR{f},'];']);
        end
        if length(subjnum) == 1
            stats = anovan(Seqbenefit.percChangeMT,var,'model','interaction','varnames',FCTR , 'display' , 'off') ; % between subject;
        else
            stats = anovaMixed(Seqbenefit.percChangeMT  , Seqbenefit.SN ,'within',var ,FCTR,'intercept',1) ;
        end
        h1 = figure;
        hold on
        lineplot(var , Seqbenefit.percChangeMT , 'style_shade' , 'markertype' , 'o'  , ...
                     'markersize' , 10 , 'markerfill' , 'w');
    case 'PercentIPItype'
        % day 1 has to be included
        ANA = getrow(Dall , Dall.isgood & ~Dall.isError & ...
            ismember(Dall.Horizon , Horizon) & ...
            ismember(Dall.Day , [1 , Day]) & ismember(Dall.seqNumb , seqNumb) &ismember(Dall.SN , subjnum));
        dayz = unique(ANA.Day);
        
        nn= ipiOfInterest;
        ipiLab = {'Random' , 'Between','Within'};
        ipiLab = ipiLab(nn+1);
        L = ipiLab{1};
        for l = 2:length(ipiLab)
            L = [L,'/',ipiLab{l}];
        end

        ipiss = ANA.IPI(:,4:10);

        A.IPIArr= reshape(ANA.IPIarrangement(:,4:10) , numel(ipiss) , 1);

        A.IPI = reshape(ipiss , numel(ipiss) , 1);
        A.Horizon = repmat(ANA.Horizon , size(ipiss , 2) , 1);
        A.Day = repmat(ANA.Day , size(ipiss , 2) , 1);
        A.seqNumb = repmat(ANA.seqNumb , size(ipiss , 2) , 1);
        A.SN = repmat(ANA.SN , size(ipiss , 2) , 1);
        A = getrow(A , ismember(A.IPIArr , nn));
        
        
        
        ANA = A;
        ANA  = tapply(ANA , {'Horizon' , 'Day' ,'SN' , 'IPIArr'} , {'IPI' , 'nanmean(x)'});
        ANA.percChangeIPI = zeros(size(ANA.IPI));
        
        Daybenefit = [];
        for chp = nn
            for d = 1:length(dayz)
                Db1= getrow(ANA , ANA.Day == 1 & ANA.IPIArr==chp);
                Db5 = getrow(ANA , ANA.Day == dayz(d) & ANA.IPIArr==chp);
                Db5.percChangeIPI = 100*abs((Db1.IPI - Db5.IPI)./Db1.IPI);
                Daybenefit = addstruct(Daybenefit , Db5);
            end
        end
        Daybenefit = getrow(Daybenefit , Daybenefit.Day~=1);
        
        
        
        %% sig test on the IPIs
        FCTR = FCTR(~ismember(FCTR  , 'seqNumb'));
        
        if length(ipiLab)>1
            FCTR = [FCTR 'IPIArr'];
        end
        var = [];
        for f = 1:length(FCTR)
            eval(['var = [var Daybenefit.',FCTR{f},'];']);
        end
        stats = anovaMixed(Daybenefit.percChangeIPI  , Daybenefit.SN ,'within',var ,FCTR,'intercept',1) ;
        
        

end