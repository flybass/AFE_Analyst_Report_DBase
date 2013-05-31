#Parser Switch Control
sub text_process{
		my $bank = shift @_;
		my $textfile = shift@_;
		if($bank =~ m/JPMO/){
			JP_Morgan($textfile);
		}
		elsif($bank =~ m/JEFFERIES/){
			JP_Morgan($textfile);
		}
		elsif($bank =~ m/MACQUARIE/){
			Macquarie($textfile);
		}
		elsif($bank =~ m/THINKEQUITY/){
			Thinkeq($textfile);
		}
		elsif($bank =~ m/NOMURA/){
			Nomura($textfile);
		}
		elsif($bank =~ m/^RBS/){
			RBS($textfile);
		}
		elsif($bank=~m/DEUTSCHE/){
			Deutsche($textfile);
		}
		elsif($bank=~m/BNP PAR/){
			BNP($textfile);
		}
		elsif($bank=~m/CREDIT SUISSE/){
			CREDIT($textfile);
		}
		elsif($bank=~m/HSBC/){
			hsbc($textfile);
		}
		elsif($bank=~m/MORGAN STANLEY/){
			morgan($textfile);
		}
		elsif($bank=~m/KGI SECUR/){
			kgi($textfile);
		}
		elsif($bank=~m/YUANTA/){
			yuanta($textfile);
		}
		else{default_parse($textfile);}
	}
	


#Parser Subroutines
sub JP_Morgan{
		my $linecount;
		my $textfile = shift@_;
		open(MYFILE, $textfile);
		while(<MYFILE>){
			$text= $text.$_;
			$linecount++;
			if($linecount<30){
				if($_=~m/·(.*)/){
				$summary=$summary.$1."\n";}
			}
			
		}
	close (MYFILE);
	}
	
	sub Macquarie{
		my $linecount=31;
		my $textfile = shift@_;
		open(MYFILE, $textfile);
		while(<MYFILE>){
			$text= $text.$_;
			$linecount++;
			if($_=~ m/Event/){$linecount=0;}
			if($linecount<30){
				if($_=~ m/Reported profit Profit bonus exp Bon exp\/rep prof /){}
				elsif($_=~ m/EPS rep.*EPS rep growth \% EPS bonus exp.*EPS/){}
				elsif($_=~m/(.*)/){
				$summary=$summary.$1."\n";}
			}
		}
	close (MYFILE);
	}
	sub Thinkeq{
		
		my $linecount;
		my $textfile = shift@_;
		open(MYFILE, $textfile);
		while(<MYFILE>){
			$text= $text.$_;
			
				if($_=~m/THINK ACTION: (.*)/){
				$summary=$summary.$1."\n";}
			}
		
	close (MYFILE);
	}
	
	sub Nomura{
		my $nextlcatch =0;

		my $textfile = shift@_;
		open(MYFILE, $textfile);
		while(<MYFILE>){
			$text= $text.$_;
			if($nextlcatch==0){
			
				if($_=~m/Our view(.*)/){
				$summary=$summary.$1."\n";}
				elsif($_=~m/First look(.*)/){
				$summary=$summary.$1."\n";}
				elsif($_=~m/\~ Action/){
				$nextlcatch =1;}
			}
			else{ if($_=~m/(.*)/){
				$summary=$summary.$1."\n";
				$nextlcatch =0;}
			}
		}
		
	close (MYFILE);
	}
	
	sub RBS{
		my $nextlcatch =0;

		my $textfile = shift@_;
		open(MYFILE, $textfile);
		while(<MYFILE>){
			$text= $text.$_;
			if($nextlcatch==0){
			
				if($_=~m/year to Dec, fully diluted/){
				$nextlcatch =1;}
				elsif($_=~m/\+\d+.*\.abnamro\.com/){
				$nextlcatch =1;}
				
			}
			elsif($nextlcatch==1){$nextlcatch++;}
			elsif($nextlcatch==2){
					if($_=~m/(.*)/){
						$summary=$summary.$1."\n";
					$nextlcatch =0;}
			}
		}
		
	close (MYFILE);
	}
	
		sub Deutsche{
		my $nextlcatch =0;

		my $textfile = shift@_;
		open(MYFILE, $textfile);
		while(<MYFILE>){
			$text= $text.$_;
			if($nextlcatch==0){
			
				if($_=~m/Price\/price relative/){
				$nextlcatch =1;}
				elsif($_=~m/Key changes/){
				$nextlcatch =1;}
				
			}
			elsif($nextlcatch==1){if($_=~m/^$/){$nextlcatch =10;}}
			elsif($nextlcatch==10){
					if($_=~m/Price\/price relative/){
					$nextlcatch =1;}
					elsif($_=~m/(.*)/){
						$summary=$summary.$1."\n";
					$nextlcatch =0;}
			}
		}
		
	close (MYFILE);
	}
	
	sub BNP{
		my $nextlcatch =0;

		my $textfile = shift@_;
		open(MYFILE, $textfile);
		while(<MYFILE>){
			$text= $text.$_;
			if($nextlcatch==0){
			
				if($_=~m/Sources\: Thomson One Analytics/){
				$nextlcatch =1;}

				
			}
			elsif($nextlcatch<5){$nextlcatch++;}
			elsif($nextlcatch==5){
					if($_=~m/(.*)/){
						$summary=$summary.$1."\n";
					$nextlcatch =6;}
			}
			else{
				if($_=~m/(.*)/){
						$summary=$summary.$1."\n";
					$nextlcatch =0;}
		}
		}
		
	close (MYFILE);
	}
	
	sub CREDIT{
		my $nextlcatch =0;

		my $textfile = shift@_;
		open(MYFILE, $textfile);
		while(<MYFILE>){
			$text= $text.$_;
			if($nextlcatch==0){
			
				if($_=~m/COMPANY UPDATE/){
				$nextlcatch =1;}
				elsif($_=~m/EARNINGS/){
				$nextlcatch =1;}
				elsif($_=~m/FORECAST/){
				$nextlcatch =1;}
				elsif($_=~m/^EPS.*\s+TP/){
				$nextlcatch =3;}
				elsif($_=~m/^Valuation$/){
				$nextlcatch =2;}

				
			}
			elsif($nextlcatch==1){
			
					if($_=~m/n\.a\./){
						$nextlcatch =0;}
						elsif($_=~m/Financial and valuation metrics/){
						$nextlcatch =0;}
						elsif($_=~m/(.*)/){
						$summary=$summary.$1."\n";
					}
			}
			elsif($nextlcatch==2){
			
					if($_=~m/(.*)DISCLOSURE APPENDIX/){
						$summary=$summary.$1."\n";
						$nextlcatch =0;}
						
					}
			elsif($nextlcatch==3){
				
					if($_=~m/Bbg/){
						$nextlcatch =0;}
						
					
					elsif($_=~m/(.*)/){
						$summary=$summary.$1."\n";
						}
						
					}
			
			
				
		}
		
		
	close (MYFILE);
	}
	
	sub hsbc{
		my $nextlcatch =0;

		my $textfile = shift@_;
		open(MYFILE, $textfile);
		while(<MYFILE>){
			$text= $text.$_;
			if($nextlcatch==0){
			
				if($_=~m/WEIGHTED IN /){
				$nextlcatch =1;}

				
			}
			
			elsif($nextlcatch==1){
				if($_=~m/Employed by a non-US affiliate of HSBC/){
						$nextlcatch=0;
						}
				
				
					elsif($_=~m/annual forecasts and valuation Revenue/){
						$nextlcatch=0;
						}
						elsif($_=~m/______________/){
						$nextlcatch=0;
						}
						
						 
					elsif($_=~m/(.*)/){
						$summary=$summary.$1."\n";
						}
						
			
		}
		}
		
	close (MYFILE);
	}
	sub morgan{
		
		my $catch=0;
		my $textfile = shift@_;
		open(MYFILE, $textfile);
		while(<MYFILE>){
			$text= $text.$_;
			if($catch ==0){
				
				if($_=~m/Investment conclusion\:(.*)/){
					$summary=$summary.$1."\n";}
						
				if($_=~m/What's new\:(.*)/){
					$summary=$summary.$1."\n";}
				if($_=~m/Quick Comment \-(.*)/){
					$summary=$summary.$1."\n";}
			
				if($_=~m/52\-Week Range Sh out.*dil.*curr.*Mkt cap.*curr/){
					$catch =1;}
			}
			elsif ($catch==1){ $catch++;}
			elsif($catch ==2){
				if($_=~m/(.*)/){
					
				$summary=$summary.$1."\n";}
				$catch =0;
			}
		}
	close (MYFILE);
	}
	
	sub kgi{
		
		my $catch=0;
		my $textfile = shift@_;
		open(MYFILE, $textfile);
		while(<MYFILE>){
			$text= $text.$_;
			if($catch ==0){
				
			
				if($_=~m/Source\:/){
					$catch =1;}
			}
			elsif ($catch==1){ 
				if($_=~m/Source\:/){
					$catch =2;}
				elsif($_=~m/(.*)/){$summary=$summary.$1."\n";}
				
				
			
		}
		}
	close (MYFILE);
	}
	
	sub yuanta{
		
		my $catch=0;
		my $textfile = shift@_;
		open(MYFILE, $textfile);
		while(<MYFILE>){
			$text= $text.$_;
			if($catch ==0){
				
			
				if($_=~m/^Event/){
					$catch =1;}
				elsif($_ =~m/What\'s new\?/){ $catch =1;}
			}
			elsif ($catch==1){ 
				if($_=~m/\@yuanta\.com/){
					$catch =2;}
				elsif($_=~m/(.*)/){$summary=$summary.$1."\n";}
				
				
			
		}
		}
	close (MYFILE);
	}
	
sub default_parse{
	my $textfile = shift@_;
	open(MYFILE, $textfile);
	while(<MYFILE>){
			$text= $text.$_;
			if( $_ =~ /\d+(\s+|\s|\t)\d+(\s+|\s|\t)\d+/){}
			elsif($_ =~ /^$/){}
			elsif($_ =~ /^\s+$/){}
			elsif($_ =~ /^\d+$/){}
			elsif($_ =~ /\.\.\.\.\.\.\.\.\.\.\.\.\./){}
			elsif($_ =~ /\-\-\-\-\-\-\-\-\-\-\-/){}
			elsif($_ =~ /page \d+/i){}
			elsif($_ =~ /www\..*\.com/){}
			else{$summary=$summary.$_."\n";}
			
	}
	
	close (MYFILE);
}

1;

