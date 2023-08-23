version: pkgs: static: {
  distcc = pkgs.dockerTools.pullImage {
    imageName = "ksmanis/gentoo-distcc";
    imageDigest = "sha256:ade67de7720fd5c7a0af3c8964c3a07d5c58be3a1f0c56b534fcda4c731bf42a";
    finalImageName = "distcc";
    finalImageTag = version;
    sha256 = "sha256-9itzT/Wqwb4d4gTh1CGkjIbtgxWysS1cU3AwBRhiQ5k=";
  
    arch = "amd64";
  };

  dnsmasq = import ./dnsmasq.nix {
    inherit version pkgs static;

    dnsEntries."atalii.intranet" = "10.13.12.1";
    dnsEntries."distcc.atalii.intranet" = "10.13.12.3";
    dnsEntries."searx.atalii.intranet" = "10.13.12.4";
    dnsEntries."kanboard.atalii.intranet" = "10.13.12.5";
  };

  searx = pkgs.dockerTools.pullImage {
    imageName = "searxng/searxng";
    imageDigest = "sha256:c21036863f019df6e5cc7210cca6e89c956d16b380616448f2cd9a8f70f29bb7";
    finalImageName = "searx";
    finalImageTag = version;
    sha256 = "sha256-vKxELY5CEQo7IHuaeuH5Upf5wCgr23tcr3hwIjMZzWk=";
  };
}
