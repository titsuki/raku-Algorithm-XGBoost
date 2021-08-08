[![Actions Status](https://github.com/titsuki/raku-Algorithm-XGBoost/workflows/test/badge.svg)](https://github.com/titsuki/raku-Algorithm-XGBoost/actions)

NAME
====

Algorithm::XGBoost - A Raku bindings for XGBoost ( https://github.com/dmlc/xgboost ).

SYNOPSIS
========

```raku
use Algorithm::XGBoost;
use Algorithm::XGBoost::Booster;
use Algorithm::XGBoost::DMatrix;
use Algorithm::XGBoost::Model;

# agaricus.txt.test is here: https://github.com/dmlc/xgboost/tree/master/demo/data
my $dmat = Algorithm::XGBoost::DMatrix.from-file("agaricus.txt.train");
say $dmat.num-row; # 6513
say $dmat.num-col; # 127
my $model = Algorithm::XGBoost.train($dmat, 10);
$model.num-feature.say; # 127

my @test[2;2] = [[0e0,0e0],[0e0,1e0]];
my $test = Algorithm::XGBoost::DMatrix.from-matrix(@test);
say $model.predict($test); # (0.9858561754226685 0.9858561754226685)
```

DESCRIPTION
===========

Algorithm::XGBoost is a Raku bindings for XGBoost ( https://github.com/dmlc/xgboost ).

METHODS
-------

### train

Defined as:

    method train(Algorithm::XGBoost::DMatrix $dmat, Int $num-iteration --> Algorithm::XGBoost::Model)

Trains a XGBoost model.

  * `$dmat` The instance of Algorithm::XGBoost::DMatrix.

  * `$num-iteration` The number of iterations for training.

### version

Defined as:

    method version(--> Version)

Returns the libxgboost version.

### global-config

Defined as:

    multi method global-config(Str $json-str)
    multi method global-config(--> Str)

Sets/Gets the global parameters: verbosity and use_rmm.

  * `verbosity` The verbosity of printing messages. Valid values of 0 (silent), 1 (warning), 2 (info), and 3 (debug).

  * `use_rmm` Whether to use RAPIDS Memory Manager (RMM) to allocate GPU memory. This option is only applicable when XGBoost is built (compiled) with the RMM plugin enabled. Valid values are true and false.

AUTHOR
======

Itsuki Toyota <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Itsuki Toyota

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

