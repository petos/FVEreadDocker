
# Docker image for FVEread

This repository is an attempt to build [petos/FVEread](https://github.com/petos/FVEread).

## Build instructions

The easiest way to build this docker container is to use `make` command:

```bash
make build
```

It'll run the Docker tooling (you need to have `docker buildx` installed).

## Debugging

If you want to debug the container (and it's needed right now, as all is in very alpha stage),
`make` is your friend too:

```bash
make debug
```

