#
#   Copyright © 2012-2013 APINC Devel Team
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
use warnings;
use Dancer ':syntax';

use VhffsRestApi::HTTP::Status;

use lib '/usr/share/vhffs/api';
use Vhffs::Constants;
use Vhffs::User;
use Vhffs::Group;
use Vhffs;
use Vhffs::Object;
use Vhffs::Panel::Group;
use Vhffs::Panel::User;

our $VERSION = '0.1';
 
my $vhffs = new Vhffs;

=pod

=head1 NAME

    VHFFS-APINC-REST API - Vhffs REST API used by the APINC platform (apinc-apm)

=head1 SYNOPSIS

    ### TODO

=cut


=pod
=head1 RESTful web API HTTP METHODS 
=cut


=pod
=head2 Description
    Exposes all users
=head2 Access
    http://server:port/api/users
=cut
get '/api/users' => sub {
    # en attendant le DBIx::Class dans Vhffs...

    my $sql = 'SELECT u.username, u.passwd, u.firstname,  u.lastname, u.mail, o.state '.
      'FROM vhffs_users u '.
      'INNER JOIN vhffs_object o ON (o.object_id = u.object_id) '.
      'ORDER BY u.username';

    my $dbh = $vhffs->get_db();
    my @users = $dbh->selectall_arrayref($sql, { Slice => {} });
    return status_not_found ( 'No users found' ) unless(@users);

    #status_ok ( to_json( @users, { utf8 => 1 } ) );
    status_ok ( to_json( @users ) );
};


=pod
=head2 Description
    Exposes user with username username
=head2 Access
    http://server:port/api/users/username
=cut
get '/api/users/:username' => sub {
    my $user = Vhffs::User::get_by_username( $vhffs , params->{username} );
    return status_not_found ( 'User ' . params->{username} . ' not found' ) unless defined $user;

    status_ok ( { 
        username => $user->{username},
        passwd => $user->{passwd},
        mail => $user->{mail},
        firstname => $user->{firstname},
        lastname => $user->{lastname}
        }
    );
};


=pod
=head2 Description
    Exposes all members (a member is a vhffs project owner)
=head2 Access
    http://server:port/api/members
=cut
get '/api/members' => sub {
    # en attendant le DBIx::Class dans Vhffs...

    my $sql = 'SELECT DISTINCT u.username, u.passwd, u.firstname,  u.lastname, u.mail, o.state '.
              'FROM vhffs_users u '.
              'INNER JOIN vhffs_object o '.
              'ON u.uid = o.owner_uid '.
              'INNER JOIN vhffs_groups g '.
              'ON o.object_id = g.object_id '.
              'WHERE g.groupname != u.username '.
              'AND o.state = '.Vhffs::Constants::ACTIVATED.' '.
              'ORDER BY u.username';

    my $dbh = $vhffs->get_db();
    my @members = $dbh->selectall_arrayref($sql, { Slice => {} });
    return status_not_found ( 'No member found' ) unless(@members);

    #status_ok ( to_json( @members, { utf8 => 1 } ) );
    status_ok ( to_json( @members ) );
};


=pod
=head2 Description
    Exposes all ACTIVATED tuples (project, owner, creation_date)
=head2 Access
    http://server:port/api/projects
=cut
get '/api/projects' => sub {
    # en attendant le DBIx::Class dans Vhffs...

    my $sql = 'SELECT g.groupname, u.username AS owner, '.
                'o.date_creation AS creation_date '.
              'FROM vhffs_users u '.
              'INNER JOIN vhffs_object o '.
              'ON u.uid = o.owner_uid '.
              'INNER JOIN vhffs_groups g '.
              'ON o.object_id = g.object_id '.
              'WHERE g.groupname != u.username '.
              'AND o.state = '.Vhffs::Constants::ACTIVATED.' '.
              'ORDER BY g.groupname';

    my $dbh = $vhffs->get_db();
    my @groups = $dbh->selectall_arrayref($sql, { Slice => {} });
    return status_not_found ( 'No group found' ) unless(@groups);

    #status_ok ( to_json( @groups, { utf8 => 1 } ) );
    status_ok ( to_json( @groups ) );
};


=pod
=head2 Description
    Exposes a project with name groupname
=head2 Access
    http://server:port/api/projects/groupname
=cut
get '/api/projects/:groupname' => sub {
    my $project = Vhffs::Group::get_by_groupname( $vhffs , params->{groupname} );
    return status_not_found ( 'Project ' . params->{groupname} . ' not found' ) unless defined $project;

    # en attendant le DBIx::Class dans Vhffs...

    my $sql = 'SELECT g.groupname, u.username AS owner , o.date_creation '.
              'FROM vhffs_users u '.
              'INNER JOIN vhffs_object o '.
              'ON u.uid = o.owner_uid '.
              'INNER JOIN vhffs_groups g '.
              'ON o.object_id = g.object_id '.
              'WHERE g.groupname = ?';

    my $dbh = $vhffs->get_db();
    my $group = $dbh->selectall_arrayref($sql, { Slice => {} }, params->{groupname});
    return status_not_found ( 'No group found' ) unless($group);

    #status_ok ( to_json( $group, { utf8 => 1 } ) );
    status_ok ( to_json( $group ) );
};


=pod
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
=cut


# default route shall remain last one :)
any qr{.*} => sub {
    status_not_found ( 'Not found' );
};

true;
