
/**
 * libemulation
 * MOS6522
 * (C) 2012 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Implements a MOS 6522 (ROM, RAM, I/O, Timer)
 */

#ifndef _MOS6522_H
#define _MOS6522_H

#include "OEComponent.h"

// Messages
typedef enum
{
	MOS6522_SET_CA1,
	MOS6522_SET_CA2,
	MOS6522_GET_CA2,
    MOS6522_GET_PA,
    
	MOS6522_SET_CB1,
	MOS6522_SET_CB2,
	MOS6522_GET_CB2,
    MOS6522_GET_PB,
} MOS6522Message;

// Notifications
typedef enum
{
	MOS6522_CA2_DID_CHANGE,
	MOS6522_CB2_DID_CHANGE,
} MOS6522Notification;

class MOS6522 : public OEComponent
{
public:
    MOS6522();
    
    bool setValue(string name, string value);
    bool getValue(string name, string& value);
    bool setRef(string name, OEComponent *ref);
    bool init();
    
    bool postMessage(OEComponent *sender, int message, void *data);
    
    OEChar read(OEAddress address);
    void write(OEAddress address, OEChar value);
    
private:
    OEComponent *controlBus;
    OEComponent *portA;
    OEComponent *portB;
    OEComponent *controlBusB;
    
    OEAddress addressA;
    OEChar ddrA;
    OEChar dataA;
	bool ca1;
	bool ca2;
    
    OEAddress addressB;
    OEChar ddrB;
    OEChar dataB;
	bool cb1;
	bool cb2;
};

#endif
