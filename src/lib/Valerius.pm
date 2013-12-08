package Valerius;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Dancer2::Core::Error;
use Text::Markdown 'markdown';
use Date::Format;
use Data::Dumper;

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
    };

get '/' => sub {
    my $news = Strehler::Element::Article->get_last_by_date('notizie');
    my $chapter = Strehler::Element::Article->get_last_by_order('romanzo');
    my %news_data = ();
    if($news)
    {
        %news_data = $news->get_ext_data('it');
        $news_data{'text'} = markdown($news_data{'text'});
        $news_data{'publish_date'} = $news_data{'publish_date'}->strftime('%d-%m-%Y');
    }
    my %chapter_data = ();
    if($chapter)
    {
        %chapter_data = $chapter->get_ext_data('it');
        $chapter_data{'text'} = markdown(substr($chapter_data{'text'}, 0, 800) . "...");
        $chapter_data{'link'} = '/romanzo/' . $chapter_data{'slug'};
    }
    template "index", { page_title => 'Homepage', page_description => 'Valerius Demoire, romanzo steampunk online pieno di guerra e robot giganti',
                        article => \%news_data, chapter => \%chapter_data };
};

get '/romanzo' => sub {
    my $entries_per_page = 20;
    my $page = params->{page} || 1;
    my $order = params->{order} || 'desc';
    my $elements = Strehler::Element::Article->get_list({ page => $page, entries_per_page => $entries_per_page, category => 'romanzo', language => 'it', ext => 1, published => 1, order => $order});
    template "novel", { page_title => 'Romanzo', page_description => 'Elenco dei capitoli che formano il romanzo di Valerius Demoire',
                        chapters => $elements->{'to_view'}, page => $page, order => $order, last_page => $elements->{'last_page'} };

};

get '/romanzo/ultimo-capitolo' => sub {
    my $last = Strehler::Element::Article->get_last_by_order('romanzo');
    my $slug = $last->get_attr_multilang('slug', 'it');
    forward '/romanzo/' . $slug;
};
get '/romanzo/primo-capitolo' => sub {
    my $last = Strehler::Element::Article->get_first_by_order('romanzo');
    my $slug = $last->get_attr_multilang('slug', 'it');
    forward '/romanzo/' . $slug;
};

get '/romanzo/:slug' => sub {
    my $slug = params->{slug};
    my $chapter = Strehler::Element::Article->get_by_slug($slug, 'it');
    if( ! $chapter->exists() || $chapter->category() ne 'romanzo')
    {
        send_error("Capitolo inesistente", 404);
    }
    else
    {
        my %chapter_data = $chapter->get_ext_data('it');
        $chapter_data{'text'} = markdown($chapter_data{'text'});
        my $next_slug = undef;
        my $prev_slug = undef;
        my $next = $chapter->next_in_category_by_order('it');
        if($next->exists())
        {
            $next_slug = $next->get_attr_multilang('slug', 'it');
        }
        my $prev = $chapter->prev_in_category_by_order('it');
        if($prev->exists())
        {
            $prev_slug = $prev->get_attr_multilang('slug', 'it');
        }
        template "chapter", { page_title => 'Capitolo ' . $chapter_data{'display_order'}, page_description => 'Valerius Demoire - Capitolo ' . $chapter_data{'display_order'} . ' - ' . $chapter_data{'title'}, canonical => "http:/www.valeriusdemoire.it/romanzo/" . $chapter_data{'slug'},
                              chapter => \%chapter_data, prev_slug => $prev_slug, next_slug => $next_slug };
    }
};


get '/personaggi' => sub {
    my $main = Strehler::Meta::Category->new(name => 'personaggi');
    my @subs = $main->subcategories();
    my @data;
    for(@subs)
    {
        my $cat = $_;
        my %el = $cat->get_basic_data();
        $el{'title'} = ucfirst($el{'title'});
        my $images = Strehler::Element::Image->get_list({ category_id => $el{'id'}});
        $el{'image'} = $images->{'to_view'}->[0]->{'source'};
        push @data, \%el;
    }
    template 'characters', { page_title => 'Personaggi', page_description => "I personaggi che vivono le avventure nell'universo di Valerius Demoire",
                             nations => \@data };
};

get '/personaggi/:nation' => sub {
    my $n = params->{nation};
    my $nation = Strehler::Meta::Category->new(parent => 'personaggi', category => $n);
    if(! $nation->exists())
    {
        send_error("Nazione inesistente", 404);
    }
    else
    {
        my $characters = Strehler::Element::Article->get_list({ category_id => $nation->get_attr('id'), ext => 1, entries_per_page => 100, order_by => 'display_order', order => 'asc', published => 1});
        my $images = Strehler::Element::Image->get_list({ category_id => $nation->get_attr('id')});
        my $image = $images->{'to_view'}->[0]->{'source'};
        
        template "chars_of_nation", { page_title => 'Personaggi ' .  $n, page_description => 'Personaggi ' .  $n,
                                      characters => $characters->{'to_view'}, nation => ucfirst($n), image => $image};
    }
};

get '/timeline' => sub {
    my $history = Strehler::Element::Article->get_list({ category => 'timeline', ext => 1, entries_per_page => 100, order_by => 'display_order', order => 'asc', published => 1});
    markdown_all($history);
    template "timeline", { page_title => 'Timeline', page_description => 'La cronologia degli avvenimenti dell\'universo di Valerius Demoire',
                           history => $history->{'to_view'} };
};

get '/autore' => sub {
    template 'author', { page_title => 'Autore', page_description => "Breve biografia dell'autore di Valerius Demoire" };
};

get '/closed' => sub {
    template 'closed', {}, {layout => 'valerius_light'};
};

sub markdown_all
{
    my $data = shift;
    my @markdowned;
    for(@{$data->{'to_view'}})
    {
        my $el = $_;
        $el->{'text'} = markdown($el->{'text'});
    }    
}

1;

