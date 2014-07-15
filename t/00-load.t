#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'DeathByCaptcha::SocketClient' ) || print "Bail out!\n";
}

diag( "Testing DeathByCaptcha::SocketClient $DeathByCaptcha::SocketClient::VERSION, Perl $], $^X" );
