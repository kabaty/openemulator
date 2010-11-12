
/**
 * OpenEmulator
 * Mac OS X Device Chooser Window Controller
 * (C) 2009-2010 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Controls the device chooser window.
 */

#import <Cocoa/Cocoa.h>

#import "DeviceChooserViewController.h"
#import "ConnectorViewController.h"

@interface DeviceChooserWindowController : NSWindowController
{
	IBOutlet id fMessage;
	IBOutlet id fView;
	IBOutlet id fPreviousButton;
	IBOutlet id fNextButton;
	
	IBOutlet id fDocumentController;
	
	DeviceChooserViewController *deviceChooserViewController;
	ConnectorViewController *connectorViewController;
	
	NSArray *selectedItemOutlets;
	NSMutableArray *selectedItemInlets;
	
	NSString *type;
	
	id currentView;
	int currentStep;
	
	BOOL isWindowSetup;
}

- (void)runModal:(id)sender forType:(NSString *)theType;

- (void)setDeviceChooserView;
- (void)setConnectorViewAtIndex:(int)index;
- (void)updateView:(id)view
			 title:(NSString *)title
   previousEnabled:(BOOL)previousEnabled
		  lastStep:(BOOL)lastStep;

- (IBAction)performCancel:(id)sender;
- (IBAction)performPrevious:(id)sender;
- (IBAction)performNext:(id)sender;

@end