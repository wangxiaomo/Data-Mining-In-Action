use warnings;
use strict 'vars';

use Smart::Comments;
use Carp       qw/croak/;
use List::Util qw/sum/;

sub Set {
    use Set::Scalar;

    my $ref = shift;
    croak "Not An Array Reference!" if not ref($ref) eq 'ARRAY';
    my $set = Set::Scalar->new(@$ref);
    return [values %{$set->{elements}}];
}


sub get_bayes_matrix {
    my ($train_matrix, $class_list) = @_;

    my $class_set   = Set($class_list);
    my $class_p     = {};
    my $feature_p   = {};
    my $class_count = {};
     
    # step 1. caculate every class's probaility
    my $size         = scalar @$train_matrix;
    my $feature_size = scalar @{$train_matrix->[0]};
    foreach my $i (0 .. $size-1) {
        $class_p->{$class_list->[$i]} += 1;
    }
    map { $class_p->{$_} /= $size } @$class_set;

    # step 2. caculate every feature's probaility of every class
    foreach my $classname (@$class_set) {
        $feature_p->{$classname} = []
            and map { $feature_p->{$classname}->[$_] = 0 }
                    (0 .. $feature_size-1);
    }
    foreach my $i (0 .. $size-1) {
        my $classname = $class_list->[$i];
        map {
            $feature_p->{$classname}->[$_] += $train_matrix->[$i][$_]
        } (0 .. $feature_size-1);
    }
    
    # step 3.caculate its probaility
    map { $class_count->{$_} = sum($feature_p->{$_}) } @$class_set;
    foreach my $classname (@$class_set) {
        map { $feature_p->{$classname}->[$_] /= $class_count->{$classname}}
            (0 .. $feature_size-1);
    }
    return $feature_p, $class_p;
}

sub create_recordset {
    my $post_list  = [
        ['my', 'dog', 'has', 'flea', 'problems',
         'help', 'please'],
        ['maybe', 'not', 'take', 'him', 'to',
         'dog', 'park', 'stupid'],
        ['my', 'dalmation', 'is', 'so', 'cute',
         'i', 'love', 'him'],
        ['stop', 'posting', 'stupid', 'worthless',
         'garbage'],
        ['mr', 'licks', 'ate', 'my', 'steak', 'how',
         'to', 'stop', 'him'],
        ['quit', 'buying', 'worthless', 'dog', 'food',
         'stupid']
    ];
    my $class_list = [0,1,0,1,0,1];
    return $post_list, $class_list;
}

sub create_word_list {
    my $recordset = shift;
    my $word_list = [];
    foreach my $record (@$recordset) {
        push @$word_list, @$record;
    }
    return Set($word_list);
}

sub get_vector_list {
    my ($word_list, $post) = @_;

    my $feature_size = scalar @$word_list;
    my $vectors = [];$vectors->[$feature_size-1] = 0.0;

    my $index   = sub {
        my $token = shift;
        return -1 if not defined($token);
        foreach my $i (0 .. $feature_size-1) {
            return $i if $word_list->[$i] eq $token;
        }
        return -1;
    };
    foreach my $token (@$post) {
        my $pos   = $index->($token);
        if ($pos == -1) {
            print "Token $token is not in word_list\n";
        } else {
            $vectors->[$pos] = 1;
        }
    }
    $vectors = [map {
        $_ or 0
    } @$vectors];
    return $vectors;
}

use Data::Dumper;

my ($post_list, $class_list) = create_recordset();
my $word_list = create_word_list($post_list);
my $vector = get_vector_list($word_list, $post_list->[0]);

my $train_matrix = [];
foreach my $record (@$post_list) {
    push @$train_matrix,get_vector_list($word_list, $record);
}

my ($feature_p, $class_p) = get_bayes_matrix($train_matrix, $class_list);
print Dumper($class_p);
print Dumper($feature_p);
