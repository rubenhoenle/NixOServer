{ pkgs, ... }:
let
  icons = {
    tandoor = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/NX211/homer-icons/master/png/tandoorrecipes.png";
      sha256 = "0f7lr0pppxvbh72c9y034acrv8d62wsbif1yzwadalngisqmp4n4";
    };
    paperless = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/NX211/homer-icons/master/png/paperless-ng.png";
      sha256 = "19dnqpmypf1fb4a20xgr3x7wd6bcir4rclrpcjgls5m0dsm5d1gx";
    };
    hedgedoc = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/NX211/homer-icons/c23d6413b03629d45f80fe8d493224bae38baf23/svg/hedgedoc.svg";
      sha256 = "0c1kn3f695szxn1abni0kbz3pdkgask3rfwg2y0rj2ghb195awfh";
    };
    nextcloud = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/NX211/homer-icons/master/png/nextcloud.png";
      sha256 = "1gqm8kldmbd60vigww3xyfy61zpn1w64v1rlk50167pk6184r444";
    };
    gatus = builtins.fetchurl {
      url = "https://github.com/TwiN/gatus/blob/714dd4ba099e05c941e706becfc06e2ad2fd9148/.github/assets/logo.png";
      sha256 = "0y0jl60arbx5gjr0c12sm7khfj3pr8yfd0d85azmylkr5q8214cv";
    };
  };

  # generate a homer config yaml file
  # as yaml is just a superset of json, we can just use json for this 
  configFile = pkgs.writeText "homer-config.yml" (builtins.toJSON {
    title = "Dashboard";
    subtitle = "Hönle";
    logo = "logo.png";

    header = true;
    footer = false;

    services = [
      {
        name = "Tools";
        icon = "fas fa-wrench";
        items = [
          {
            name = "Gatus";
            logo = "assets/icons/gatus.png";
            subtitle = "Health dashboard";
            keywords = "Health dashboard";
            url = "https://status.home.hoenle.xyz";
            target = "_blank";
          }
          {
            name = "Tandoor";
            logo = "assets/icons/tandoor.png";
            subtitle = "Recipe management";
            keywords = "Recipe management";
            url = "https://recipes.home.hoenle.xyz";
            target = "_blank";
          }
          {
            name = "Paperless";
            logo = "assets/icons/paperless.png";
            subtitle = "Document management";
            keywords = "Document management";
            url = "https://paperless.home.hoenle.xyz";
            target = "_blank";
          }
          {
            name = "Hedgedoc";
            logo = "assets/icons/hedgedoc.svg";
            subtitle = "Markdown pad";
            keywords = "Markdown pad";
            url = "https://pad.home.hoenle.xyz";
            target = "_blank";
          }
          {
            name = "Nextcloud";
            logo = "assets/icons/nextcloud.png";
            subtitle = "Private cloud suite";
            keywords = "Private cloud suite";
            url = "https://cloud.home.hoenle.xyz";
            target = "_blank";
          }
        ];
      }
    ];
  });
in
{
  virtualisation.oci-containers.containers = {
    homer = {
      image = "docker.io/b4bz/homer:latest";
      autoStart = true;
      volumes = [
        "${configFile}:/www/assets/config.yml"
        "${icons.tandoor}:/www/assets/icons/tandoor.png"
        "${icons.paperless}:/www/assets/icons/paperless.png"
        "${icons.hedgedoc}:/www/assets/icons/hedgedoc.svg"
        "${icons.nextcloud}:/www/assets/icons/nextcloud.png"
        "${icons.gatus}:/www/assets/icons/gatus.png"
      ];
      ports = [
        "127.0.0.1:7451:8080"
      ];
    };
  };
}
