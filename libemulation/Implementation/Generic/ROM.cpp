
/**
 * libemulation
 * ROM
 * (C) 2010 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Controls read only memory
 */

#include "ROM.h"

#include "AddressDecoder.h"

ROM::ROM()
{
}

bool ROM::setData(string name, OEData *data)
{
	if (name == "image")
		data->swap(this->data);
	else
		return false;
	
	return true;
}

bool ROM::init()
{
	if (!data.size())
	{
		logMessage("missing ROM");
		return false;
	}
	
	int size = getNextPowerOf2(data.size());
	data.resize(size);
	datap = (OEUInt8 *) &data.front();
	mask = size - 1;
	
	return true;
}

OEUInt8 ROM::read(OEAddress address)
{
	return datap[address & mask];
}