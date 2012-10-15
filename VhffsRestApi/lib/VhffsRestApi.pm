package VhffsRestApi;
use Dancer ':syntax';

our $VERSION = '0.1';

use strict;
use lib '/usr/share/vhffs/api';

use Vhffs::User;
use Vhffs::Group;
use Vhffs;
use Vhffs::Object;
 
my $vhffs = new Vhffs;
 
get '/' => sub {
    template 'index';
};

get '/user/:username' => sub {
    my $user = Vhffs::User::get_by_username( $vhffs , params->{username} );
    return 'user unknown' unless(defined $user);
    return { username => params->{username} , email => $user->{mail} };
};

true;
