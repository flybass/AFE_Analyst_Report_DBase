#This executes commands using the mongodb
use File::Find;
use Algorithm::Permute;



#This is the import subroutine which takes a directory (calls importer)
my @pdfs;
sub import_com{
	my $import_dir = shift @_;
	finddepth(\&push_name_if_pdf, $import_dir);
	sub push_name_if_pdf{
			if( $_ =~m/\.pdf/g){
				push(@pdfs, $File::Find::name);
				print $_, "\n";}
		}
	catalog();
	
			
}

sub import_com_test{
	my $import_dir = shift @_;
	opendir (DIR, $import_dir) or die $!;
	my @pdfs;
	while (my $file = readdir(DIR)) {

        if( $file =~m/\.pdf$/g){
				push(@pdfs, $import_dir.'/'.$file);
				print $_, "\n";}
		}

        closedir(DIR);
	
	catalog(\@pdfs);
			
}

#called to add the pdfs to dbase (calls bank subroutines)
#necessary global writes
$text="";
$summary="";
sub catalog{
	my $temp_ref = shift;
	my $numprocessed =0;
	foreach(@pdfs){
		my $date;
		my $bank;
		my $title;
		
		
	
		my $location = $_;
	
		if( $_=~ m/.*\/(\d\d\d\d)-(\d\d)-(\d\d)/){
		$date = DateTime->new(year => $1, month =>$2, day => $3);
		}
		if( $_=~ m/\((.+?)\)\s+.*/){
			$bank = $1;
			print $bank."\n";
		}
		if( $_ =~m/\)\s+(.*)\.\d+\.pdf/){
			$title = $1;
		}
		#system('cd C:\XPdf');
	
		system('pdftotext "'.$_.'"');
	
		my $textfile = substr $_, 0, (length($_)-4);
		$textfile = $textfile.'.txt';
		text_process($bank, $textfile);
		
		if($summary eq ''){default_parse($textfile);}
		my @scores = sentiment_score($summary);
		unlink $textfile;
		if(defined $date && defined $bank && defined $title){
			my $pdf_entry=pdf_entry->new( date => $date, bank =>$bank, 
			title=>$title, text =>$text, location =>$location, summary =>$summary,
			sent_score =>$scores[0], uncert_score=>$scores[1] );
			$pdf_entry->save;}
			print $bank, "\n";
		#reset globals
		$text="";
		$summary="";
		$numprocessed++;
		#print $numprocessed, "\n";
		import_progress_bar($#pdfs+2, $numprocessed);
		}
		report_all();
		@pdfs=();
}
#This empties the collection (was full from previous import
sub empty{
	my $collection =$db->get_collection('pdf_entry');
	$collection->remove({});
}

#Search Subroutine - conducts search of database, input is a search object
sub search_com{
	my $search_obj = shift @_;
	my @banks = @{$search_obj->banks};
	my @final_keywords = @{$search_obj->keywords};
	my $title = $search_obj->title;
	
	my $search_bank_regex ='';
	foreach(@banks){
		if($search_bank_regex eq ''){$search_bank_regex=$_;}
		else{$search_bank_regex=$search_bank_regex.'|'.$_;}}

	my $search_keyword_regex ='';
	foreach(@final_keywords){
		search_word_rep($_);
		
		my $box_term='';
		my $perm = new Algorithm::Permute($_);
		while (@res = $perm->next) {
			$box_term =$box_term.'('.join('.*', @res).')|';
		}
		$search_keyword_regex =$search_keyword_regex.'('.(substr $box_term,0, -1).')|';
		}
		reset_boxes();
		
		
	$search_keyword_regex =substr $search_keyword_regex,0,-1;
	print $search_keyword_regex, "\n";
	
	my $min_S = $search_obj->sent_min +0;
	my $max_S = $search_obj->sent_max +0;
	#summary search cursor
	my $cursor = pdf_entry->find({date => {'$gte' => $search_obj->sdate, '$lte'=> $search_obj->edate}, 
		summary => {'$regex' => $search_keyword_regex, '$options' => 'i'},
		bank => {'$regex' => $search_bank_regex, '$options' => 'i'},
		title => {'$regex' => $title, '$options' => 'i'},
		sent_score => {'$gte' => $min_S, '$lte'=>$max_S }});
	
	#full text search cursor
	my $cursor_full_t = pdf_entry->find({date => {'$gte' => $search_obj->sdate, '$lte'=> $search_obj->edate}, 
		text => {'$regex' => $search_keyword_regex, '$options' => 'i'},
		bank => {'$regex' => $search_bank_regex, '$options' => 'i'},
		title => {'$regex' => $title, '$options' => 'i'},
		sent_score => {'$gte' => $min_S, '$lte'=> $max_S}});
	
	
	
	my @search_results;
	$cursor->each(sub{
		my $pdf = shift;
		#print $pdf->bank, "\n";
		push(@search_results, $pdf);
		
	});
	
	my @search_results_full_t;
	$cursor_full_t->each(sub{
		my $pdf = shift;
		#print $pdf->bank, "\n";
		push(@search_results_full_t, $pdf);
		
	});
	
	my ($ranked_res,$res_texts)  = result_rank(\@search_results_full_t, $search_keyword_regex);
	my (%ranked_res, %res_texts)= (%$ranked_res,%$res_texts);

	search_report(\@search_results, $search_obj, \%ranked_res,\%results_texts );
	search_report_full_t(\@search_results_full_t, $search_obj, \%ranked_res, \%results_texts);
	

}

#generates a rank score for the result
sub result_rank{
	my @search_results = @{shift @_};
	my $search_keyword_regex = shift @_;
	#splits regex but carries delimiters
	my @keywords = split(/(\.\*)|(\|)|(\()|(\))/, $search_keyword_regex);
	#filter out words from delimiters
	@keywords = grep(/\w+/, @keywords);
	#upper case search words
	@keywords = map{uc($_)} @keywords;

	
	my %keyword_hash   = map { $_ => 1 } @keywords;
	@keywords = keys %keyword_hash;

	my %ranked_res;
	my %res_texts;
	foreach(@search_results){
		my $pdf = $_;
		my $full_text = $_->text;
		$full_text = uc($full_text);
		my $matches =0;
		my $results_text = '';
		foreach(@keywords){
			while ($full_text =~/[\., \n]([^\.]*?\s$_\s.*?\.)[\n,\s]/g){
				$results_text =$results_text.$1."\n";}
			while ($full_text =~/[^\w]$_[^\w]/g){
				$matches++;}
		}
		$ranked_res{$pdf->location} = $matches;
		#print $matches, "\n";
		$results_texts{$pdf->location} = $results_text;
			
	}
	
	
	return (\%results_texts, \%ranked_res);

	
		
}

sub close_mongo{
	 $db=Mongoose->db('admin');
	 $db->run_command({ shutdown => 1});

 
 #return 1;

#$closeObj->Kill(0);
}


1;
