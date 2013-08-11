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

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "category",
  { data_type => "varchar", is_nullable => 1, size => 120 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-08-03 15:21:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yEhoF79wyGYiy8Lo2L1d7Q

__PACKAGE__->has_many(
  "images",
  "Valerius::ValeriusDB::Result::Image",
  { "foreign.category" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
  "articles",
  "Valerius::ValeriusDB::Result::Article",
  { "foreign.category" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->resultset_class('Valerius::ValeriusDB::Category::ResultSet');

package Valerius::ValeriusDB::Category::ResultSet;
use base 'DBIx::Class::ResultSet';



sub make_select
{
    my $self = shift;
    my @category_values = $self->all();
    my @category_values_for_select;
    push @category_values_for_select, { value => undef, label => "-- seleziona --" }; 
    for(@category_values)
    {
        push @category_values_for_select, { value => $_->id, label => $_->category }
    }
    return \@category_values_for_select;
  
}



1;
