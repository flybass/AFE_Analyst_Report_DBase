#This is the graphics file
use Tk;
use Tk::ProgressBar;
use DateTime;



#Allows for selection of all options
sub main_gui{
	#Launches main window
	my $mw = Tk::MainWindow->new();
	$mw->Label(-text => 'PDF Dbase Project Main Menu')->pack;
	#$mw->Button(-text => 'Switch Db', -command =>sub{ $mw->destroy; pick_proj(initialize_projects());})->pack;
	$mw->Button(-text => 'Import files', -command =>sub {import_files($mw); @pdfs=(); close_report();})->pack;
	$mw->Button(-text => 'Empty Collection', -command =>sub {delete_collection($mw);})->pack;
	$mw->Button(-text => 'Query Database', -command =>sub {setup_search_report(); search($mw); })->pack;
	$mw->Button(-text => 'Quit', -command => sub {eval{close_mongo();}; exit; })->pack;
	MainLoop;
	
	
}


	



#Allows file select which is passed to import subroutine
my $progBar;
my $progress;
my $percentDone;
sub import_files{
	my $mw = shift @_;
	
	#my $start_dir = 'C:/';
	my $import_dir = $mw->FileSelect(-directory => "N:/");
	$import_dir->configure(-verify => ['-d']);
	$import_dir = $import_dir->Show;

    
	$import_dir  =~ s/\//\\/g;
	system('md Reports\\'.$proj_db);
	my $cur_dt = DateTime->now( time_zone => 'America/New_York' );
	print $cur_dt, "\n";
	
	my $cur_dt_string = ($cur_dt->ymd).'T'.($cur_dt->hms('-'));
	
	$report_file = Excel::Writer::XLSX->new( 'Reports'.'/'.$proj_db.'/'.$cur_dt_string.'_Import_Report.xlsx');
	$worksheet = $report_file->add_worksheet('DB Contents');
	
	#calls import with input directory
	$progBar = Tk::MainWindow->new(-title => 'Import Progress');
	$progress = $progBar->ProgressBar(
        -width => 30,
        -from => 0,
        -to => 100,
        -blocks => 50,
        -colors => [0, 'green', 50, 'yellow' , 80, 'red'],
        -variable => \$percentDone
        )->pack(-fill => 'x');
       # $progBar->MapWindow;
	import_com($import_dir);
	#$progBar->UnmapWindow;
	$percentDone=0;
	$progress=0;

	
	}
	
#Gives progress bar on file import

sub import_progress_bar{
	my $numReports = shift @_;
	my $numFinished = shift @_;
	$percentDone = 100*$numFinished/$numReports;
	#print $percentDone, "\n";
	
        $progBar->update;
      if($numReports==$numFinished+1){$progress=0; $progBar->destroy; $percentDone=0;}
}
	




#Allows for removal of collection (recatalog purposes
sub delete_collection{
	my $mw = shift @_;
	#calls empty which uses remove
	empty();
	}


#Allows for searching collection (launches search subroutine)
my @keywords_boxes;
sub search{


	my $mw = Tk::MainWindow->new();
	my @banks ='';
	my $date_start;
	my $date_end;
	my $title ='';
	@keywords_boxes=();
	my @final_keywords;
	@final_keywords =();
	my $sent_min = -(9**9**9);
	my $sent_max = 9**9**9;
	

	$mw->Label(-text => 'Search Menu, (Comma Separated Values)')->pack;
	my $banks_entry = $mw->Entry(-text=>'Bank(s)')->pack;
	my $sdate_entry = $mw->Entry(-text=>'Start Date (YYYY-MM-DD)')->pack;
	my $edate_entry = $mw->Entry(-text=>'End Date (YYYY-MM-DD)')->pack;
	my $title_entry = $mw->Entry(-text=>'Title')->pack;
	my $keyword_entry = $mw->Entry(-text=>'Search Terms (AND)')->pack;
	my $senti_min = $mw->Entry(-text=>'Sentiment Min')->pack;
	my $senti_max = $mw->Entry(-text=>'Sentiment Max')->pack;
	push(@keywords_boxes, $keyword_entry);
	$mw->Button(-text=>'GO SEARCH', 
		-command => sub {if($banks_entry->get() eq 'Bank(s)'){}
				else{@banks = split(', ',$banks_entry->get());}
					foreach(@keywords_boxes){
						my @keywords = split(", ", $_->get());
						if ($keywords[0] eq 'Search Terms (AND)'){$keywords[0]='.*';}
						#convert keyword into dictionary equivalence with dbase_dicts fncn
						@keywords = kw_equiv(\@keywords);
						push(@final_keywords, \@keywords);}
					
						$date_start = $sdate_entry->get();
				if( $date_start=~ m/(\d\d\d\d)-(\d\d)-(\d\d)/){
					$date_start = DateTime->new(year => $1, month =>$2, day => $3)}
					else{$date_start = DateTime->new(year => 1990, month =>1, day => 1);}
	
				$date_end =$edate_entry->get();
				if( $date_end=~ m/(\d\d\d\d)-(\d\d)-(\d\d)/){
					$date_end = DateTime->new(year => $1, month =>$2, day => $3)}
					else{$date_end = DateTime->new(year => 3000, month =>1, day => 1);}
					
				if($title_entry->get() eq 'Title'){}
				else{$title = $title_entry->get();}
				
				if($senti_min->get() eq 'Sentiment Min'){}
				else{ $sent_min =  $senti_min->get();}
				if($senti_max->get() eq 'Sentiment Max'){}
				else{ $sent_max =  $senti_max->get();}
				
				
				my $search_object = search_obj->new( banks => \@banks, keywords =>\@final_keywords, title=>$title,
						sdate =>$date_start, edate =>$date_end, sent_min =>$sent_min, sent_max =>$sent_max );
				
				#foreach(@final_keywords){print $_->[0], "\n";}
				search_com($search_object);
				
				
				$mw->destroy;
				
				@keywords_boxes=();
				
			
				
		})->pack;
	$mw->Button(-text=>'Add Search (OR)', -command => sub {expand_search($mw);})->pack;
	
	
	
	
	
	
	
		
			
	
	}
	
sub expand_search{
	my $mw = shift @_;
	my $keyword_entry_n = $mw->Entry(-text=>'Search Terms (AND)')->pack;
	push(@keywords_boxes, $keyword_entry_n);
	
	
	
	}

sub pick_proj{

	my @options = @{shift @_};
	my $mw = Tk::MainWindow->new();
	$mw->title("Projects");
	$mw->Label(-text => 'Please Select Project')->pack;
	my $proj_options = $mw->Listbox()->pack();
	my $keyword_entry= $mw->Entry(-text=>'NEW')->pack;
	
	$proj_options->insert('end', @options);
	$mw->Button(-text => "Select", 
            -command => sub { $proj_db = $options[($proj_options->curselection)[0]];
            	    if ($keyword_entry->get() eq 'NEW'){}
            	    else{$proj_db = $keyword_entry->get(); push(@options,$keyword_entry->get());}
            	    $db = Mongoose->db(db_name=> $proj_db, -now=>1 );
            	    
            	    print $proj_db, "\n";
            	    
            	    overwrite_projects(\@options);
            	    
            	    $mw->destroy(); 
            
                    main_gui();})->pack(-side => "bottom");
                    
          $mw->Button(-text => "Remove", 
            -command => sub { $proj_db = $options[($proj_options->curselection)[0]];
            	    if ($keyword_entry->get() eq 'NEW'){}
            	    else{$proj_db = $keyword_entry->get(); push(@options,$keyword_entry->get());}
            	    $db = Mongoose->db(db_name=> $proj_db, -now=>1 );
            	    empty();
            	   splice @options, ($proj_options->curselection)[0], 1;
            	   #print "@options";
            	    
            	    overwrite_projects(\@options);
            	    
            	    $mw->destroy(); 
            	    eval{close_mongo();}; 
            	    
            	    exit; 
            
                    })->pack(-side => "bottom");
                    
          
            MainLoop;
}



	
	
1;



	
	
	
