use utf8;
package Valerius::ValeriusDB::Result::Category;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Valerius::ValeriusDB::Result::Category

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

=head1 TABLE: C<CATEGORIES>

=cut

__PACKAGE__->table("CATEGORIES");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 category

  data_type: 'varchar'
  is_nullable: 1
  size: 120

=head2 parent

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "category",
  { data_type => "varchar", is_nullable => 1, size => 120 },
  "parent",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 articles

Type: has_many

Related object: L<Valerius::ValeriusDB::Result::Article>

=cut

__PACKAGE__->has_many(
  "articles",
  "Valerius::ValeriusDB::Result::Article",
  { "foreign.category" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 categories

Type: has_many

Related object: L<Valerius::ValeriusDB::Result::Category>

=cut

__PACKAGE__->has_many(
  "categories",
  "Valerius::ValeriusDB::Result::Category",
  { "foreign.parent" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 configured_tags

Type: has_many

Related object: L<Valerius::ValeriusDB::Result::ConfiguredTag>

=cut

__PACKAGE__->has_many(
  "configured_tags",
  "Valerius::ValeriusDB::Result::ConfiguredTag",
  { "foreign.category_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 images

Type: has_many

Related object: L<Valerius::ValeriusDB::Result::Image>

=cut

__PACKAGE__->has_many(
  "images",
  "Valerius::ValeriusDB::Result::Image",
  { "foreign.category" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 parent

Type: belongs_to

Related object: L<Valerius::ValeriusDB::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "parent",
  "Valerius::ValeriusDB::Result::Category",
  { id => "parent" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07037 @ 2014-02-05 23:07:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:T3i5GQag6JfTBapp3SuMiw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
