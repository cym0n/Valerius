package Valerius::Element::MarkdownArticle;

use Moo;
use Text::Markdown 'markdown';

extends 'Strehler::Element::Article';

sub text
{
    my $self = shift;
    my $text = shift;
    return markdown($text);
}

sub abstract
{
    my $self = shift;
    my $language = shift;
    my $text = $self->get_attr_multilang('text', $language);
    return markdown(substr($text, 0, 800) . "...");
}

1;
