
/**
 * libntsc
 * CGA NTSC
 * (C) 2010 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Implements a CGA NTSC emulation.
 */

#ifndef _NTSC_CGA_H
#define _NTSC_CGA_H

// Modifiable parameters:
#define NTSC_CGA_FILTER_N	17
#define NTSC_CGA_CHEBYSHEV_SIDELOBE_DB	50.0

// Do not modify these defines:
#define NTSC_CGA_RGBITOSAMPLEBITNUM	16
#define NTSC_CGA_RGBITOSAMPLESIZE	(1 << NTSC_CGA_RGBITOSAMPLEBITNUM)

#define NTSC_CGA_INPUTBITNUM	8
#define NTSC_CGA_INPUTSIZE		(1 << NTSC_CGA_INPUTBITNUM)
#define NTSC_CGA_INPUTSAMPLENUM	4

#define NTSC_CGA_OUTPUTSIZE		24
#define NTSC_CGA_OFFSETGAIN		(1.0 * NTSC_CGA_INPUTSAMPLENUM / \
								NTSC_CGA_OUTPUTSIZE)

#define NTSC_CGA_INPUTBLACK	0

typedef int NTSCCGA[NTSC_CGA_INPUTSIZE][NTSC_CGA_OUTPUTSIZE];

void ntscCGAInit(NTSCCGA convolutionTable,
				NTSCConfiguration *config);
void ntscCGABlit(NTSCCGA convolutionTable,
				 unsigned char *input, int width, int height,
				 int *output, int outputPitch, int doubleScanlines);

#endif
