#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";
 
use Dancer2;
use Strehler::Admin;
use Valerius;

Valerius->dance;
