use utf8;
package Valerius::ValeriusDB::Result::Article;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Valerius::ValeriusDB::Result::Article

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<ARTICLES>

=cut

__PACKAGE__->table("ARTICLES");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 image

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 category

  data_type: 'integer'
  is_nullable: 1

=head2 display_order

  data_type: 'integer'
  is_nullable: 1

=head2 publish_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 published

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "image",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "category",
  { data_type => "integer", is_nullable => 1 },
  "display_order",
  { data_type => "integer", is_nullable => 1 },
  "publish_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "published",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-08-03 15:21:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lEn2C3+/a+gD9UAF/4BTwg

__PACKAGE__->has_many(
  "contents",
  "Valerius::ValeriusDB::Result::Content",
  { "foreign.article" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->belongs_to(
  "category",
  "Valerius::ValeriusDB::Result::Category",
  { id => "category" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => undef,
    on_update     => undef,
  },
);


sub main_title
{
    my $self = shift;
    my @contents = $self->contents->search({ language => 'it' });
    if($contents[0])
    {
        return $contents[0]->title;
    }
    else
    {
        #Should not be possible
        return "*** no title ***";
    }

}

1;