{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-23.05";

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
	version = "23072100";
        pkgs = nixpkgs.legacyPackages.${system};
        static = pkgs.pkgsStatic;

	images = (import ./images.nix) version pkgs static;
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ docker dive ];
	};

        packages = images // {
	  default = pkgs.stdenv.mkDerivation {
	    inherit version;
	    name = "atalii-images";
            phases = "installPhase";
          
            installPhase = ''
              mkdir -p $out
	      cp ${images.dnsmasq} $out/dnsmasq
	      cp ${images.distcc} $out/distcc
	      cp ${images.searx} $out/searx
	    '';
	  };
	};
      });
}
