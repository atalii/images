{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-23.05";

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        static = pkgs.pkgsStatic;

	version = "23071600";

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

	    echo 'address=/atalii.intranet/10.13.12.1' >> /etc/dnsmasq.conf
	  '';

	  config = {
	    Cmd = [ "/bin/dnsmasq" "--keep-in-foreground" ];
	    Expose = [ 53 ];
	  };
	};

	distcc = pkgs.dockerTools.pullImage {
	  imageName = "ksmanis/gentoo-distcc";
	  imageDigest = "sha256:ade67de7720fd5c7a0af3c8964c3a07d5c58be3a1f0c56b534fcda4c731bf42a";
	  finalImageName = "distcc";
	  finalImageTag = version;
	  sha256 = "sha256-Sa2mX1rGhn+Zqk9kD1gHdgibEUHaMgFLd0uW5Bx9C1E=";

	  arch = "amd64";
	};
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ docker dive ];
	};

        packages = {
	  inherit dnsmasq;
	  inherit distcc;

	  default = pkgs.stdenv.mkDerivation {
	    inherit version;
	    name = "atalii-images";
            phases = "installPhase";
          
            installPhase = ''
              mkdir -p $out
	      cp ${dnsmasq} $out/dnsmasq
	      cp ${distcc} $out/distcc
	    '';
	  };
	};
      });
}
