use NativeCall;

unit class Algorithm::XGBoost::DMatrix:ver<0.0.1>:auth<cpan:TITSUKI> is repr('CPointer');

my constant $library = %?RESOURCES<libraries/xgboost>.Str; $*ERR.print: $library.subst(/(.+)/, ""); # Force evaluation
my sub XGDMatrixCreateFromFile(Str, int32, Algorithm::XGBoost::DMatrix is rw --> int32) is native($library) { * }
my sub XGDMatrixNumRow(Algorithm::XGBoost::DMatrix, ulong is rw --> int32) is native($library) { * }
my sub XGDMatrixNumCol(Algorithm::XGBoost::DMatrix, ulong is rw --> int32) is native($library) { * }
my sub XGDMatrixCreateFromMat(Pointer[num32], ulong, ulong, num32, Algorithm::XGBoost::DMatrix is rw --> int32) is native($library) { * }
method new {!!!}

method from-file(::?CLASS:U: Str $path --> ::?CLASS:D) {
    my $h = Pointer.new;
    XGDMatrixCreateFromFile($path, 1, $h);
    nativecast(Algorithm::XGBoost::DMatrix, $h);
}

method from-matrix(::?CLASS:U: @matrix where { $_.shape ~~ ($,$) }, Num $missing = 1e0 --> ::?CLASS:D) {
    my $h = Pointer.new;
    my $data = CArray[num32].new(@matrix.flat);
    my ($nr, $nc) = @matrix.shape;
    XGDMatrixCreateFromMat(nativecast(Pointer[$data.of], $data), $nr, $nc, $missing, $h);
    nativecast(Algorithm::XGBoost::DMatrix, $h);
}

method num-row(--> Int) {
    my int32 $nr;
    XGDMatrixNumRow(self, $nr);
    $nr;
}

method num-col(--> Int) {
    my int32 $nc;
    XGDMatrixNumCol(self, $nc);
    $nc;
}
