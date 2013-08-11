package Valerius;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Dancer2::Core::Error;
use Text::Markdown 'markdown';
use Date::Format;
use Data::Dumper;

set layout => 'valerius';

get '/' => sub {
    my $category_news = schema->resultset('Category')->find( { category => 'notizie' } );
    my @news = $category_news->articles->search( { published => 1 }, { order_by => { -desc => 'publish_date' } });
    my $news_data = $news[0]->contents->find({ language => 'it' });

    my $category_novel = schema->resultset('Category')->find( { category => 'romanzo' } );
    my @chapters = $category_novel->articles->search( { published => 1 }, { order_by => { -desc => 'display_order' } });
    my $chapter_data = $chapters[0]->contents->find({ language => 'it' });
    
    my %article;
    $article{'title'} = $news_data->title;
    $article{'text'} = markdown($news_data->text);
    $article{'publish_date'} = $news[0]->publish_date->strftime('%d-%m-%Y');
    
    my %extract;
    $extract{'title'} = $chapter_data->title;
    $extract{'text'} = markdown(substr($chapter_data->text, 0, 800) . "...");
    $extract{'chapter_number'} = $chapters[0]->display_order;
    $extract{'link'} = '/novel/' . $chapter_data->slug;
    
    template "index", { article => \%article, chapter => \%extract };
};

get '/novel' => sub {
    my $entries_per_page = 20;
    my $page = params->{page} || 1;
    my $order = params->{order} || 'desc';
    my $category_novel = schema->resultset('Category')->find( { category => 'romanzo' } );
    my $rs = $category_novel->articles->search({ published => 1 }, { order_by => { '-' . $order => 'display_order' } , page => 1, rows => $entries_per_page});
    my $pager = $rs->pager();
    my $elements = $rs->page($page);
    my @chapters;
    for($elements->all())
    {
        my $el = $_;
        my %chap;
        $chap{'number'} = $el->display_order;
        $chap{'title'} = $el->contents->find({ language => 'it' })->title;
        $chap{'slug'} = $el->contents->find({ language => 'it' })->slug;
        push @chapters, \%chap;
    }

    template "novel", { chapters => \@chapters, page => $page, order => $order, last_page => $pager->last_page() };
};

get '/novel/last-chapter' => sub {
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

