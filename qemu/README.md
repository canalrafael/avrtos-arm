# QEMU

> QEMU is a generic and open source machine emulator and virtualizer.
>
> QEMU can be used in several different ways. The most common is for System Emulation, where it provides a virtual model of an entire machine (CPU, memory and emulated devices) to run a guest OS. In this mode the CPU may be fully emulated, or it may work with a hypervisor such as KVM, Xen or Hypervisor.Framework to allow the guest to run directly on the host CPU.[[1]](#1)

## Supported Host Platform

From the [documentation](https://www.qemu.org/docs/master/about/build-platforms.html):

|CPU Architecture|Accelerators|
|-|-|
|x86|hvf (64 bit only), kvm, nvmm, tcg, whpx (64 bit only), xen|

The host platform used in the project is primarily *x86*.

## Emulation

The TCG provides the ability to emulate many CPU architectures. From the [documentation](https://www.qemu.org/docs/master/about/emulation.html), we confirm that is support the *ARM aarch64*:

|Architecture (qemu name)|Notes|
|-|-|
|Arm (arm, aarch64)|Wide range of features, see A-profile CPU architecture support for details|

### Semihosting

TODO

### TCG Plugins

> QEMU TCG plugins provide a way for users to run experiments taking advantage of the total system control emulation can have over a guest. It provides a mechanism for plugins to subscribe to events during translation and execution and optionally callback into the plugin during these events. TCG plugins are unable to change the system state only monitor it passively. However they can do this down to an individual instruction granularity including potentially subscribing to all load and store operations.[[1]](#1)
>

### Other emulation features

> When running system emulation you can also enable deterministic execution which allows for repeatable record/replay debugging. See Record/Replay for more details.[[1]](#1)

## System Emulation

### Introduction

#### Virtualization Accelerators

From the [documentation](https://www.qemu.org/docs/master/system/introduction.html), a number of hypervisors (called accelerators through this document) are available. We listed only a few:

|Accelerator|Host OS|Host Architectures|
|-|-|-|
|KVM|Linux|Arm (64 bit only), MIPS, PPC, RISC-V, s390x, x86|
|Windows Hypervisor Platform (whpx)|Windows|x86|
|Tiny Code Generator (tcg)|Linux, other POSIX, Windows, MacOS|Arm, x86, Loongarch64, MIPS, PPC, s390x, Sparc64|

### Invocation

TODO

## Abbreviations
|Abbreviation|Extended Name|
|-|-|
|TCG|Tiny Code Generator|

## References

<span id="1">[[1] QEMU Documentation](https://www.qemu.org/docs/master/about/index.html)</span>