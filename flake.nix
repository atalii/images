{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-23.05";

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
	version = "23092600";
        pkgs = nixpkgs.legacyPackages.${system};
        static = pkgs.pkgsStatic;

	images = (import ./images) version pkgs static;
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
	    '' + (builtins.concatStringsSep
	      "\n" (map
	        (name: "cp ${images."${name}"} $out/${name}")
	        (builtins.attrNames images)));
	  };
	};
      });
}
