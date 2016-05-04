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

## **Without the Operating System**?

---

# [fit] Conventional
# [fit] deployment

---

## *Hardware*

---

## Hardware
## *Operating System*

---

## Hardware
## Operating System
## *User Applications*

---

# [fit] Cloud
# [fit] deployment

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

## Operating systems allow programs to share hardware

---

## Hypervisors allow operating systems to share hardware

---

## Hardware
## Hypervisor
## *User Applications*

---

## Other concerns

### *Boot time*
### *Security*
### *Footprint*
### *Optimization*

---

# Atman*OS*

---

# Go ported to run on Xen

---

# `runtime`
# as a kernel

---

# [fit] <2k lines of Go

---

# [fit] <200 lines of assembly

---

# What's in a port?

---

# Memory Management

```go
func sysAlloc(
  n uintptr, sysStat *uint64) unsafe.Pointer

func sysMap(
  v unsafe.Pointer, n uintptr, reserved bool, sysStat *uint64)

func sysFree(
  v unsafe.Pointer, n uintptr, sysStat *uint64) {}
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

# [fit] Function calls
# [fit] not system calls

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

---

### Memory Manager
### Process Scheduler
### Locks
### Device Drivers

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

# TCP/IP stack

---

# `net`

---

# Filesystem?
