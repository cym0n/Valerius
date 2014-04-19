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
sub bare_text
{
    my $self = shift;
    my $text = shift;
    return $text;
}

sub abstract
{
    my $self = shift;
    my $language = shift;
    my $text = $self->get_attr_multilang('text', $language, 1);
    return markdown(substr($text, 0, 800) . "...");
}

sub incipit
{
    my $self = shift;
    my $language = shift;
    my $text = $self->get_attr_multilang('text', $language, 1);
    return substr($text, 0, 100) . "...";
}

1;
