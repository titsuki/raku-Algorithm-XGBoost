use NativeCall;
use Algorithm::XGBoost::Booster;
use Algorithm::XGBoost::DMatrix;
use Algorithm::XGBoost::Model;

unit class Algorithm::XGBoost:ver<0.0.1>:auth<cpan:TITSUKI>;

my constant $library = %?RESOURCES<libraries/xgboost>.Str;
my sub XGBoostVersion(int32 is rw, int32 is rw, int32 is rw) is native($library) { * }
my sub XGBLastError is native($library) { * }
my sub XGBRegisterLogCallBack(&callback (Str --> void)) is native($library) { * }
my sub XGBSetGlobalConfig(Str --> int32) is native($library) { * }
my sub XGBGetGlobalConfig(Str is rw --> int32) is native($library) { * }

method new {!!!}

method version(--> Version) {
  my int32 $a;
  my int32 $b;
  my int32 $c;
  XGBoostVersion($a, $b, $c);
  Version.new(($a,$b,$c).join("."))
}

my sub XGBoosterCreate(Algorithm::XGBoost::DMatrix is rw, ulong, Algorithm::XGBoost::Booster is rw --> int32) is native($library) { * }
my sub XGBoosterUpdateOneIter(Algorithm::XGBoost::Booster, int32, Algorithm::XGBoost::DMatrix --> int32) is native($library) { * }

method train(Algorithm::XGBoost::DMatrix $dmat, Int $num-iteration --> Algorithm::XGBoost::Model) {
    my $h = Pointer.new;
    XGBoosterCreate($dmat, 1, $h);
    my $booster = nativecast(Algorithm::XGBoost::Booster, $h);
    
    for ^$num-iteration -> $iter {
        XGBoosterUpdateOneIter($booster, $iter, $dmat);
    }
    Algorithm::XGBoost::Model.create($booster);
}

=begin pod

=head1 NAME

Algorithm::XGBoost - A Raku bindings for XGBoost ( https://github.com/dmlc/xgboost ).

=head1 SYNOPSIS

=begin code :lang<raku>

use Algorithm::XGBoost;
use Algorithm::XGBoost::Booster;
use Algorithm::XGBoost::DMatrix;
use Algorithm::XGBoost::Model;

# agaricus.txt.test is here: https://github.com/dmlc/xgboost/tree/master/demo/data
my $dmat = Algorithm::XGBoost::DMatrix.from-file("agaricus.txt.test");
say $dmat.num-row; # 1611
say $dmat.num-col; # 127
my $model = Algorithm::XGBoost.train($dmat, 10);
$model.num-feature.say; # 127

my @test[2;2] = [[0e0,0e0],[0e0,1e0]];
my $test = Algorithm::XGBoost::DMatrix.from-matrix(@test);
say $model.predict($test); # (0.9858198761940002 0.9858198761940002)

=end code

=head1 DESCRIPTION

Algorithm::XGBoost is a Raku bindings for XGBoost ( https://github.com/dmlc/xgboost ).

=head2 METHODS

=head3 train

Defined as:

       method train(Algorithm::XGBoost::DMatrix $dmat, Int $num-iteration --> Algorithm::XGBoost::Model)

Trains a XGBoost model.

=item C<$dmat> The instance of Algorithm::XGBoost::DMatrix.

=item C<$num-iteration> The number of iterations for training.

=head3 version

Defined as:

       method version(--> Version)

Returns the libxgboost version.

=head1 AUTHOR

Itsuki Toyota <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Itsuki Toyota

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
