use LibraryMake;
use Zef;
use Zef::Fetch;
use Zef::Extract;
use Distribution::Builder::MakeFromJSON;

class Algorithm::XGBoost::CustomBuilder:ver<0.0.1> is Distribution::Builder::MakeFromJSON {
    method build(IO() $work-dir = $*CWD) {
        my $workdir = ~$work-dir;
	my $srcdir = "$workdir/src";
	my %vars = get-vars($workdir);
	%vars<xgboost> = $*VM.platform-library-name('xgboost'.IO);
        mkdir $srcdir unless $srcdir.IO.e;
	mkdir "$workdir/resources" unless "$workdir/resources".IO.e;
	mkdir "$workdir/resources/libraries" unless "$workdir/resources/libraries".IO.e;

        self!install-xgboost($workdir);
        if "$workdir/resources/libraries/%vars<xgboost>".IO.f {
            run 'rm', '-f', "$workdir/resources/libraries/%vars<xgboost>";
        }
        run 'cp', "$workdir/src/xgboost/lib/%vars<xgboost>", "$workdir/resources/libraries/%vars<xgboost>";
    }
    method !install-xgboost($workdir) {
        my $goback = $*CWD;
        my $srcdir = "$workdir/src";
        my %vars = get-vars($workdir);

        chdir($srcdir);
        my @fetch-backends = [
            { module => "Zef::Service::Shell::wget" },
            { module => "Zef::Service::Shell::curl" },
        ];
        my $fetcher      = Zef::Fetch.new(:backends(@fetch-backends));
        my $uri          = 'https://github.com/dmlc/xgboost/releases/download/v1.4.2/xgboost.tar.gz';
        my $archive-file = "xgboost.tar.gz".IO.e
        ?? "xgboost.tar.gz"
        !! $fetcher.fetch(Candidate.new(:$uri), "xgboost.tar.gz");

        my @extract-backends = [
            { module => "Zef::Service::Shell::tar" },
            { module => "Zef::Service::Shell::p5tar" },
        ];
        my $extractor   = Zef::Extract.new(:backends(@extract-backends));
        my $extract-dir = $extractor.extract(Candidate.new(:uri($archive-file)), $*CWD);
        chdir("xgboost");
        when self!is-osx { shell("brew install libomp && cmake . && make") }
        when self!is-win { shell("cmake -G\"Visual Studio 14 2015 Win64\" && make") }
        when self!is-linux { shell("cmake . && make") }
        chdir($goback);
    }
    method !is-osx(--> Bool) { shell("uname", :out).out.slurp.trim.lc eq "darwin" }
    method !is-win(--> Bool) { $*DISTRO.is-win }
    method !is-linux(--> Bool) { so (self!is-osx, self!is-win).none }
}
