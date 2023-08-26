use LibraryMake;
use Zef;
use Zef::Fetch;
use Zef::Extract;
use Distribution::Builder::MakeFromJSON;

class Algorithm::XGBoost::CustomBuilder:ver<0.0.5>:auth<cpan:TITSUKI> is Distribution::Builder::MakeFromJSON {
    method build(IO() $work-dir = $*CWD) {
        my $goback = $*CWD;
        my $workdir = ~$work-dir;
        if $*DISTRO.is-win {
            die "Sorry, this binding doesn't support windows";
        }
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
        run 'ln', '-s', "$workdir/src/xgboost/lib/%vars<xgboost>", "$workdir/resources/libraries/%vars<xgboost>";
        chdir($goback);
    }
    method !install-xgboost($workdir) {
        my $srcdir = "$workdir/src";
        my %vars = get-vars($workdir);

        chdir($srcdir);
        my @fetch-backends = [
            { module => "Zef::Service::Shell::wget" },
            { module => "Zef::Service::Shell::curl" },
        ];
        my $fetcher      = Zef::Fetch.new(:backends(@fetch-backends));
        my $uri          = 'https://github.com/dmlc/xgboost/releases/download/v1.7.6/xgboost.tar.gz';
        my $archive-file = "xgboost.tar.gz".IO.e
        ?? "xgboost.tar.gz"
        !! $fetcher.fetch(Candidate.new(:$uri), "xgboost.tar.gz");
        my @extract-backends = [
            { module => "Zef::Service::Shell::tar" },
            { module => "Zef::Service::Shell::p5tar" },
        ];
        my $extractor   = Zef::Extract.new(:backends(@extract-backends));
        my $archive-file-with-cwd = $*CWD.add($archive-file);
        my $extract-dir = $extractor.extract(Candidate.new(:uri($archive-file-with-cwd)), $*CWD);
        chdir("xgboost");
        when self!is-osx {
            my $fh = open :w, "./cmake/xgboost-config.cmake.in";
            $fh.say: "../../misc/xgboost-config.cmake.in".IO.slurp;
            $fh.close;
            shell("brew install libomp && cmake . && make")
        }
        when self!is-linux { shell("cmake . && make") }
    }
    method !is-osx(--> Bool) { shell("uname", :out).out.slurp.trim.lc eq "darwin" }
    method !is-linux(--> Bool) { so (self!is-osx, $*DISTRO.is-win).none }
}
