{ pkgs, config, ... }:
{
    # Holds MC_HOSTNAME=<server> so the hostname stays out of the public repo
    sops.secrets.minecraft_tunnel_env = { };

    systemd.user.services.minecraft-cloudflared = {
        Unit = {
            Description = "Cloudflare Access tunnel for Minecraft";
            After       = [ "network-online.target" "sops-nix.service" ];
            Wants       = [ "network-online.target" "sops-nix.service" ];
        };

        Service = {
            EnvironmentFile = config.sops.secrets.minecraft_tunnel_env.path;
            ExecStart   = "${pkgs.cloudflared}/bin/cloudflared access tcp --hostname \${MC_HOSTNAME} --url 127.0.0.1:25565";
            Restart     = "always";
            RestartSec  = 5;
        };

        Install.WantedBy = [ "default.target" ];
    };
}
