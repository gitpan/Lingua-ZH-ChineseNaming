# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 10 };
use Lingua::ZH::ChineseNaming;
ok(1); # If we made it this far, we're ok.

#########################

my $n = new Lingua::ZH::ChineseNaming(
				      FAMILY_NAME => '³¯',
				      GIVEN_NAME => '¶ê¶ê'
);

ok($n->{general}, 38);
ok($n->{FAMILY_NAME}, '³¯');
ok($n->{GIVEN_NAME}, '¶ê¶ê');
ok($n->{hexagram}, 'gen over li');
ok($n->{heavenly}, 12);
ok($n->{personal}, 24);
ok($n->{earthly},  26);
ok($n->{external}, 14);
ok($n->{diagram}, "---\n- -\n- -\n---\n- -\n---"),

