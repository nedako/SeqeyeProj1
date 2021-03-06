 %% plotting recipes
 Dall = Dall1;
out  = se1_pubFigs(Dall , 'MT','RandvsStructCommpare'); 
out  = se1_pubFigs(Dall , 'MT','Segments' , 'poolDays' , 0); 

out  = se1_pubFigs(Dall , 'IPI','IPIcompareTypes');
out  = se1_pubFigs(Dall , 'IPI','compareLearning', 'poolDays' , 0);
out  = se1_pubFigs(Dall , 'IPI','compareLearning_histogram', 'poolDays' , 0);

out  = se1_pubFigs(Dall , 'RT','RandvsStructCommpare'); 
out  = se1_pubFigs(Dall , 'RT','Segments' , 'poolDays' , 0);


out  = se1_pubFigs(Dall , 'Eye', 'sacDurSplitDay' , 'isSymmetric' , 1 , 'poolDays' , 0);
out  = se1_pubFigs(Dall , 'Eye', 'sacAmpSplitDay' , 'isSymmetric' , 1 , 'poolDays' , 0);
out  = se1_pubFigs(Dall , 'Eye', 'sacFreqSplitDay' , 'isSymmetric' , 1 , 'poolDays' , 0);

out  = se1_pubFigs(Dall , 'Eye', 'FixDurSplitipitype' , 'isSymmetric' , 1 , 'poolDays' , 0);
out  = se1_pubFigs(Dall , 'Eye', 'previewSplitipitype' , 'isSymmetric' , 1 , 'poolDays' , 0);

out  = se1_pubFigs(Dall , 'Eye', 'EyePrsTimePos' , 'isSymmetric' , 1 , 'poolDays' , 0);


%% significance test recipes



%% significance test on MTs
stats = se1_SigTest(Dall , 'MT' , 'seqNumb' , [0:6] , 'Day' , [4] ,...
    'whatIPI','WithBetRand','PoolSequences' , 0 ,...
    'ipiOfInterest' , [] , 'poolIPIs' , 0 , 'subjnum' , [1:12]);

%% significance test on IPIs
stats = se1_SigTest(Dall , 'IPI' , 'seqNumb' , [0:2] , 'Day' , [1:5] , 'Horizon' , [1:13],...
    'PoolDays' , 0,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
    'PoolHorizons' , [],'ipiOfInterest' , [0:2] , 'poolIPIs' , 0 , 'subjnum' , [1:13]);
%% single subject horizon significance test
stats = se1_SigTest(Dall , 'PerSubjMTHorz' , 'seqNumb' , [0:2] , 'Day' , [5] , 'Horizon' , [1:13],...
    'PoolDays' , 0,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
    'PoolHorizons' , [],'ipiOfInterest' , [0 2] , 'poolIPIs' , 0 , 'subjnum' , [1:13]);

%% significance test for percent change in MTs (Random Structured)
stats = se1_SigTest(Dall , 'PercentseqType' , 'seqNumb' , [0:2] , 'Day' , [1:5] , 'Horizon' , [7:13],...
    'PoolDays' , 0,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
    'PoolHorizons' , [6:13],'ipiOfInterest' , [0 : 2] , 'poolIPIs' , 0 , 'subjnum' , [1:13]);


%% significance test for percent change in IPIs (random within between)
stats = se1_SigTest(Dall , 'PercentIPItype' , 'seqNumb' , [0:2] , 'Day' , [5] , 'Horizon' , [1:13],...
    'PoolDays' , 0,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
    'PoolHorizons' , [],'ipiOfInterest' , [0 2] , 'poolIPIs' , 0 , 'subjnum' , [1:13]);

%% Saccade Frequency
stats = se1_SigTest(Dall , 'Eye_seq_sacPerSec' , 'seqNumb' , [0:2] , 'Day' , [1:5] , 'Horizon' , [1:13],...
    'PoolDays' , 1,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
    'PoolHorizons' , [],'ipiOfInterest' , [0 2] , 'poolIPIs' , 0 , 'subjnum' , [1:13],'isSymmetric' , 1);

%%
stats = se1_SigTest(Dall , 'Eye_seq_sacAmp' , 'seqNumb' , [0] , 'Day' , [1 5] , 'Horizon' , [13],...
    'PoolDays' , 1,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
    'PoolHorizons' , [],'ipiOfInterest' , [0 2] , 'poolIPIs' , 0 , 'subjnum' , [1:13],'isSymmetric' , 1);
%%
stats = se1_SigTest(Dall , 'Eye_ipi_fixDur' , 'seqNumb' , [0:2] , 'Day' , [1:5] , 'Horizon' , [1:13],...
    'PoolDays' , 0,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
    'PoolHorizons' , [],'ipiOfInterest' , [0:3] , 'poolIPIs' , 0 , 'subjnum' , [1:13],'isSymmetric' , 1);
%%
stats = se1_SigTest(Dall , 'Eye_ipi_lookahead' , 'seqNumb' , [0:2] , 'Day' , [1:5] , 'Horizon' , [1:13],...
    'PoolDays' , 0,'whatIPI','WithBetRand','PoolSequences' , 0 ,...
    'PoolHorizons' , [],'ipiOfInterest' , [0 3] , 'poolIPIs' , 0 , 'subjnum' , [1:13],'isSymmetric' , 1);


        
        
        
        
        
        
        
        
