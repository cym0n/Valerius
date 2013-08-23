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
    my $news = Strehler::Element::Article::get_last_by_date('notizie');
    my $chapter = Strehler::Element::Article::get_last_by_order('romanzo');
    my %news_data = undef;
    if($news)
    {
        %news_data = $news->get_ext_data('it');
        $news_data{'text'} = markdown($news_data{'text'});
        $news_data{'publish_date'} = $news_data{'publish_date'}->strftime('%d-%m-%Y');
    }
    my %chapter_data = undef;
    if($chapter)
    {
        %chapter_data = $chapter->get_ext_data('it');
        $chapter_data{'text'} = markdown(substr($chapter_data{'text'}, 0, 800) . "...");
        $chapter_data{'link'} = '/novel/' . $chapter_data{'slug'};
    }
    template "index", { page_title => 'Homepage', page_description => 'Valerius Demoire, romanzo steampunk online pieno di guerra e robot giganti',
                        article => \%news_data, chapter => \%chapter_data };
};

get '/novel' => sub {
    my $entries_per_page = 20;
    my $page = params->{page} || 1;
    my $order = params->{order} || 'desc';
    my $elements = Strehler::Element::Article::get_list({ page => $page, entries_per_page => $entries_per_page, category => 'romanzo', language => 'it', ext => 1, published => 1, order => $order});
    template "novel", { page_title => 'Romanzo', page_description => 'Elenco dei capitoli che formano il romanzo di Valerius Demoire',
                        chapters => $elements->{'to_view'}, page => $page, order => $order, last_page => $elements->{'last_page'} };

};

get '/novel/last-chapter' => sub {
    my $last = Strehler::Element::Article::get_last_by_order('romanzo');
    my $slug = $last->get_attr_multilang('slug', 'it');
    forward '/novel/' . $slug;
};
get '/novel/first-chapter' => sub {
    my $last = Strehler::Element::Article::get_first_by_order('romanzo');
    my $slug = $last->get_attr_multilang('slug', 'it');
    forward '/novel/' . $slug;
};

get '/novel/:slug' => sub {
    my $slug = params->{slug};
    my $chapter = Strehler::Element::Article::get_by_slug($slug, 'it');
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
        template "chapter", { page_title => 'Capitolo ' . $chapter_data{'display_order'}, page_description => 'Valerius Demoire - Capitolo ' . $chapter_data{'display_order'} . ' - ' . $chapter_data{'title'}, canonical => "http:/www.valeriusdemoire.it/novel/" . $chapter_data{'slug'},
                              chapter => \%chapter_data, prev_slug => $prev_slug, next_slug => $next_slug };
    }
};

get '/characters' => sub {
    template 'under_constr', { page_title => 'Personaggi', page_description => "I personaggi che vivono le avventure nell'universo di Valerius Demoire" };
};

get '/author' => sub {
    template 'author', { page_title => 'Autore', page_description => "Breve biografia dell'autore di Valerius Demoire" };
};

get '/closed' => sub {
    template 'closed', {}, {layout => 'valerius_light'};
};


1;

