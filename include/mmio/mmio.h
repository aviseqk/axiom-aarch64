#ifndef AXIOM_MMIO_H
#define AXIOM_MMIO_H

#include <stdint.h>

// TODO: query and find about the synchronization and memory barriers putting for mmio-mapped address as that's an unaddressed issue

// performing a 32-bit volatile access to this memory-mapped address
static inline uint32_t mmio_read32(uintptr_t addr)
{
	return *(volatile uint32_t *)addr;
}

static inline void mmio_write32(uintptr_t addr, uint32_t value)
{
	*(volatile uint32_t *)addr = value;
}


#endif
