#
#   Copyright © 2012 APINC Devel Team
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see <http://www.gnu.org/licenses/>.
#
package VhffsRestApi;

use strict;
use utf8;
use Dancer ':syntax';

use VhffsRestApi::HTTP::Status;

use lib '/usr/share/vhffs/api';
use Vhffs::User;
use Vhffs::Group;
use Vhffs;
use Vhffs::Object;

our $VERSION = '0.1';
 
my $vhffs = new Vhffs;
 
get '/api/user/:username' => sub {
    my $user = Vhffs::User::get_by_username( $vhffs , params->{username} );
    return status_not_found ( 'User ' . params->{username} . ' not found' ) unless defined $user;
    status_ok ( { username => params->{username} , email => $user->{mail} } );
};

post '/api/user/' => sub {
    my $params = request->params;
    my ($username, $passwd, $mail) = ($params->{username}, $params->{passwd}, $params->{mail});

    if ( !defined $username or !defined $passwd or !defined $mail ) {
        return status_bad_request ( 'Missing argument (needs username, passwd and mail)' );
    }

    if ( not Vhffs::User::check_username($username) ) {
        return status_bad_request ( 'Not a valid vhffs username' );
    }

    my $user = Vhffs::User::get_by_username( $vhffs , $username );

    if ( defined $user ) {
       return status_conflict ( 'User already exists' );
    }

    $user = Vhffs::User::create($vhffs, $username, $passwd, 0, $mail);

    if ( !defined $user )
    {
        return status_conflict ( 'Unable to create user ' . $username );
    }
    else
    {
        return status_ok ( 'User '. $username . ' created' );
    }
};

# default route shall remain last one :)
any qr{.*} => sub {
    status_not_found ( 'Not found' );
};

true;
