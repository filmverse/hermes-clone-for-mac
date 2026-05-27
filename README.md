# hermes-clone-for-mac

Folder-isolated build of [Hermes](https://github.com/facebook/hermes) — Meta's
JavaScript engine — pinned to the tag that ships with **React Native 0.85.3**
(`hermes-v250829098.0.10`). One script, no `sudo`, no system-wide install,
nothing installed outside this folder.

When you're done, `rm -rf hermes-clone-for-mac` and every trace of Hermes is
gone.

## Prerequisites

- macOS (Apple Silicon or Intel)
- [Xcode Command Line Tools](https://developer.apple.com/xcode/) — install with
  `xcode-select --install` if you don't have them
- [Homebrew](https://brew.sh) — only needed if `cmake` is missing; the script
  installs `cmake` for you
- `git`

## Install

```sh
git clone <this-repo-url> hermes-clone-for-mac
cd hermes-clone-for-mac
./install.sh
```

The first build takes roughly **15–30 minutes** depending on your CPU. The
script is idempotent — safe to re-run; it skips the clone if Hermes is already
checked out and only re-builds what changed.

What `install.sh` does:

1. Installs `cmake` via Homebrew if missing.
2. Clones Hermes into `./hermes/`.
3. Checks out the RN 0.85.3 tag (`hermes-v250829098.0.10`).
4. Configures CMake (`Release`, native arch from `uname -m`).
5. Builds with all available CPU cores.
6. Runs a smoke test (`hermes -e "print('hello from hermes')"`).
7. Prints the version and the upstream commit hash.

Binaries land in `./hermes/build/bin/`:

- `hermes` — the JS interpreter / runtime
- `hermesc` — the bytecode compiler (`.js` → `.hbc`)
- `hbcdump` — dump and inspect compiled `.hbc` bytecode

## Use

Two options, pick whichever you prefer.

### Option A — `source env.sh` once per shell

```sh
source env.sh
hermes -e "print('hi')"
hermesc demo.js -emit-binary -out demo.hbc
hbcdump demo.hbc
```

`env.sh` only modifies `PATH` for the current shell session — it does not
touch your `.zshrc`, `.bashrc`, or any other config file.

### Option B — call binaries by path

```sh
./hermes/build/bin/hermes -e "print('hi')"
```

No shell setup, but more typing.

## Compile + run roundtrip

The canonical Hermes workflow is compile-then-run:

```sh
echo "print('compiled bytecode works');" > demo.js
./hermes/build/bin/hermesc demo.js -emit-binary -out demo.hbc
./hermes/build/bin/hermes demo.hbc
```

## Verify the install

```sh
./hermes/build/bin/hermes --version
./hermes/build/bin/hermes -e "print(1 + 1)"     # -> 2
git -C hermes rev-parse HEAD                    # upstream commit pinned by tag
```

## Re-run / update

Just re-run `./install.sh`. CMake's incremental build skips work that's already
done. To move to a different Hermes tag, edit `HERMES_TAG` at the top of
`install.sh` and re-run.

## Uninstall

```sh
rm -rf hermes-clone-for-mac
```

Nothing leaks outside this folder. Homebrew's `cmake` (if the script installed
it for you) stays — remove it with `brew uninstall cmake` if you want.

## What this is NOT

- Not a system-wide install. No files are placed in `/opt`, `/usr/local/bin`,
  or anywhere outside this folder.
- Not a fork of Hermes. The upstream source is cloned fresh on your machine and
  is **not** checked into this repo (see `.gitignore`).
- Not a replacement for the Hermes that ships inside a React Native app — it's
  the same engine, but built as standalone CLI tools you can experiment with.

## Version pinned

| Tag | RN release | Upstream |
|---|---|---|
| `hermes-v250829098.0.10` | React Native 0.85.3 | https://github.com/facebook/hermes |

To confirm the exact upstream commit on your machine after install:

```sh
git -C hermes rev-parse HEAD
```
