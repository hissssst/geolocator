with import <nixpkgs> { };
let
  packages = beam.packagesWith beam.interpreters.erlang;
in
packages.mixRelease {
  elixir = beam.packages.erlangR24.elixir_1_13;
  pname = "geolocator";
  version = "0.0.0";
  
  src = ./.; #FIXME once uploaded to repository, change the source

  mixNixDeps = with pkgs; import ./mix.nix { inherit lib beamPackages; };
  postBuild = ''
    # for external task you need a workaround for the no deps check flag
    # https://github.com/phoenixframework/phoenix/issues/2690
    mix do deps.loadpaths --no-deps-check, phx.digest
    mix phx.digest --no-deps-check
  '';
}
