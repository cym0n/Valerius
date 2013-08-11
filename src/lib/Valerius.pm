package Valerius;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Dancer2::Core::Error;
use Text::Markdown 'markdown';
use Date::Format;
use Data::Dumper;

set layout => 'valerius';

get '/' => sub {
    my $news = Strehler::Element::Article::get_last_by_date('notizie');
    my $chapter = Strehler::Element::Article::get_last_by_order('romanzo');
    my %news_data = $news->get_ext_data('it');

    $news_data{'publish_date'} = $news_data{'publish_date'}->strftime('%d-%m-%Y');
    my %chapter_data = $chapter->get_ext_data('it');
    $chapter_data{'text'} = markdown(substr($chapter_data{'text'}, 0, 800) . "...");

    template "index", { article => \%news_data, chapter => \%chapter_data };
};

get '/novel' => sub {
    my $entries_per_page = 20;
    my $page = params->{page} || 1;
    my $order = params->{order} || 'desc';
    my $elements = Strehler::Element::Article::get_list({ page => $page, entries_per_page => $entries_per_page, category => 'romanzo', language => 'it', ext => 1, published => 1});
    template "novel", { chapters => $elements->{'to_view'}, page => $page, order => $order, last_page => $elements->{'last_page'} };
    #template "novel", { chapters => \@chapters, page => $page, order => $order, last_page => $pager->last_page() };
};

get '/novel/last-chapter' => sub {
    my $category = Strehler::Element::Category->new(name => 'romanzo');
    my $category_novel = schema->resultset('Category')->find( { category => 'romanzo' } );
    my @chapters = $category_novel->articles->search( { published => 1 }, { order_by => { -desc => 'display_order' } });
    my $chapter_data = $chapters[0]->contents->find({ language => 'it' });
    forward '/novel/' . $chapter_data->slug;
};
get '/novel/first-chapter' => sub {
    my $category_novel = schema->resultset('Category')->find( { category => 'romanzo' } );
    my @chapters = $category_novel->articles->search( { published => 1 }, { order_by => { -asc => 'display_order' } });
    my $chapter_data = $chapters[0]->contents->find({ language => 'it' });
    forward '/novel/' . $chapter_data->slug;
};

get '/novel/:slug' => sub {
    my $slug = params->{slug};
    my $category_novel = schema->resultset('Category')->find( { category => 'romanzo' } );
    my $chapter = schema->resultset('Content')->find({ slug => $slug, language => 'it' });
    if( !( $chapter ) || $chapter->article->category->category ne 'romanzo' || $chapter->article->published == 0)
    {
        send_error("Capitolo inesistente", 404);
    }
    else
    {
        my @prevs = $category_novel->articles->search({ published => 1, display_order => { '<', $chapter->article->display_order }}, { order_by => {-desc => 'display_order' }});
        my $prev_slug = undef;
        if($#prevs >= 0)
        {
            $prev_slug = $prevs[0]->contents->find({ language => 'it' })->slug;
        }
        my @nexts = $category_novel->articles->search({ published => 1, display_order => { '>', $chapter->article->display_order }}, { order_by => {-asc => 'display_order' }});
        my $next_slug = undef;
        if($#nexts >= 0)
        {
            $next_slug = $nexts[0]->contents->find({ language => 'it' })->slug;
        }

        template "chapter", { number => $chapter->article->display_order, title => $chapter->title, text => markdown($chapter->text), prev_slug => $prev_slug, next_slug => $next_slug };
    }
};

get '/characters' => sub {
    template 'under_constr';
};

get '/author' => sub {
    template 'author';
}

