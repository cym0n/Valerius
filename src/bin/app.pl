#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";
 
use Dancer2;
use Valerius::Admin;
use Strehler::Admin;
use Strehler::API;
use Valerius;

Valerius->dance;
