{ config, pkgs, ... }:
{

    sops.secrets."gpg/private_key" = {
        mode = "0600";
    };

    programs.gpg = {
        enable = true;
        settings = {
            default-key = "A4BEC917B5CA5246";
        };
    };

    programs.password-store = {
        enable = true;
        settings = {
            PASSWORD_STORE_DIR = "/home/jb/.password-store";
            PASSWORD_STORE_KEY = "A4BEC917B5CA5246";
        };
    };

    home.activation.importGpgKey = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        if [ -f ${config.sops.secrets."gpg/private_key".path} ]; then
            $DRY_RUN_CMD ${pkgs.gnupg}/bin/gpg --import \
                ${config.sops.secrets."gpg/private_key".path} || true
        fi
    '';

}
