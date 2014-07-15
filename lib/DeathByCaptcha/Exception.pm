# Initially written by kwitt@dmotorworks.com
# Heavily refactored by Sergey Kolchin <ksa242@gmail.com>

package DeathByCaptcha::Exception;

use strict;
use warnings;
our $VERSION = '0.01';

sub stringify;
use overload '""' => \&stringify;

sub new
{
    my ($class, $text) = @_;
    my $self = {};
    $self->{ERROR_TEXT} = $text;
    bless $self, $class;
    return $self;
}

sub stringify
{
    my ($self) = @_;
    my $class = ref($self);
    my $text  = $self->{ERROR_TEXT};
    if (defined($text) && length($text)) {
        return "$class: $text";
    } else {
        return "$class";
    }
}

1;
