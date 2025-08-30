# Dynabox

*The Swiss Army knife for tackle glibc problems, compatibility without compromise.*

This project is built for hackers, researchers, and anyone who hates the words:

> “Works on my machine.”

*Dynabox* makes glibc portable, hackable, and disposable.

## Prerequisites

- **Docker** is required, but you don't have to know how to use it. No Docker, no party.
- (Optional but highly recommended) **Docker Buildx plugin** — it's modern, faster, and makes multi-arch builds less painful.
- I have only tested things with buildx plugin so... ~*I suggest you do the same xD*~

## What is Dynabox?

When you're debugging binaries on Linux, one of the biggest headaches is **glibc mismatch**:

- The target binary was built against a specific glibc version, but your host has something else.
- You want to debug locally, but without the tricky workarounds like setting up a debuginfod service, downloading shady pre-built VMs, or spending a weekend building one yourself.
- Symbols are missing, common structures are hard to locate, relocations break, or *ld-linux.so* just won't play nice.

**Dynabox (Dynamic Linking Toolbox)** solves these problems by giving you a ***portable, containerized glibc lab***.

Think of it as a *Swiss Army knife for glibc versions* — build, extract, and drop any glibc into your workflow without polluting your host.

## Features

- **Build arbitrary glibc versions**
  - One command, reproducible, containerized.
- **Export glibc to your host**
  - Copy straight out of the container into `/opt/glibc/<version>` for local use.
- **Proxy-aware builds**
  - Works even behind corporate firewalls (auto-detects your host IP).
- **Minimal final images**
  - Built from [scratch](https://hub.docker.com/_/scratch), no fat layers, only what you need.
- **Multi-architecture support**
  - Currently supports `x86_64-*-linux-gnu` and `i[4567]86-*-linux-gnu`.

## TODOs / Coming Soon

- **Patchelf integration**
  - Automatically patch binaries to run with your chosen glibc.
- **Compile with a specific glibc**
  - Build programs that mimic exactly the target libc version.
- **Source-level debugging**
  - Auto-switch to the right glibc source + debug symbols for deeper debugging.
- **Prebuilt images**
  - Popular glibc versions on Docker Hub, so you don't have to waste CPU cycles.
- **More architecture support**
  - Because the world is bigger than *x86*. *ARM*, *RISC-V*, *PowerPC*... they all deserve some love.
- **Flexible path customization**
  - Allow exporting and installing glibc under user-defined directories instead of the default `/opt/glibc/<version>`.

## Why Dynabox ?

Because sometimes you don't want the overhead of *QEMU*, *VMs*, or a full *chroot*. They come with extra learning curves, and honestly, sometimes you just want your tools to work *locally*.

Me ? I'm probably a perfectionist. Debugging inside a *VM* makes my skin crawl.

For example, let's build and export both *glibc 2.23* for *64-bit* and *32-bit* support:

```bash
./dynabox.sh build --version 2.23 --arch both
./dynabox.sh export --version 2.23 --arch both
```

Then patch your binary so it runs against the correct glibc:

```bash
patchelf --set-interpreter "/opt/glibc/2.23/64/lib/ld-linux-x86-64.so.2" \
         --set-rpath "/opt/glibc/2.23/64/lib" <binary>
```

... and boom you're running your binary with exactly the glibc it was meant for.

*Dynabox is about **control** — the kind of control hackers, reverse engineers, and low-level tinkerers crave.*

## Quick Start

```bash
# Build glibc 2.23 for x86_64
./dynabox.sh build --version 2.23 --arch x86_64

# Export it to host
./dynabox.sh export --version 2.23 --arch x86_64

# Use it with patchelf
patchelf --set-interpreter "/opt/glibc/2.23/64/ld-linux-x86-64.so.2" \
         --set-rpath "/opt/glibc/2.23/64/lib" ./binary
```

## FAQs

### Version 'GLIBC_2.34' not found

Drop the following script into a shell script and compile against your chosen glibc. Remember set the `GLIBC_VERSION` environment variable before running.

```bash
#!/usr/bin/env bash

SRC="$1"
OUT="$2"

if [[ -z "$SRC" || -z "$OUT" ]]; then
  echo "Usage: $0 source.c output_binary"
  exit 1
fi

GLIBC_PATH=$(realpath /opt/glibc/${GLIBC_VERSION}/64)

gcc -Wall "$SRC" -o "$OUT" \
  -B "$GLIBC_PATH/lib" \
  -Wl,--rpath="$GLIBC_PATH/lib" \
  -Wl,--dynamic-linker="$GLIBC_PATH/lib/ld-linux-x86-64.so.2"
```

A `compile` sub-command is coming soon to automate this step — but until then, you've got a script.

PRs are welcome if you'd like to help hack it in. *:evilface:*

### Source-Level Debugging

Want to go full hacker mode and debug with a ***glibc source code view*** like the following picture show ? Here's a quick guide.

<center>
  <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/574f8a51-d6d6-4bfb-8221-eab0852f16fc" />
</center>

Firstly, ensure you've exported the correspond glibc, then:

```bash
# Clone glibc repo
git clone https://github.com/bminor/glibc.git && cd glibc

# Checkout the version you are working with
git checkout glibc-<version>
```

Now, make sure you know the path to the glibc source code root. When debugging a binary in `gdb`:

```bash
# Set the source path for glibc
dir /path/to/glibc
```

From here, step into glibc functions, inspect variables, and enjoy source-level debugging.

Since I have no experience with other debuggers, if there's different, please let me know and PRs are always welcome.

## License

MIT. Do what you want, break what you must.
