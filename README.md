# Test2::Tools::ComboObject ![static](https://github.com/uperl/Test2-Tools-ComboObject/workflows/static/badge.svg) ![linux](https://github.com/uperl/Test2-Tools-ComboObject/workflows/linux/badge.svg)

Combine checks and diagnostics into a single test as an object

# SYNOPSIS

```perl
use Test2::V0;
use Test2::Tools::ComboObject;
use feature qw( signatures );

sub my_test_tool ($test_name //='my test tool', @numbers) {
  my $combo = combo $test_name;
  foreach my $number (@numbers) {
    if($number % 2) {
      $combo->fail("$number is not even");
    } else {
      $combo->pass;
    }
  }
  return $combo->finish;
}

my_test_tool undef, 4, 6, 8, 9, 100, 200, 300, 9999, 2859452842;
my_test_tool 'try again', 2, 4, 6, 8;

done_testing;
```

output:

```perl
prove -lvm examples/synopsis.t
examples/synopsis.t ..
# Seeded srand with seed '20241121' from local date.
not ok 1 - my test tool

# Failed test 'my test tool'
# at examples/synopsis.t line 17.
# 9 is not even
# 9999 is not even
ok 2 - try again
1..2
Dubious, test returned 1 (wstat 256, 0x100)
Failed 1/2 subtests

Test Summary Report
-------------------
examples/synopsis.t (Wstat: 256 (exited 1) Tests: 2 Failed: 1)
  Failed test:  1
  Non-zero exit status: 1
Files=1, Tests=2,  0 wallclock secs ( 0.00 usr  0.00 sys +  0.03 cusr  0.00 csys =  0.03 CPU)
Result: FAIL
```

# DESCRIPTION

Combine multiple checks into a single test.  Sometimes you want a test tool that has multiple
possible failure points, but you want to hide that complexity from the user of your test tool.
This class helps provide a OO interface to make this easy without having to track status and
diagnostics in separate variables.

If any one check fails the test will fail.  If all checks pass then the test will pass.
You can log diagnostics which will be directed to either `diag` or `note` depending on
if the test fails or passes (respectively) overall.

# ATTRIBUTES

## context

```perl
my $ctx = $combo->context;
```

The [Test2::API::Context](https://metacpan.org/pod/Test2::API::Context) context.  When created, this context takes into account the
extra stack frames so that any failure diagnostics will point back to the call point of
your tool.

## name

```perl
my $name = $combo->name;
```

The string name of the test.  The default `combo object test` will be used if not provided.

## status

The boolean status of the test.  Zero `0` for failure and One `1` for pass.  You should
generally not set this yourself directly, and instead use ["pass"](#pass), ["fail"](#fail) or ["ok"](#ok)
below.

# FUNCTIONS

## combo

```perl
my $combo = combo $test_name;
my $combo = combo;
```

Exported by default.  Takes an optional test name.  Will use
`combo object test` if not provided.

# METHODS

Note that methods that do not specify a return type will return the combo object,
so such methods may be chained.

## finish

```perl
my $status = $combo->finish;
```

Complete the combo test by generating the appropriate [Test2](https://metacpan.org/pod/Test2) events and release its
context.  It also returns the pass/fail status, to make it a good choice to return from
your tool, since it is a common practice for tools to return true/false when the
pass/fail (respectively).

```perl
sub test_tool {
  my $combo = combo;
  ...
  return $combo->finish;
}
```

If the the combo object is not explicitly finished when the object is destroyed then
it will be finished for you in its destructor.

## log

```
$combo->log(@messages);
```

Include the given `@messages` as either a `diag` or `note` if the test
overall fails or passes (respectively).

## pass

```perl
$self->pass;
$self->pass(@messages);
```

Marks a passing check.  `@messages` if provided will be added to the log.

## fail

```perl
$self->fail;
$self->fail(@messages);
```

Marks a failing check.  `@messages` if provided will be added to the log.

## ok

```perl
$self->ok($status);
$self->ok($status, @messages);
```

Marks a passing or failing check depending on if the `$status` is true or false (respectively).
`@messages` if provided will be added to the log.

# CAVEATS

This class creates a [Test2::API::Context](https://metacpan.org/pod/Test2::API::Context), and does release it when the object is
either finished (via ["finish"](#finish)) or when it falls out of scope.  Because of this any
caveats about storing and releasing contexts also applies to objects of this class.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2024 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
