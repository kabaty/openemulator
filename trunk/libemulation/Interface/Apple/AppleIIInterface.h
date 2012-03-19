
/**
 * libemulation
 * Apple II Interface
 * (C) 2010-2012 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Defines the Apple II interface
 */

#ifndef _APPLEIIINTERFACE_H
#define _APPLEIIINTERFACE_H

#include "CanvasInterface.h"

typedef enum
{
    APPLEII_VRAMMODE_TEXT1,
    APPLEII_VRAMMODE_TEXT2,
    APPLEII_VRAMMODE_HIRES1,
    APPLEII_VRAMMODE_HIRES2,
    APPLEII_VRAMMODE_MIXED1,
    APPLEII_VRAMMODE_MIXED2,
    APPLEII_VRAMMODE_SHIRES,
} AppleIIVRAMMode;

typedef struct
{
    OEUInt8 *textMain[2];
    OEUInt8 *hiresMain[2];
    OEUInt8 *textAux[2];
    OEUInt8 *hiresAux[2];
    OEUInt8 *hbl[2];
} AppleIIVRAM;

#define APPLEIIVIDEO_TEXT     (1 << 0)
#define APPLEIIVIDEO_PAGE2    (1 << 1)
#define APPLEIIVIDEO_MIXED    (1 << 2)
#define APPLEIIVIDEO_HIRES    (1 << 3)

#define APPLEIIMMU_ALTZP      (1 << 0)
#define APPLEIIMMU_RAMRD      (1 << 1)
#define APPLEIIMMU_RAMWRT     (1 << 2)
#define APPLEIIMMU_80STORE    (1 << 3)
#define APPLEIIMMU_PAGE2      (1 << 4)
#define APPLEIIMMU_HIRES      (1 << 5)
#define APPLEIIMMU_INTCXROM   (1 << 6)
#define APPLEIIMMU_SLOTC3ROM  (1 << 7)
#define APPLEIIMMU_LCBANK1    (1 << 8)
#define APPLEIIMMU_LCRAMRD    (1 << 9)
#define APPLEIIMMU_LCRAMWR    (1 << 10)

typedef enum
{
    APPLEII_SET_VRAMMODE,
    APPLEII_GET_VRAM,
    APPLEII_MAP_SLOTMEMORYMAPS,
    APPLEII_UNMAP_SLOTMEMORYMAPS,
    APPLEII_MAP_MEMORYMAPS,
    APPLEII_UNMAP_MEMORYMAPS,
    
    APPLEII_SET_AUXMEMORY,
    APPLEII_SET_MMUSOFTSWITCHES,
    APPLEII_GET_MMUSOFTSWITCHES,
} AppleIIAddressDecoderMessage;

// Move this to AppleIIControl:
//    APPLEII_ASSERT_DISKMOTORON,
//    APPLEII_CLEAR_DISKMOTORON,

typedef enum
{
    APPLEII_VRAM_DID_CHANGE,
    APPLEII_SLOTEXPANSIONMEMORY_WILL_UNMAP,
} AppleIIAddressDecoderNotification;

typedef enum
{
    APPLEII_REFRESH_VIDEO,
    APPLEII_READ_FLOATINGBUS,
    APPLEII_SET_TEXT,
    APPLEII_SET_PAGE2,
    APPLEII_SET_MIXED,
    APPLEII_SET_HIRES,
} AppleIIVideoMessage;

typedef enum
{
    APPLEII_SET_PDL0,
    APPLEII_SET_PDL1,
    APPLEII_SET_PDL2,
    APPLEII_SET_PDL3,
    APPLEII_SET_PB0,
    APPLEII_SET_PB1,
    APPLEII_SET_PB2,
    APPLEII_GET_AN0,
    APPLEII_GET_AN1,
    APPLEII_GET_AN2,
    APPLEII_GET_AN3,
    
    APPLEII_SET_BANKSELECT_COMPONENT,
} AppleIIGamePortMessage;

typedef enum
{
    APPLEII_DID_STROBE,
    APPLEII_AN0_DID_CHANGE,
    APPLEII_AN1_DID_CHANGE,
    APPLEII_AN2_DID_CHANGE,
    APPLEII_AN3_DID_CHANGE,
} AppleIIGamePortNotification;

#endif