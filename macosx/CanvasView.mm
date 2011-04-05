
/**
 * OpenEmulator
 * Mac OS X Canvas View
 * (C) 2010-2011 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Controls a canvas view.
 */

#import "Carbon/Carbon.h"

#import "CanvasView.h"
#import "CanvasWindowController.h"
#import "SystemEventInterface.h"
#import "Application.h"
#import "DocumentController.h"
#import "StringConversion.h"

#import "OpenGLHAL.h"

#define NSLeftControlKeyMask	0x00000001
#define NSLeftShiftKeyMask		0x00000002
#define NSLeftAlternateKeyMask	0x00000020
#define NSLeftCommandKeyMask	0x00000008
#define NSRightControlKeyMask	0x00002000
#define NSRightShiftKeyMask		0x00000004
#define NSRightAlternateKeyMask	0x00000040
#define NSRightCommandKeyMask	0x00000010

@implementation CanvasView

// Callback methods

static void setCapture(void *userData, OpenGLHALCapture capture)
{
	NSLog(@"CanvasView setCapture");
	
	BOOL isCapture = (capture != OPENGLHAL_CAPTURE_NONE);
	BOOL enableMouseCursor = (capture !=
							  OPENGLHAL_CAPTURE_KEYBOARD_AND_DISCONNECT_MOUSE_CURSOR);
	
	[(Application *)NSApp setCapture:isCapture];
	
	if (isCapture)
		CGDisplayHideCursor(kCGDirectMainDisplay);
	else
		CGDisplayShowCursor(kCGDirectMainDisplay);
	
	PushSymbolicHotKeyMode(isCapture ?
						   kHIHotKeyModeAllDisabled : 
						   kHIHotKeyModeAllEnabled);
	
	CGAssociateMouseAndMouseCursorPosition(enableMouseCursor);
}

static void setKeyboardFlags(void *userData, int flags)
{
	// To-Do: check if performSelectorOnMainThread is needed
	
	[(CanvasView *)userData setKeyboardFlags:flags];
}

static CVReturn displayLinkCallback(CVDisplayLinkRef displayLink,
									const CVTimeStamp *now,
									const CVTimeStamp *outputTime,
									CVOptionFlags flagsIn,
									CVOptionFlags *flagsOut,
									void *displayLinkContext)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[(CanvasView *)displayLinkContext updateView];
	
	[pool release];
	
	return kCVReturnSuccess;
}

// Class

- (id)initWithFrame:(NSRect)rect
{
	NSLog(@"CanvasView init");
	
	NSOpenGLPixelFormatAttribute pixelFormatAtrributes[] =
	{
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAColorSize, 24,
		NSOpenGLPFAAlphaSize, 8,
		NSOpenGLPFADepthSize, 0,
		NSOpenGLPFAStencilSize, 0,
		NSOpenGLPFAAccumSize, 8,
		0
	};
	
	NSOpenGLPixelFormat *pixelFormat;
	pixelFormat = [[NSOpenGLPixelFormat alloc]
				   initWithAttributes:pixelFormatAtrributes];
	
	if (!pixelFormat)
	{
		NSLog(@"Cannot create NSOpenGLPixelFormat");
		
		return nil;
	}
	
	[pixelFormat autorelease];
	
	if (self = [super initWithFrame:rect pixelFormat:pixelFormat])
	{
		[self registerForDraggedTypes:[NSArray arrayWithObjects:
									   NSStringPboardType,
									   NSFilenamesPboardType, 
									   nil]];
		
		if (CVDisplayLinkCreateWithActiveCGDisplays(&displayLink) == kCVReturnSuccess)
		{
			CVDisplayLinkSetOutputCallback(displayLink, &displayLinkCallback, self);
			CGLContextObj cglContext = (CGLContextObj)[[self openGLContext] CGLContextObj];
			CGLPixelFormatObj cglPixelFormat = (CGLPixelFormatObj)[[self pixelFormat] 
																   CGLPixelFormatObj];
			CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink,
															  cglContext,
															  cglPixelFormat);
		}
		
		// From:
		//   http://stuff.mit.edu/afs/sipb/project/darwin/src/
		//   modules/AppleADBKeyboard/AppleADBKeyboard.cpp
		keyMap[0x00] = CANVAS_K_A;
		keyMap[0x0b] = CANVAS_K_B;
		keyMap[0x08] = CANVAS_K_C;
		keyMap[0x02] = CANVAS_K_D;
		keyMap[0x0e] = CANVAS_K_E;
		keyMap[0x03] = CANVAS_K_F;
		keyMap[0x05] = CANVAS_K_G;
		keyMap[0x04] = CANVAS_K_H;
		keyMap[0x22] = CANVAS_K_I;
		keyMap[0x26] = CANVAS_K_J;
		keyMap[0x28] = CANVAS_K_K;
		keyMap[0x25] = CANVAS_K_L;
		keyMap[0x2e] = CANVAS_K_M;
		keyMap[0x2d] = CANVAS_K_N;
		keyMap[0x1f] = CANVAS_K_O;
		keyMap[0x23] = CANVAS_K_P;
		keyMap[0x0c] = CANVAS_K_Q;
		keyMap[0x0f] = CANVAS_K_R;
		keyMap[0x01] = CANVAS_K_S;
		keyMap[0x11] = CANVAS_K_T;
		keyMap[0x20] = CANVAS_K_U;
		keyMap[0x09] = CANVAS_K_V;
		keyMap[0x0d] = CANVAS_K_W;
		keyMap[0x07] = CANVAS_K_X;
		keyMap[0x10] = CANVAS_K_Y;
		keyMap[0x06] = CANVAS_K_Z;
		keyMap[0x12] = CANVAS_K_1;
		keyMap[0x13] = CANVAS_K_2;
		keyMap[0x14] = CANVAS_K_3;
		keyMap[0x15] = CANVAS_K_4;
		keyMap[0x17] = CANVAS_K_5;
		keyMap[0x16] = CANVAS_K_6;
		keyMap[0x1a] = CANVAS_K_7;
		keyMap[0x1c] = CANVAS_K_8;
		keyMap[0x19] = CANVAS_K_9;
		keyMap[0x1d] = CANVAS_K_0;
		keyMap[0x24] = CANVAS_K_ENTER;
		keyMap[0x35] = CANVAS_K_ESCAPE;
		keyMap[0x33] = CANVAS_K_BACKSPACE;
		keyMap[0x30] = CANVAS_K_TAB;
		keyMap[0x31] = CANVAS_K_SPACE;
		keyMap[0x1b] = CANVAS_K_MINUS;
		keyMap[0x18] = CANVAS_K_EQUAL;
		keyMap[0x21] = CANVAS_K_LEFTBRACKET;
		keyMap[0x1e] = CANVAS_K_RIGHTBRACKET;
		keyMap[0x2a] = CANVAS_K_BACKSLASH;
		keyMap[0x0a] = CANVAS_K_NON_US1;
		keyMap[0x29] = CANVAS_K_SEMICOLON;
		keyMap[0x27] = CANVAS_K_QUOTE;
		keyMap[0x32] = CANVAS_K_GRAVEACCENT;
		keyMap[0x2b] = CANVAS_K_COMMA;
		keyMap[0x2f] = CANVAS_K_PERIOD;
		keyMap[0x2c] = CANVAS_K_SLASH;
		keyMap[0x39] = CANVAS_K_CAPSLOCK;
		keyMap[0x7a] = CANVAS_K_F1;
		keyMap[0x78] = CANVAS_K_F2;
		keyMap[0x63] = CANVAS_K_F3;
		keyMap[0x76] = CANVAS_K_F4;
		keyMap[0x60] = CANVAS_K_F5;
		keyMap[0x61] = CANVAS_K_F6;
		keyMap[0x62] = CANVAS_K_F7;
		keyMap[0x64] = CANVAS_K_F8;
		keyMap[0x65] = CANVAS_K_F9;
		keyMap[0x6d] = CANVAS_K_F10;
		keyMap[0x67] = CANVAS_K_F11;
		keyMap[0x6f] = CANVAS_K_F12;
		keyMap[0x69] = CANVAS_K_PRINTSCREEN;
		keyMap[0x6b] = CANVAS_K_SCROLLLOCK;
		keyMap[0x71] = CANVAS_K_PAUSE;
		keyMap[0x72] = CANVAS_K_INSERT;
		keyMap[0x73] = CANVAS_K_HOME;
		keyMap[0x74] = CANVAS_K_PAGEUP;
		keyMap[0x75] = CANVAS_K_DELETE;
		keyMap[0x77] = CANVAS_K_END;
		keyMap[0x79] = CANVAS_K_PAGEDOWN;
		keyMap[0x7c] = CANVAS_K_RIGHT;
		keyMap[0x7b] = CANVAS_K_LEFT;
		keyMap[0x7d] = CANVAS_K_DOWN;
		keyMap[0x7e] = CANVAS_K_UP;
		keyMap[0x47] = CANVAS_KP_NUMLOCK;
		keyMap[0x4b] = CANVAS_KP_SLASH;
		keyMap[0x43] = CANVAS_KP_STAR;
		keyMap[0x4e] = CANVAS_KP_MINUS;
		keyMap[0x45] = CANVAS_KP_PLUS;
		keyMap[0x4c] = CANVAS_KP_ENTER;
		keyMap[0x53] = CANVAS_KP_1;
		keyMap[0x54] = CANVAS_KP_2;
		keyMap[0x55] = CANVAS_KP_3;
		keyMap[0x56] = CANVAS_KP_4;
		keyMap[0x57] = CANVAS_KP_5;
		keyMap[0x58] = CANVAS_KP_6;
		keyMap[0x59] = CANVAS_KP_7;
		keyMap[0x5b] = CANVAS_KP_8;
		keyMap[0x5c] = CANVAS_KP_9;
		keyMap[0x52] = CANVAS_KP_0;
		keyMap[0x41] = CANVAS_KP_PERIOD;
		keyMap[0x51] = CANVAS_KP_EQUAL;
		keyMap[0x6a] = CANVAS_K_F16;
		keyMap[0x40] = CANVAS_K_F17;
		keyMap[0x4f] = CANVAS_K_F18;
		keyMap[0x50] = CANVAS_K_F19;
		keyMap[0x7f] = CANVAS_K_POWER;
		
		keyMap[0x3b] = CANVAS_K_LEFTCONTROL;
		keyMap[0x38] = CANVAS_K_LEFTSHIFT;
		keyMap[0x3a] = CANVAS_K_LEFTALT;
		keyMap[0x37] = CANVAS_K_LEFTGUI;
		keyMap[0x3e] = CANVAS_K_RIGHTCONTROL;
		keyMap[0x3c] = CANVAS_K_RIGHTSHIFT;
		keyMap[0x3d] = CANVAS_K_RIGHTALT;
		keyMap[0x36] = CANVAS_K_RIGHTGUI;
	}
	
	return self;
}

- (void)dealloc
{
	NSLog(@"CanvasView dealloc");
	
	CVDisplayLinkStop(displayLink);
    CVDisplayLinkRelease(displayLink);
	
	[super dealloc];
}

- (void)awakeFromNib
{
	NSLog(@"CanvasView awakeFromNib");
	
	CanvasWindowController *canvasWindowController = [[self window] windowController];
	document = [canvasWindowController document];
	canvas = [canvasWindowController canvas];
	
	[self startOpenGL];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)isMouseInView
{
	NSPoint mouseLocation = [self convertPoint:[[self window] convertScreenToBase:
												[NSEvent mouseLocation]]
									  fromView:nil];
	return NSMouseInRect(mouseLocation, [self bounds], [self isFlipped]);
}

- (void)windowWillClose:(NSNotification *)notification
{
	NSLog(@"CanvasView windowWillClose");
	
	[self stopDisplayLink];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	NSLog(@"CanvasView windowDidBecomeKey");
	
	if (!canvas)
	{
		NSLog(@"CanvasView windowDidBecomeKey abort");
		return;
	}
	
	[document lockEmulation];
	((OpenGLHAL *)canvas)->becomeKeyWindow();
	[document unlockEmulation];
	
	if ([self isMouseInView])
		[self mouseEntered:nil];
	
	[document lockEmulation];
	[self synchronizeKeyboardFlags];
	[document unlockEmulation];
	
	NSTrackingAreaOptions options = (NSTrackingMouseEnteredAndExited |
									 NSTrackingMouseMoved |
									 NSTrackingActiveInKeyWindow);
	NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:[self bounds]
														options:options
														  owner:self
													   userInfo:nil];
	[self addTrackingArea:area];
	[area release];
}

- (void)windowDidResignKey:(NSNotification *)notification
{
	NSLog(@"CanvasView windowDidResignKey");
	
	if (!canvas)
	{
		NSLog(@"CanvasView windowDidResignKey abort");
		return;
	}
	
	if ([self isMouseInView])
		[self mouseExited:nil];
	
	[document lockEmulation];
	((OpenGLHAL *)canvas)->resignKeyWindow();
	[document unlockEmulation];
	
	for (NSTrackingArea *area in [self trackingAreas])
		if ([area owner] == self)
			[self removeTrackingArea:area];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pasteboard = [sender draggingPasteboard];
	if ([[pasteboard types] containsObject:NSFilenamesPboardType])
	{
		DocumentController *documentController;
		documentController = [NSDocumentController sharedDocumentController];
		
		NSString *path = [[pasteboard propertyListForType:NSFilenamesPboardType]
						  objectAtIndex:0];
		NSString *pathExtension = [[path pathExtension] lowercaseString];
		
		if ([[documentController diskImagePathExtensions] containsObject:pathExtension])
		{
			if ([document canMount:path])
				return NSDragOperationCopy;
		}
		else if ([[documentController audioPathExtensions] containsObject:pathExtension] ||
				 [[documentController textPathExtensions] containsObject:pathExtension])
			return NSDragOperationCopy;
	}
	else if ([[pasteboard types] containsObject:NSStringPboardType])
		return NSDragOperationCopy;
	
	return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pasteboard = [sender draggingPasteboard];
	
	if ([[pasteboard types] containsObject:NSFilenamesPboardType])
	{
		NSPasteboard *pasteboard = [sender draggingPasteboard];
		NSString *path = [[pasteboard propertyListForType:NSFilenamesPboardType]
						  objectAtIndex:0];
		
		DocumentController *documentController;
		documentController = [NSDocumentController sharedDocumentController];
		[documentController application:NSApp openFile:path];
		
		return YES;
	}
	else if ([[pasteboard types] containsObject:NSStringPboardType])
	{
		string clipboard = getCPPString([pasteboard stringForType:NSStringPboardType]);
		
		[document lockEmulation];
		((OpenGLHAL *)canvas)->paste(clipboard);
		[document unlockEmulation];
		
		return YES;
	}
	
	return NO;
}

// Drawing

- (void)startOpenGL
{
	NSLog(@"CanvasView startOpenGL");
	
	[[self openGLContext] makeCurrentContext];
	
	GLint value = 1;
	[[self openGLContext] setValues:&value
					   forParameter:NSOpenGLCPSwapInterval]; 
	
	((OpenGLHAL *)canvas)->open(setCapture,
								setKeyboardFlags,
								self);
}

- (void)stopOpenGL
{
	NSLog(@"CanvasView stopOpenGL");
	
	[[self openGLContext] makeCurrentContext];
	
	if (canvas)
		((OpenGLHAL *)canvas)->close();
}

- (void)startDisplayLink
{
	NSLog(@"CanvasView startDisplayLink");
	
	CVDisplayLinkStart(displayLink);
}

- (void)stopDisplayLink
{
	NSLog(@"CanvasView stopDisplayLink");
	
	CVDisplayLinkStop(displayLink);
}

- (NSSize)defaultViewSize
{
	[document lockEmulation];
	OESize size = ((OpenGLHAL *)canvas)->getCanvasSize();
	[document unlockEmulation];
	
	NSSize defaultViewSize;
	defaultViewSize.width = (size.width < 128) ? 128 : size.width;
	defaultViewSize.height = (size.height < 128) ? 128 : size.height;
	
	return defaultViewSize;
}

- (void)drawRect:(NSRect)theRect
{
/*	NSRect frame = [self bounds];
	
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
	
	[[self openGLContext] makeCurrentContext];
	
	if (((OpenGLHAL *)canvas)->update(NSWidth(frame), NSHeight(frame), 0, true))
		[[self openGLContext] flushBuffer];
	
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);*/
}

- (void)updateView
{
	[[self openGLContext] makeCurrentContext];
	
	NSRect frame = [self bounds];
	if (((OpenGLHAL *)canvas)->update(NSWidth(frame), NSHeight(frame), 0, false))
		[[self openGLContext] flushBuffer];
}

// Keyboard

- (int)getUsageId:(int)keyCode
{
	NSInteger usageId = (keyCode < DEVICE_KEYMAP_SIZE) ? keyMap[keyCode] : 0;
	
	if (!usageId)
		NSLog(@"Unknown key code %d", keyCode);
	
	return usageId;
}

- (void)sendUnicodeKeyEvent:(NSInteger)unicode
{
	// Discard private usage areas
	if (((unicode >= 0xe000) && (unicode <= 0xf8ff)) ||
		((unicode >= 0xf0000) && (unicode <= 0xffffd)) ||
		((unicode >= 0x100000) && (unicode <= 0x10fffd)))
		return;
	
	if (unicode == 127)
		unicode = 8;
	
	[document lockEmulation];
	((OpenGLHAL *)canvas)->sendUnicodeKeyEvent(unicode);
	[document unlockEmulation];
}

- (void)updateFlags:(int)flags
			forMask:(int)mask
			usageId:(int)usageId
{
	if ((flags & mask) == (keyModifierFlags & mask))
		return;
	
	BOOL value = ((flags & mask) != 0);
	
	[document lockEmulation];
	((OpenGLHAL *)canvas)->setKey(usageId, value);
	[document unlockEmulation];
}

- (void)synchronizeKeyboardFlags
{
	CGEventRef event = CGEventCreate(NULL);
	CGEventFlags modifierFlags = CGEventGetFlags(event);
	CFRelease(event);
	
	bool hostCapsLock = modifierFlags & NSAlphaShiftKeyMask;
	bool emulationCapsLock = keyboardFlags & CANVAS_L_CAPSLOCK;
	if (hostCapsLock != emulationCapsLock)
	{
		if (!capsLockNotSynchronized)
		{
			capsLockNotSynchronized = true;
			
			((OpenGLHAL *)canvas)->setKey(CANVAS_K_CAPSLOCK, true);
			((OpenGLHAL *)canvas)->setKey(CANVAS_K_CAPSLOCK, false);
		}
	}
	else
		capsLockNotSynchronized = false;
}

- (void)setKeyboardFlags:(NSInteger)theKeyboardFlags
{
	keyboardFlags = theKeyboardFlags;
	
	[self synchronizeKeyboardFlags];
}

- (void)keyDown:(NSEvent *)theEvent
{
	NSString *characters = [theEvent characters];
	for (NSInteger i = 0; i < [characters length]; i++)
		[self sendUnicodeKeyEvent:[characters characterAtIndex:i]];
		
	if (![theEvent isARepeat])
	{
		NSInteger usageId = [self getUsageId:[theEvent keyCode]];
		[document lockEmulation];
		((OpenGLHAL *)canvas)->setKey(usageId, true);
		[document unlockEmulation];
	}
}

- (void)keyUp:(NSEvent *)theEvent
{
	NSInteger usageId = [self getUsageId:[theEvent keyCode]];
	[document lockEmulation];
	((OpenGLHAL *)canvas)->setKey(usageId, false);
	[document unlockEmulation];
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	NSInteger flags = [theEvent modifierFlags];
	
	[self updateFlags:flags forMask:NSLeftControlKeyMask
			  usageId:CANVAS_K_LEFTCONTROL];
	[self updateFlags:flags forMask:NSLeftShiftKeyMask
			  usageId:CANVAS_K_LEFTSHIFT];
	[self updateFlags:flags forMask:NSLeftAlternateKeyMask
			  usageId:CANVAS_K_LEFTALT];
	[self updateFlags:flags forMask:NSLeftCommandKeyMask
			  usageId:CANVAS_K_LEFTGUI];
	[self updateFlags:flags forMask:NSRightControlKeyMask
			  usageId:CANVAS_K_RIGHTCONTROL];
	[self updateFlags:flags forMask:NSRightShiftKeyMask
			  usageId:CANVAS_K_RIGHTSHIFT];
	[self updateFlags:flags forMask:NSRightAlternateKeyMask
			  usageId:CANVAS_K_RIGHTALT];
	[self updateFlags:flags forMask:NSRightCommandKeyMask
			  usageId:CANVAS_K_RIGHTGUI];
	keyModifierFlags = flags;
	
	[document lockEmulation];
	[self synchronizeKeyboardFlags];
	[document unlockEmulation];
}

// Mouse

- (void)mouseEntered:(NSEvent *)theEvent
{
	NSLog(@"CanvasView mouseEntered");
	
	[document lockEmulation];
	((OpenGLHAL *)canvas)->enterMouse();
	[document unlockEmulation];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	NSLog(@"CanvasView mouseExited");
	
	[document lockEmulation];
	((OpenGLHAL *)canvas)->exitMouse();
	[document unlockEmulation];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	NSPoint position = [NSEvent mouseLocation];
	
	[document lockEmulation];
	((OpenGLHAL *)canvas)->setMousePosition(position.x, position.y);
	((OpenGLHAL *)canvas)->moveMouse([theEvent deltaX], [theEvent deltaY]);
	[document unlockEmulation];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	[self mouseMoved:theEvent];
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
	[self mouseMoved:theEvent];
}

- (void)otherMouseDragged:(NSEvent *)theEvent
{
	[self mouseMoved:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[document lockEmulation];
	((OpenGLHAL *)canvas)->setMouseButton(0, true);
	[document unlockEmulation];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[document lockEmulation];
	((OpenGLHAL *)canvas)->setMouseButton(0, false);
	[document unlockEmulation];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
	[document lockEmulation];
	((OpenGLHAL *)canvas)->setMouseButton(1, true);
	[document unlockEmulation];
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
	[document lockEmulation];
	((OpenGLHAL *)canvas)->setMouseButton(1, false);
	[document unlockEmulation];
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
	[document lockEmulation];
	((OpenGLHAL *)canvas)->setMouseButton([theEvent buttonNumber], true);
	[document unlockEmulation];
}

- (void)otherMouseUp:(NSEvent *)theEvent
{
	[document lockEmulation];
	((OpenGLHAL *)canvas)->setMouseButton([theEvent buttonNumber], false);
	[document unlockEmulation];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	[document lockEmulation];
	if ([theEvent deltaX])
		((OpenGLHAL *)canvas)->sendMouseWheelEvent(0, [theEvent deltaX]);
	if ([theEvent deltaY])
		((OpenGLHAL *)canvas)->sendMouseWheelEvent(1, [theEvent deltaY]);
	[document unlockEmulation];
}

// Copy / paste

- (NSString *)copyString
{
	string clipboard;
	
	[document lockEmulation];
	bool result = ((OpenGLHAL *)canvas)->copy(clipboard);
	[document unlockEmulation];
	
	return result ? getNSString(clipboard) : nil;
}

- (void)copy:(id)sender
{
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	NSString *theString = [self copyString];
	
	if (theString)
	{
		NSArray *pasteboardTypes = [NSArray arrayWithObjects:NSStringPboardType, nil];
		[pasteboard declareTypes:pasteboardTypes owner:self];
		
		[pasteboard setString:theString
					  forType:NSStringPboardType];
	}
	else
	{
		NSArray *pasteboardTypes = [NSArray arrayWithObjects:NSTIFFPboardType, nil];
		[pasteboard declareTypes:pasteboardTypes owner:self];
		
		[self lockFocus];
		NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
								 initWithFocusedViewRect:[self bounds]];
		[self unlockFocus];
		
		[pasteboard setData:[rep TIFFRepresentation]
					forType:NSTIFFPboardType];
	}
}

- (void)pasteString:(NSString *)text
{
	[document lockEmulation];
	((OpenGLHAL *)canvas)->paste(getCPPString(text));
	[document unlockEmulation];
}

- (void)paste:(id)sender
{
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	[self pasteString:[pasteboard stringForType:NSStringPboardType]];
}

- (void)startSpeaking:(id)sender
{
	NSString *theString = [self copyString];
	if (theString)
	{
		NSTextView *dummy = [[[NSTextView alloc] init] autorelease];
		[dummy insertText:theString];
		[dummy startSpeaking:self];
	}
}

// Support for the text system

- (BOOL)hasMarkedText
{
	return NO;
}

- (NSRange)markedRange
{
	return NSMakeRange(NSNotFound, 0);
}

- (NSRange)selectedRange
{
	return NSMakeRange(NSNotFound, 0);
}

- (void)setMarkedText:(id)aString
		selectedRange:(NSRange)selectedRange
	 replacementRange:(NSRange)replacementRange
{
}

- (void)unmarkText
{
}

- (NSArray *)validAttributesForMarkedText
{
	return [NSArray array];
}

- (NSAttributedString *)attributedSubstringForProposedRange:(NSRange)aRange
												actualRange:(NSRangePointer)actualRange
{
	return nil;
}

- (void)insertText:(id)aString
  replacementRange:(NSRange)replacementRange
{
	for (NSInteger i = 0; i < [aString length]; i++)
		[self sendUnicodeKeyEvent:[aString characterAtIndex:i]];
}

- (NSUInteger)characterIndexForPoint:(NSPoint)aPoint
{
	return NSNotFound;
}

- (NSRect)firstRectForCharacterRange:(NSRange)aRange
						 actualRange:(NSRangePointer)actualRange
{
	return [self bounds];
}

- (void)doCommandBySelector:(SEL)aSelector
{
}

- (BOOL)drawsVerticallyForCharacterAtIndex:(NSUInteger)charIndex
{
	return NO;
}

@end