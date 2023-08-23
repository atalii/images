{ version, pkgs, static, dnsEntries ? [] }:

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
}
