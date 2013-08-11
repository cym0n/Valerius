use utf8;
package Valerius::ValeriusDB::Result::Description;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Valerius::ValeriusDB::Result::Description

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

=head1 TABLE: C<DESCRIPTIONS>

=cut

__PACKAGE__->table("DESCRIPTIONS");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 image

  data_type: 'integer'
  is_nullable: 1

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 language

  data_type: 'varchar'
  is_nullable: 1
  size: 2

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "image",
  { data_type => "integer", is_nullable => 1 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "language",
  { data_type => "varchar", is_nullable => 1, size => 2 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-08-03 15:21:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NLTvU0r5sI3Hoqo4EoK7Tg

__PACKAGE__->belongs_to(
  "image",
  "Valerius::ValeriusDB::Result::Image",
  { id => "image" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);



1;
