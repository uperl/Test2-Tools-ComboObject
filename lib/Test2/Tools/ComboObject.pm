use warnings;
use 5.020;
use experimental qw( postderef signatures );

package Test2::Tools::ComboObject {

  # ABSTRACT: Combine checks and diagnostics into a single test as an object

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 context

=head2 name

=head2 status

=cut

  use Exporter 'import';
  use Test2::API ();
  use Class::Tiny qw/ context /, {
    name => "combo object test",
    status => 1,
    _log => sub { [] },
    _count => 0,
    _done => 0,
    _extra => 0,
  };

  sub BUILD ($self, $) {
    my %args = ( level => 3 + $self->_extra );
    $self->context( Test2::API::context( %args ) );
  }

  sub DEMOLISH ($self, $) {
    $self->finish;
  }

=head1 FUNCTIONS

=head2 combo

=cut

  our @EXPORT = qw( combo );

  sub combo :prototype(;$) {
    my $name = shift // 'combo object test';
    return __PACKAGE__->new( name => $name, _extra => 1 );
  }

=head1 METHODS

=head2 finish

=cut

  sub finish ($self) {
    return $self->status if $self->_done;

    $self->_done(1);

    unless ( $self->_count ) {
      push $self->_log->@*, "Test::ComboTest object had no checks";
      $self->status(0);
    }

    if ( $self->status ) {
      if ( $self->_log->@* ) {
        $self->context->pass( $self->name );
        $self->context->note( $_ ) for $self->_log->@*;
        $self->context->release;
      } else {
        $self->context->pass_and_release( $self->name );
      }
    } else {
      $self->context->fail_and_release( $self->name, $self->_log->@* );
    }

    return $self->status;
  }

=head2 log

=cut

  sub log ( $self, @messages ) {
    push $self->_log->@*, @messages;
    return $self;
  }

=head2 pass

=cut

  sub pass ( $self, @messages ) {
    $self->log(@messages);
    $self->_count( $self->_count + 1 );
    return $self;
  }

=head2 fail

=cut

  sub fail ( $self, @messages ) {
    $self->status(0);
    $self->log(@messages);
    $self->_count( $self->_count + 1 );
    return $self;
  }

=head2 ok

=cut

  sub ok ( $self, $status, @messages ) {
    $self->status(0) unless $status;
    $self->log(@messages);
    $self->_count( $self->_count + 1 );
    return $self;
  }

}

1;