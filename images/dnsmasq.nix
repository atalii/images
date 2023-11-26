{ version, pkgs, static, dnsEntries, blocklist }:

let
  resolvConf = import ./resolv.conf { inherit pkgs version; };
  dnsmasq = static.dnsmasq.override { dbusSupport = false; };

  block = domains:
    let eachBlock = map (domain: {
      "${domain}" = "0.0.0.0";
      "www.${domain}" = "0.0.0.0";
    }) domains; in builtins.foldl' (x: y: x // y) {} eachBlock;

  allRecords = dnsEntries // (block blocklist);

  addDnsEntryCmds = builtins.concatStringsSep "\n"
    (map
      (name:
        "echo 'address=/${name}/${allRecords.${name}}' >> /etc/dnsmasq.conf")
      (builtins.attrNames allRecords));

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
