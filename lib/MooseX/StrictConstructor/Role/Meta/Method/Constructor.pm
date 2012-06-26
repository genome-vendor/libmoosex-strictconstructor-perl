package MooseX::StrictConstructor::Role::Meta::Method::Constructor;
BEGIN {
  $MooseX::StrictConstructor::Role::Meta::Method::Constructor::VERSION = '0.11';
}

use strict;
use warnings;

use B ();
use Carp ();

use Moose::Role;

around '_generate_BUILDALL' => sub {
    my $orig = shift;
    my $self = shift;

    my $source = $self->$orig();
    $source .= ";\n" if $source;

    my @attrs = (
        "__INSTANCE__ => 1,",
        map { B::perlstring($_) . ' => 1,' }
        grep {defined}
        map  { $_->init_arg() } @{ $self->_attributes() }
    );

    $source .= <<"EOF";
my \%attrs = (@attrs);

my \@bad = sort grep { ! \$attrs{\$_} }  keys \%{ \$params };

if (\@bad) {
    Carp::confess "Found unknown attribute(s) passed to the constructor: \@bad";
}
EOF

    return $source;
};

no Moose::Role;

1;

# ABSTRACT: A role to make immutable constructors strict



=pod

=head1 NAME

MooseX::StrictConstructor::Role::Meta::Method::Constructor - A role to make immutable constructors strict

=head1 VERSION

version 0.11

=head1 SYNOPSIS

  Moose::Util::MetaRole::apply_metaroles(
      for_class => $caller,
      class     => {
          constructor =>
              ['MooseX::StrictConstructor::Role::Meta::Method::Constructor'],
      },
  );

=head1 DESCRIPTION

This role simply wraps C<_generate_BUILDALL()> (from
C<Moose::Meta::Method::Constructor>) so that immutable classes have a
strict constructor.

=head1 AUTHOR

  Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2010 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0

=cut


__END__


