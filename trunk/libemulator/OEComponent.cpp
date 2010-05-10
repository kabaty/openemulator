
/**
 * libemulator
 * OEComponent
 * (C) 2009-2010 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Component type
 */

#include "math.h"
#include <sstream>

#include "OEComponent.h"

OEComponent::OEComponent()
{
}

OEComponent::~OEComponent()
{
}

int OEComponent::ioctl(int command, void *data)
{
	return 0;
}

int OEComponent::read(int address)
{
	return 0;
}

void OEComponent::write(int address, int value)
{
}

void OEComponent::addObserver(OEComponent *component)
{
	observers.push_back(component);
}

void OEComponent::removeObserver(OEComponent *component)
{
	vector<OEComponent *>::iterator iterator;
	for (iterator = observers.begin();
		 iterator != observers.end();
		 iterator++)
	{
		if (*iterator == component)
			observers.erase(iterator);
	}
}

void OEComponent::postNotification(int message, void *data)
{
	OEIoctlNotification notification;
	notification.component = this;
	notification.message = message;
	notification.data = data;
	
	vector<OEComponent *>::iterator iterator;
	for (iterator = observers.begin();
		 iterator != observers.end();
		 iterator++)
		(*iterator)->ioctl(OEIOCTL_NOTIFY, &notification);
}

int getInt(string value)
{
	if (value.substr(0, 2) == "0x")
	{
		unsigned int i;
		std::stringstream ss;
		ss << std::hex << value.substr(2);
		ss >> i;
		return i;
	}
	else
		return atoi(value.c_str());
}

double getFloat(string value)
{
	return atof(value.c_str());
}

string getString(int value)
{
	std::stringstream ss;
	ss << value;
	return ss.str();
}

string getHex(int value)
{
	std::stringstream ss;
	ss << "0x" << std::hex << value;
	return ss.str();
}

vector<char> getCharVector(string value)
{
	vector<char> result;
	
	if (value.substr(0, 2) == "0x")
		value = value.substr(2);
	
	int size = value.size() / 2;
	result.resize(size);
	
	for (int i = 0; i < size; i++)
	{
		unsigned int n;
		std::stringstream ss;
		ss << std::hex << value.substr(i * 2, 2);
		ss >> n;
		result[i] = n;
	}
	
	return result;
}

int getPreviousPowerOf2(int value)
{
	return (int) pow(2, floor(log2(value)));
}
