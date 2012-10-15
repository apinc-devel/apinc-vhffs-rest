#!/usr/bin/env perl
use Dancer;

# changing default settings
# By default, Dancer uses config.yml for the application's settings.
# But we can easily change them from our script, and not use config.yml at all:
set warnings => false;
set serializer => 'JSON';

use strict;
use VhffsRestApi;

dance;
