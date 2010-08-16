
/**
 * OpenEmulator
 * Mac OS X Device Chooser View Controller
 * (C) 2009-2010 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Controls a device chooser view.
 */

#import <Cocoa/Cocoa.h>

#import "ChooserViewController.h"

@interface DeviceChooserViewController : ChooserViewController
{
	NSMutableArray *infos;
}

- (void)updateForDeviceType:(NSString *)deviceType
			 withFreeInlets:(NSArray *)freeInlets;
- (NSMutableArray *)selectedItemOutlets;

@end
