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

---

## Hardware
## Operating System
## *User Applications*

---

## The operating system
## allows programs to share hardware

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

---

## Known Tools

^ No SSH

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

^ Xen is a popular hypervisor, used by EC2, Linode, Rackspace.
  Lets you cross-compile unmodified Go programs, just like for Linux and Windows.

---

## Amazon EC2
## Linode
## Rackspace
## IBM SoftLayer

---

# Porting the runtime

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

# `time_atman.go`

```go
func _nanotime() (ns int64) {
	systemstack(func() { ns = shadowTimeInfo.nanotime() })
	return ns
}

func (t *timeInfo) nanotime() int64 {
	t.checkSystemTime()
	return int64(t.SystemNsec) + t.nsSinceSystem()
}
```

^ If we follow these calls down

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

# [fit] `nanotime() int64`

---

```go
//go:nosplit
func nanotime() int64 {
	var ns int64

	systemstack(func() {
		ns = shadowTimeInfo.nanotime()
	})

	return ns
}
```

---

```go
func (t *timeInfo) nanotime() int64 {
	t.checkSystemTime()

	return int64(t.SystemNsec) + t.nsSinceSystem()
}
```

---

```go
func (t *timeInfo) checkSystemTime() {
	src := &_atman_shared_info.VCPUInfo[0].Time

	for t.needsUpdate(&t.SystemVersion, &src.Version) {
		t.SystemVersion = src.Version

		lfence()
		t.SystemNsec = src.SystemNsec
		t.TSC = src.TSC
		t.TSCMul = src.TSCMul
		t.TSCShift = src.TSCShift
		lfence()
	}
}
```

---

# [fit] 2k lines of Go

---

# [fit] 200 lines of assembly

---

## [fit] `atman build -o kernel ./hello`

---

# `file kernel`

```
kernel: ELF 64-bit LSB executable,
        x86-64,
        version 1 (SYSV),
        statically linked,
        not stripped
```

---

# `readelf --sections kernel`

```
  ...
  [12] .note.Xen.loader  NOTE             0000000000400fb0  00000fb0
       0000000000000018  0000000000000000   A       0     0     4
  [13] .note.Xen.version NOTE             0000000000400f98  00000f98
       0000000000000018  0000000000000000   A       0     0     4
  [14] .note.Xen.hyperca NOTE             0000000000400f80  00000f80
       0000000000000018  0000000000000000   A       0     0     4
  ...
```

---

# `xl create --console config.xl`

```
Atman OS
     ptr_size:  8
   start_info:  0x5bd000
    ...
    first_pfn:  0
nr_p2m_frames:  0

Hello, world
The current time is 2016-04-26 03:03:08.78049478 +0000 UTC
```

---

# Kernel size: 2.2MB

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

---

# TCP/IP stack

^ The largest subsystem in Atman, and the first which can live
  almost entirely outside of the runtime.

---

# `net`

---

# Filesystems?
