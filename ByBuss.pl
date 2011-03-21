use strict;
use warnings;

use vars qw($VERSION %IRSSI);
use utf8;
use Irssi;
use POSIX;

$VERSION = '1.0';
%IRSSI = (
	authors			=>	'tmn',
	contact			=>	'tmn @ EFnet',
	name			=>	'ByBuss for Irssi',
	description		=>	'Finn ut når bussen går i Trondheim ved å spørre Bussorakelet.',
	license			=>	'Public Domain'
);

my $test;

# ==========[ Main method ]============================================================
sub bybuss {
	my ($question) = @_;
	my ($reader, $writer);
	pipe($reader, $writer);
	
	## ask Bussorakelet
	my $pid = fork();
	my $ans;
	

	if ($pid > 0) {
		close ($writer);
		Irssi::pidwait_add($pid);
		return $reader;
	}
	else {
		eval {
			my $ask = get ('http://m.atb.no/xmlhttprequest.php?service=routeplannerOracle.getOracleAnswer&question='.$question);
			my $data = formatAnswer($ask);
			## print($writer $data);
			close($writer);
		};
		POSIX::_exit(1);
	}
}


# ==========[ Format Answer ]============================================================
sub formatAnswer {
	my ($answer) = @_;
	
	## må da klare å korte ned dette på et vis
	$answer =~ s/ kl. / kl /g;
	$answer =~ s/  / /g;
	$answer =~ s/\. /./g;
	$answer =~ s/\./.\n/g;
	
	return $answer;
}

# ==========[ Theme register ]============================================================
Irssi::theme_register([
	'bybuss_print_answer',
	'$0'
]);

# ==========[ Command bind ]============================================================
Irssi::command_bind('bybuss', sub {
	if ($_[0]) {
		Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'bybuss_print_answer', bybuss($_[0]));
	}
});