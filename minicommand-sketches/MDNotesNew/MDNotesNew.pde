#include <MD.h>
#include <MidiTools.h>
#include <MDRecorder.h>

class ConfigPage_1 : public EncoderPage {
  public:
  RangeEncoder trackEncoder;
  uint8_t track;
  
  ConfigPage_1() :
    trackEncoder(0, 15, "TRK")
  {
    track = 255;
    encoders[0] = &trackEncoder;
  }  
  
  virtual void loop() {
    if (trackEncoder.hasChanged()) {
      track = trackEncoder.getValue();
      GUI.setLine(GUI.LINE2);
      GUI.clearFlash();
      GUI.flash_put_value(0, track);
      if (MD.isMelodicTrack(track)) {
        GUI.flash_p_string_at_fill(8, MD.getMachineName(MD.kit.machines[track].model));
      } else {
        track = 255;
        GUI.flash_p_string_at_fill(8, PSTR("XXX"));
      }
    }
  }
};

class MDNotesSketch : public Sketch {
public:
  ConfigPage_1 configPage_1;
  uint8_t track;

  MDNotesSketch() {
    track = 255;
  }

  void setup() {
    MDTask.setup();
    MDTask.autoLoadKit = true;
    MDTask.reloadGlobal = true;
    MDTask.addOnKitChangeCallback(_onKitChanged);
    GUI.addTask(&MDTask);

    Midi2.setOnNoteOnCallback(_onNoteOnCallbackKeyboard);
//    Midi2.setOnNoteOffCallback(_onNoteOffCallbackKeyboard);

    setPage(&configPage_1);
  }

  void destroy() {
    GUI.removeTask(&MDTask);
    MDTask.destroy();
  }

  void onNoteOn(uint8_t *msg) {
    if (configPage_1.track != 255) {
      MD.sendNoteOn(configPage_1.track, msg[1], msg[2]);
    }
  }
  
  bool handleEvent(gui_event_t *event) {
    if (EVENT_PRESSED(event, Buttons.BUTTON1)) {
      MDRecorder.startRecord(16, 16);
      return true;
    }
    if (EVENT_PRESSED(event, Buttons.BUTTON2)) {
      MDRecorder.looping = true;
      MDRecorder.startPlayback(16);
      return true;
    }
    if (EVENT_PRESSED(event, Buttons.BUTTON3)) {
      MDRecorder.stopPlayback();
      return true;
    }
    if (EVENT_PRESSED(event, Buttons.BUTTON4)) {
      MDRecorder.looping = false;
      MDRecorder.startMDPlayback(16);
      return true;
    }
    return false;
  }
    

  void onKitChanged() {
    GUI.setLine(GUI.LINE1);
    GUI.flash_p_string_fill(PSTR("SWITCH KIT"));
    GUI.setLine(GUI.LINE2);
    GUI.flash_string_fill(MD.kit.name);
    configPage_1.trackEncoder.old = 255;
  }
};

MDNotesSketch sketch;

void setup() {
  sketch.setup();
  MidiClock.mode = MidiClock.EXTERNAL;
  MidiClock.transmit = false;
  MidiClock.start();
  MidiClock.addOn16Callback(_on16Callback);
  GUI.setSketch(&sketch);
  MDRecorder.setup();
}

void loop() {
}

void _onKitChanged() {
  sketch.onKitChanged();
}

void _onNoteOnCallbackKeyboard(uint8_t *msg) {
  sketch.onNoteOn(msg);
}

void _on16Callback() {
  GUI.setLine(GUI.LINE1);
  GUI.put_value(1, MDRecorder.rec16th_counter);
  GUI.put_value(2, MDRecorder.play16th_counter);
  GUI.put_value(3, MDRecorder.eventList.size());
  GUI.setLine(GUI.LINE2);
  GUI.put_value(2, (uint8_t)(MidiClock.div16th_counter % 32));
}