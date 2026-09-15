{...}: {
  flake.nixosModules.forgejo = {pkgs, ...}: {
    services.forgejo = {
      enable = true;

      database = {
        type = "postgres";
        createDatabase = true;
      };

      settings = {
        server = {
          DOMAIN = "git.lazarus";
          # Bind all interfaces: reachable on LAN and via the tailnet.
          HTTP_ADDR = "0.0.0.0";
          # Port 3003 — adguard-home owns 3000.
          HTTP_PORT = 3003;
          # Adjust once you have a name/IP that resolves for clients.
          ROOT_URL = "http://lazarus:3003/";

          # Git over SSH reuses the system sshd via authorized_keys.
          SSH_DOMAIN = "git.lazarus";
          START_SSH_SERVER = false;
          DISABLE_SSH = false;
        };

        service = {
          DISABLE_REGISTRATION = true;
          REQUIRE_SIGNIN_VIEW = true;
        };

        session.COOKIE_SECURE = false;

        mailer.ENABLED = false;

        other.SHOW_FOOTER_VERSION = true;
      };
    };

    environment.systemPackages = [
      pkgs.forgejo
    ];

    services.openssh.enable = true;

    networking.firewall.allowedTCPPorts = [
      3003 # forgejo web
    ];
  };
}
