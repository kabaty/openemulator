
/**
 * libemulation
 * Apple-1 Terminal
 * (C) 2010-2011 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Implements an Apple-1 terminal
 */

#include "OEComponent.h"

#include "OEImage.h"
#include "CanvasInterface.h"
#include "ControlBusInterface.h"

#include <queue>

class Apple1Terminal : public OEComponent
{
public:
    Apple1Terminal();
    
    bool setValue(string name, string value);
    bool getValue(string name, string& value);
    bool setRef(string name, OEComponent *ref);
    bool setData(string name, OEData *data);
    bool init();
    
    bool postMessage(OEComponent *sender, int message, void *data);
    
    void notify(OEComponent *sender, int notification, void *data);
    
private:
    OEComponent *device;
    OEComponent *vram;
    OEComponent *controlBus;
    OEComponent *monitorDevice;
    OEComponent *monitor;
    
    OEUInt32 cursorX, cursorY;
    bool clearScreenOnCtrlL;
    bool splashScreen;
    bool splashScreenActive;
    
    OEData font;
    bool canvasShouldUpdate;
    OEImage image;
    bool cursorActive;
    OEUInt32 cursorCount;
    
    ControlBusPowerState powerState;
        
    bool isRTS;
    queue<OEUInt8> pasteBuffer;
    
    void scheduleTimer();
    void loadFont(OEData *data);
    void updateCanvas();
    void clearScreen();
    void putChar(OEUInt8 c);
    void sendKey(CanvasUnicodeChar key);
    void copy(wstring *s);
    void paste(wstring *s);
    void emptyPasteBuffer();
    OEUInt8 *getVRAMData();
};