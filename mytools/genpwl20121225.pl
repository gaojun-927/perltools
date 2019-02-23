#! /usr/bin/perl -w
#usage:
#can write tr tf tp vh vl at begin of line to define
#can write 1 or 1*5 to define length
#things after  digital is comment
use strict;
my $tr=100e-9;
my $tf=100e-9;
my $tp=5e-6;
my $vh=3.3;
my $vl=0;
my $init=1;
my $lastvalue=0;
my $currentvalue=0;
my $currenttime=0;
my $rep=1;
my $lastrep=1;
while(<>){
	$tr=$1 if /^tr\s+(\S+)/;
	$tf=$1 if /^tf\s+(\S+)/;
	$tp=$1 if /^tp\s+(\S+)/;
	$vh=$1 if /^vh\s+(\S+)/;
	$vl=$1 if /^vl\s+(\S+)/;
	$currenttime=$1 if /^td\s+(\S+)/;
	if(/^([10])/){
		$currentvalue=$1;
		if(/^[10]\*([0-9]+)/){
			$rep=$1;
		}else{
			$rep=1;
		}
		if($init){
			$init=0;
			$lastvalue=$currentvalue;
			$lastrep=$rep;
			if($currentvalue==1){
				print "0 $vh\n";
			}else{
				print "0 $vl\n";
			}
		}else{
			$currenttime=$currenttime+$tp*$lastrep;
			if($lastvalue!=$currentvalue){
				if($currentvalue==1){
					print "$currenttime $vl\n";
					my $temp=$currenttime+$tr;
					print "$temp $vh\n";
				}else{
					print "$currenttime $vh\n";
					my $temp=$currenttime+$tf;
					print "$temp $vl\n";
				}
			}
			$lastvalue=$currentvalue;
			$lastrep=$rep;
		}
	}
}