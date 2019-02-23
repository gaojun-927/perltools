function result=adc_snr(data, OSR, fs, windowtype, width,exDCwidth,weight,datalength,overlap,threshold,isplot,isdebug,outputfilename)
%
%result(1)=Tdb;result(2)=Sdb;result(3)=Ndb;result(4)=Ddb;
%result(5)=SNDR;result(6)=SNR;result(7)=THD;result(8)=SFDR;result(9)=ENOB;
%result(10)=Sbin;result(11)=SFDRp;result(12)=vp;result(13)=fin;
%

% data: input data, each data per line or filename
%windowtype:1:hamming;3:hanning;6:BH;103:hanning'periodic'others:rect, details see below
%OSR: over sample ratio
%change from: 20071229
%width: fsin-width*fstep:fsin+width*fstep are all signal, DC 0 - (DCwidth-1)*fstep are DC signal
%to :
%width: fsin-width*fstep:fsin+width*fstep are all signal, DC 0 - (DCwidth)*fstep are DC signal
%total signal bin is 2*width+1, total DC bin is width+1
%fs: sample frequency, affect plot result
%weight: 'a': a-weighted(any char has the same effect now), [m,n]: only mHz
%to nHz will be used . default is 1, do nothing. 20081125
%threshold: threshold to differ noise and harmonic(dB)
%isplot: option for plot, see below
%0:disable can be fast
%1:plot OSR
%2:plot OSR+log full
%3:plot OSR+log full +time domin
%isdebug: option for debug,
%isdebug(1) for debug DC delete,
%isdebug(2) for debug harmonic find
%isdebug(3) for data preprocess
%outputfilename: write file to outputfilename

%Author : Gao Jun
%2005/08
Version=1.1;
%What's  New
%add weight to input, which will introduce filter at fft result after OSR
%reduce and DC reduce. 20081125
%fix display problem (when split data, fs is not correct when input fs=0)
%adjust noise power 
%change from sum of abs(fft) to sum of (fft^2) to meet defination 20081119
%delete signal bin before calculate distortion and noise 
%instead of total - signal. For high DR. 20080407
%use normal signal algo to calculate signal power, PG
%add D+N information 20080226
%according to my new recognize,
%add 106 window, which is N+1 blackmanharris 
%This window is fit for coherent and non coherent
%for coherent, hanning is good for less bin width
%Rect has less bin width but high side
%hamming has same bin width but slow roll off
%BH has large bin width
%for noncoherent, BH is good for low side
%Hanning has more low side at far, but the near bin power is high
%suggest for coherent, 103,1,1 is good(less bin)
%for noncoherent, 6,4,4 is good 
%change DCwidth define
%change default win type to 103, win width to 1. 20071229
%change output format to array 20061009
%add datalength for fft average
%change noisefloor calculation method 20060427
%plot SFDR position
%reduce harmonic search range from (Sbin+-width)*N to (Sbin+-1)*N 20060401
%add winpara  20060207
%wintype 5->6 winwid 5->4  20060110
minPower=1e-20;
%%

temp=exist('data');
if ~temp
    display(sprintf('ADC SNR Calculaton\nAuthor: Gao Jun Ver:%3.2f',Version)) ;
    display(sprintf('Usage:adc_snr(data, OSR, fs, windowtype, width,DCwidth,datalength,threshold,isplot,isdebug,outputfilename)'));
    return;
end;
[temp,temp1]=size(data);
if(temp==1&&temp1>1)
    data=data';
end

if ischar(data)
    inputfilename=data;
    data=textread(data,'%f');
end

temp=exist('windowtype');
if ~temp
    windowtype=103;
end;
temp=exist('OSR');
if ~temp ||OSR<1
    OSR=1;
end;
temp=exist('weight');
if ~temp
    weight=1;
end
temp=exist('width');
if ~temp 
    width=1; 
end;
temp=exist('exDCwidth');
% if ~temp 
%     DCwidth=width+1; 
% end;
if ~temp
    DCwidth=width+1;
else
    DCwidth=exDCwidth+1;
end

temp=exist('threshold');
if ~temp
    threshold=10; 
end;
temp=exist('isplot');
if ~temp 
    isplot=2; 
end;
if isplot>3 
    isplot=2; 
end;
temp=exist('isdebug');
if ~temp 
    isdebug=[0 0 0 ];
end;
%debug[1] DC reduce;
%debug[2] harmonic search
%debug[3] new method to find integer period

% outputfilename:
%empty: no result file
%0: no result file
%1: adc_snr_results_temp.txt
%2:adc_snr_results_temp.txt without head
%other number:0
%char array : output file name
temp=exist('outputfilename');
if ~temp
    outputfile=0;
    outputfilename='fafa';
else
    if ischar(outputfilename)
        outputfile=1;
    else
        switch outputfilename
            case 0,
                outputfile=0;
                outputfilename='lala';
            case 1,
                outputfile=1;
                outputfilename='adc_snr_results_temp.txt';
            case 2,
                outputfile=2;
                outputfilename='adc_snr_results_temp.txt';
            otherwise,
                outputfile=0;
                outputfilename='papa';
        end;
    end;
end;
temp=exist('datalength');
if ~temp 
    datalength=length(data); 
end;
if (datalength>length(data)) 
    datalength=length(data); 
end;
datalength=floor(datalength/2)*2;

temp=exist('fs');
if ~temp||fs==0 
    fs=datalength;
end;

temp=exist('overlap');
if ~temp 
    overlap=0; 
end;
%%


%list input param
display('Input parameter');
temp=exist('inputfilename');
if temp
    display(sprintf('Inputfilename:%s',inputfilename));
end;
display(sprintf('OSR:%d fs:%d wintype:%d width:%d DCwidth:%d ', OSR,fs,windowtype,width,DCwidth));
display(sprintf('threshold:%d isplot:%d isdebug:%d%d%d outputfile:%d outputfilename:%s datalength %d overlap %d',threshold,isplot,isdebug(1),isdebug(2),isdebug(3),outputfile,outputfilename,datalength,overlap));

if ischar(weight) 
    filtertype='a-weighted';
elseif length(weight)>1
    filtertype=sprintf('%dHz-%dHz',weight(1),weight(2));
else
    filtertype='';
end
display(filtertype);
%%
 %if debug[3] , use new method
        if isdebug(3)>0
            %Read in transient data and extract integer multiple of periods.
            xraw=data;
            idat = find(xraw(2:length(xraw))==xraw(1));
            idat = idat+1;
            n = length(idat);
            endpt = idat(n)-1;
            nperr = abs(xraw(idat(n)+1)-xraw(2));
            %Find equal data points and truncate the transient vector
            while n > 1
                if abs(xraw(idat(n-1)+1)-xraw(2))<nperr
                    nperr = abs(xraw(idat(n-1)+1)-xraw(2));
                    endpt = idat(n-1)-1;
                    n = n-1;
                else
                    n = n-1;
                end
            end
            data = xraw(1:endpt);             %Filter raw data.
        end;
        %end debug[3]
        %debug[3] has better not to be used with other options
%%
times=max([1 floor((length(data)-datalength)/(datalength-overlap))+1])
data_origin=data;
data_fft_total=0;
 %preprocess data
        data_point=floor(datalength/2)*2;
        data_point_lp=floor(data_point/OSR/2);
        
         %for multipara window
        windowtype_old=windowtype;
        windowtype=floor(windowtype);
        winpara=floor((windowtype_old-windowtype)*1000);
        if (windowtype==5||windowtype==105) && winpara==0 winpara=10;end;
        if windowtype==9 && winpara==0 winpara=100; end;
        %for example: 5.007mean win=5 para=7
        switch windowtype,
            %% for window number >100, the 'periodic' will be effective
            % blackman,kaiser(10),blackmanharris are good for low width
            %for different window,diff width, estimated signal power is not the
            %same.  below will give one simulation result
            %input: deltasigma ADC 2 order simulink data
            %4*1024*128 step(data point) 128OSR
            %vp=0.28 vref=2
            %format: window=***windowname***(data_point); % power1(width=2) power2(=4) power3(=8)
            case 1,
                window=hamming(data_point);  % 10.6  13.4  15
                %         data_logic=data_logic.*hamming(data_point); %good for ADC_out_bits
            case 2,
                window=bartlett(data_point); % 31.7 32.4 33.5
                %         data_logic=data_logic.*bartlett(data_point); % terrible
            case 3,
                window=hanning(data_point); % 33.6 47.8 56
                %         data_logic=data_logic.*hanning(data_point);
            case 4,
                window=blackman(data_point); % 41.9 58 64.7
                %         data_logic=data_logic.*blackman(data_point); %good
            case 5, % side is~ 10*winpara+8.7dB for winpara>4.5
                window=kaiser(data_point,winpara); % 33.4 73.3 74.1
                %         data_logic=data_logic.*kaiser(data_point,10);%good @10
            case 6,
                window=blackmanharris(data_point); % 27.4 74.2 74.2
                %         data_logic=data_logic.*blackmanharris(data_point); %good
            case 7,
                window= barthannwin(data_point); % 36.9 47.8 52.7
            case 8,
                window= bohmanwin(data_point); %39.3 59.3 69.4
            case 9,
                window=chebwin(data_point, winpara);  % too slow
            case 10,
                window= flattopwin(data_point); % 13.8 57.5 60.6
            case 11,
                window= gausswin(data_point); % 33.9 36.6 38
            case 12,
                window=nuttallwin(data_point); % 28 73.8 73.8
            case 13,
                window=parzenwin(data_point); % 30.5 52.3 62.2
            case 14,
                window= tukeywin(data_point, 0.5); % 22.6 34.5 44.4
            case 15,
                window= triang(data_point); % 27.5 35.6 40.6
            case 101,
                window=hamming(data_point,'periodic');
            case 103,
                window= hanning(data_point,'periodic');
            case 104,
                window= blackman(data_point,'periodic');
            case 105, 
                window=kaiser(data_point+1,winpara);
                window(data_point+1)=[];
            case 106,
                window= blackmanharris(data_point+1);
                window(data_point+1)=[];
            case 110,
                window= flattopwin(data_point,'periodic'); 
            otherwise,
                window=ones(data_point,1);
        end
        c_factor=sqrt(sum(window.*window)/data_point)
        
%%

data_fft_totalpower=0;
for temp=1:times
    data=data_origin(1+(temp-1)*(datalength-overlap):datalength+1+(temp-1)*(datalength-overlap)-1);

    if datalength/OSR/(width+1)<10
        warning('data point too small');
    end;

    % data_logic=data(1:data_point)-mean(data(1:data_point)); %del DC first
    data_logic=data(1:data_point);

    data_logic=data_logic.*window;
    data_logic=data_logic-mean(data_logic); %del DC
    data_logic=data_logic./c_factor;  %adjust power

    %fft data 
    data_fft=abs(fft(data_logic))/data_point;
    data_fft_total=data_fft_total+data_fft;
    data_fft_totalpower=data_fft_totalpower+data_fft.*data_fft;
end;% end cal total fft result
%%        
        data_point
        
        %20081119 change from sum of abs(fft) to sum of abs(fft ^2)
       % data_fft=data_fft_total/times;
        data_fft=sqrt(data_fft_totalpower/times);%change from fft avg to fft power avg, this is origin defination
        
        data_fft=data_fft*2;  %fold
        data_fft(data_point/2+1)=data_fft(data_point/2+1)/2; % N/2+1 do not need *2, but it multiply by 2 before, so divided by 2 here
        data_fft(1)=data_fft(1)/2;
        % DCdb=20*log10(data_fft(1)+minPower)
%%

        %here is a new method for replace DCpower. % gaojun
        data_fft_temp=(data_fft(1:data_point_lp)+minPower);
        for temp=1:10
            indexhigh=find(data_fft_temp> (1*rms(data_fft_temp)+mean(data_fft_temp)) ) ;
            indexlow=find(data_fft_temp<mean(data_fft_temp)/100);indexlow=[ ];
            if isdebug(1)>0
                plot([1:length(data_fft_temp)],data_fft_temp,[1:length(data_fft_temp)],mean(data_fft_temp),'r');% hold on;
                pause;
            end
            data_fft_temp(indexhigh)=0;data_fft_temp(indexlow)=0;
            newavg=sum(data_fft_temp)/(length(data_fft_temp)-length(indexhigh)-length(indexlow));
            %newavg=0;
            data_fft_temp(indexhigh)=newavg;
            data_fft_temp(indexlow)=newavg;
        end;
        if DCwidth>=0
            data_fft(1:DCwidth)=mean(data_fft_temp);
        end
        %%
        % data_fft(1:DCwidth)=0;
    
        % %temp add
        % data_fft(6895)=1e-3;
        % data_fft(6896)=1e-3;
        % data_fft(6894)=1e-3;
        % %end temp add
%%        
        

        % sin(vp=1V, vrms=0.7V, power=1/2 Vsqure )
        %-->(fft) 1/2 1/2 -->(fold) 1 -->(power) 1/2 -->(power db) --> -3db( vrms )
        data_fft_power=data_fft(1:data_point/2+1).^2/2;
        data_fft_powerdb=20*log10(data_fft(1:data_point/2+1)/2*sqrt(2)+minPower);
        
        fstep=fs/data_point;
        if ~ischar(weight)&&length(weight)==1
            data_fft_lp=data_fft(1:data_point_lp);
            data_fft_power_lp=data_fft_power(1:data_point_lp);
            data_fft_power_lpdb=data_fft_powerdb(1:data_point_lp);
        elseif ischar(weight) % a-weighted
            filter=aweight([0:fstep:fstep*(data_point_lp-1)])';
            data_fft_lp=data_fft(1:data_point_lp).*filter;
            data_fft_power_lp=data_fft(1:data_point_lp).^2/2.*filter.*filter;
            data_fft_power_lpdb=10*log10(data_fft_power_lp+minPower);
        elseif length(weight)>1 % [lowfreq, highfreq]
            filter=([0:fstep:fstep*(data_point_lp-1)]>weight(1)&[0:fstep:fstep*(data_point_lp-1)]<weight(2))';
            data_fft_lp=data_fft(1:data_point_lp).*filter;
            data_fft_power_lp=data_fft(1:data_point_lp).^2/2.*filter.*filter;
            data_fft_power_lpdb=10*log10(data_fft_power_lp+minPower);
        end


noisefloor=mean(data_fft_power_lpdb);
if data_point<512 warning('data point less than 512');end
%%
gaplength=0;%to calculate signal and distortion width;
%find Signal
Sbin=find(data_fft_power_lp==max(data_fft_power_lp(DCwidth+1:data_point_lp)));
if length(Sbin)>1
    Sbin=Sbin(1);
end
Slow=max([Sbin-width,1]);
Shigh=min([Sbin+width,data_point_lp]);
Spower=sum(data_fft_power_lp(Slow:Shigh));
Sdb=10*log10(Spower);
Sdb_single=10*log10(data_fft_power_lp(Sbin));
gaplength=gaplength+Shigh-Slow+1;
%%

%find harmonic
Dpower=0;
low_old=DCwidth+1;
high_old=DCwidth+1;
Dbin(1)=0;
Dbinhigh(1)=0;
Dbinlow(1)=0;
%%

%for SFDR plot
n_sfdr=0;
d_sfdr=0;
sfdr_position_l=0;
sfdr_position_h=0;
sfdr_position=0;
%%
distoration_count=0;
for temp=2:data_point_lp/Sbin
    %do not consider folding effect
    %low,high: search range
    %low_old high_old save low, high
    % attention : (Sbin-1)*N+1 is the ideal harmonic bin
    % but Sbin may have error for +-1bin
%     low=max([ DCwidth Dbinhigh(temp-1) Sbin+width  (Sbin-width-1)*temp+1-1 ])+1; %here the search range may be too wide
     low=max([ DCwidth Dbinhigh(temp-1) Sbin+width  (Sbin-1-1)*temp ])+1;
    if low>data_point_lp  low=data_point_lp;end

%     high=min([(Sbin+width-1)*temp+1 data_point_lp]);%here the search range may be too wide
    high=min([(Sbin+1-1)*temp+1 data_point_lp]);
    if low>high low=high;end % search rang can not define properly


    %if reached the last several number,
    %the search range will repeat last situation
    if (low_old==low &&high_old==high)   break;    end

    range=data_fft_power_lp(low:high);
    %Dhigh,Dlow: harmonic range
    %Dbinhigh() Dbinlow() save Dhigh, Dlow
    tempvar=find(range==max(range));
    showthiswarning=0;
    if length(tempvar)>1  
        if showthiswarning<5
            warning('more than 1 harmonic in one search range');
        end
        showthiswarning=showthiswarning+1; %a counter
        tempvar=tempvar(1); 
    end
    Dbin(temp)=tempvar+low-1;
    
    if Dbin(temp)+width>data_point_lp Dhigh=data_point_lp; else Dhigh=Dbin(temp)+width;end
    if Dbin(temp-1)==0 Dbinhigh_temp=0; else Dbinhigh_temp=Dbinhigh(temp-1);end
    
    Dlow=max( [Dbin(temp)-width-1,DCwidth,Sbin+width,Dbinhigh_temp ] )+1;

    if Dlow>Dhigh Dlow=Dbin(temp);Dhigh=Dbin(temp);end


    noisefloor1=mean( data_fft_power_lpdb( max( temp-floor(data_point_lp*0.2),1 ) : min(  temp+floor(data_point_lp*0.2) , data_point_lp) ) );
    noisefloor2=10*log10((max(minPower,sum(data_fft_power_lp)-Spower))/(data_point_lp-2*width-1)); %global noisefloor
    noisefloor=min(noisefloor1,noisefloor2);
%noisefloor= mean( data_fft_power_lpdb(low:high ) ); 
% local  noisefloor,range too narrow;
%the noisefloor below is a rough calculation

    %the noisefloor below may get NaN for mean calculation, so as to affect
    %the judgement
%     noisefloor=
%     (
%         mean(   data_fft_power_lpdb(max([1,Dlow-width*4]):max([1,Dlow-1]))  )
%     +   mean(  data_fft_power_lpdb(min([data_point_lp,Dhigh+1]):min([data_point_lp,Dhigh+width*4])) )
%     )
%     /2;
% rewrite to easy to read:
    ttta1=max([1,Dlow-width*4]);
    ttta2=max([1,Dlow-1]);
    if ttta1>ttta2 
        if width>0 warning(' noisefloor calculate range 1 error'), end;
        ttt=ttta1;ttta1=ttta2;ttta2=ttt;
    end;
    ttta= data_fft_power_lpdb(ttta1:ttta2)  ;
    ttta= mean(ttta);
    tttb1=min([data_point_lp,Dhigh+1]);
    tttb2=min([data_point_lp,Dhigh+width*4]);
    if tttb1>tttb2 
         if width>0 warning(' noisefloor calculate range 2 error');end;
         ttt=tttb1;tttb1=tttb2;tttb2=ttt;
    end;
    tttb= data_fft_power_lpdb(tttb1:tttb2);
    tttb=mean(tttb);
    noisefloor=(ttta+tttb)/2;

    %
    if(data_fft_power_lpdb(Dbin(temp))-noisefloor)>threshold && ( Dlow<=Dbin(temp) && Dhigh>=Dbin(temp) )

        % %% if interesting can delete some harmonic here
        %         if temp==3
        %             data_fft_power_lp(Dlow:Dhigh)=10^(noisefloor/10);
        %             data_fft_power_lpdb(Dlow:Dhigh)=noisefloor;
        %         end;
        % %%end delete

        %pick up 2 and 3 order harmonic
        if   temp==2 D2=10*log10(sum(data_fft_power_lp(Dlow:Dhigh))), end;
        if   temp==3 D3=10*log10(sum(data_fft_power_lp(Dlow:Dhigh))), end;

        Dpower=Dpower+sum(data_fft_power_lp(Dlow:Dhigh));

        %save harmonic in d_sfdr;
        n_sfdr=n_sfdr+1;
        d_sfdr(n_sfdr)=sum(data_fft_power_lp(Dlow:Dhigh));
        sfdr_position_l(n_sfdr)=Dlow;
        sfdr_position_h(n_sfdr)=Dhigh;
        sfdr_position(n_sfdr)=Dbin(temp);
        gaplength=gaplength+Dhigh-Dlow+1;
        distoration_count=distoration_count+1; %distotion number
        %for debug only
        if isdebug(2)>0
            skip_low=0;skip_dlow=0;skip_dhigh=0;
            delta=(data_fft_power_lpdb(Dbin(temp))-noisefloor);
        end
        % debug
    else
        %for debug only
        if isdebug(2)>0
            skip_low=0;skip_dlow=0;skip_dhigh=0;
            delta=(data_fft_power_lpdb(Dbin(temp))-noisefloor);
            if (data_fft_power_lpdb(Dbin(temp))-noisefloor)<=threshold
                skip_low=1;
                delta=(data_fft_power_lpdb(Dbin(temp))-noisefloor);
            end
            if Dlow>Dbin(temp)  skip_dlow=1;end
            if Dhigh<Dbin(temp) skip_dhigh=1;end
        end
        % end debug

        Dbin(temp)=0;  % not DC but  (-fstep)
    end

    Dbinhigh(temp)=Dhigh;
    Dbinlow(temp)=Dlow;


    %for debug only
    if isdebug(2)>0
        plot([low_old:high_old],data_fft_power_lpdb(low_old:high_old),'go',[low:high],data_fft_power_lpdb(low:high)+1,'b+',[Dlow:Dhigh],data_fft_power_lpdb(Dlow:Dhigh),'r+',Dbin(temp),mean(data_fft_power_lpdb(Dlow:Dhigh)),'bo',[low:high],noisefloor,'b-',[1:data_point_lp],data_fft_power_lpdb)
        legend(sprintf('skip-low %d skip-dlow %d skip-dhigh %d delta=%3.1f \n temp=%d\n greenO old range, blue+  search range\n red+ D range, blueO Dmean(not for delta)', skip_low,skip_dlow,skip_dhigh,delta,temp));
        pause;
    end
    % debug

    low_old=low;
    high_old=high;
end


% Drange=[Dbinlow' Dbin' Dbinhigh']
Dpower;
Ddb=10*log10(Dpower+minPower);
Dmax_db=10*log10(max(d_sfdr)+minPower);
Dmax_positionh=sfdr_position_h(find(d_sfdr==max(d_sfdr)));
Dmax_positionl=sfdr_position_l(find(d_sfdr==max(d_sfdr)));
Dmax_position=sfdr_position(find(d_sfdr==max(d_sfdr)));
if (Dmax_position ~=0)
    Dmax_db_single=10*log10(data_fft_power_lp(Dmax_position));
else
    Dmax_db_single=10*log10(minPower);
end
if ~exist('D2') D2=NaN;end;
if ~exist('D3') D3=NaN;end;


%total power
Tpower=sum(data_fft_power_lp);
Tpower1=rms(data_logic)^2;
Tdb=10*log10(Tpower);


%delete Signal
data_fft_power_lp_temp=data_fft_power_lp;
data_fft_power_lp_temp(Slow:Shigh)=0;
%%
NDpower=sum(data_fft_power_lp_temp);
if(NDpower<0) NDpower=minPower;
end
NDdb=10*log10(NDpower);
Npower=NDpower-Dpower;
Npower=Npower/(data_point_lp-gaplength)*data_point_lp;%adjust noise power to count sbin and dbin.20081119
if(Npower<0) Npower=minPower;
end
Ndb=10*log10(Npower);

gaplength
distoration_count

% %N+D 
% NDpower=Tpower-Spower;
% if(NDpower<0) NDpower=minPower;
% end
% NDdb=10*log10(NDpower);

% %find noise
% Npower=Tpower-Spower-Dpower;
% if(Npower<0) Npower=minPower;
% end
% Ndb=10*log10(Npower);

%SNR SNDR
SNR=Sdb-Ndb;
SFDR=Sdb-Dmax_db;
SFDR_single=Sdb_single-Dmax_db_single;
SFDRp=round((Dmax_position-1)/(Sbin-1));
THD=Sdb-Ddb;
SNDR=10*log10(Spower/ ( Npower+ Dpower));
ENOB = (SNDR-1.76)/6.02;
fstep=fs/data_point;
fin=fstep*(Sbin-1);
vp=sqrt(2*Spower);

%change to results format
results.Tdb=Tdb;
results.Sdb=Sdb;
results.Ndb=Ndb;
results.Ddb=Ddb;
results.SNDR=SNDR;
results.SNR=SNR;
results.THD=THD;
results.SFDR=SFDR;
results.ENOB=ENOB;
results.Sbin=Sbin;
results.SFDRp=SFDRp;
results.vp=vp;
results.fin=fin;
results.NDdb=NDdb;
results

result(1)=Tdb;
result(2)=Sdb;
result(3)=Ndb;
result(4)=Ddb;
if(SNDR<200)
    result(5)=SNDR;
else
    result(5)=200;
end
if(SNR<200)
    result(6)=SNR;
else
    result(6)=200;
end
if(THD<500)
    result(7)=THD;
else
    result(7)=500;
end
result(8)=SFDR;
result(9)=ENOB;
result(10)=Sbin;
result(11)=SFDRp;
result(12)=vp;
result(13)=fin;



%write result to file
if outputfile>0
    results_head='data_point, data_point_lp, OSR, Sbin, Spower, Sdb, D2, D3, Dpower, Ddb, Dmax_db, Npower, Ndb, Tpower, Tdb, SNR, SFDR, THD, SNDR, ENOB, fin, Vp';
    results=[data_point data_point_lp OSR Sbin Spower Sdb D2 D3 Dpower Ddb Dmax_db Npower Ndb Tpower Tdb SNR SFDR THD SNDR ENOB fin vp];
    fid=fopen(outputfilename,'w');
    if outputfile==1
        fprintf(fid,'%s\n',results_head);
        fprintf(fid,'%d,%d,%d,%d,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f',results);
%         dlmwrite(outputfilename,results_head,' ');
%         dlmwrite(outputfilename,results,'-append');
    else
        if outputfile==2
             fprintf(fid,'%d,%d,%d,%d,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f,%5.3f',results);
%             dlmwrite(outputfilename,results);
        end
    end;
    fclose(fid);
end;


%plot
if isplot>0
    x=[0:fstep:fstep*(data_point_lp-1)];
    switch isplot
        case 1,
            subplot(2,2,1:4);
        case 2,
            subplot(2,2,1:2);
        case 3,
            subplot(2,2,1:2);
        otherwise,
            subplot(2,2,1:4);
    end;
    marky=min(0,max(data_fft_power_lpdb)+60);
    if data_point_lp<50
        plot(x,data_fft_power_lpdb,'-o',(Dbin-1)*fstep, marky,'b*',(Sbin-1)*fstep,marky,'r+', [(Slow-1)*fstep (Shigh-1)*fstep ] , marky, 'k+',(Dmax_positionh-1)*fstep,marky+1,'r*',(Dmax_positionl-1)*fstep,marky+1,'r*',(Dmax_position-1)*fstep,marky+1,'r*');
    else
        plot(x,data_fft_power_lpdb,(Dbin-1)*fstep, marky,'b*',(Sbin-1)*fstep,marky,'r+', [(Slow-1)*fstep (Shigh-1)*fstep ] , marky, 'k+',(Dmax_positionh-1)*fstep,marky+1,'r*',(Dmax_positionl-1)*fstep,marky+1,'r*',(Dmax_position-1)*fstep,marky+1,'r*');
    end;
    
    xlabel(sprintf('Freq(Hz)\n***WinType=%d(%d);SignalWidth=%d;DCWidth=%d;filter=%s***',windowtype,winpara,width,DCwidth-1,filtertype));
    ylabel('dBVref_r_m_s');
    title(sprintf('PSD plot;OSR data Point=%d  <f_i_n=%5.3f;V_p=%5.3fV_r_e_f>',data_point_lp*2,fin,vp));grid on;
    SNRstring=[sprintf('SNDR=%5.2fdB SNR=%5.2fdB\nTHD=%5.2fdB SFDR@%d=%5.2fdB\nENOB=%5.2f ',SNDR,SNR,THD,SFDRp,SFDR,ENOB) date];
    text(fstep*(data_point_lp-1),max(marky-10,max(data_fft_power_lpdb)),SNRstring,'VerticalAlignment','top','HorizontalAlignment','right','BackgroundColor','w','EdgeColor','k','Editing','off' );

    if isplot>1
        switch isplot
            case 2,
                subplot(2,2,3:4);
            case 3,
                subplot(2,2,3);
        end;
        x=[0:fstep:fstep*(data_point/2)];
        x(1)=fstep*0.5; % delete 0 log warning
        semilogx(x,data_fft_powerdb,(Dbin-1)*fstep, 0,'b*',(Sbin-1)*fstep,0,'r+');
        xlabel('Hz');ylabel('dBVref_r_m_s');
        title(sprintf(' Full data PSD plot;data point=%d',data_point));
        INFOstring=[sprintf('T=%5.3fdb S=%5.3fdb\nD=%5.3fdb N=%5.3fdb',Tdb,Sdb,Ddb,Ndb)];
        text(fstep*(data_point/2),min(data_fft_powerdb)+20,INFOstring,'VerticalAlignment','bottom','HorizontalAlignment','right','BackgroundColor','w','EdgeColor','k');
        if isplot==3
            subplot(2,2,4);
            plot([0:1/fs:(data_point-1)/fs],data(1:data_point));
            xlabel('Time(s)');ylabel('LSB');title('Time Domin Wave');
        end;
    end;
end;

function rms=rms(input)
    input_woDC=input-mean(input);
    rms=sqrt(sum(input_woDC.*input_woDC)/length(input));

function out=aweight(f)
    f2=f.^2;
    f4=f2.^2;
    %20.6^2=4.2436e2;12200^2=14884e4;107.7^2=1.159929e4;737.9^2=5.4449641e5
    %r=12200^2*f4/(f2+20.6^2)/(f2+12200^2)/sqrt((f2+107.7^2)*(f2+737.9^2))
    r=14884e4*f4./(f2+4.2436e2)./(f2+14884e4)./sqrt((f2+1.159929e4).*(f2+5.4449641e5));
    out=r*1.2589254;
