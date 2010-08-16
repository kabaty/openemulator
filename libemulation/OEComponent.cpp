
/**
 * libemulation
 * OEComponent
 * (C) 2009-2010 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Component definition
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

bool OEComponent::setProperty(const string &name, const string &value)
{
	return false;
}

bool OEComponent::getProperty(const string &name, string &value)
{
	return false;
}

bool OEComponent::setData(const string &name, OEData *data)
{
	return false;
}

bool OEComponent::getData(const string &name, OEData **data)
{
	return false;
}

bool OEComponent::setResource(const string &name, OEData *data)
{
	return false;
}

bool OEComponent::connect(const string &name, OEComponent *component)
{
	return false;
}

bool OEComponent::addObserver(OEComponent *component, int notification)
{
	observers[notification].push_back(component);
	
	return true;
}

bool OEComponent::removeObserver(OEComponent *component, int notification)
{
	OEComponents::iterator first = observers[notification].begin();
	OEComponents::iterator last = observers[notification].end();
	OEComponents::iterator i = remove(first, last, component);
	
	if (i != last)
		observers[notification].erase(i, last);
	
	return (i != last);
}

void OEComponent::notify(OEComponent *component, int notification, void *data)
{
	OEComponents::iterator i;
	for (i = observers[notification].begin();
		 i != observers[notification].end();
		 i++)
		notify(this, notification, data);
}

bool OEComponent::addDelegate(OEComponent *component, int event)
{
	delegates[event].push_back(component);
	
	return true;
}

bool OEComponent::removeDelegate(OEComponent *component, int event)
{
	OEComponents::iterator first = delegates[event].begin();
	OEComponents::iterator last = delegates[event].end();
	OEComponents::iterator i = remove(first, last, component);
	
	if (i != last)
		delegates[event].erase(i, last);
	
	return (i != last);
}

bool OEComponent::postEvent(OEComponent *component, int event, void *data)
{
	OEComponents::iterator i;
	for (i = delegates[event].begin();
		 i != delegates[event].end();
		 i++)
		if ((*i)->postEvent(component, event, data))
			return true;
	
	return false;
}

int OEComponent::read(OEUInt32 address)
{
	return 0;
}

void OEComponent::write(OEUInt32 address, int value)
{
}

int OEComponent::readw(OEUInt32 address)
{
	return 0;
}

void OEComponent::writew(OEUInt32 address, int value)
{
}

int OEComponent::readd(OEUInt32 address)
{
	return 0;
}

void OEComponent::writed(OEUInt32 address, int value)
{
}

bool OEComponent::readBlock(OEUInt32 address, OEData *value)
{
	return false;
}

bool OEComponent::writeBlock(OEUInt32 address, const OEData *value)
{
	return false;
}

bool OEComponent::sendDebugCommand(char *command)
{
	return false;
}

int OEComponent::getInt(const string &value)
{
	if (value.substr(0, 2) == "0x")
	{
		unsigned int i;
		stringstream ss;
		ss << hex << value.substr(2);
		ss >> i;
		return i;
	}
	else
		return atoi(value.c_str());
}

double OEComponent::getFloat(const string &value)
{
	return atof(value.c_str());
}

string OEComponent::getString(int value)
{
	stringstream ss;
	ss << value;
	return ss.str();
}

string OEComponent::getHex(int value)
{
	stringstream ss;
	ss << "0x" << hex << value;
	return ss.str();
}

OEData OEComponent::getCharVector(const string &value)
{
	OEData result;
	int start = (value.substr(0, 2) == "0x") ? 2 : 0;
	int size = value.size() / 2 - start;
	result.resize(size);
	
	for (int i = 0; i < size; i++)
	{
		unsigned int n;
		stringstream ss;
		ss << hex << value.substr(start + i * 2, 2);
		ss >> n;
		result[i] = n;
	}
	
	return result;
}

int OEComponent::getNextPowerOf2(int value)
{
	return (int) pow(2, ceil(log2(value)));
}
