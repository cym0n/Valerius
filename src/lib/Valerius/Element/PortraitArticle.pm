package Valerius::Element::PortraitArticle;

use Moo;
use Dancer2;
use Strehler::Element::Image;
#use Text::Markdown 'markdown';

extends 'Strehler::Element::Article';

sub get_ext_data
{
    my $self = shift;
    my $language = shift;
    my %data = $self->SUPER::get_ext_data($language);
    my $image_id = $self->row->image;
    if($image_id)
    {
        my $image = Strehler::Element::Image->new($image_id);
        $data{'image_title'} = $image->get_attr_multilang('title', $language);
    }
    else
    {
        $data{'image_title'} = undef;
    }
    return %data;
}



1;
