package Valerius::Admin;

use Dancer2;
use Strehler::Dancer2::Plugin::Admin;

get '/' => sub {
    template 'strehler-home';
};
true;
