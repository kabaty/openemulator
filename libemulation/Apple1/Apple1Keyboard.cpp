
/**
 * libemulation
 * Apple I Keyboard
 * (C) 2010 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Controls the Apple I Keyboard
 */

#include "Apple1Keyboard.h"

#include "Host.h"
#include "MC6821.h"

#define APPLE1KEYBOARD_MASK	0x40

Apple1Keyboard::Apple1Keyboard()
{
	host = NULL;
	pia = NULL;
}

bool Apple1Keyboard::connect(const string &name, OEComponent *component)
{
	if (name == "host")
	{
		if (host)
			host->removeObserver(this, HOST_HID_UNICODEKEYBOARD_CHANGED);
		host = component;
		if (host)
			host->addObserver(this, HOST_HID_UNICODEKEYBOARD_CHANGED);
	}
	else if (name == "pia")
		pia = component;
	else
		return false;
	
	return true;
}

void Apple1Keyboard::notify(int notification, OEComponent *component, void *data)
{
	HostHIDEvent *event = (HostHIDEvent *) data;
	
	key = event->usageId;
	
	bool value = true;
	pia->postEvent(pia, MC6821_SET_CA1, &value);
}

OEUInt8 Apple1Keyboard::read(int address)
{
	bool value = false;
	pia->postEvent(pia, MC6821_SET_CA1, &value);
	
	return key | APPLE1KEYBOARD_MASK;
}
