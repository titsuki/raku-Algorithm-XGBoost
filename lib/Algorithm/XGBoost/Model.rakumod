use NativeCall;
use Algorithm::XGBoost::DMatrix;
use Algorithm::XGBoost::Booster;

unit class Algorithm::XGBoost::Model:ver<0.0.1>:auth<cpan:TITSUKI> is repr('CPointer');

my constant $library = %?RESOURCES<libraries/xgboost>.Str;
my sub XGBoosterGetNumFeature(Algorithm::XGBoost::Model, ulong is rw --> int32) is native($library) { * }
my sub XGBoosterPredict(Algorithm::XGBoost::Model, Algorithm::XGBoost::DMatrix, int32, uint32, int32, ulong is rw, Pointer[num32] is rw --> int32) is native($library) { * }

method new {!!!}

method create(::?CLASS:U: $booster --> ::?CLASS) {
    nativecast(::?CLASS, $booster)
}

method num-feature(--> Int) {
    my ulong $num;
    XGBoosterGetNumFeature(self, $num);
    $num;
}

method predict(Algorithm::XGBoost::DMatrix $dmat, Int $option-mask = 0, Int $ntree-limit = 0, $training = 1 --> Seq) {
    my ulong $size;
    my $ret = Pointer[num32].new;
    XGBoosterPredict(self, $dmat, $option-mask, $ntree-limit, $training, $size, $ret);
    nativecast(CArray[$ret.of], $ret)[^$size]
}

