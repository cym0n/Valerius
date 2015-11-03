package Valerius;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Strehler::Dancer2::Plugin::EX;
use Dancer2::Core::Error;
use Date::Format;
use HTML::Entities;
use Valerius::Element::PortraitArticle;

set layout => 'valerius';

hook before => sub {
    my $context = shift;
    return if(! config->{admin_secured});
    return if(! config->{site_closed});
    return if(request->path_info eq dancer_app->prefix . '/closed');
    if(! session 'user')
    {
        $context->response( forward(dancer_app->prefix . '/closed') );
        $context->response->halt;
    }
};

hook before_template_render => sub {
        my $tokens = shift;
        $tokens->{'google_monitor'} = config->{'google_monitor'};
        if($tokens->{'page_type'} && $tokens->{'page_type'} eq 'chapter_page')
        {
            $tokens->{'page_title'} = encode_entities('Valerius Demoire - Capitolo ' . $tokens->{'element'}->{'display_order'} . ' - ' . $tokens->{'element'}->{'title'});
            $tokens->{'page_description'} = encode_entities($tokens->{'element'}->{'incipit'});
            $tokens->{'canonical'} => "http:/www.valeriusdemoire.it/romanzo/" . $tokens->{'element'}->{'slug'};
        }
    };


latest_page '/', 'index',
    { article => 'notizie',
      chapter => { category => 'romanzo', 'item-type' => 'markdown', by => 'order' }
    }, 
    { body_class => 'right-sidebar', nav_page => 'home', 
      page_title => 'Homepage', 
      page_description => 'Valerius Demoire, romanzo steampunk online pieno di guerra e robot giganti'};

list '/romanzo', 'novel', 'romanzo',
    { nav_page => 'chapters', 
      page_title => 'Romanzo', 
      page_description => 'Elenco dei capitoli che formano il romanzo di Valerius Demoire' };

get '/romanzo/ultimo-capitolo' => sub {
    my $last = Strehler::Element::Article->get_last_by_order('romanzo', 'it');
    my $slug = $last->get_attr_multilang('slug', 'it');
    forward '/romanzo/' . $slug;
};

get '/romanzo/primo-capitolo' => sub {
    my $last = Strehler::Element::Article->get_first_by_order('romanzo', 'it');
    my $slug = $last->get_attr_multilang('slug', 'it');
    forward '/romanzo/' . $slug;
};

slug '/romanzo/:slug', 'chapter', 'romanzo',
    { nav_page => 'chapters', 'page_type' => 'chapter_page' };
    
get '/personaggi' => sub {
    my $main = Strehler::Meta::Category->new(category => 'personaggi', parent => undef);
    my @subs = $main->subcategories();
    my @data;
    for(@subs)
    {
        my $cat = $_;
        my %el = $cat->get_basic_data();
        $el{'name'} = ucfirst($el{'name'});
        my $images = Strehler::Element::Image->get_list({ category_id => $el{'id'}});
        $el{'image'} = $images->{'to_view'}->[0]->{'image'};
        push @data, \%el;
    }
    template 'characters', {  nav_page => 'characters', page_title => 'Personaggi', page_description => "I personaggi che vivono le avventure nell'universo di Valerius Demoire",
                             nations => \@data };
};

get '/personaggi/:nation' => sub {
    my $n = params->{nation};
    #my $nation = Strehler::Meta::Category->new(parent => 'personaggi', category => $n);
    my $nation = Strehler::Meta::Category->explode_name("personaggi/" . $n);
    if(! $nation->exists())
    {
        send_error("Nazione inesistente", 404);
    }
    else
    {
        my $characters = Valerius::Element::PortraitArticle->get_list({ category_id => $nation->get_attr('id'), ext => 1, entries_per_page => 100, order_by => 'display_order', order => 'asc', published => 1});
        my $images = Strehler::Element::Image->get_list({ category_id => $nation->get_attr('id')});
        my $image = $images->{'to_view'}->[0]->{'source'};
        
        template "chars_of_nation", {  nav_page => 'characters', page_title => 'Personaggi ' .  $n, page_description => 'Personaggi ' .  $n,
                                      characters => $characters->{'to_view'}, nation => ucfirst($n), image => $image};
    }
};

get '/autore' => sub {
    template 'author', {  nav_page => 'author', page_title => 'Autore', page_description => "Breve biografia dell'autore di Valerius Demoire" };
};

get '/download' => sub {
    template 'download', {  nav_page => 'download', page_title => 'Download', page_description => "Scarica qui i libri conclusi nel formato che trovi pi&ugrave; comodo" };
};

get '/closed' => sub {
    template 'closed', {}, {layout => 'valerius_light'};
};

1;

