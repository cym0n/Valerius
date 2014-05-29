package Valerius::Element::PortraitArticle;

use Moo;
use Dancer2;
use Strehler::Element::Image;

extends 'Strehler::Element::Article';

sub multilang_data_fields
{
    return ('title', 'text', 'slug', 'image_title');
}

sub image_title
{
    my $self = shift;
    my $attribute = shift;
    my $language = shift;
    my $image = Strehler::Element::Image->new($self->get_attr('image', 1));
    if($image->exists())
    {
        return $image->get_attr_multilang('title', $language) . " " . $image->get_attr_multilang('description', $language);
    }
    else
    {
        return undef;
    }
}


1;
