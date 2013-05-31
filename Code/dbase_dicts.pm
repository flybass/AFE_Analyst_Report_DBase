#Here we load in the various dictionary files

use Spreadsheet::ParseExcel;

#1) This file helps to augment search by pulling equivalent terms for any query
# IE _ A search for EPS is a search for EPS U Earnings per share
my %search_dict;

#Here we take a user customizable csv input for the search dictionary
sub initialize_search_dict{
	my $parser = Spreadsheet::ParseExcel->new();
	my $dict_book = $parser->parse('fin_dict.xls');
	my $worksheet = $dict_book->worksheet('HASH');
	my ( $row_min, $row_max ) = $worksheet->row_range();

        for my $row ( 1 .. $row_max ) {
    

                my $key = $worksheet->get_cell( $row, 0 );
                my $val = $worksheet->get_cell( $row, 1 );
                next unless $key & $val;
                $search_dict{$key->value()} = $val->value();
          
            }
}
	
	
#1) These are lists of McDonald Sentiment Words
# This allows for a sentiment scoring on the articles
%mcdonald_words;
sub initialize_sentiment_dict{
	my $parser = Spreadsheet::ParseExcel->new();
	my $dict_book = $parser->parse('LoughranMcDonald.xls');
	my $array_to_write =0;
	for my $readsheet ( $dict_book->worksheets() ) {
	
		my ( $row_min, $row_max ) = $readsheet->row_range();
		

		for my $row ( $row_min .. $row_max ) {
    

			my $word = $readsheet->get_cell( $row, 0 );
			$word = $word->value();
			next unless $word;
			$mcdonald_words{$word} = $readsheet->get_name();
          
		}
            
        }
     
        
}


#Calculates Equivalencies from keywords
#returns array of equivalent keywords (regex ready)
sub kw_equiv{
	my @keywords = @{shift @_};

	my @kw_equivs;
	foreach(@keywords){
		if(exists $search_dict{uc($_)}){
			push(@kw_equivs, '('.$_.'|'.$search_dict{uc($_)}.')');
		}
		else{ push(@kw_equivs, $_);}
	}
	
	return @kw_equivs;
	
		
	
}

sub sentiment_score{
	my $summarytext = shift @_;
	my @scores;
	if ($summarytext eq ""){@scores = (9**9**9, 9**9**9);}
	else{
		my @words_in_summary = split(/(\s|\n)/, $summarytext);
		my $n_positive=0;
		my $n_sub_pos =0;
		my $n_uncertain =0;
		my $n_weak = 0;
		my $n_negative =0;
		foreach(@words_in_summary){
			my $senti = $mcdonald_words{uc($_)};
			
			if($senti eq 'Negative'){$n_negative++;}
			elsif($senti eq 'ModalWeak'){$n_weak++;}
			elsif($senti eq 'Uncertainty'){$n_uncertain++;}
			elsif($senti eq 'ModalStrong'){$n_sub_pos++;}
			elsif($senti eq 'Positive'){$n_positive++;}
		}
	
		my $sentiscore = ((2*$n_positive) + $n_sub_pos - $n_weak -(2*$n_negative))/($#words_in_summary+1);
		my $uncertscore = $n_uncertain/($#words_in_summary+1);
		@scores = ($sentiscore, $uncertscore);}
	return @scores;
}

sub initialize_projects{
	open(MYFILE, 'Projects/projects.txt');
	my @options = <MYFILE>;
	chomp (@options);
	close (MYFILE);

		
	return \@options;
	
}

sub overwrite_projects{
	my @options = @{shift @_};
	open(MYFILE, '>Projects/projects.txt');
	foreach(@options){
		print MYFILE $_."\n";
		
	}
	close (MYFILE);
	
}














1;
