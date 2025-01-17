{ pkgs, nodejs, lib, python3Packages, fetchFromGitHub, nixosTests }:
let
  nodeEnv = import ./node-env.nix {
    inherit (pkgs) stdenv lib python2 runCommand writeTextFile;
    inherit pkgs nodejs;
    libtool = if pkgs.stdenv.isDarwin then pkgs.darwin.cctools else null;
  };
  nodePackages = import ./node-packages.nix {
    inherit (pkgs) fetchurl nix-gitignore stdenv lib fetchgit;
    inherit nodeEnv;
  };

  nodeDependencies = (nodePackages.shell.override (old: {
  })).nodeDependencies;
in
with python3Packages; buildPythonApplication rec {

  pname = "isso";
  version = "0.12.6.1";

  src = fetchFromGitHub {
    owner = "posativ";
    repo = pname;
    rev = version;
    sha256 = "sha256-b2iJmOOsaI4lqJ5//jmHflXRx4yFDaAoKZixXoWIyZg=";
  };

  propagatedBuildInputs = [
    itsdangerous
    jinja2
    misaka
    html5lib
    werkzeug
    bleach
    flask-caching
  ];

  nativeBuildInputs = [
    cffi
    nodejs
  ];

  preBuild = ''
    ln -s ${nodeDependencies}/lib/node_modules ./node_modules
    export PATH="${nodeDependencies}/bin:$PATH"

    make js
  '';

  checkInputs = [
    pytest
    pytest-cov
  ];

  checkPhase = ''
    pytest
  '';

  passthru.tests = { inherit (nixosTests) isso; };

  meta = with lib; {
    description = "A commenting server similar to Disqus";
    homepage = "https://posativ.org/isso/";
    license = licenses.mit;
    maintainers = with maintainers; [ fgaz ];
  };
}
