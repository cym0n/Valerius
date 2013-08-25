use utf8;
package Valerius::ValeriusDB::Result::Image;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Valerius::ValeriusDB::Result::Image

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

=head1 TABLE: C<IMAGES>

=cut

__PACKAGE__->table("IMAGES");

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

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "image",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "category",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-08-03 15:21:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:P8K/4MfKm9RMKYUQ4Vk6gg

__PACKAGE__->has_many(
  "descriptions",
  "Valerius::ValeriusDB::Result::Description",
  { "foreign.image" => "self.id" },
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


1;
