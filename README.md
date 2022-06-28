# Geolocator

> Proudly developed and dockerised using Nix

Project for working with Geolocation data in a form of REST API. Service can import data in form of CSV files or plain RESTful JSON requests. Access `/api/v1/location` to try it out.

## Usage

You can use it in production in a different forms. Deploy it as a Nix package, or run it as a docker container. Both package and container are stripped to have minimum possible size. Container uses `busybox` coreutils set (which is required for releases). So

* To build docker image: `nix build -f docker.nix`
* To build package: `nix build -f default.nix`

To run it, you'll need an instance of a PostGIS database. Please provide `DATABASE_URL` variable containing url to the PostGIS instance and `SECRET_KEY_BASE` and `RELEASE_COOKIE` variables with secrets.

## Development

Enter development shell: `nix-shell`, then run the project the way you'd usually run it `iex -S mix phx.server` and access it on port `4000`.

## Deployment notice

Sorry, I couldn't deploy this service to any free cloud provider, because I couldn't find a free one with postgis instance. However, using postgis is vital, because this whole project is about geographical data.
