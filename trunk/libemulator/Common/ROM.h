
/**
 * libemulator
 * Generic ROM
 * (C) 2010 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Controls a generic ROM segment
 */

#include "OEComponent.h"

class ROM : public OEComponent
{
public:
	int ioctl(int message, void *data);
	int read(int address);
	
private:
	int offset;
	vector<char> memory;
};