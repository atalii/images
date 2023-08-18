version: pkgs: static: {
  distcc = pkgs.dockerTools.pullImage {
    imageName = "ksmanis/gentoo-distcc";
    imageDigest = "sha256:ade67de7720fd5c7a0af3c8964c3a07d5c58be3a1f0c56b534fcda4c731bf42a";
    finalImageName = "distcc";
    finalImageTag = version;
    sha256 = "sha256-D1oGSsCTFXLgi5Z0j3UySv/aYma01g4JFqAi4GRLSjo=";
  
    arch = "amd64";
  };

  dnsmasq =
    let
      resolvConf = import ./resolv.conf { inherit pkgs version; };
      dnsmasq = static.dnsmasq.override { dbusSupport = false; };
    in pkgs.dockerTools.buildImage {
      name = "dnsmasq";
      tag = version;

      copyToRoot = [ resolvConf dnsmasq ];

      runAsRoot = ''
        #!${pkgs.runtimeShell}
	${pkgs.dockerTools.shadowSetup}

	groupadd -r nogroup
	useradd -r -g nogroup nobody
	mkdir -p /var/run

	echo 'address=/atalii.intranet/10.13.12.1' >> /etc/dnsmasq.conf
	echo 'address=/distcc.atalii.intranet/10.13.12.3' >> /etc/dnsmasq.conf
	echo 'address=/searx.atalii.intranet/10.13.12.4' >> /etc/dnsmasq.conf
	echo 'address=/kanboard.atalii.intranet/10.13.12.5' >> /etc/dnsmasq.conf
      '';

      config = {
        Cmd = [ "/bin/dnsmasq" "--keep-in-foreground" ];
	Expose = [ 53 ];
      };
    };

  searx = pkgs.dockerTools.pullImage {
    imageName = "searxng/searxng";
    imageDigest = "sha256:c21036863f019df6e5cc7210cca6e89c956d16b380616448f2cd9a8f70f29bb7";
    finalImageName = "searx";
    finalImageTag = version;
    sha256 = "sha256-1Mbo7K+W8NoycoURPaZcxpXV54d3yjAaHoqcIpinhJU=";
  };
}
