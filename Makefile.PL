use 5.006;
use inc::Module::Install 0.91;
use strict;
use warnings FATAL => 'all';

perl_version '5.006';
all_from 'lib/Log/Contextual.pm';
requires 'Data::Dumper::Concise';
requires 'Exporter::Declare' => 0.111;
requires 'Carp';
requires 'Scalar::Util';
requires 'Moo' => 1.003000;

test_requires 'Test::Fatal';

WriteAll;
