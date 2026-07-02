{ config, inputs, ... }:
{

    imports = [ inputs.sops-nix.homeManagerModules.sops ];

    sops.secrets."git/email" = { };
    sops.secrets."git/name" = { };
    
    programs.git = {
        enable = true;
        includes = [
            #{ path = "/run/user/1000/git-identity"; }
            { path = "${config.home.homeDirectory}/.config/git/identity"; }
        ];
        settings = {
            init.defaultBranch = "main";
            url."git@github.com".insteadOf = "https://github.com";
            core.sshCommand = "ssh";
        };
    };

    programs.ssh = {
        enable = true;
        settings = {
            "github.com" = {
                hostname = "github.com";
                user = "git";
                identityFile = "/home/jb/.ssh/github";
                identitiesOnly = true;
            };
        };
    };

    home.activation.writeGitIdentity = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.config/git"
        name_file="${config.sops.secrets."git/name".path}"
        email_file="${config.sops.secrets."git/email".path}"

        if [ -f "$name_file" ] && [ -f "$email_file" ]; then
            printf "[user]\n\tname = %s\n\temail = %s\n" \
                "$(cat $name_file)" \
                "$(cat $email_file)" \
                > "$HOME/.config/git/identity"
        fi
	'';
		# $DRY_RUN_CMD sh -c 'printf "[user]\n\tname = %s\n\temail = %s\n" \
		# 	"$(cat ${config.sops.secrets."git/name".path})" \
		# 	"$(cat ${config.sops.secrets."git/email".path})" \
		# 	> /run/user/1000/git-identity'

}
