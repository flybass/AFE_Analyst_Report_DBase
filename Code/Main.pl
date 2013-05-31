#This is the Main program file for the PDF Database Project
#0) turn on mongodb with handling
use Win32::Process;
use Moose;
use Mongoose::Document;
use Mongoose::Role::Collapser;
use Mongoose::Role::Expander;
use Mongoose::Role::Engine;
use Class::Load::XS;
use Class::Load::PP;
use Params::Validate::XS;
use Params::Validate::PP;
use Tk;
use Tk::FileSelect;
use Tk::FBox;
use Tk::Widget;
use Tk::Frame;
use Tk::Derived;
use Tk::ProgressBar;
use DateTime;
use Excel::Writer::XLSX;
use File::Find;
use Algorithm::Permute;
use Spreadsheet::ParseExcel;
use Mongoose::Engine::Base;
use DateTime::TimeZone;
use DateTime::TimeZone::America::New_York; 

#use DateTime::from_epoch;
#use DateTime::set_time_zone;
#use DateTime::Now;





my $proj_db;
my $db;

my $processObj;
Win32::Process::Create(
    $processObj,
    "C:/windows/system32/cmd.exe",
    "cmd.exe /c mongod.exe",
    0,
    NORMAL_PRIORITY_CLASS,
    "."
);


#my $db=Mongoose->db($proj_db);


#At present, this imports
#1) the package which defines the objects for the database 
require "dbase_objects.pm";

#2) A set of subs which generate report files
require "dbase_reports.pm";

#3) A set of subroutines which handles graphical elements
require "dbase_graphics.pm";

#4) A set of parsing subroutines for banks (along with a switch to calls)
require "dbase_bankparsers.pm";

#5) A set of subroutines that handle mongodb interaction
require "dbase_manage.pm";

#6) A set of dictionaries for enhanced searching and sentiment scoring
require "dbase_dicts.pm";


#Main Routine
package main;
#load dictionaries
initialize_search_dict();
initialize_sentiment_dict();


#launch program
pick_proj(initialize_projects());










