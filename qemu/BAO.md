# BAO

> Bao (from Mandarin Chinese “bǎohù”, meaning “to protect”) is a lightweight, open-source embedded hypervisor which aims at providing strong isolation and real-time guarantees. Bao provides a minimal, from-scratch implementation of the partitioning hypervisor architecture.[[1]](#1)

## Background Concepts

### Mixed-Criticality Systems

Systems that interact with the environment and that incorporates a number of subsystems running in different criticality levels.

Main Requirements:

- Consolidation
- Performance
  - incorporate different subsystems with minimum performance penalty possible
- Safety/Real-time
  - guarantee that non-critical subsystems interfere with critical subsystems, and that subsystems will not interfere between themselves
- Security
- Certification

### Virtualization

Technology that allows to run multiple independent software stacks on top of the same hardware.

By its definition, it is a obvious solution to the mixed-criticality systems. It already gives system encapsulation where systems should not interfere with each other.

Examples of virtualization are hypervisors:
- "Traditional" Hypervisor
  - fully featured
  - large code base
  - High-overhead I/O
  - **KVM**
- Embedded Hypervisor
  - Generic
  - Soft read-time
  - intermediate code base
  - **XVisor**
- Microkernel Hypervisor
  - Secure by design
  - Performance issues
  - **seL4**
- **Static Partitioning Hypervisor**
  - Small code base
  - Strong isolation and real-time
  - Inefficient resource management
  - **Bao**

### Static Partitioning Hypervisor

No resource sharing. All resources are allocated in build or initialization time.

1:1 virtual-to-physical CPU mapping.

No CPU sharing.

Devices are passthrough, which means once the hypervisor allocated the device to a guest, the guest will take "ownership" of the device and communicate directly. No device is emulated.  No virtual devices.

Exception are the * hardware interrupts*.

Reliance on HW virtualization support.

## The Bao Hypervisor

The Bao hypervisor is a static partitioning hypervisor.

Type:
- Type 1: bare-metal

Support:
- MMU
- MPU

Static Partitioning:
- 1:1 vCPU to physical CPU
- Static memory assignment
- Device pass through
- HW interrupts

Inter VM communication:
- Shared memory
- Notifications

Bao depends on HW assisted:
- 2nd stage translation
  - Guest OS translates virtual address to guest virtual address. Bao hypervisor translates the guest virtual address to physical address.
- Relies on the IOMMU to isolate devices, due to DMA capabilities.

Super pages:
- Reduced TLB pressure

Cache Coloring:
- Avoid interference on LLC
- Guests and hypervisor

## Setup
 
TODO

## References

<span id="1">[[1] Bao Project](http://bao-project.org/)</span>

<span id="2">[[2] Arm Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)</span>