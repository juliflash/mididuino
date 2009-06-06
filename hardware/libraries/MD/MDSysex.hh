#ifndef MDSYSEX_H__
#define MDSYSEX_H__

#include "WProgram.h"
#include "Midi.h"
#include "MidiSysex.hh"

typedef void (*md_callback_t)();
typedef void (*md_status_callback_t)(uint8_t type, uint8_t param);

typedef enum {
    MD_NONE,
    
    MD_GET_CURRENT_KIT,
    MD_GET_KIT,
    
    MD_GET_CURRENT_GLOBAL,
    MD_GET_GLOBAL,
    
    MD_DONE
} getCurrentKitStatus_t;
class MDSysexListenerClass : public MidiSysexListenerClass {
public:
  md_callback_t onPatternMessageCallback;
  md_status_callback_t onStatusResponseCallback;
  md_callback_t onGlobalMessageCallback;
  md_callback_t    onKitMessageCallback;
  md_callback_t onSongMessageCallback;
  md_callback_t onCurrentKitCallback;
  
  getCurrentKitStatus_t mdGetCurrentKitStatus;

public:
  MDSysexListenerClass() : MidiSysexListenerClass() {
    ids[0] = 0;
    ids[1] = 0x20;
    ids[2] = 0x3c;
    onStatusResponseCallback = NULL;
    onGlobalMessageCallback = NULL;
    onKitMessageCallback = NULL;
    onCurrentKitCallback = NULL;
  }

  uint8_t msgType;

  void getCurrentKit(md_callback_t callback);

  void setOnPatternMessageCallback(md_callback_t callback) {
    onPatternMessageCallback = callback;
  }
  
  void setOnCurrentKitCallback(md_callback_t callback) {
    onCurrentKitCallback = callback;
  }
  
  void setOnStatusResponseCallback(md_status_callback_t callback) {
    onStatusResponseCallback = callback;
  }
  void setOnGlobalMessageCallback(md_callback_t callback) {
    onGlobalMessageCallback = callback;
  }
  void setOnKitMessageCallback(md_callback_t callback) {
    onKitMessageCallback = callback;
  }

  void setOnSongMessageCallback(md_callback_t callback) {
    onSongMessageCallback = callback;
  }
  
  void handleGlobalDump(uint8_t c);
  void handleKitDump(uint8_t c);
  
  virtual void start();
  virtual void handleByte(uint8_t byte);
  virtual void end();

  void setup();
};

#include "MDMessages.hh"

extern MDSysexListenerClass MDSysexListener;


#endif /* MDSYSEX_H__ */
