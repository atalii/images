{ version, pkgs, static, dnsEntries }:

let
  resolvConf = import ./resolv.conf { inherit pkgs version; };
  dnsmasq = static.dnsmasq.override { dbusSupport = false; };

  addDnsEntryCmds = builtins.concatStringsSep "\n"
    (map
      (name:
        "echo 'address=/${name}/${dnsEntries.${name}}' >> /etc/dnsmasq.conf")
      (builtins.attrNames dnsEntries));

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
  '' + addDnsEntryCmds;

  config = {
    Cmd = [ "/bin/dnsmasq" "--keep-in-foreground" ];
    Expose = [ 53 ];
  };
}
