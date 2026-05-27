# hermes-clone-for-mac

Folder-isolated build of [Hermes](https://github.com/facebook/hermes) — Meta's
JavaScript engine — pinned to the tag that ships with **React Native 0.85.3**
(`hermes-v250829098.0.10`).

- One script. ~15–30 min build.
- No `sudo`. No system-wide install. Nothing written outside this folder.
- Clean uninstall: `rm -rf hermes-clone-for-mac`.

---

## Prerequisites

- macOS (Apple Silicon or Intel)
- [Xcode Command Line Tools](https://developer.apple.com/xcode/) — `xcode-select --install`
- [Homebrew](https://brew.sh) — only needed if `cmake` is missing; the script installs `cmake` for you
- `git`

---

## Install

```sh
git clone <this-repo-url> hermes-clone-for-mac
cd hermes-clone-for-mac
./install.sh
```

What the script does:

1. Installs `cmake` via Homebrew if missing.
2. Clones Hermes into `./hermes/`.
3. Checks out the RN 0.85.3 tag.
4. Configures CMake (`Release`, native arch from `uname -m`).
5. Builds with all available CPU cores (first build ~15–30 min).
6. Runs a smoke test.
7. Prints the version and the upstream commit hash.

Safe to re-run — the clone is skipped if `./hermes/` already exists, and CMake's incremental build skips work it's already done.

---

## Quick start

After install, three lines and you're running JS through Hermes:

```sh
source ./env.sh
echo "print('hello');" > hello.js
hermes hello.js
```

`source env.sh` adds `hermes/build/bin/` to your `PATH` **for the current shell only**. It doesn't touch your `.zshrc` / `.bashrc`.

Prefer no shell setup? Call binaries by path instead: `./hermes/build/bin/hermes hello.js`.

---

## The three tools

The build produces three CLI binaries in `./hermes/build/bin/`:

| Tool | Purpose |
|---|---|
| `hermes` | Run JS source files or compiled bytecode |
| `hermesc` | Compile JS source to Hermes bytecode (`.hbc`) |
| `hbcdump` | **Interactive REPL** for inspecting compiled bytecode |

### `hermes` — running JavaScript

Run a `.js` file:

```sh
echo "print('Hello');" > hello.js
hermes hello.js
```

Inline one-liner via process substitution (bash/zsh):

```sh
hermes <(echo "print(1 + 1);")
```

Run compiled bytecode:

```sh
hermes hello.hbc
```

> **Note:** `hermes` takes a file argument. It does **not** have a Node-style
> `-e "code"` flag in this tag. Put your code in a file (or use `<(...)`).

See all flags: `hermes -help`.

### `hermesc` — compile JS to bytecode

The main performance feature of Hermes: precompile JS to `.hbc` so apps skip parsing at launch. This is what React Native does internally.

```sh
echo "print('compiled');" > demo.js
hermesc demo.js -emit-binary -out demo.hbc
hermes demo.hbc
```

Useful flags:

| Flag | Effect |
|---|---|
| `-O` | Full optimisation (used in RN release builds) |
| `-O0` | No optimisation (faster compile, debug-friendly) |
| `-g` | Emit source-location info for backtraces |
| `-output-source-map` | Emit `.hbc.map` alongside the binary |
| `-non-strict` | Allow sloppy-mode JS (strict is default) |
| `-commonjs` | Treat inputs as CommonJS modules |
| `-parse-ts` / `-parse-flow` / `-parse-jsx` | Enable extra syntax parsers |

See all flags: `hermesc -help`.

### `hbcdump` — inspect compiled bytecode

**`hbcdump file.hbc` drops you into a REPL** — it's interactive, not a one-shot dumper. If your terminal "hangs" after launching it, that's the prompt waiting for input.

```sh
$ hbcdump demo.hbc
hbcdump> help              # list commands
hbcdump> summary           # high-level stats
hbcdump> disassemble       # full bytecode disassembly
hbcdump> function 0        # disassemble function at index 0
hbcdump> string            # dump the string table
hbcdump> filename          # show source filename
hbcdump> quit
```

Run non-interactively by piping commands in:

```sh
printf "summary\nquit\n" | hbcdump demo.hbc
```

---

## Hermes vs Node.js

Hermes is a JavaScript **engine**, not a runtime like Node. Many Node APIs are not part of the engine:

| Feature | Available? |
|---|---|
| `print(...)` | Yes — writes to stdout, the idiomatic CLI primitive |
| `console.log(...)` | Yes — a minimal `console` is shipped |
| ES2015+ (arrow funcs, classes, `Map`, `Set`, `Promise`, async/await, generators) | Yes |
| Strict mode by default | Yes — use `-non-strict` to opt out |
| `require(...)` / file-path `import` | No — use `-commonjs` for bundles, otherwise concatenate |
| `fs`, `process`, `Buffer`, `os`, `path` | No — these are Node APIs, not engine APIs |
| Top-level filesystem / network access | No |

Use Hermes for: running JS without Node, producing `.hbc` for RN apps, engine experimentation (try `-dump-ast`, `-dump-ir`, `-dump-bytecode`), benchmarking with the same engine RN ships.

---

## Verify the install

```sh
hermes --version

echo "print(1 + 1);" > /tmp/check.js
hermes /tmp/check.js                    # -> 2

git -C hermes rev-parse HEAD            # upstream commit pinned by the tag
```

---

## Re-run / update

Re-run `./install.sh` any time — it's idempotent.

To move to a different Hermes version, edit `HERMES_TAG` at the top of `install.sh` and re-run. You can find available tags with:

```sh
git -C hermes tag --list 'hermes-v*' | tail -20
```

---

## Uninstall

```sh
rm -rf hermes-clone-for-mac
```

Nothing leaks outside this folder. Homebrew's `cmake` (if the script installed it for you) stays — remove it with `brew uninstall cmake` if you want.

---

## What this is NOT

- **Not a system-wide install.** No files in `/opt`, `/usr/local/bin`, or anywhere outside this folder.
- **Not a fork of Hermes.** The upstream source is cloned fresh on your machine and is not vendored in this repo (see `.gitignore`).
- **Not a Hermes replacement for a React Native app.** It's the same engine, but built as standalone CLI tools for experimentation, not as a library to link into an RN build.
- **Not a Node.js replacement.** No filesystem, no network, no Node stdlib — see the "Hermes vs Node.js" table above.

---

## Version pinned

| Tag | RN release | Upstream |
|---|---|---|
| `hermes-v250829098.0.10` | React Native 0.85.3 | https://github.com/facebook/hermes |

Confirm the exact upstream commit on your machine after install:

```sh
git -C hermes rev-parse HEAD
```
