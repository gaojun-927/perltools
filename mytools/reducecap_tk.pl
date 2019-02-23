use strict;
use Tk ;
use Tk::BrowseEntry;
use Tk::Balloon;
use Tk::Dialog;

my $filename='';
my $tofilename='';
my $isInc=0;
my $isSame=0;


my $mw=new MainWindow(-title=>'Reducecap_tk by Gao Jun');
my $frame1=$mw->Frame();
my $filename_label=$frame1->Label( -text=>' file name: ');
my $file_entry=$frame1->Entry( -textvariable=>\$filename );

my $openfile_button=$frame1->Button( -command=>sub{ $filename=$mw->getOpenFile() }, 
									# -command=>sub{...},\&fun,[\&fun,arg,arg] but not \&fun(..)
							  		-text=>'...',
									);
my $tofile_button=$frame1->Button( -command=>sub{ $tofilename=$mw->getOpenFile() }, 
									# -command=>sub{...},\&fun,[\&fun,arg,arg] but not \&fun(..)
							  		-text=>'...',
									);
my $isSame_checkbutton=$frame1->Checkbutton( -text=>'Same Name', 
										 -variable=>\$isSame,
										 -command=>sub{if($isSame){$tofilename=$filename}}
										 	);
my $tofile_label=$frame1->Label( -text=>' to file: ');

my $tofile_entry=$frame1->Entry(  -textvariable=>\$tofilename,  );
$tofile_entry->bind('<FocusOut>' => sub{
										if($tofilename ne $filename){
											$isSame_checkbutton->deselect()
											}
										}
					);



my $isInc_checkbutton=$frame1->Checkbutton(  -text=>'Deal Inc file',
											 -variable=>\$isInc ,
											 -command=>sub{ if($isInc){
														#	$isSame_checkbutton->select(); #select only set the value not call command
														 	$isSame=0;
														 	$isSame_checkbutton->invoke(); #invoke vill call command but the var value toggle?
														 	}
											 	 } 
										 );
my $frame2=$mw->Frame();										 
my $rule_label=$frame2->Label(-text=>"Rule:");
my @rule_frame;
my @rule;
foreach my $i(1..5){
	$rule_frame[$i]->{'frame'}=$mw->Frame();
	$rule[$i]->{'valid'}=0;
	$rule_frame[$i]->{'valid'}=$rule_frame[$i]->{'frame'}->Checkbutton( -text=>'valid', -variable=>\$rule[$i]->{'valid'} );
	$rule[$i]->{'exclude'}='i';
	$rule_frame[$i]->{'exclude'}=$rule_frame[$i]->{'frame'}->Radiobutton( -text=>'force exclude', -variable=>\$rule[$i]->{'exclude'}, -value=>'f_e', );
	$rule_frame[$i]->{'include'}=$rule_frame[$i]->{'frame'}->Radiobutton( -text=>'force include', -variable=>\$rule[$i]->{'exclude'}, -value=>'f_i', );
	$rule_frame[$i]->{'include1'}=$rule_frame[$i]->{'frame'}->Radiobutton( -text=>'include', -variable=>\$rule[$i]->{'exclude'}, -value=>'i', );
	$rule[$i]->{'target'}='$capvalue';
	$rule_frame[$i]->{'target'}=$rule_frame[$i]->{'frame'}->BrowseEntry(  -variable=>\$rule[$i]->{'target'} );
	$rule_frame[$i]->{'target'}->insert(0,'$node1','$node2','$capvalue');
	$rule[$i]->{'op'}='>';
	$rule_frame[$i]->{'op'}=$rule_frame[$i]->{'frame'}->BrowseEntry(  -variable=>\$rule[$i]->{'op'} );
	$rule_frame[$i]->{'op'}->insert(0,'match','not match','>','<');
	$rule[$i]->{'thread'} ='';
	$rule_frame[$i]->{'thread'}=$rule_frame[$i]->{'frame'}->Entry(  -textvariable=>\$rule[$i]->{'thread'} );	
}
my $frame3=$mw->Frame();
my $run_button=$frame3->Button(-text=>'RUN',-command=>\&run);
my $close_button=$frame3->Button(-text=>'EXIT', -command=>sub{ exit;} );
my $statusbar=$mw->Label(-borderwidth=>1,-relief=>'groove',-anchor=>'n');
my $balloon=$mw->Balloon(-statusbar=>$statusbar,);
$balloon->attach($run_button,-msg=>'run cap reduce');
my $rule_explain=<<HERE;
The program will process each rule for each cap line.
Once it fit the force exclude rule, the line will be drop.
Once it fit the force include rule, the line will be reserved.
When all rule not force exclude is fit, the line will be reserved
HERE
$balloon->attach($rule_label,-balloonmsg=>$rule_explain);
$balloon->attach($isSame_checkbutton,-msg=>'output file has the same name with input file');
$balloon->attach($isInc_checkbutton,-balloonmsg=>"The output filename MUST be the same with the origin filename\nThe origin file will be renamed to *.bak");
	

$frame1->pack(-side=>'top',-fill=>'x',);
$filename_label->pack(-side=>'left',-anchor=>'n');
$file_entry->pack(-side=>'left',-anchor=>'nw',-ipadx=>35);
$openfile_button->pack(-side=>'left',-anchor=>'nw');
$tofile_label->pack(-side=>'left',-anchor=>'nw');
$tofile_entry->pack(-fill=>'x',-side=>'left',-anchor=>'nw',-ipadx=>35);
$tofile_button->pack(-side=>'left',-anchor=>'nw');
$isSame_checkbutton->pack(-side=>'left',-anchor=>'nw'); 
$isInc_checkbutton->pack(-side=>'left',-anchor=>'nw');
$frame2->pack(-side=>'top',-fill=>'x',-anchor=>'nw');
$rule_label->pack( -side=>'left',-anchor=>'nw',-fill=>'x');
foreach my $i(1..5){
	$rule_frame[$i]->{'frame'}->pack(-side=>'top',-fill=>'x');
	$rule_frame[$i]->{'valid'}->pack(-side=>'left',-anchor=>'nw',-fill=>'x');
	$rule_frame[$i]->{'exclude'}->pack(-side=>'left',-anchor=>'nw',-fill=>'x');
	$rule_frame[$i]->{'include'}->pack(-side=>'left',-anchor=>'nw',-fill=>'x');
	$rule_frame[$i]->{'include1'}->pack(-side=>'left',-anchor=>'nw',-fill=>'x');
	$rule_frame[$i]->{'target'}->pack(-side=>'left',-anchor=>'nw',-fill=>'x');
	$rule_frame[$i]->{'op'}->pack(-side=>'left',-anchor=>'nw',-fill=>'x');
	$rule_frame[$i]->{'thread'}->pack(-side=>'left',-anchor=>'nw',-fill=>'x');
}
$frame3->pack(-side=>'top',-fill=>'x');
$close_button->pack(-side=>'right',-anchor=>'e');
$run_button->pack(-side=>'right',-anchor=>'e');
$statusbar->pack(-side=>'bottom',-fill=>'x');
MainLoop;
sub run{
	if(!checked()){
		return;
	}else{
		process_file($filename,$tofilename);
		$mw->Dialog( -title=>'OK',
					-text=>'OK',
					)->Show();
	}
}
sub checked{
	if($filename eq '' or !(-e $filename) or $tofilename eq '' ){
		$mw->Dialog( -title=>'Notice',-text=>'No such file')->Show();
		return 0;
	}
	foreach my $i(1..5){
		if( $rule[$i]->{'valid'} ){
			if($rule[$i]->{'target'} eq '$node1' or $rule[$i]->{'target'} eq '$node2'){
				if( $rule[$i]->{'op'} eq '>' or $rule[$i]->{'op'} eq '<' ){
					$mw->Dialog(-title=>'Notice', -text=>"$rule[$i]->{'target'} $rule[$i]->{'op'} ?" )->Show();
					return 0;
				}
			}
			if($rule[$i]->{'target'} eq '$capvalue' ){
				if( $rule[$i]->{'op'} eq 'match' or   $rule[$i]->{'op'} eq 'not match'){
					$mw->Dialog(-title=>'Notice', -text=>"$rule[$i]->{'target'} $rule[$i]->{'op'}  ?" )->Show();
					return 0;
				}
			}			
		}
	}
	return 1;
}
sub process_file{
	my ($infile,$tofile)=@_;
	print "\nprocess $infile to $tofile, option isSame is $isSame \n";
	my $newname;
	my @inctable;
	if( ! -e $infile ){
		print "fail to open $infile\n";
		return
	}
	if($isSame){
		$newname=$infile.'.bak';
		rename($infile, $newname);
	}else{
		$newname=$infile;
	}
	
	open FHin, $newname;

	open FHout,">  $tofile";
	my $status=0; #$status==1:there is previous line in $output
	my $output='';
	my $multi=1;
	while(<FHin>){
        if ( /\\$/ ){
            $status=1;
            my $tt=$_;
            chop $tt;chop $tt;
            $output=$output.$tt;
    	}else{
            if( $status ){
                    $output=$output.$_;
            }else{
                    $output=$_;
            }
            #process
            #1.inc
            if($output=~/^\s*\.?inc\S*\s+(\S+)/){
            	my $temp=$1;
            	if( $temp=~/^"(\S+)"$/ ){
            		$temp=$1;
            	}
            	push(@inctable,$temp);
            }
            if( $output=~ /(\S+)\s+(\S+)\s*?\)?\s+capacitor\s+c=([-\d.e]+)([fp]?)/ #spectre
            ){		
            		my $node1;my $node2;my $cap;
            		$node1=$1;$node2=$2;
                    if($4 eq 'f'){
                            $multi=1e-15;
                    }elsif($4 eq 'p'){
                            $multi=1e-12;
                    }else{
                            $multi=1;
                    }
                    $cap=$3*$multi;
                    if( !fitrule($node1,$node2,$cap) ){
                            $output=''; $status=0;
                             next;
                    }
            }
            	
                print FHout  $output;
                $output='';
                $status=0;
        }
	}
	close(FHin);
	if($isInc){
		foreach my $filename(@inctable){
			process_file($filename,$filename);
		}
	}
}
sub fitrule{
	#return 1 if the input is reserved
	my ($node1,$node2,$capvalue)=@_;
#	print "\n 1. $capvalue \n";
	foreach my $i(1..5){
		if($rule[$i]->{'valid'}){
			my $op=$rule[$i]->{'op'};
			my $target=$rule[$i]->{'target'};
			my $thread=$rule[$i]->{'thread'};
			my $result=0;
			if($op eq 'match'){
				$result=eval "$target=~/$thread/";
#				print "\nMatch $result = $target =~ $thread\n";
			}elsif( $op eq 'not match'){
				$result=eval "$target!~/$thread/";
#				print 'not match'.$result;
			}else{
#				print "begin: $result=( ($target) $op ($thread) ) ";
				$result=eval " ( ($target) $op ($thread) ) ";
			}
			if(  ( $rule[$i]->{'exclude'} eq 'f_e' && $result==1 ) 
				|| ( $rule[$i]->{'exclude'} ne 'f_e' && $result==0 )){
				return 0;
			} 
			if(  $rule[$i]->{'exclude'} eq 'f_i' && $result==1 ){
				return 1;
			}
		}
	}
	return 1;
}
