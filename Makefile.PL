#!perl -w

require 5.008001;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'DeathByCaptcha::SocketClient',
    DISTNAME		 => 'DeathByCaptcha-SocketClient',
    VERSION_FROM     => 'lib/DeathByCaptcha/SocketClient.pm',
    ABSTRACT   		 => 'DeathByCaptcha API interface',
    AUTHOR           => q{Daniel Torres <daniel.torres@owasp.org>},  
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.008001,
    PREREQ_PM => {
        'HTTP::Request::Common' => 0,
        'HTTP::Status' => 0,
        'URI::Escape' => 0,
        'JSON' => 0,
        'IO' => 0,
        'MIME::Base64' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'DeathByCaptcha-SocketClient-*' },
);
