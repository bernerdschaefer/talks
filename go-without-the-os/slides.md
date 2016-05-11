# [fit] Go
# [fit] **without the OS**

---

# [fit] Hi, I'm Bernerd
## @bjschaefer

---

# [fit] I help companies
# [fit] build products users love
# [fit] ![inline](thoughtbot.png)

---

# [fit] Go
# [fit] **without the OS**

^ We're all at the Go meetup, so we know why we're talking about "Go".
  But why are we talking about OSes?

---

## **Without the Operating System**?

^ Operating systems do many useful things.
  Understand in context.

---

# [fit] Conventional
# [fit] deployment

---

## *Hardware*

^ Server in a closet or datacenter

---

## Hardware
## *Operating System*

^ Interfaces with the Hardware
  Drivers...
  Userspace

---

## Hardware
## Operating System
## *User Applications*

^ Where what you're paid for runs

---

## The operating system
## allows programs to share hardware

^ Safe, hopefully transparent
  How many people deploy this way?

---

# [fit] The Cloud

---

## *Hardware*

---

## Hardware
## *Hypervisor*

---

## Hardware
## Hypervisor
## *Operating Systems*

---

## Hardware
## Hypervisor
## Operating Systems
## *User Applications*

---

## Hypervisors allow operating systems to share hardware

^ In the cloud, OSs allow user programs to share shared/virtual hardware

---

## What if we remove the OS?

---

## Hardware
## Hypervisor
## *User Applications*

^ This actually looks a lot like the conventional deployment.

---

## What do we give up?

---

## [fit] A Lot

---

## General Purpose Computing Environment

^ POSIX, shell scripting...

---

## Known Tools

^ No SSH
  The flip side...

---

## 500+ packages
## 100,000,000+ lines of code

---

## Linux Kernel
## 15,000,000+ lines of code

^ There's a lot going on, much of it irrelevant:
  Don't need the drivers for unused hardware
  Don't need the software from user applications

---

## Other concerns

### *Boot time*
### *Security*
### *Footprint*
### *Optimization*

^ Hearbleed, Shellshock, ImageTragick...

---

## Hardware
## Hypervisor
## *User Applications*

^ Okay. You buy this. How can you do it? And do it in Go?

---

# Atman*OS*

---

# Port of Go
# for Xen

^ Lets you cross-compile unmodified Go programs, just like for Linux and Windows,
  to run direclty on Xen.

---

# Xen

^ Hypervisor

---

# Host OS
## (Linux or BSD)

^ Provides drivers and priveledged code

---

# Hypercalls

^ Exposes priveleged operations, like system calls

---

# Shared memory

^ Provides access to shared data, and drivers

---

## Amazon EC2
## Linode
## Rackspace
## IBM SoftLayer

---

# Porting Go

^ Go's runtime provides a number of hooks,
  in the form of stub methods,
  for porting the runtime to a new OS / arch.

---

# Memory Management

```go
func sysAlloc(
  n uintptr, sysStat *uint64) unsafe.Pointer

func sysMap(
  v unsafe.Pointer, n uintptr, reserved bool, sysStat *uint64)

func sysFree(
  v unsafe.Pointer, n uintptr, sysStat *uint64)
```

---

# Time

```go
func nanotime() int64

func time_now() (sec int64, nsec int32)
```

---

# Locking Primitives

```go
func semacreate() uintptr

func semasleep(ns int64) int32

func semawakeup(mp *m)
```

---

# Processes

```go
func newosproc(mp *m, stk unsafe.Pointer)

func osyield()
```

---

# I/O

```go
func read(
  fd int32, buf unsafe.Pointer, n int32) int32

func write(
  fd uintptr, buf unsafe.Pointer, n int32) int64
```

---

# `sys_freebsd_amd64.s`

```x86asm
TEXT runtime·nanotime(SB), NOSPLIT, $32
	MOVL	$232, AX
	MOVQ	$4, DI		// CLOCK_MONOTONIC
	LEAQ	8(SP), SI
	SYSCALL
	MOVQ	8(SP), AX	// sec
	MOVQ	16(SP), DX	// nsec

	// sec is in AX, nsec in DX
	// return nsec in AX
	IMULQ	$1000000000, AX
	ADDQ	DX, AX
	MOVQ	AX, ret+0(FP)
	RET
```

^ In most ports, the hooks are Assembly and Go wrappers
  around syscalls.

---

# `mem_linux.go`

```go
func sysMap(v unsafe.Pointer, n uintptr, reserved bool, sysStat *uint64) {
	mSysStatInc(sysStat, n)

	p := mmap(v, n, _PROT_READ|_PROT_WRITE, _MAP_ANON|_MAP_FIXED|_MAP_PRIVATE, -1, 0)
	if uintptr(p) == _ENOMEM {
		throw("runtime: out of memory")
	}
	if p != v {
		throw("runtime: cannot map pages in arena address space")
	}
}
```

^ But Atman is different.

---

# `runtime`
# as a kernel

---

# Functions not system calls

---

### Memory Manager
### Time
### Locks
### Process Scheduler
### Device Drivers

^ It's like this for everything that it's responsible for

---

# Memory Management

```go
type atmanMemoryManager struct {}

func (*atmanMemoryManager) allocPages(v unsafe.Pointer, n uint64) unsafe.Pointer
func (*atmanMemoryManager) allocPage(page vaddr)
func (*atmanMemoryManager) clearPage(pfn pfn)
func (*atmanMemoryManager) physAllocPage() pfn
func (*atmanMemoryManager) reserveHeapPages(n uint64) unsafe.Pointer
func (*atmanMemoryManager) reservePFN() pfn
...
```

---

# [fit] CODE WALK

---

# [fit] 2k lines of Go

---

# [fit] 200 lines of assembly

---

# [fit] DEMO

---

# What's next?

---

# Deploy to EC2 and Linode

^ It turns out this is tricky, and difficult to test.
  I want to do this in a demo, but I couldn't get Amazon
  to recognize the disk image.
  It's also Linux only...
  Anyone have experience with pv-grub or building custom kernels for Amazon?

---

# Console input

^ Read console from userland via syscall package.
  Small change, but the will provide a model for blocking I/O

---

# `pprof`

^ We could profile app and OS together!

---

# TCP/IP stack
# and `net`

^ The largest subsystem in Atman, and the first which can live
  almost entirely outside of the runtime.
  Lots of room to explore Go-native approaches.

---

# Filesystems?

^ Maybe?

---

# Questions?

---

# Thanks!
