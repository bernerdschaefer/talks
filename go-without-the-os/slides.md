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

## Build Go programs
## to run directly on Xen

---

## [fit] `atman build ./hello`

---

# AtmanOS is Go<br>ported to Xen

---

# [fit] <2k lines of Go

---

# [fit] <200 lines of assembly

---

### Memory Management
### Locking Primitives
### Process Scheduling
### Events
### Device Drivers

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
