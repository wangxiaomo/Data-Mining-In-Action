use warnings;
use strict 'vars';

use Smart::Comments;

sub log2 {
    return log(shift)/log(2);
}

sub get_shannon_score {
    my $recordset   = shift;
    my $size        = scalar @$recordset;
    my $label_count = {};

    foreach my $record (@$recordset) {
        my $label = $record->[-1];
        $label_count->{$label} = 0
            if not exists $label_count->{$label};
        $label_count->{$label} += 1;
    }
    my $shannon_score = 0.0;
    foreach my $label (keys %$label_count) {
        my $prob = $label_count->{$label}/$size;
        $shannon_score -= $prob*log2($prob);
    }
    return $shannon_score;
}


sub split_recordset {
    my ($recordset, $column, $value) = @_;
    my $target_recordset = [];

    foreach my $record (@$recordset) {
        if ($record->[$column] ~~ $value) {
            my $new_arr = [
                @{$record}[
                    0 .. $column-1,
                    $column+1 .. scalar(@{$record})-1
                ]];
            push @$target_recordset, $new_arr;
        }
    }
    return $target_recordset;
}

sub get_best_feature {
    my ($recordset, $labels) = @_;

    my $feature_nums  = scalar(@{$recordset->[0]})-1;
    my $base_entropy  = get_shannon_score($recordset);
    my $best_infogain = 0.0;
    my $best_feature  = -1;

    use Set::Scalar;

    foreach my $i (0 .. $feature_nums-1) {
        my $feature_value_list     = 
            [map { $_->[$i] } @$recordset];
        my $unique_value_list_set  = 
            Set::Scalar->new(@$feature_value_list);
        my $unique_value_list = [keys %{$unique_value_list_set->{elements}}];
        my $new_entropy = 0.0;
        foreach my $value (@$unique_value_list) {
            my $subrecordset = split_recordset($recordset, $i, $value);
            my $prob = scalar(@$subrecordset)/scalar(@$recordset);
            $new_entropy += $prob*get_shannon_score($subrecordset);
        }
        my $infogain = $base_entropy-$new_entropy;
        if ($infogain>$best_infogain) {
            $best_infogain = $infogain;
            $best_feature  = $i;
        }
    }
    return $best_feature;
}

sub create_tree {
    my ($recordset, $labels) = @_;

    my $class_list = 
        [map { $_->[-1] } @$recordset];
    if (scalar(grep{$_ ~~ $class_list->[0]} @$class_list) == 
            scalar(@$class_list)) {
        return $class_list->[0];
    }
    if (scalar(@$recordset) == 1) {
        return;
    }
    my $best_feature        = get_best_feature($recordset);
    my $best_feature_label  = $labels->[$best_feature];
    ### BEST_FEATURE_LABEL $best_feature_label
    my $tree   = {$best_feature_label=>{}};
    $labels = [grep { $_ ne $labels->[$best_feature] } @$labels];
    my $feature_values_list = 
        [map { $_->[$best_feature] } @$recordset];
    use Set::Scalar;
    my $unique_values_list_set = 
        Set::Scalar->new(@$feature_values_list);
    my $unique_values_list  = [keys %{$unique_values_list_set->{elements}}];
    foreach my $value (@$unique_values_list) {
        my $sub_labels = [@$labels];
        $tree->{$best_feature_label}->{$value} = create_tree(
            split_recordset($recordset, $best_feature, $value), $sub_labels);
    }
    ### TREE: $tree
    return $tree;
}

sub create_recordset {
    my $recordset = [
        [1,1,'yes'],
        [1,1,'yes'],
        [1,0,'no'],
        [0,1,'no'],
        [0,1,'no'],
    ];
    my $labels = ['no surfacing', 'flippers'];
    return ($recordset, $labels);
}


my ($group, $labels) = create_recordset();
use Data::Dumper;
print Dumper(create_tree($group, $labels));
#print get_best_feature($group), "\n";
