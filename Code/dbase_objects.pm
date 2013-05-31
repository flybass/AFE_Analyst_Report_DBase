#database objects have date, title, bank, full text, location paths, and summaries

package pdf_entry;
use Moose;

with 'Mongoose::Document';
use DateTime;
has 'date' => (
        is=>'rw',
        isa=>'DateTime',
        traits=>['Raw'],
        default=>sub{ DateTime->now }
    );
has 'title' => ( is => 'rw', isa => 'Str' );
has 'bank' => ( is => 'rw', isa => 'Str' );
has 'text' => ( is => 'rw', isa => 'Str' );
has 'location' => ( is => 'rw', isa => 'Str' );
has 'summary' => (is => 'rw', isa =>'Str');
has 'sent_score' => (is => 'rw', isa =>'Num');
has 'uncert_score' => (is => 'rw', isa =>'Num');

1;

package search_obj;
use Moose;
has 'title' => ( is => 'rw', isa => 'Str' );
has 'banks' => ( is => 'rw', isa => 'ArrayRef' );
has 'keywords' => ( is => 'rw', isa => 'ArrayRef' );
has 'sdate' => (
        is=>'rw',
        isa=>'DateTime',
        traits=>['Raw'],
        default=>sub{ DateTime->now }
    );
has 'edate' => (
        is=>'rw',
        isa=>'DateTime',
        traits=>['Raw'],
        default=>sub{ DateTime->now }
    );
has 'sent_min' => (is => 'rw', isa =>'Num');
has 'sent_max' => (is => 'rw', isa =>'Num');

1;
