
/**
 * OpenEmulator
 * Mac OS X Document
 * (C) 2009 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Controls an emulation document.
 */

#import "Document.h"
#import "DocumentWindowController.h"

#import "OEEmulator.h"
#import "OEParser.h"

@implementation Document

- (id) init
{
	if (self = [super init])
	{
		emulation = nil;
		
		pasteboard = [NSPasteboard generalPasteboard];
		pasteboardTypes = [[NSArray alloc] initWithObjects:
						   NSStringPboardType,
						   nil];
		
		power = false;
		label = nil;
		description = nil;
		modificationDate = nil;
		runTime = nil;
		image = nil;
		
		expansions = [[NSMutableArray alloc] init];
		diskDrives = [[NSMutableArray alloc] init];
		peripherals = [[NSMutableArray alloc] init];
		
		// To-Do: [self setVideoPreset:x];
		volume = nil;
	}
	
	return self;
}

- (id) initFromTemplateURL:(NSURL *) absoluteURL
					 error:(NSError **) outError
{
//	printf("initFromTemplateURL\n");
	if ([self init])
	{
		if ([self readFromURL:absoluteURL
					   ofType:nil
						error:outError])
			return self;
	}
	
	*outError = [NSError errorWithDomain:NSCocoaErrorDomain
									code:NSFileReadUnknownError
								userInfo:nil];
	return nil;
}

- (void) dealloc
{
//	printf("dealloc\n");
	if (emulation)
		delete (OEEmulator *) emulation;
	
	[pasteboardTypes release];
	
	[expansions release];
	[diskDrives release];
	[peripherals release];
	
	[super dealloc];
}

- (void) setDMLProperty:(NSString *) key value:(NSString *) value
{
	if (!emulation)
		return;
	
	xmlDocPtr dml = ((OEEmulator *) emulation)->getDML();
	
	xmlNodePtr rootNode = xmlDocGetRootElement(dml);
	
	xmlSetProp(rootNode, BAD_CAST [key UTF8String], BAD_CAST [value UTF8String]);
}

- (NSString *) getDMLProperty:(NSString *) key
{
	if (!emulation)
		return nil;
	
	xmlDocPtr dml = ((OEEmulator *) emulation)->getDML();
	
	xmlNodePtr rootNode = xmlDocGetRootElement(dml);
	
	xmlChar *valuec = xmlGetProp(rootNode, BAD_CAST [key UTF8String]);
	NSString *value = [NSString stringWithUTF8String:(const char *) valuec];
	xmlFree(valuec);
	
	return value;
}

- (void) setIoctlProperty:(NSString *) key ref:(NSString *) ref value:(NSString *) value
{
	if (!emulation)
		return;
	
	OEIoctlProperty property;
	
	property.key = string([key UTF8String]);
	property.value = string([value UTF8String]);
	
	((OEEmulator *)emulation)->ioctl(string([ref UTF8String]),
									  OEIoctlSetProperty,
									  &property);
}

- (NSString *) getIoctlProperty:(NSString *)key ref:(NSString *) ref
{
	if (!emulation)
		return nil;
	
	OEIoctlProperty msg;
	
	msg.key = string([key UTF8String]);
	
	if (((OEEmulator *)emulation)->ioctl(string([ref UTF8String]),
									  OEIoctlGetProperty,
									  &msg))
		return [NSString stringWithUTF8String:msg.value.c_str()];
	else
		return nil;
}

- (NSImage *) getResourceImage:(NSString *) imagePath
{
	NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	NSString *path = [[resourcePath
					   stringByAppendingString:@"/images/"]
					  stringByAppendingString:imagePath];
	NSImage *theImage = [[NSImage alloc] initWithContentsOfFile:path];
	if (theImage)
		[theImage autorelease];
	
	return theImage;
}

- (void) updateRunTime
{
	NSString *property = [self getIoctlProperty:@"runTime" ref:@"host::events"];
	int timeDifference = [property intValue];
	
	int seconds = timeDifference % 60;
	int minutes = (timeDifference / 60) % 60; 
	int hours = (timeDifference / 3600) % 3600;
	
	NSString *value = [NSString stringWithFormat:@"%d:%02d:%02d",
					   hours,  minutes, seconds];
	
	[self setRunTime:value];
}

- (NSAttributedString *) formatDeviceLabel:(NSString *) deviceLabel
					   withInformativeText:(NSString *) informativeText
{
	NSMutableParagraphStyle *paragraphStyle;
	paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy]
					  autorelease];
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	
	NSDictionary *deviceLabelAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSFont messageFontOfSize:12.0f],
									  NSFontAttributeName,
									  paragraphStyle,
									  NSParagraphStyleAttributeName,
									  [NSColor controlTextColor],
									  NSForegroundColorAttributeName,
									  nil];
	NSMutableAttributedString *aString;
	aString = [[[NSMutableAttributedString alloc] initWithString:deviceLabel
													  attributes:deviceLabelAttrs]
						autorelease];
	
	NSDictionary *informativeTextAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
										  [NSFont messageFontOfSize:9.0f],
										  NSFontAttributeName,
										  paragraphStyle,
										  NSParagraphStyleAttributeName,
										  [NSColor darkGrayColor],
										  NSForegroundColorAttributeName,
										  nil];
	NSAttributedString *aInformativeText;
	aInformativeText = [[[NSAttributedString alloc] initWithString:informativeText
						 attributes:informativeTextAttrs] autorelease];
	[aString appendAttributedString:aInformativeText];
	
	return aString;
}

- (void) updateDevices
{
	OEParser parser(((OEEmulator *) emulation)->getDML());
	if (!parser.isOpen())
		return;
	
	[expansions release];
	expansions = [[NSMutableArray alloc] init];
	[diskDrives release];
	diskDrives = [[NSMutableArray alloc] init];
	[peripherals release];
	peripherals = [[NSMutableArray alloc] init];
	
	OEDMLInfo *dmlInfo = parser.getDMLInfo();
	
	int expansionIndex = 0;
	int diskDriveIndex = 0;
	int peripheralIndex = 0;
	for (OEPortsInfo::iterator o = dmlInfo->outlets.begin();
		 o != dmlInfo->outlets.end();
		 o++)
	{
		NSString *imagePath = [NSString stringWithUTF8String:o->image.c_str()];
		NSString *deviceLabel = [NSString stringWithUTF8String:o->label.c_str()];
		
		NSImage *deviceImage = [self getResourceImage:imagePath];
		NSString *informativeText = [NSString localizedStringWithFormat:@"\n(on %@)",
									 [NSString stringWithUTF8String:
									  o->connectedLabel.c_str()]];
		NSAttributedString *aString = [self formatDeviceLabel:deviceLabel
										  withInformativeText:informativeText];
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  aString, @"title",
							  deviceImage, @"image",
							  nil];
		if (o->type == "expansion")
			[self insertObject:dict inExpansionsAtIndex:expansionIndex++];
		else if (o->type == "diskdrive")
			[self insertObject:dict inDiskDrivesAtIndex:diskDriveIndex++];
		else if (o->type == "peripheral")
			[self insertObject:dict inPeripheralsAtIndex:peripheralIndex++];
	}
	
	return;
}

- (BOOL) readFromURL:(NSURL *) absoluteURL
			  ofType:(NSString *) typeName
			   error:(NSError **) outError
{
//	printf("readFromURL\n");
	const char *emulationPath = [[absoluteURL path] UTF8String];
	const char *resourcePath = [[[NSBundle mainBundle] resourcePath] UTF8String];
	
	if (emulation)
		delete (OEEmulator *)emulation;
	
	emulation = (void *)new OEEmulator(emulationPath, resourcePath);
	
	if (emulation)
	{
		if (((OEEmulator *)emulation)->isOpen())
		{
			[self setLabel:[self getDMLProperty:@"label"]];
			[self setGroup:[self getDMLProperty:@"group"]];
			[self setDescription:[self getDMLProperty:@"description"]];
			[self updateRunTime];
			[self setImage:[self getResourceImage:[self getDMLProperty:@"image"]]];
			
			[self updateDevices];
			
			[self setBrightness:[NSNumber numberWithFloat:0.0F]];
			[self setContrast:[NSNumber numberWithFloat:0.0F]];
			[self setSharpness:[NSNumber numberWithFloat:0.0F]];
			[self setSaturation:[NSNumber numberWithFloat:0.0F]];
			[self setTemperature:[NSNumber numberWithFloat:0.0F]];
			[self setTint:[NSNumber numberWithFloat:0.0F]];
			
			[self setVolume:[NSNumber numberWithFloat:1.0F]];
			
			return YES;
		}
		
		delete (OEEmulator *)emulation;
		emulation = NULL;
	}
	
	*outError = [NSError errorWithDomain:NSCocoaErrorDomain
									code:NSFileReadUnknownError
								userInfo:nil];
	return NO;
}

- (BOOL) writeToURL:(NSURL *) absoluteURL
			 ofType:(NSString *) typeName
			  error:(NSError **) outError
{
//	printf("writeToURL\n");
	const char *emulationPath = [[[absoluteURL path] stringByAppendingString:@"/"]
								 UTF8String];
	if (emulation)
	{
		if (((OEEmulator *)emulation)->save(string(emulationPath)))
			return YES;
	}
	
	*outError = [NSError errorWithDomain:NSCocoaErrorDomain
									code:NSFileWriteUnknownError
								userInfo:nil];
	return NO;
}

- (void) setFileModificationDate:(NSDate *) date
{
	[super setFileModificationDate:date];
	
	NSString *value;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	value = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	
	[self setModificationDate:value];
}

- (IBAction) saveDocumentAsTemplate:(id) sender
{
	NSString *path = [TEMPLATE_FOLDER stringByExpandingTildeInPath];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path])
		[fileManager createDirectoryAtPath:path
			   withIntermediateDirectories:YES
								attributes:nil
									 error:nil];
	
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setRequiredFileType:@"emulation"];
	[panel beginSheetForDirectory:path
							 file:nil
				   modalForWindow:[self windowForSheet]
					modalDelegate:self
				   didEndSelector:@selector(saveDocumentAsTemplateDidEnd:
											returnCode:contextInfo:)
					  contextInfo:nil];
}

- (void) saveDocumentAsTemplateDidEnd:(NSSavePanel *) panel
						   returnCode:(int) returnCode
						  contextInfo:(void *) contextInfo
{
	if (returnCode != NSOKButton)
		return;
	
	NSError *error;
	if (![self writeToURL:[panel URL]
				   ofType:nil
					error:&error])
		[[NSAlert alertWithError:error] runModal];
}

- (void) makeWindowControllers
{
	NSWindowController *windowController;
	windowController = [[DocumentWindowController alloc] init];
	
	[self addWindowController:windowController];
	[windowController release];
}

- (BOOL) validateUserInterfaceItem:(id) item
{
	if ([item action] == @selector(copy:))
		return [self isCopyValid];
	else if ([item action] == @selector(paste:))
		return [self isPasteValid];
	else if ([item action] == @selector(startSpeaking:))
		return [self isCopyValid];
	
	return YES;
}

- (BOOL) isCopyValid
{
	return YES; // To-Do: libemulation
}

- (BOOL) isPasteValid
{
	return [pasteboard availableTypeFromArray:pasteboardTypes] != nil;
}

- (void) powerButtonPressedAndReleased:(id) sender
{
	[self powerButtonPressed:sender];
	[self powerButtonReleased:sender];
}

- (void) powerButtonPressed:(id) sender
{
	// To-Do: libemulation
	[self setPower:![self power]];
}

- (void) powerButtonReleased:(id) sender
{
	// To-Do: libemulation
}

- (void) resetButtonPressedAndReleased:(id) sender
{
	[self resetButtonPressed:sender];
	[self resetButtonReleased:sender];
}

- (void) resetButtonPressed:(id) sender
{
	// To-Do: libemulation
}

- (void) resetButtonReleased:(id) sender
{
	// To-Do: libemulation
}

- (void) pauseButtonPressedAndReleased:(id) sender
{
	[self pauseButtonPressed:sender];
	[self pauseButtonReleased:sender];
}

- (void) pauseButtonPressed:(id) sender
{
	// To-Do: libemulation
}

- (void) pauseButtonReleased:(id) sender
{
	// To-Do: libemulation
}

- (NSString *) getDocumentText
{
	// To-Do: libemulation
	return @"This is a meticulously designed test of the speech synthesizing system.";  
}

- (void) copy:(id) sender
{
	if ([self isCopyValid])
	{
		[pasteboard declareTypes:pasteboardTypes owner:self];
		[pasteboard setString:[self getDocumentText] forType:NSStringPboardType];
	}
}

- (void) paste:(id) sender
{
	if ([self isPasteValid])
	{
//		NSString *text = [pasteboard stringForType:NSStringPboardType];
		
		// To-do: Send to libemulator
		// (using [text UTF8String])
	}
}

- (void) startSpeaking:(id) sender
{
	NSTextView *dummy = [[NSTextView alloc] init];
	[dummy insertText:[self getDocumentText]];
	[dummy startSpeaking:self];
	[dummy release];
}

- (BOOL) power
{
	return power;
}

- (void) setPower:(BOOL) value
{
	if (power != value)
		power = value;
}

- (NSString *) label
{
	return [[label retain] autorelease];
}

- (void) setLabel:(NSString *) value
{
    if (label != value)
	{
        [label release];
        label = [value copy];
    }
}

- (NSString *) group
{
	return [[group retain] autorelease];
}

- (void) setGroup:(NSString *) value
{
    if (group != value)
	{
        [group release];
        group = [value copy];
    }
}

- (NSString *) description
{
	return [[description retain] autorelease];
}

- (void) setDescription:(NSString *) value
{
    if (description != value)
	{
		if (description)
			[self updateChangeCount:NSChangeDone];
		
		[self setDMLProperty:@"description" value:value];
		
        [description release];
        description = [value copy];
    }
}

- (NSString *) modificationDate
{
	return modificationDate;
}

- (void) setModificationDate:(NSString *) value
{
    if (modificationDate != value)
	{
        [modificationDate release];
        modificationDate = [value copy];
    }
}

- (NSString *) runTime
{
	return runTime;
}

- (void)setRunTime:(NSString *) value
{
    if (runTime != value)
	{
        [runTime release];
        runTime = [value copy];
    }
}

- (NSImage *) image
{
	return [[image retain] autorelease];
}

- (void)setImage:(NSImage *) value
{
    if (image != value)
	{
        [image release];
        image = [value copy];
    }
}

- (NSMutableArray *) expansions
{
	return [[expansions retain] autorelease];
}

- (void) insertObject:(id) value inExpansionsAtIndex:(NSUInteger) index
{
    [expansions insertObject:value atIndex:index];
}

- (void) removeObjectFromExpansionsAtIndex:(NSUInteger) index
{
    [expansions removeObjectAtIndex:index];
}

- (NSMutableArray *) diskDrives
{
	return [[diskDrives retain] autorelease];
}

- (void) insertObject:(id) value inDiskDrivesAtIndex:(NSUInteger) index
{
    [diskDrives insertObject:value atIndex:index];
}

- (void) removeObjectFromDiskDrivesAtIndex:(NSUInteger) index
{
    [diskDrives removeObjectAtIndex:index];
}

- (NSMutableArray *) peripherals
{
	return [[peripherals retain] autorelease];
}

- (void) insertObject:(id) value inPeripheralsAtIndex:(NSUInteger) index
{
    [peripherals insertObject:value atIndex:index];
}

- (void) removeObjectFromPeripheralsAtIndex:(NSUInteger) index
{
    [peripherals removeObjectAtIndex:index];
}

- (NSNumber *) brightness
{
	return [[brightness retain] autorelease];
}

- (void) setBrightness:(NSNumber *) value
{
    if (brightness != value)
	{
		if (brightness)
			[self updateChangeCount:NSChangeDone];
		
        [brightness release];
        brightness = [value copy];
    }
}

- (NSNumber *) contrast
{
	return [[contrast retain] autorelease];
}

- (void) setContrast:(NSNumber *) value
{
    if (contrast != value)
	{
		if (contrast)
			[self updateChangeCount:NSChangeDone];
		
        [contrast release];
        contrast = [value copy];
    }
}

- (NSNumber *) sharpness
{
	return [[sharpness retain] autorelease];
}

- (void) setSharpness:(NSNumber *) value
{
    if (sharpness != value)
	{
		if (sharpness)
			[self updateChangeCount:NSChangeDone];
		
        [sharpness release];
        sharpness = [value copy];
    }
}

- (NSNumber *) saturation
{
	return [[saturation retain] autorelease];
}

- (void) setSaturation:(NSNumber *) value
{
    if (saturation != value)
	{
		if (saturation)
			[self updateChangeCount:NSChangeDone];
		
        [saturation release];
        saturation = [value copy];
    }
}

- (NSNumber *) temperature
{
	return [[temperature retain] autorelease];
}

- (void) setTemperature:(NSNumber *) value
{
    if (temperature != value)
	{
		if (temperature)
			[self updateChangeCount:NSChangeDone];
		
        [temperature release];
        temperature = [value copy];
    }
}

- (NSNumber *) tint
{
	return [[tint retain] autorelease];
}

- (void) setTint:(NSNumber *) value
{
    if (tint != value)
	{
		if (tint)
			[self updateChangeCount:NSChangeDone];
		
        [tint release];
        tint = [value copy];
    }
}

- (NSNumber *) volume
{
	return [[volume retain] autorelease];
}

- (void) setVolume:(NSNumber *) value
{
    if (volume != value)
	{
		if (volume)
			[self updateChangeCount:NSChangeDone];
		
        [volume release];
        volume = [value copy];
    }
}

@end