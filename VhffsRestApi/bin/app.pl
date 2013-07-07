#!/usr/bin/env perl
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

use strict;
use utf8;
use warnings;
use Switch;

use Dancer;
use VhffsRestApi;
use VhffsRestApi::Development;

# changing default settings
# By default, Dancer uses config.yml for the application's settings.
# But we can easily change them from our script, and not use config.yml at all:
set warnings => false;
set serializer => 'JSON';

dance;
