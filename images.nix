version: pkgs: static: {
  distcc = pkgs.dockerTools.pullImage {
    imageName = "ksmanis/gentoo-distcc";
    imageDigest = "sha256:ade67de7720fd5c7a0af3c8964c3a07d5c58be3a1f0c56b534fcda4c731bf42a";
    finalImageName = "distcc";
    finalImageTag = version;
    sha256 = "sha256-Sa2mX1rGhn+Zqk9kD1gHdgibEUHaMgFLd0uW5Bx9C1E=";
  
    arch = "amd64";
  };

  dnsmasq =
    let
      resolvConf = import ./resolv.conf { inherit pkgs version; };
    in pkgs.dockerTools.buildImage {
      name = "dnsmasq";
      tag = version;

      copyToRoot = [ resolvConf static.dnsmasq ];

      runAsRoot = ''
        #!${pkgs.runtimeShell}
	${pkgs.dockerTools.shadowSetup}

	groupadd -r nogroup
	useradd -r -g nogroup nobody
	mkdir -p /var/run

	echo 'address=/atalii.intranet/10.13.12.1' >> /etc/dnsmasq.conf
	echo 'address=/distcc.atalii.intranet/10.13.12.3' >> /etc/dnsmasq.conf
      '';

      config = {
        Cmd = [ "/bin/dnsmasq" "--keep-in-foreground" ];
	Expose = [ 53 ];
      };
    };
}
