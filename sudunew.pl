#!/bin/perl
#sudu

use strict;
my $sudu;
my $isdebug=1;
$sudu=init($sudu);
fillsudu($sudu);
print "start is:";
printsudu($sudu);
printsududetail($sudu);
reduce_and_check($sudu);
printsudu($sudu);
printsududetail($sudu);
our $depth=0;#depth
our $totalcnt=0;#total
my $pt=[0,0];
my ($status,$suducopy)=resolve($sudu);
printsudu($suducopy);
print "status: $status\n";


sub	resolve{
		my $sudu=$_[0];
		my $pt=[0,0];
		my $status=0;
		my $suducopy;
		my $deep=3;
		$totalcnt++;
		
		$suducopy=copysudu($sudu);
		print "\ndepth is $depth\n";
		print "begin into resolve function, :\n";
		printsudu($suducopy);
	
		$status=reduce_and_check($suducopy);
		print "status=: $status\n";
		print "reduce to:";
		printsudu($suducopy);
		
		
		if($status eq 'ok'|| $depth>$deep){
			print 'too deep '."\n" if $depth>$deep;
			
			print "$status\n";
			return ($status,$suducopy);
		}elsif( $status eq 'cf'){
			print "is cf and return\n";
			
			return ($status,$suducopy);
		}
		else{
			print "status is $status\n" if $isdebug;
			$depth++;
			my @ptmap;
			my @ptmapt;
			for (my $i=1;$i<=81;$i++){
				$ptmapt[$i]=@{$suducopy->[$i]};
			}
			for (my $i=1;$i<=81;$i++){
				my $min=1000;
				my $p=$i;
				for(my $j=1;$j<=81;$j++){
					if($min>$ptmapt[$j]){
						$min=$ptmapt[$j];
						$p=$j;
					}
				}
				$ptmapt[$p]=1000;
				$ptmap[$i]=$p;
			}
			$ptmap[0]=0;
				
			my $cnt=0;
			while( $cnt <81){
				print "$depth:".' cnt is '."$cnt,".' old pt is '.$ptmap[$pt->[0]].'('.$pt->[0].')'.$pt->[1].' '."\n"  if $isdebug;
				print 'old value is '.$suducopy->[  $ptmap[$pt->[0]] ][0]."\n" if $isdebug;
				print '@ is '."@{$suducopy->[  $ptmap[$pt->[0]] ]}"."\n" if $isdebug;	
				findnextpt($suducopy,$pt,\@ptmap);
				$suducopy->[ $ptmap[$pt->[0]] ][0]=$pt->[1];
				
				print 'pt is '.$ptmap[$pt->[0]].'('.$pt->[0].')& '.$pt->[1].' '."\n" if $isdebug;
				print 'value is '.$suducopy->[  $ptmap[$pt->[0]] ][0]."\n" if $isdebug;
				print '@ is '."@{$suducopy->[  $ptmap[$pt->[0]] ]}"."\n" if $isdebug;
				my $ttt;			
				($status,$ttt)=resolve($suducopy);
				print "now status is $status\n" if $isdebug;
				if ( $status eq 'cf' ){
					my $tt=1;
					print "status is cf and pt is $ptmap[$pt->[0]]\n";
					while($tt<@{$suducopy->[  $ptmap[$pt->[0]]  ]}){
						
						last if($suducopy->[ $ptmap[$pt->[0]] ][$tt]>$pt->[1]);
						$tt++;
					}
					for (my $temp=$tt-1; 
        		$temp<@{$suducopy->[  $ptmap[$pt->[0]]  ]}-1;$temp++){
        		$suducopy->[ $ptmap[$pt->[0]] ][$temp]=$suducopy->[ $ptmap[$pt->[0]] ][$temp+1];
					}
					pop(@{$suducopy->[  $ptmap[$pt->[0]]  ]});
					$pt->[1]=$suducopy->[ $ptmap[$pt->[0]] ][$tt]-1;
					$status=reduce_and_check($suducopy);
					if ( $status eq 'ok' ) {return ( $status,$ttt);}
					
				}elsif( $status eq 'ok' ){					
					return ($status,$ttt);
				}elsif( $status eq 'un'){
				}

				$cnt++;
			}
			$depth--;
			return ('un',$suducopy);
		}
}

sub findnextpt{
	my ($suducopy,$pt,$ptmap)=@_;
	if(  $pt->[0]==0  ||
			 $pt->[1]>=$suducopy->[ $ptmap->[$pt->[0]] ][-1] ||
			 #( $pt->[1]==0 && @{$suducopy->[ $ptmap->[$pt->[0]] ]}==1 )
			  @{$suducopy->[ $ptmap->[$pt->[0]] ]}==1
		 ){
		 		my $counttemp=0;
				do{
					$pt->[0]++;
					if($pt->[0]>81){
						$pt->[0]=1;$counttemp+=1;
						} 					
				}while( $suducopy->[ $ptmap->[$pt->[0]] ][0]!=0 && $counttemp<2);
				$pt->[1]=$suducopy->[ $ptmap->[ $pt->[0] ] ][1];
				if( $counttemp>=2) {
						$pt->[0]=0;$pt->[1]=0;
						print "attention\n";
					}					
				print "in find spe\n" if $isdebug;
			}else{
				for(my $i=1;$i<@{$suducopy->[ $ptmap->[ $pt->[0] ] ]};$i++){
					if($suducopy->[ $ptmap->[$pt->[0]] ][$i]>$pt->[1]){
						$pt->[1]=$suducopy->[ $ptmap->[$pt->[0]] ][$i];
						last;
					}
				}
				print "in find norm\n" if $isdebug;
			}
	
}

sub ij2n{
	my ($i,$j)=@_;
	return ($i-1)*9+$j;
}

sub n2ij{
	my $n=$_[0];
	my ($i,$j);
	$j=$n%9;
	$j=9 if $j==0;
	$i=int(($n-1)/9)+1;
	return($i,$j);
}
sub cleansudu{
	my $sudu=$_[0];
	my ($i,$j,$k);
	for($i=1;$i<=9;$i++){
		for($j=1;$j<=9;$j++){
#			if($sudu->[ij2n($i,$j)][0]==0){
			if(1){
#				print "i,j:$i,$j\n";
#				print @{$sudu->[ij2n($i,$j)]}.":@{$sudu->[ij2n($i,$j)]}\n";
				my $t=@{$sudu->[ij2n($i,$j)]};
				for($k=$t;$k>1;$k--){
					pop( @{$sudu->[ij2n($i,$j)]} );
#					print "@{$sudu->[ij2n($i,$j)]}\n";
					
				}
			}
		}
	}
}
	
sub init{
	my $sudu=$_;
	my $i=1;my $j=1;
	for($i=1;$i<=9;$i++){
		for($j=1;$j<=9;$j++){
			$sudu->[ij2n($i,$j)][0]=0;
		}
	}

#	$sudu->[ij2n(1,1)]=[4];
#	$sudu->[ij2n(1,4)]=[3];
#	$sudu->[ij2n(1,7)]=[2];
#	$sudu->[ij2n(2,4)]=[5];
#	$sudu->[ij2n(2,6)]=[8];
#	$sudu->[ij2n(3,2)]=[7];
#	$sudu->[ij2n(3,5)]=[4];
#	$sudu->[ij2n(3,9)]=[6];
#	
#  $sudu->[ij2n(4,2)]=[8];
#	$sudu->[ij2n(4,5)]=[9];
#	$sudu->[ij2n(4,7)]=[1];
#	$sudu->[ij2n(4,8)]=[3];
#	$sudu->[ij2n(5,9)]=[2];
#	$sudu->[ij2n(6,1)]=[9];
#	$sudu->[ij2n(6,2)]=[6];
#	$sudu->[ij2n(6,3)]=[1];
#	$sudu->[ij2n(6,8)]=[8];
#	
#	$sudu->[ij2n(7,1)]=[7];
#	$sudu->[ij2n(7,3)]=[9];
#	$sudu->[ij2n(7,5)]=[8];
#	$sudu->[ij2n(7,6)]=[5];		
#	$sudu->[ij2n(7,8)]=[2];
#	$sudu->[ij2n(7,9)]=[4];	
#	$sudu->[ij2n(8,2)]=[3];
#	$sudu->[ij2n(9,2)]=[5];

########################

#	$sudu->[ij2n(1,1)]=[3];
#	$sudu->[ij2n(1,9)]=[6];
#	$sudu->[ij2n(2,4)]=[2];
#	$sudu->[ij2n(2,6)]=[6];
#	$sudu->[ij2n(2,8)]=[7];
#	$sudu->[ij2n(2,9)]=[8];
#	$sudu->[ij2n(3,2)]=[2];
#	$sudu->[ij2n(3,8)]=[9];
#	
#	
#  $sudu->[ij2n(4,3)]=[7];
#	$sudu->[ij2n(4,4)]=[6];
#	$sudu->[ij2n(5,1)]=[2];
#	$sudu->[ij2n(5,2)]=[8];
#	$sudu->[ij2n(5,4)]=[1];
#	$sudu->[ij2n(5,7)]=[5];
#	$sudu->[ij2n(6,3)]=[1];
#	$sudu->[ij2n(6,5)]=[4];
#	$sudu->[ij2n(6,6)]=[2];
#	
#	$sudu->[ij2n(7,2)]=[5];
#	$sudu->[ij2n(7,7)]=[2];
#	$sudu->[ij2n(8,2)]=[9];
#	$sudu->[ij2n(8,6)]=[5];		
#	$sudu->[ij2n(9,6)]=[3];
#	$sudu->[ij2n(9,7)]=[9];	
################################
#	$sudu->[ij2n(1,3)]=[3];
#	$sudu->[ij2n(1,8)]=[2];
#	$sudu->[ij2n(2,2)]=[1];
#	$sudu->[ij2n(2,5)]=[3];
#	$sudu->[ij2n(2,8)]=[7];
#	$sudu->[ij2n(3,1)]=[5];
#	$sudu->[ij2n(3,5)]=[2];
#	$sudu->[ij2n(3,9)]=[9];
#	$sudu->[ij2n(4,2)]=[8];
#	$sudu->[ij2n(4,4)]=[2];
#	$sudu->[ij2n(5,2)]=[2];
#	$sudu->[ij2n(5,4)]=[7];
#	$sudu->[ij2n(5,5)]=[4];
#	$sudu->[ij2n(5,6)]=[6];
#	$sudu->[ij2n(5,8)]=[1];
#	$sudu->[ij2n(6,6)]=[8];
#	$sudu->[ij2n(6,8)]=[4];
#	$sudu->[ij2n(7,1)]=[9];
#	$sudu->[ij2n(7,5)]=[8];
#	$sudu->[ij2n(7,9)]=[2];
#	$sudu->[ij2n(8,2)]=[4];
#	$sudu->[ij2n(8,5)]=[6];
#	$sudu->[ij2n(8,8)]=[3];
#	$sudu->[ij2n(9,2)]=[7];
#	$sudu->[ij2n(9,7)]=[6];
#######################

	$sudu->[ij2n(1,1)]=[1];
	$sudu->[ij2n(1,4)]=[2];
	
	$sudu->[ij2n(2,3)]=[3];
	$sudu->[ij2n(2,6)]=[1];
	$sudu->[ij2n(2,7)]=[8];	
	
	$sudu->[ij2n(3,2)]=[4];
	$sudu->[ij2n(3,5)]=[9];
	$sudu->[ij2n(3,8)]=[5];
	
	
  $sudu->[ij2n(4,1)]=[5];
	$sudu->[ij2n(4,4)]=[3];
	$sudu->[ij2n(4,6)]=[2];
	$sudu->[ij2n(4,8)]=[4];	
		
	$sudu->[ij2n(5,3)]=[1];
	$sudu->[ij2n(5,7)]=[6];
	
	$sudu->[ij2n(6,2)]=[2];
	$sudu->[ij2n(6,4)]=[8];
	$sudu->[ij2n(6,6)]=[9];
	$sudu->[ij2n(6,9)]=[3];
	
		
	$sudu->[ij2n(7,2)]=[3];
	$sudu->[ij2n(7,5)]=[4];
	$sudu->[ij2n(7,8)]=[9];	
	
	$sudu->[ij2n(8,3)]=[8];
	$sudu->[ij2n(8,4)]=[7];
	$sudu->[ij2n(8,7)]=[1];	
			
	$sudu->[ij2n(9,6)]=[5];
	$sudu->[ij2n(9,9)]=[6];	

	return $sudu;
	
}

sub printsudu{
	my $sudu=$_[0];
	my $i=1;my $j=1;
	print "\nsudu:\n";
	for($i=1;$i<=9;$i++){
		for($j=1;$j<=9;$j++){
			print $sudu->[ij2n($i,$j)][0].' ';
		}
		print "\n";
	}
	print "--------------------\n";
}

sub printsududetail{
	my $sudu=$_[0];
	my $i=1;my $j=1;
	print "\ndetail:\n";
	for($i=1;$i<=9;$i++){
		for($j=1;$j<=9;$j++){
			print "($i,$j):@{$sudu->[ij2n($i,$j)]} * ";
		}
		print "\n";
	}
		print "\n";
}
sub printsuduwitharray{
	my $sudu=$_[0];
	my $i=1;my $j=1;
	print "\nlen:\n";
	for($i=1;$i<=9;$i++){
		for($j=1;$j<=9;$j++){
			print @{$sudu->[ij2n($i,$j)]}.' ';
		}
		print "\n";
	}
}
	
	
sub copysudu{
	my $org=$_[0];
	my $copy;
	my $i=1;my $j=1;
	for($i=1;$i<=9;$i++){
		for($j=1;$j<=9;$j++){
		
			@{$copy->[ij2n($i,$j)]}=@{$org->[ij2n($i,$j)]};
		}
	}
	return $copy;
}
sub fillsudu{
	my $sudu=$_[0];
	my $i=1;my $j=1;
	for($i=1;$i<=9;$i++){
		for($j=1;$j<=9;$j++){
			for(my $temp=1;$temp<10;$temp++){
				push (@{$sudu->[ij2n($i,$j)]},$temp)
				if ( notinline($sudu,$i,$j,$temp) && notinrow($sudu,$i,$j,$temp) && notin9($sudu,$i,$j,$temp)&& $sudu->[ij2n($i,$j)][0]==0 );
			}
		}
	}
	
}	
sub notinline{
	my ($sudu,$i,$j,$num)=@_;
	for(my $temp=1;$temp<10;$temp++){
		return 0 if($temp!=$j && $sudu->[ij2n($i,$temp)][0]==$num);
	}
	return 1;
}
sub notinrow{
	my ($sudu,$i,$j,$num)=@_;
	for(my $temp=1;$temp<10;$temp++){
		return 0 if($temp!=$i && $sudu->[ij2n($temp,$j)][0]==$num);
	}
	return 1;
}	

sub notin9{
	my ($sudu,$i,$j,$num)=@_;
	my $i1=int(($i-1)/3)+1;
	my $j1=int(($j-1)/3)+1;
	my ($t1,$t2);
	for ($t1=1;$t1<=3;$t1++){
		for($t2=1;$t2<=3;$t2++){
			return 0 if($sudu->[ij2n( ($i1-1)*3+$t1,($j1-1)*3+$t2)][0]==$num && (($i1-1)*3+$t1)!=$i && (($j1-1)*3+$t2)!=$j);
		}
	}
	return 1;
}
		
	

sub reducesudu{
	my $sudu=$_[0];
	my $act=0;
	my $i=1;my $j=1;
	do{
		for($i=1;$i<=9;$i++){
			for($j=1;$j<=9;$j++){
				if (@{$sudu->[ij2n($i,$j)]}==2){
					shift(@{$sudu->[ij2n($i,$j)]});
					$act=1;
				}
			}
		}
	}while($act);
	return $act;
	
}
sub reducesudu1{
	my $sudu=$_[0];
	my $act=0;
	my $i=1;my $j=1;

		for($i=1;$i<=9;$i++){
			for($j=1;$j<=9;$j++){
				if (@{$sudu->[ij2n($i,$j)]}==2){
					shift(@{$sudu->[ij2n($i,$j)]});
					totalcleanandfillsudu($sudu);
					$act=1;
				}
			}
		}
		if($act){
			cleansudu($sudu);
			fillsudu($sudu);
		}

	return $act;
	
}	

sub totalcleanandfillsudu{
	my $sudu=$_[0];
	cleansudu($sudu);
	fillsudu($sudu);
}

sub reducesudu2{
	my $sudu=$_[0];
	
	my $i=1;my $j=1;my $k=1;
	my @num;
	my $act=0;
	
	for($i=0;$i<=9;$i++){
		$num[$i]=0;
	}

	for($i=1;$i<=9;$i++){ #eachline
		for($j=0;$j<=9;$j++){
			$num[$j]=0;
		}
		for($j=1;$j<=9;$j++){ 
			if($sudu->[ij2n($i,$j)][0]==0){
				
				for($k=1;$k<@{$sudu->[ij2n($i,$j)]};$k++){
					$num[ $sudu->[ ij2n($i,$j)][$k] ]++;
				}
			}
		} 
		print "in line reduce, @num\n" if $isdebug;
		for($k=1;$k<=9;$k++){ #
			if($num[$k]==1){
				print "num $k is reduced in line\n" if $isdebug;
				for($j=1;$j<=9;$j++){
					if($sudu->[ij2n($i,$j)][0]==0){
						my $st=0;
						for(my $m=1;$m<@{$sudu->[ij2n($i,$j)]};$m++){
							if($sudu->[ij2n($i,$j)][$m]==$k){
								$st=1;
								$act=1;
							}
						}
						if( $st){
							$sudu->[ij2n($i,$j)][0]=$k;
							my $arrlen=@{$sudu->[ij2n($i,$j)]};
							for(my $m=1;$m<$arrlen;$m++){
								pop(@{$sudu->[ij2n($i,$j)]});
							}
						}
						totalcleanandfillsudu($sudu);
					}
				}
			}
		}

	}
	

	
	for($i=1;$i<=9;$i++){ #eachrow
		for($j=0;$j<=9;$j++){ #clear counter
			$num[$j]=0;
		}
		for($j=1;$j<=9;$j++){ 
			if($sudu->[ij2n($j,$i)][0]==0){
				for($k=1;$k<@{$sudu->[ij2n($j,$i)]};$k++){
					$num[ $sudu->[ ij2n($j,$i)][$k] ]++;
				}
			}
		} 
		print "in row $i reduce@num\n" if $isdebug;
		for($k=1;$k<=9;$k++){ #
			if($num[$k]==1){
				print "row $k is reduced\n" if $isdebug;
				for($j=1;$j<=9;$j++){
					if($sudu->[ij2n($j,$i)][0]==0){
						my $st=0;
						for(my $m=1;$m<@{$sudu->[ij2n($j,$i)]};$m++){
							if($sudu->[ij2n($j,$i)][$m]==$k){
								$st=1;
								$act=1;
							}
						}
						if( $st){
							print "change@{$sudu->[ij2n($j,$i)]}\n" if $isdebug;
							
							$sudu->[ij2n($j,$i)][0]=$k;
							printsudu($sudu) if $isdebug;
							my $arrlen=@{$sudu->[ij2n($j,$i)]};
							for(my $m=1;$m<$arrlen;$m++){
								pop(@{$sudu->[ij2n($j,$i)]});
							}
						}
						totalcleanandfillsudu($sudu);
					}
				}
			}
		}
	}
	print "after row reduce\n" if $isdebug;
	printsudu($sudu) if $isdebug;
	printsududetail($sudu) if $isdebug;
		my ($m,$n);
	for($i=1;$i<=3;$i++){ #each9
		for($j=1;$j<=3;$j++){#each9
			for($m=0;$m<=9;$m++){
				$num[$m]=0;
			}
			for ( $m=1;$m<=3;$m++){   #j
				for(  $n=1;$n<=3;$n++){	#j
					if($sudu->[ ij2n( ($i-1)*3+$m,($j-1)*3+$n  ) ][0]==0){
						for($k=1;$k<@{$sudu->[ij2n( ($i-1)*3+$m,($j-1)*3+$n ) ]};$k++){
							$num[ $sudu->[ ij2n( ($i-1)*3+$m,($j-1)*3+$n ) ][$k] ]++;
						}
					}
				}
			}
			print "in9 $i,$j: @num\n" if $isdebug;
			for($k=1;$k<=9;$k++){ #
				if($num[$k]==1){
					print "in9  reduec $k\n" if $isdebug;
					for($m=1;$m<=3;$m++){
						for($n=1;$n<=3;$n++){
							if($sudu->[ij2n( ($i-1)*3+$m, ($j-1)*3+$n ) ][0]==0){
								my $st=0;
								for(my $q=1;$q<@{$sudu->[ij2n( ($i-1)*3+$m,($j-1)*3+$n )]};$q++){
									if($sudu->[ij2n(($i-1)*3+$m,($j-1)*3+$n)][$q]==$k){
										$st=1;
										$act=1;
									}
								}
								
								if( $st){
									print "change @{$sudu->[ij2n(($i-1)*3+$m,($j-1)*3+$n)]}\n" if $isdebug;
									$sudu->[ij2n(($i-1)*3+$m,($j-1)*3+$n)][0]=$k;
								
									my $arrlen=@{$sudu->[ij2n( ($i-1)*3+$m,($j-1)*3+$n)]};
									for(my $q=1;$q<$arrlen;$q++){
										pop(@{$sudu->[ij2n( ($i-1)*3+$m,($j-1)*3+$n)]});
									}
								}
								totalcleanandfillsudu($sudu);
							}
						}
					}
				}

			}
		}
	}
	if($act){
		cleansudu($sudu);
		fillsudu($sudu);
	}

return $act;
	
}

sub removeinline{
	my ($sudu,$num,$line)=@_;
	
	for (my $j=1;$j<=9;$j++){
		$sudu->[ij2n($line,$j)]=grep(/[^$num]/,$sudu->[ij2n($line,$j)])if($sudu->[ij2n($line,$j)][0]==0);
	}
}
sub removeinrow{
	my ($sudu,$num,$row)=@_;
	for (my $j=1;$j<=9;$j++){
		$sudu->[ij2n($j,$row)]=grep(/[^$num]/,$sudu->[ij2n($j,$row)])if($sudu->[ij2n($j,$row)][0]==0);
	}
}
	

sub reduce_and_check{
	my $sudu=$_[0];
	my $act1=0;
	my $act2=0;
	do{

		$act1=reducesudu1($sudu);
		print "after reduce1 is:" if $isdebug;
		printsudu($sudu) if $isdebug;
		printsududetail($sudu) if $isdebug;
		$act2=reducesudu2($sudu);
		print "after reduce2 is:" if $isdebug;
		printsudu($sudu) if $isdebug;
		print "show detail" if $isdebug;
		printsududetail($sudu) if $isdebug;
		print "act2=$act2\n" if $isdebug;

	}while($act1 || $act2);
	print "reduce finish\n";
	$act1=check($sudu);
	print "check results: $act1\n";
	return $act1;

}

sub check{
	my $sudu=$_[0];
	
	my $i=1;my $j=1;
	my @num;
	for($i=1;$i<=9;$i++){
		for($j=1;$j<=9;$j++){
			if($sudu->[ij2n($i,$j)][0]==0 && @{$sudu->[ij2n($i,$j)]}==1){
				return 'cf';
			}
		}
	}
	for($i=0;$i<=9;$i++){
		$num[$i]=0;
	}

	for($i=1;$i<=9;$i++){ #eachline
		for($j=0;$j<=9;$j++){
			$num[$j]=0;
		}
		for($j=1;$j<=9;$j++){
			$num[ $sudu->[ ij2n($i,$j)][0] ]++;
		}
		for($j=1;$j<=9;$j++){
			return 'cf' if $num[$j]>1; #conflict
		}
	}
	print " passed line\n";
	for($i=1;$i<=9;$i++){ #eachrow
		for($j=0;$j<=9;$j++){
			$num[$j]=0;
		}
		for($j=1;$j<=9;$j++){
			$num[ $sudu->[ij2n($j,$i)][0] ]++;
		}
		for($j=1;$j<=9;$j++){
			return 'cf' if $num[$j]>1; #conflict
		}
	}
	print " passed row\n";
	my ($m,$n);
	for($i=1;$i<=3;$i++){ #each9
		for($j=1;$j<=3;$j++){
			for($m=0;$m<=9;$m++){
				$num[$m]=0;
			}
			for ( $m=1;$m<=3;$m++){
				for(  $n=1;$n<=3;$n++){	
					$num[ $sudu->[ ij2n( ($i-1)*3+$m,($j-1)*3+$n)][0] ]++;
				}
			}
			for($m=1;$m<=9;$m++){
				return 'cf' if $num[$m]>1; #conflict
			}
		}
	}
	print " passed 9\n";
	for($i=1;$i<=9;$i++){
		for($j=1;$j<=9;$j++){
			return 'un' if $sudu->[ij2n($i,$j)][0]==0; #still has undetermained num 
		}
	}
	return 'ok';
}
sub guess{
}
sub loadsudu{
	my $filename=$_[0];
	open FILE, $filename or die "open file error\n";
	my @in=<FILE>;
}
