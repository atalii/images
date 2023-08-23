{ pkgs, version }:

pkgs.stdenv.mkDerivation {
  inherit version;
  name = "resolv.conf";
  src = ./.;

  phases = "installPhase";

  installPhase = ''
    mkdir -p $out/etc
    cp $src/resolv.conf $out/etc
  '';
}
