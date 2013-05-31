#This handles the reports
use Excel::Writer::XLSX;

$report_file;
$search_report_file;
$worksheet;
my $s_query;
$s_results;
$s_results_full_t;

sub setup_search_report{
	system('md Reports\\'.$proj_db);
	my $cur_dt = DateTime->now( time_zone => 'America/New_York' );
	print $cur_dt, "\n";
	
	my $cur_dt_string = ($cur_dt->ymd).'T'.($cur_dt->hms('-'));
	
	$search_report_file = Excel::Writer::XLSX->new( 'Reports'.'/'.$proj_db.'/'.$cur_dt_string.'_Search_Report.xlsx');
	
	$s_query = $search_report_file->add_worksheet('Search Query');
	$s_results = $search_report_file->add_worksheet('Search Results');
	$s_results_full_t = $search_report_file->add_worksheet('Search Results FullT');
	
}

sub report_all{

	#set up excel report file
	$worksheet->write(0, 0, "Date");
	$worksheet->write(0, 1, "Bank");
	$worksheet->write(0, 2, "Title");
	$worksheet->write(0, 3, "Location");
	$worksheet->write(0, 4, "Summary");
	$worksheet->write(0, 5, "Sentiment Score");
	$worksheet->write(0, 6, "Uncertainty Score");
	my $rowWrite =1;
	
	
	my $cursor = pdf_entry->find({  });
	$cursor->each(sub{
		my $pdf = shift;
	
		$worksheet->write_date_time($rowWrite, 0, $pdf->date);
		$worksheet->write($rowWrite, 1, $pdf->bank);
		$worksheet->write($rowWrite, 2, $pdf->title);
		$worksheet->write_url($rowWrite, 3, $pdf->location);
		$worksheet->write($rowWrite, 4, $pdf->summary);
		$worksheet->write($rowWrite, 5, $pdf->sent_score);
		$worksheet->write($rowWrite, 6, $pdf->uncert_score);
		$rowWrite++;
		
	
	});
	
	
		
	
}

sub search_report{
	
	my @search_results = @{shift @_}; 
	my $search_obj = shift @_;
	my %rank_table = %{shift @_};
	my %res_texts = %{shift @_};
	#unwrap parts of search object
	my @banks = @{$search_obj->banks};
	my $sdate = $search_obj->sdate;
	my $edate = $search_obj->edate;
	my $title = $search_obj->title;
	
	#prepare query sheet
	
	$s_query->write(0,0, "Bank");
	$s_query->write(0, 1, "Start Date");
	$s_query->write(0, 2, "End Date");
	$s_query->write(0, 3, "Title");
	$s_query->write(0, 4, "Keywords");
	$s_query->write(0, 5, "Sentiment Score Min");
	$s_query->write(0, 6, "Sentiment Score Max");
	
	#write query
	my $rowWrite =1;
	foreach(@banks){$s_query->write($rowWrite,0, $_); $rowWrite++;}
	$rowWrite =1;
	my $colWrite=0;
	
	$rowWrite++;
	$colWrite=0;
	$s_query->write_date_time(1,1, $sdate);
	$s_query->write_date_time(1,2, $edate);
	$s_query->write(1,3, $title);
	$s_query->write(1,5, $search_obj->sent_min);
	$s_query->write(1,6, $search_obj->sent_max);
	
	#write results
	#prep result sheet
	$s_results->write(0, 0, "Date");
	$s_results->write(0, 1, "Bank");
	$s_results->write(0, 2, "Title");
	$s_results->write(0, 3, "Location");
	$s_results->write(0, 4, "Result Text");
	$s_results->write(0, 5, "Summary");
	$s_results->write(0, 6, "Sentiment Score");
	$s_results->write(0, 7, "Uncertainty Score");
	$s_results->write(0, 8, "Matches");
	
	
	$rowWrite =1;
	foreach(@search_results){
		$s_results->write_date_time($rowWrite, 0, $_->date);
		$s_results->write($rowWrite, 1, $_->bank);
		$s_results->write($rowWrite, 2, $_->title);
		$s_results->write_url($rowWrite, 3, $_->location);
		#to be fixed to result text
		$s_results->write($rowWrite, 4, $res_texts{$_->location});
		$s_results->write($rowWrite, 5, $_->summary);
		$s_results->write($rowWrite, 6, $_->sent_score);
		$s_results->write($rowWrite, 7, $_->uncert_score);
		$s_results->write($rowWrite, 8, $rank_table{$_->location});
		$rowWrite++;
	}
	
	
}

sub close_report{
	$report_file->close();
}

sub close_search_report{
	$search_report_file->close();
}


my $rep_rowWrite =2;
my $rep_colWrite =0;
sub search_word_rep{
	my $box_ref = $_;
	my @box = @{$box_ref};
	foreach(@box){
	
			$s_query->write($rep_rowWrite,4+$rep_colWrite, $_);
			#print $_, "BOX \n";
			$rep_colWrite++;}
		$rep_rowWrite++;
		$rep_colWrite=0;
}

sub reset_boxes{
	$rep_rowWrite =2; 
	$rep_colWrite =0;
}

sub search_report_full_t{
	
	my @search_results = @{shift @_}; 
	my $search_obj = shift @_;
	my %rank_table = %{shift @_};
	my %res_texts = %{shift @_};
	#unwrap parts of search object
	my @banks = @{$search_obj->banks};
	my $sdate = $search_obj->sdate;
	my $edate = $search_obj->edate;
	my $title = $search_obj->title;
	
	#write results
	#prep result sheet
	$s_results_full_t->write(0, 0, "Date");
	$s_results_full_t->write(0, 1, "Bank");
	$s_results_full_t->write(0, 2, "Title");
	$s_results_full_t->write(0, 3, "Location");
	$s_results_full_t->write(0, 4, "Result Text");
	$s_results_full_t->write(0, 5, "Summary");
	$s_results_full_t->write(0, 6, "Sentiment Score");
	$s_results_full_t->write(0, 7, "Uncertainty Score");
	$s_results_full_t->write(0, 8, "Matches");
	$rowWrite =1;
	foreach(@search_results){
		$s_results_full_t->write_date_time($rowWrite, 0, $_->date);
		$s_results_full_t->write($rowWrite, 1, $_->bank);
		$s_results_full_t->write($rowWrite, 2, $_->title);
		$s_results_full_t->write_url($rowWrite, 3, $_->location);
		#to be fixed to result text
		$s_results_full_t->write($rowWrite, 4, $res_texts{$_->location});
		$s_results_full_t->write($rowWrite, 5, $_->summary);
		$s_results_full_t->write($rowWrite, 6, $_->sent_score);
		$s_results_full_t->write($rowWrite, 7, $_->uncert_score);
		$s_results_full_t->write($rowWrite, 8, $rank_table{$_->location});
		$rowWrite++;
	}
	
	close_search_report();
	
	
}


1;
