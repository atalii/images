{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-23.05";

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        static = pkgs.pkgsStatic;

	version = "23061100";

	resolvConf = import ./resolv.conf { inherit pkgs version; };

        dnsmasq = pkgs.dockerTools.buildImage {
          name = "dnsmasq";
	  tag = version;

	  copyToRoot = [ resolvConf static.dnsmasq ];  

	  runAsRoot = ''
	    $!${pkgs.runtimeShell}
	    ${pkgs.dockerTools.shadowSetup}

	    groupadd -r nogroup
	    useradd -r -g nogroup nobody
	    mkdir -p /var/run
	  '';

	  config = {
	    Cmd = [ "/bin/dnsmasq" "--keep-in-foreground" ];
	    Expose = [ 53 ];
	  };
	};
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ docker dive ];
	};

        packages = {
	  inherit dnsmasq;

	  default = pkgs.stdenv.mkDerivation {
	    inherit version;
	    name = "atalii-images";
            phases = "installPhase";
          
            installPhase = ''
              mkdir -p $out
	      cp ${dnsmasq} $out/dnsmasq
	    '';
	  };
	};
      });
}
