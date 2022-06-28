{ pkgs ? import <nixpkgs> { system = "x86_64-linux";}}:
pkgs.dockerTools.buildLayeredImage {
  name = "geolocator";
  tag = "latest";

  contents = [
    (import ./default.nix)
    pkgs.busybox
  ];

  config = {
    Cmd = [ "/bin/default_release start" ];
    WorkingDir = "/";
    # ## Don't forget to specify this env in runtime
    Env = [
      "RELEASE_COOKIE=Wou4Fah3oocuquo3dumaikahwee4oc"
      "SECRET_KEY_BASE=SoAebJqZm7KQw9elfucjxorGFP55crKGEFlLq4dAKCWHEKjhzJ7AoXPKO2Df1Dhn"
      "DATABASE_URL=postgresql://postgres:postgres@localhost:5432/db"
    ];
  };
}
