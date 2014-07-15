# Initially written by kwitt@dmotorworks.com
# Heavily refactored by Sergey Kolchin <ksa242@gmail.com>

package DeathByCaptcha::Client;

use strict;
use warnings;

our $VERSION = '0.01';
use constant API_VERSION => "DBC/Perl v4.1.0";
use constant SOFTWARE_VENDOR_ID => 0;

use constant DEFAULT_TIMEOUT => 45;
use constant POLLS_INTERVAL => 5;


sub loadImage
{
    my $fn = shift;
    open (FILE, "<$fn") or die "Failed opening $fn ($!)";
    my $buff;
    my $img = '';
    while ($buff = <FILE>) {
        $img .= $buff;
    }
    close(FILE);
    return $img;
}

sub connect
{
    return 1;
}

sub close
{
    return 1;
}

sub getBalance
{
    my $self = shift;
    if (defined (my $user = $self->getUser())) {
        if (0 < $user->{"user"}) {
            return $user->{"balance"};
        }
    }
    return undef;
}

sub getText
{
    my $self = shift;
    if (defined (my $captcha = $self->getCaptcha(shift))) {
        if (0 < $captcha->{"captcha"} and "" ne $captcha->{"text"}) {
            return $captcha->{"text"};
        }
    }
    return undef;
}

sub decode
{
    my $self = shift;
    my $fn = shift;
    my $timeout = 30;
    my $deadline = time + ((defined $timeout and 0 < $timeout)
        ? $timeout
        : +DEFAULT_TIMEOUT);
    if (defined (my $captcha = $self->upload($fn))) {
        while ($deadline > time and not defined $captcha->{"text"}) {
            sleep (+POLLS_INTERVAL);
            $captcha = $self->getCaptcha($captcha->{"captcha"});
        }
        if (defined $captcha->{"text"}) {
            if ($captcha->{"is_correct"}) {
                return $captcha;
            }
        }
    }
    return undef;
}

1;


__END__

=head1 NAME

DeathByCaptcha::SocketClient - DeathByCaptcha API interface .


=head1 SYNOPSIS


Usage:

   use DeathByCaptcha::SocketClient;
   my $client = DeathByCaptcha::SocketClient->new($Captcha_username, $Captcha_pass);				

=head1 DESCRIPTION

DeathByCaptcha API interface

=head1 FUNCTIONS

=head2 constructor

   my $client = DeathByCaptcha::SocketClient->new($Captcha_username, $Captcha_pass);

To get deathbycaptcha account go to:

http://www.deathbycaptcha.com/


=head2 decode

   $captcha = $client->decode('captcha.png',+DeathByCaptcha::Client::DEFAULT_TIMEOUT); 
   $recaptcha_response=$captcha->{"text"};  
   print "Captcha: $recaptcha_response  \n";  

=head2 loadImage
   
=head2 connect
   
=head2 close

=head2 getBalance

=head2 getText        
                  
=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html
=cut




