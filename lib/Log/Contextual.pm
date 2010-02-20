package Log::Contextual;

use strict;
use warnings;

our $VERSION = '1.000';

require Exporter;
use Data::Dumper::Concise;

BEGIN { our @ISA = qw(Exporter) }

my @dlog = (qw{
   Dlog_debug DlogS_debug
   Dlog_trace DlogS_trace
   Dlog_warn DlogS_warn
   Dlog_info DlogS_info
   Dlog_error DlogS_error
   Dlog_fatal DlogS_fatal
});

my @log = (qw{
   log_debug
   log_trace
   log_warn
   log_info
   log_error
   log_fatal
});

our @EXPORT_OK = (
   @dlog, @log,
   qw{set_logger with_logger}
);

our %EXPORT_TAGS = (
   dlog => \@dlog,
   log  => \@log,
);

sub import {
   my $package = shift;
   die 'Log::Contextual does not have a default import list'
      unless @_;

   for my $idx ( 0 .. $#_ ) {
      if ( $_[$idx] eq '-logger' ) {
         set_logger($_[$idx + 1]);
         splice @_, $idx, 2;
         last;
      }
   }
   $package->export_to_level(1, $package, @_);
}

our $Get_Logger;

sub set_logger {
   my $logger = $_[0];
   $logger = do { my $l = $logger; sub { $l } }
      if ref $logger ne 'CODE';
   $Get_Logger = $logger;
}

sub with_logger {
   my $logger = $_[0];
   $logger = do { my $l = $logger; sub { $l } }
      if ref $logger ne 'CODE';
   local $Get_Logger = $logger;
   $_[1]->();
}

sub log_trace (&) {
   my $log = $Get_Logger->();
   $log->trace($_[0]->())
      if $log->is_trace;
}

sub log_debug (&) {
   my $log = $Get_Logger->();
   $log->debug($_[0]->())
      if $log->is_debug;
}

sub log_info (&) {
   my $log = $Get_Logger->();
   $log->info($_[0]->())
      if $log->is_info;
}

sub log_warn (&) {
   my $log = $Get_Logger->();
   $log->warn($_[0]->())
      if $log->is_warn;
}

sub log_error (&) {
   my $log = $Get_Logger->();
   $log->error($_[0]->())
      if $log->is_error;
}

sub log_fatal (&) {
   my $log = $Get_Logger->();
   $log->fatal($_[0]->())
      if $log->is_fatal;
}



sub Dlog_trace (&@) {
  my $code = shift;
  my @values = @_;
  log_trace {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_trace (&$) {
  my $code = $_[0];
  my $value = $_[1];
  log_trace {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

sub Dlog_debug (&@) {
  my $code = shift;
  my @values = @_;
  log_debug {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_debug (&$) {
  my $code = $_[0];
  my $value = $_[1];
  log_debug {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

sub Dlog_info (&@) {
  my $code = shift;
  my @values = @_;
  log_info {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_info (&$) {
  my $code = $_[0];
  my $value = $_[1];
  log_info {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

sub Dlog_warn (&@) {
  my $code = shift;
  my @values = @_;
  log_warn {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_warn (&$) {
  my $code = $_[0];
  my $value = $_[1];
  log_warn {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

sub Dlog_error (&@) {
  my $code = shift;
  my @values = @_;
  log_error {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_error (&$) {
  my $code = $_[0];
  my $value = $_[1];
  log_error {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

sub Dlog_fatal (&@) {
  my $code = shift;
  my @values = @_;
  log_fatal {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_fatal (&$) {
  my $code = $_[0];
  my $value = $_[1];
  log_fatal {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

1;

__END__

=head1 NAME

Log::Contextual - Super simple logging interface

=head1 SYNOPSIS

 use Log::Contextual qw{:log set_logger with_logger};

 my $logger  = Log::Contextual::SimpleLogger->new({ levels => [qw{debug}]});

 set_logger { $logger };

 log_debug { "program started" };

 sub foo {
   with_logger Log::Contextual::SimpleLogger->new({
       levels => [qw{trace debug}]
     }) => sub {
     log_trace { 'foo entered' };
     # ...
     log_trace { 'foo left' };
   };
 }

=head1 DESCRIPTION

This module is a simple interface to extensible logging.

=head1 FUNCTIONS

=head2 set_logger

 my $logger = WarnLogger->new;
 set_logger $logger;

Arguments: Ref|CodeRef $returning_logger

C<set_logger> will just set the current logger to whatever you pass it.  It
expects a C<CodeRef>, but if you pass it something else it will wrap it in a
C<CodeRef> for you.

=head2 with_logger

 my $logger = WarnLogger->new;
 with_logger $logger => sub {
    if (1 == 0) {
       log_fatal { 'Non Logical Universe Detected' };
    } else {
       log_info  { 'All is good' };
    }
 };

Arguments: Ref|CodeRef $returning_logger, CodeRef $to_execute

C<with_logger> sets the logger for the scope of the C<CodeRef> C<$to_execute>.
as with L<set_logger>, C<with_logger> will wrap C<$returning_logger> with a
C<CodeRef> if needed.

=head2 log_$level

Arguments: CodeRef $returning_message

All of the following six functions work the same except that a different method
is called on the underlying C<$logger> object.  The basic pattern is:

 sub log_$level (&) {
   if ($logger->is_$level) {
     $logger->$level(shift->());
   }
 }

=head3 log_trace

 log_trace { 'entered method foo with args ' join q{,}, @args };

=head3 log_debug

 log_debug { 'entered method foo' };

=head3 log_info

 log_info { 'started process foo' };

=head3 log_warn

 log_warn { 'possible misconfiguration at line 10' };

=head3 log_error

 log_error { 'non-numeric user input!' };

=head3 log_fatal

 log_fatal { '1 is never equal to 0!' };

=head2 Dlog_$level

Arguments: CodeRef $returning_message

All of the following six functions work the same as their log_$level brethren,
except they return what is passed into them and as a bonus put the stringified
(with L<Data::Dumper::Concise>) version of their args into C<$_>.  This means
you can do cool things like the following:

 my @nicks = Dlog_debug { "names: $_" } map $_->value, $frew->names->all;

and the output might look something like:

 names: "fREW"
 "fRIOUX"
 "fROOH"
 "fRUE"
 "fiSMBoC"

=head3 Dlog_trace

 my ($foo, $bar) = Dlog_trace { "entered method foo with args $_" } @_;

=head3 Dlog_debug

 Dlog_debug { "random data structure: $_" } { foo => $bar };

=head3 Dlog_info

 return Dlog_info { "html from method returned: $_" } "<html>...</html>";

=head3 Dlog_warn

 Dlog_warn { "probably invalid value: $_" } $foo;

=head3 Dlog_error

 Dlog_error { "non-numeric user input! ($_)" } $port;

=head3 Dlog_fatal

 Dlog_fatal { '1 is never equal to 0!' } 'ZOMG ZOMG' if 1 == 0;

=head1 AUTHOR

frew - Arthur Axel "fREW" Schmidt <frioux@gmail.com>

=head1 DESIGNER

mst - Matt S. Trout <mst@shadowcat.co.uk>

=head1 COPYRIGHT

Copyright (c) 2010 the Log::Contextual L</AUTHOR> and L</DESIGNER> as listed
above.

=head1 LICENSE

This library is free software and may be distributed under the same terms as
Perl 5 itself.

=cut

