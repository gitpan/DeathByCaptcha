# Initially written by kwitt@dmotorworks.com
# Heavily refactored by Sergey Kolchin <ksa242@gmail.com>

package DeathByCaptcha::HttpClient;

use strict;
use warnings;
our $VERSION = '0.01';
use HTTP::Request::Common;
use HTTP::Status;
use LWP::UserAgent;
use URI::Escape;
use JSON qw(decode_json);

use DeathByCaptcha::Exception;
use base 'DeathByCaptcha::Client';

use constant API_SERVER_URL => 'http://api.dbcapi.me/api';
use constant API_RESPONSE_TYPE => 'application/json';


sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    my ($username, $password) = @_;
    $self->{'username'} = $username || '';
    $self->{'password'} = $password || '';
    $self->{'useragent'} = LWP::UserAgent->new(agent => +DeathByCaptcha::Client::API_VERSION);
    return $self;
}


sub getUser
{
    my $self = shift;
    my $response = $self->{'useragent'}->request(HTTP::Request::Common::POST(
        join("/", +API_SERVER_URL, 'user'),
        Accept => +API_RESPONSE_TYPE,
        Content => [username => $self->{'username'},
                    password => $self->{'password'}]
    ));
    if (HTTP::Status::RC_FORBIDDEN == $response->code) {
        die new DeathByCaptcha::Exception(
            "Access forbidden, check your credentials"
        );
    }
    my $user;
    eval { $user = decode_json($response->content()); };
    return (defined $user and 0 < $user->{"user"}) ? $user : undef;
}

sub getCaptcha
{
    my $self = shift;
    my $cid = shift;
    if (0 < $cid) {
        my $response = $self->{'useragent'}->request(HTTP::Request::Common::GET(
            join("/", +API_SERVER_URL, 'captcha', $cid),
            Accept => +API_RESPONSE_TYPE
        ));
        if (HTTP::Status::RC_OK == $response->code) {
            my $captcha;
            eval { $captcha = decode_json($response->content); };
            if (defined $captcha and 0 < $captcha->{"captcha"}) {
                if (defined $captcha->{"text"} and "" eq $captcha->{"text"}) {
                    $captcha->{"text"} = undef;
                }
                return $captcha;
            }
        }
    }
    return undef;
}

sub upload
{
    my $self = shift;
    my $fn = shift;
    if (defined $fn) {
        my $response = $self->{'useragent'}->request(HTTP::Request::Common::POST(
            join("/", +API_SERVER_URL, 'captcha'),
            Accept => +API_RESPONSE_TYPE,
            Content_Type => 'form-data',
            Content => [swid => +DeathByCaptcha::Client::SOFTWARE_VENDOR_ID,
                        username => $self->{'username'},
                        password => $self->{'password'},
                        captchafile => [undef, "img", Content => DeathByCaptcha::Client::loadImage($fn)]]
        ));
        if (HTTP::Status::RC_BAD_REQUEST == $response->code) {
            die new DeathByCaptcha::Exception(
                "CAPTCHA was rejected, check if it's a valid image"
            );
        }
        if (HTTP::Status::RC_SERVICE_UNAVAILABLE == $response->code) {
            die new DeathByCaptcha::Exception(
                "CAPTCHA was rejected due to service overload, try again later"
            );
        }
        if (HTTP::Status::RC_SEE_OTHER == $response->code) {
            my ($url) = $response->header('Location');
            if ($url =~ m{/(\d+)$}) {
                return $self->getCaptcha($1);
            }
        }
    }
    return undef;
}

sub report
{
    my $self = shift;
    my $cid = shift;
    if (0 < $cid) {
        my $response = $self->{'useragent'}->request(HTTP::Request::Common::POST(
            join('/', +API_SERVER_URL, 'captcha', $cid, 'report'),
            Accept => +API_RESPONSE_TYPE,
            Content => [username  => $self->{'username'},
                        password  => $self->{'password'}]
        ));
        if (HTTP::Status::RC_OK == $response->code) {
            my $captcha;
            eval { my $captcha = decode_json($cid); };
            if (defined $captcha and not $captcha->{'is_correct'}) {
                return 1;
            }
        }
    }
    return 0;
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


=head2 report
   
=head2 upload
   
=head2 getCaptcha

=head2 getUser      
                  
=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html
=cut
