
/**
 * libemulation
 * Apple III MOS6502
 * (C) 2012 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Emulates an Apple III MOS6502 microprocessor
 */

#ifndef _APPLEIIIMOS6502_H
#define _APPLEIIIMOS6502_H

#include "MOS6502.h"

class AppleIIIMOS6502 : public MOS6502
{
public:
    AppleIIIMOS6502();
    
    bool setRef(string name, OEComponent *ref);
    bool init();
    
private:
    OEComponent *extendedMemoryBus;
    
    void execute();
};

#endif
