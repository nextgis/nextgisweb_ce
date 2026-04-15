develop:
    #!/bin/bash -ex
    [[ -d .venv ]] || uv venv .venv
    git submodule update --init --recursive crater
    VIRTUAL_ENV=.venv uv pip install --editable ./crater

update:
    #!/bin/bash -ex
    git submodule update --init --remote
    git submodule foreach git submodule update

prepare:
    #!/bin/bash -ex
    .venv/bin/crater -c crater.yaml

build:
    #!/bin/bash -ex
    git submodule init package/*
    rm -rf build/package/*
    for p in package/*; do
        dst=$(realpath -m "build/$p")
        git -C "$p" ls-files -z | rsync -a --from0 --files-from=- "$p" "$dst"/
        git -C "$p" submodule foreach --recursive '
            set -ex
            sub="'"$dst"'"/"$displaypath";
            git ls-files -z | rsync -a --from0 --files-from=- . "$sub"/
        '
    done
    docker buildx bake --file docker-bake.hcl
