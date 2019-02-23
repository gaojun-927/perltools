#!/bin/perl
#sudu

use strict;
my $sudu;
$sudu=init($sudu);
reducesudu($sudu);
our $i=0;#depth
our $j=0;#total
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
		$suducopy=copysudu($sudu);
		print "i is $i";
		print "\nbegin into:\n";
		printsudu($suducopy);

	
		my $act=0;
		do{
			cleansudu($suducopy);
			fillsudu($suducopy);
			$act=reducesudu($suducopy);
		}while($act);
		cleansudu($suducopy);
		fillsudu($suducopy);
		
		print "reduce into:\n";	
		printsudu($suducopy);
			

		
		$status=check($suducopy);
		print "status: $status\n";
		
		
		if($status eq 'ok'|| $i>$deep){
			print 'too deep '."\n" if $i>$deep;
			

			return ($status,$suducopy);
		}elsif( $status eq 'cf'){
			print "cf\n";
			
			return ($status,$suducopy);
		}
		else{
			$i++;
			$j++;


			while($pt->[0]<81){
				print 'old pt is '.$pt->[0].' '.$pt->[1].' '."\n";
				print 'old value is '.$suducopy->[$pt->[0] ][0]."\n";
				print '@ is '."@{$suducopy->[$pt->[0] ]}"."\n";	
				
				if($pt->[0]==0|| $pt->[1]>=@{$suducopy->[ $pt->[0] ]}-1 ||( $pt->[1]==0 && @{$suducopy->[ $pt->[0] ]}==1 ) ){
					while( $suducopy->[ $pt->[0]+1 ][0]!=0 && $pt->[0]<81){$pt->[0]++;}
					$pt->[0]++;
					$pt->[1]=1;
					last if $pt->[0]>81;
				}else{
					$pt->[1]++;
				}
				$suducopy->[$pt->[0] ][0]=$suducopy->[$pt->[0] ][$pt->[1]];
				
				print 'pt is '.$pt->[0].' '.$pt->[1].' '."\n";
				print 'value is '.$suducopy->[$pt->[0] ][0]."\n";
				print '@ is '."@{$suducopy->[$pt->[0] ]}"."\n";
				my $ttt;			
				($status,$ttt)=resolve($suducopy);
				
				if ( $status eq 'cf' ){
					for (my $temp=$pt->[1]; 
        		$temp<@{$suducopy->[$pt->[0]]}-1;$temp++){
        		$suducopy->[ $pt->[0] ][$temp]=$suducopy->[ $pt->[0] ][$temp+1];
					}
					pop(@{$suducopy->[$pt->[0]]});
					$pt->[1]--;
					
				}elsif( $status eq 'ok' ){					
					return ($status,$ttt);
				}elsif( $status eq 'un'){
				}
				$suducopy->[ $pt->[0] ][0]=0;
				

				
#				print "sudu loop:\n";
#				printsudu($suducopy);
#				$act=0;
#				do{
#					cleansudu($suducopy);
#					fillsudu($suducopy);
#					$act=reducesudu($suducopy);
#				}while($act);
#				print "sudu loop reduce:\n";
#				printsudu($suducopy);
			}
			$i--;
			return ('un',$suducopy);
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
				for($k=@{$sudu->[ij2n($i,$j)]};$k>1;$k--){
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
	for($i=1;$i<=9;$i++){
		for($j=1;$j<=9;$j++){
			print $sudu->[ij2n($i,$j)][0].' ';
		}
		print "\n";
	}
}
sub printsuduwitharray{
	my $sudu=$_[0];
	my $i=1;my $j=1;
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
	for($i=1;$i<=9;$i++){
		for($j=1;$j<=9;$j++){
			if (@{$sudu->[ij2n($i,$j)]}==2){
				shift(@{$sudu->[ij2n($i,$j)]});
				$act=1;
			}
		}
	}
	return $act;
	
}
sub check{
	my $sudu=$_[0];
	
	my $i=1;my $j=1;
	my @num;
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
