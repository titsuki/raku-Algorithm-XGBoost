use NativeCall;

unit class Algorithm::XGBoost::DMatrix:ver<0.0.3>:auth<cpan:TITSUKI> is repr('CPointer');

my constant $library = %?RESOURCES<libraries/xgboost>.Str;
my sub XGDMatrixCreateFromFile(Str, int32, Algorithm::XGBoost::DMatrix is rw --> int32) is native($library) { * }
my sub XGDMatrixNumRow(Algorithm::XGBoost::DMatrix, ulong is rw --> int32) is native($library) { * }
my sub XGDMatrixNumCol(Algorithm::XGBoost::DMatrix, ulong is rw --> int32) is native($library) { * }
my sub XGDMatrixCreateFromMat(Pointer[num32], ulong, ulong, num32, Algorithm::XGBoost::DMatrix is rw --> int32) is native($library) { * }
my sub XGDMatrixGetFloatInfo(Algorithm::XGBoost::DMatrix, Str, ulong is rw, Pointer[num32] is rw --> int32) is native($library) { * }
my sub XGDMatrixSetFloatInfo(Algorithm::XGBoost::DMatrix, Str, CArray[num32], ulong --> int32) is native($library) { * }

method new {!!!}

method from-file(::?CLASS:U: Str $path --> ::?CLASS:D) {
    my $h = Pointer.new;
    XGDMatrixCreateFromFile($path, 1, $h);
    nativecast(Algorithm::XGBoost::DMatrix, $h);
}

method from-matrix(::?CLASS:U: @x where { $_.shape ~~ ($,$) }, @y?, Num :$missing = NaN --> ::?CLASS:D) {
    my $h = Pointer.new;
    my $data = CArray[num32].new(@x.flat);
    my ($nr, $nc) = @x.shape;
    XGDMatrixCreateFromMat(nativecast(Pointer[$data.of], $data), $nr, $nc, $missing, $h);
    XGDMatrixSetFloatInfo($h, "label", CArray[num32].new(@y), @y.elems);
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
