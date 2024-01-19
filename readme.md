![👁️](https://views.whatilearened.today/views/github/seyhajin/llvm-ir-zig.svg)

# LLVM IR module in Zig

A minimal example to create and execute a LLVM IR module in Zig.

## Install

First of all, you need to install [LLVM](https://llvm.org/) and [Zig](ziglang.org) according to your system.

### Windows

#### with [Scoop](https://scoop.sh/)

```batch
scoop install llvm zig
```

> [!WARNING]
> untested

#### with [Chocolatey](https://chocolatey.org/)

```batch
choco install llvm zig
```

> [!WARNING]
> untested

### Linux

```batch
apt-get install llvm zig
```

> [!WARNING]
> untested

### MacOS

#### with [Homebrew](https://brew.sh/)

```bash
brew install llvm zig
```

> [!TIP]
> Tested successfully with LLVM 17.0.6 and Zig 0.11+.

## Clone

```bash
git clone https://github.com/seyhajin/llvm-ir-zig
```

Alternatively, download [zip](https://github.com/seyhajin/llvm-ir-zig/archive/refs/heads/master.zip) from Github repository and extract wherever you want.

## Build & Run

> [!NOTE]
> For simplicity, the program uses LLVM's dynamic libraries installed in your environment.

Build and run program :

```bash
zig build run
```

**Output:**

```
Hello, world!
sum(2, 3)=5
```

## LLVM IR Module

LLVM IR module equivalent of:
```C
int sum(int a, int b) {
    return a + b;    
}

void main() {
    printf("Hello, world!\nsum(2, 3)=%d\n", sum(2, 3));
}
```
