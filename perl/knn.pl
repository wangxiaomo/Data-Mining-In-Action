use warnings;
use strict 'vars';

use Smart::Comments;
use List::Util qw/max sum/;

sub knn_classfity {
    my ($target, $recordset, $labels, $k) = @_;

    my $rows      = scalar @{$recordset};
    my $columns   = scalar @{$recordset->[0]};
    my $distances = {};

    foreach my $i (0 .. $rows-1) {
        my $value = sum(map {
            ($target->[$_]-$recordset->[$i][$_]) ** 2
        } (0 .. $columns-1));
        $distances->{$i} = $value ** 0.5;
    }
    ### DISTANCES: %$distances
    $k = $rows if $k>$rows;
    ### $k
    my @k_indexs = (reverse sort {
                          $distances->{$a} <=> $distances->{$b}
                    } keys %$distances) [0 .. $k-1];
    ### @k_indexs
    my %k_labels    = ();
    foreach my $index (@k_indexs) {
        $k_labels{$labels->[$index]} += 1;
    }
    ### %k_labels
    my $max_labels  = max(values %k_labels);
    print $max_labels,"\n";
    return grep {$k_labels{$_} == $max_labels} keys %k_labels;
}

sub make_record_set {
    my $record_set = [
        [1.0, 1.1],
        [1.0, 1.0],
        [0, 0],
        [0, 0.1],
    ];
    my $labels = ['A', 'A', 'B', 'B'];
    return ($record_set, $labels);
}


my ($group, $labels) = make_record_set();
my $target = [0,0];
print knn_classfity($target, $group, $labels, 3), "\n";
