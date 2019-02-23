function rms=rms(input)
input_woDC=input-mean(input);
rms=sqrt(sum(input_woDC.*input_woDC)/length(input));