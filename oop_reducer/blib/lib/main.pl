use strict;
use warnings;
use utf8;
use Local::Source::Array;
use Local::Source::Text;
use Local::Reducer::Sum;
use Local::Reducer::MaxDiff;
use Local::Row::JSON;

my $sum_reducer = Local::Reducer::Sum->new(
    field => 'price',
    source => Local::Source::Array->new(array => [
        'not-a-json',
        '{"price": 0}',
        '{"price": 1}',
        '{"price": 2}',
        '[ "invalid json structure" ]',
        '{"price":"low"}',
        '{"price": 3}',
    ]),
    row_class => 'Local::Row::JSON',
    initial_value => 0,
);

my $sum_result;

$sum_result = $sum_reducer->reduce_n(3);
print $sum_result;
















