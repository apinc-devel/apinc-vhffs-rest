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
# Inspired Dancer::Plugin::REST
# http://cpansearch.perl.org/src/SUKRIA/Dancer-Plugin-REST-0.07/lib/Dancer/Plugin/REST.pm

package VhffsRestApi::Development;

use strict;
use utf8;
use warnings;

use lib '/usr/share/vhffs/api';
use Vhffs::User;
use Vhffs::Group;
use Vhffs;
use Vhffs::Object;


sub build_database {

    # note : pour recréer la base dans un shell faire :
    # su - postgres -c 'dropdb vhffs_test'
    # su - postgres -c 'createdb -O apinc vhffs_test'
    # psql vhffs_test apinc -h localhost
    #     vhffs_test => \i /usr/share/vhffs/backend/initdb.sql

    # importer des utilisateurs dans la base pour faciliter le dévelopement
    my @users = (
        {
            username  => 'laurent',
            firstname => 'Laurent',
            lastname  => 'Drift',
            mail      => 'laurent@laurent.la',
        },
        {
            username  => 'setaou',
            firstname => 'Hervé',
            lastname  => 'Setaou',
            mail      => 'setaou@setaou.se',
        },
        {
            username  => 'misric',
            firstname => 'Sylvain',
            lastname  => 'Misric',
            mail      => 'misric@misric.mi',
        },
        {
            username  => 'contributeur',
            firstname => 'Contrib',
            lastname  => 'Uter',
            mail      => 'contributeur@contributeur.co',
        }
    );


    my @groups = (
        {
            groupname => 'project1',
            username  => 'contributeur',
        },
        {
            groupname => 'project2',
            username  => 'contributeur',
        }
    );
            
    my $vhffs = new Vhffs;

    foreach (@users) {
        my ($username, $mail, $firstname, $lastname) = ($_->{username}, $_->{mail}, $_->{firstname}, $_->{lastname});
        my $user = Vhffs::User::get_by_username( $vhffs , $username );
        if ( defined $user ) {
            print "User $username already exists skipping...\n";
        }
        else {      
            $user = Vhffs::User::create($vhffs, $username, $username, 0, $mail, $firstname, $lastname);
            if( !defined $user ) {
                print "Unable to create $username\n";
            }
            else {
                print "User $username created!\n";
                # pour le dév on skip la création via les robots
		$user->set_status( Vhffs::Constants::ACTIVATED );
		$user->commit;
            }
        }
    }



    foreach (@groups) {
        my ($groupname, $username, $gid) = ($_->{groupname}, $_->{username}, $_->{gid});
        my $owner = Vhffs::User::get_by_username( $vhffs, $username );
        return undef unless defined($owner);

        my $group = Vhffs::Group::get_by_groupname( $vhffs , $groupname );

        if ( defined $group ) {
            print "Group $groupname already exists skipping...\n";
        }
        else {   
    # my $group = Vhffs::Group::create($vhffs, $groupname, $realname, $owner_uid, $gid, $description)
            $group = Vhffs::Group::create($vhffs, $groupname, $groupname, $owner->{uid}, $gid, "development data" );
            if( !defined $group ) {
                print "Unable to create $groupname\n";
            }
            else {
                print "Group $groupname created!\n";
                # pour le dév on skip la création via les robots
		$group->set_status( Vhffs::Constants::ACTIVATED );
		$group->commit;
            }
        }
    }
}

1;
