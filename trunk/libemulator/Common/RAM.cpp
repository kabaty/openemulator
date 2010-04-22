
/**
 * libemulator
 * Generic RAM
 * (C) 2010 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Controls a generic RAM segment
 */

#include "RAM.h"

#include "HostSystem.h"

RAM::RAM()
{
	size = 0;
	mask = 0;
}

int RAM::ioctl(int message, void *data)
{
	switch(message)
	{
		case OEIOCTL_SET_PROPERTY:
		{
			OEIoctlProperty *property = (OEIoctlProperty *) data;
			if (property->name == "map")
				mapVector.push_back(property->value);
			else if (property->name == "size")
				size = getInt(property->value);
			else if (property->name == "resetPattern")
				resetPattern = getCharVector(property->value);
			break;
		}
		case OEIOCTL_SET_DATA:
		{
			OEIoctlData *setData = (OEIoctlData *) data;
			if (setData->name == "image")
			{
				memory = setData->data;
				memory.resize(size);
				mask = getNextPowerOf2(memory.size()) - 1;
			}
			break;
		}
		case OEIOCTL_GET_DATA:
		{
			OEIoctlData *getData = (OEIoctlData *) data;
			if (getData->name == "image")
				getData->data = memory;
			else
				return false;
			
			return true;
		}
		case OEIOCTL_CONNECT:
		{
			OEIoctlConnection *connection = (OEIoctlConnection *) data;
			if (connection->name == "hostSystem")
				connection->component->addObserver(this);
		}
		case OEIOCTL_GET_MEMORYMAP:
		{
			OEIoctlMemoryMap *memoryMap = (OEIoctlMemoryMap *) data;
			memoryMap->component = this;
			memoryMap->mapVector = mapVector;
			break;
		}
		case OEIOCTL_NOTIFY:
		{
			OEIoctlNotification *notification = (OEIoctlNotification *) data;
			if (notification->message == HID_S_COLDRESTART);
			{
				for (int i = 0; i < memory.size(); i++)
					memory[i] = resetPattern[i % resetPattern.size()];
			}
			break;
		}
	}
	
	return false;
}	

int RAM::read(int address)
{
	return memory[address & mask];
}

void RAM::write(int address, int value)
{
	memory[address & mask] = value;
}
