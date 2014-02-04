#!/usr/bin/env perl
#
#   Copyright © 2013 APINC Devel Team
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

use strict;
use utf8;
use warnings;

use Dancer;
use VhffsRestApi::Development;

my $do_it = '';
while ($do_it !~ /^[nN][oO]|[yY][eE][sS]$/) {
    print "Do you want to fill vhffs database with developement data ? (yes/no) : ";
    $do_it = <STDIN>;
    chomp $do_it;

    if ($do_it =~ m/[yY][eE][sS]/) {
        debug "Filling vhffs database with development data.";
        VhffsRestApi::Development::build_database;
    }
}

1;
