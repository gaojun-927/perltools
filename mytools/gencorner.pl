use strict;
my $modelfile='/disk96/library/smic/smic13mmrf_1233_cds_20060529_v1p3/smic13mmrf_1233_1P5M_200605261027/models/spectre/l013_io33_v2p5_spe.lib';
my $name='smic13mmrf';
my @moscorner=('tt','ff','ss','fnsp','snfp'); #0,1,2,3,4
my @rescorner=('res_tt','res_ff','res_ss'); #0,1,2
my @capcorner=('tt');
my @bipcorner=('bjt_tt','bjt_ff','bjt_ss');
my @othercorner=('bip','bip3'); #for all

#mos,res,cap,bip
my %list=('tt'=>[0,0,0,0], #tt
			'ff'=>[1,1,1,1],'ss'=>[2,2,2,2], 
			'fs'=>[3,0,0,0],'sf'=>[4,0,0,0], 
			'mfrfcs'=>[1,1,2,0],'mfrscf'=>[1,2,1,0],'msrfcs'=>[2,1,2,0],'msrscf'=>[2,2,1,0], # rc
			'rfcs'=>[0,1,2,0],'rscf'=>[0,2,1,0], #rc 
			'mfrfbs'=>[1,1,0,2],'mfrsbf'=>[1,2,0,1],'msrfbs'=>[2,1,0,2],'msrsbf'=>[2,2,0,1],#rb
			'fsrfbs'=>[3,1,0,2],'fsrsbf'=>[3,2,0,1],'sfrfbs'=>[4,1,0,2],'sfrsbf'=>[4,2,0,1],#rb & mos
			);
my $key;
my $array;
while( ($key,$array)=each(%list) ){
	open(FILE,">$key.list") or die "open $key.list error";

	print FILE gensection( $moscorner[ $array->[0] ]);
	if(@rescorner==3 && $rescorner[ $array->[1] ] ne $moscorner[ $array->[0] ] ){
		print FILE gensection($rescorner[ $array->[1] ]);
	}
	if(@capcorner==3 && $capcorner[ $array->[2] ] ne $moscorner[ $array->[0] ] ){
		print FILE gensection($capcorner[ $array->[2] ]);
	}
	if(@bipcorner==3 && $bipcorner[ $array->[3] ] ne $moscorner[ $array->[0] ] ){
		print FILE gensection($bipcorner[ $array->[3] ]);
	}
	foreach my $oc(@othercorner){
		print FILE gensection($oc);
	}
	close(FILE);
}
print "gen each section file ok\n";

open(FILE,">$name.list") or die "open $name.list error";
print FILE title();
while( ($key,$array)=each(%list) ){
	print FILE (eachsection($key,$array));
}	
print FILE tail();
close(FILE);
print "ok\n";

sub gensection{
	my $input=shift;
	return( "include \"$modelfile\" section=$input\n" );
}
sub title{
	return <<HERE;
simulator lang = spectre
library aaa
HERE
}
sub eachsection{
	my ($key,$array)=shift;
	return <<HERE;
	
section $key
include "$key.list"
endsection $key

HERE
}
sub tail{
	return <<HERE;
endlibrary aaa
HERE
}


	
		


	

