
/**
 * OpenEmulator
 * Mac OS X Document
 * (C) 2009-2012 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Controls an emulation
 */

#import <Cocoa/Cocoa.h>

#define USER_TEMPLATES_FOLDER @"~/Library/Application Support/OpenEmulator/Templates"

@class EmulationWindowController;

@interface Document : NSDocument
{
    void *emulation;
    
    EmulationWindowController *emulationWindowController;
    NSMutableArray *canvasWindowControllers;
    
    BOOL newCanvasesCapture;
    NSMutableArray *newCanvases;
}

- (id)initWithTemplateURL:(NSURL *)templateURL error:(NSError **)outError;
- (IBAction)saveDocumentAsTemplate:(id)sender;

- (void *)constructEmulation:(NSURL *)url;
- (void)destroyEmulation;
- (void)lockEmulation;
- (void)unlockEmulation;
- (void *)emulation;

- (void)showEmulation:(id)sender;
- (void)constructCanvas:(NSDictionary *)dict;
- (void)destroyCanvas:(NSValue *)canvasValue;
- (void)showCanvas:(NSValue *)canvasValue;
- (void)captureNewCanvases:(BOOL)value;
- (void)showNewCanvases;

- (BOOL)canMountNow:(NSString *)path;
- (BOOL)mount:(NSString *)path;
- (BOOL)canMount:(NSString *)path;

@end