namespace MDMelodyHelper {
  bool loadedKit = false;

void onCurrentKitCallback() {
    loadedKit = true;
    GUI.setLine(GUI.LINE1);
    GUI.put_string_fill(MD.kit.name);
}

void handleGuiSysex() {
  if (BUTTON_PRESSED(Buttons.BUTTON1)) {
    loadedKit = false;
    MDSysexListener.getCurrentKit(onCurrentKitCallback);
  }
}

void onControlChangeCallback(uint8_t *msg);

void setupMidi() {
  Midi.setOnControlChangeCallback(onControlChangeCallback);
}

char *noteNames[] = {
  "C",
  "Db",
  "D",
  "Eb",
  "E",
  "F",
  "Gb",
  "G",
  "Ab",
  "A",
  "Bb",
  "B"
};

#define NOTE_OFFSET 8

void onControlChangeCallback(uint8_t *msg) {
  uint8_t channel = MIDI_VOICE_CHANNEL(msg[0]);
  uint8_t track, param;
  MD.parseCC(channel, msg[1], &track, &param);
  if (param == 0) {
    int8_t offset;
    uint8_t pitch = MD.trackGetCCPitch(track, msg[2], &offset);

    GUI.setLine(GUI.LINE1);
    GUI.put_value_at(13, track);
    
    GUI.setLine(GUI.LINE2);
    GUI.put_p_string_at(0, MD.getMachineName(MD.kit.machines[track].model));

    if (pitch == 128) {
      GUI.put_p_string_at_fill(NOTE_OFFSET, PSTR("XXX"));
    } else {
      uint8_t note = pitch % 12;
      uint8_t octave = pitch / 12;
      GUI.put_string_at_fill(NOTE_OFFSET, noteNames[note]);
      GUI.lines[GUI.curLine].data[NOTE_OFFSET + 1] = octave + '0';
      for (uint8_t i = 0; i < offset; i += 2) {
        GUI.lines[GUI.curLine].data[NOTE_OFFSET + 2 + (i >> 1)] = '+';
      }
    }
  }
}

class MDMelodyHelperSketch : public SubSketch {
  public:
void setup() {
  setupMidi();
  GUI.setLine(GUI.LINE1);
  GUI.put_p_string_fill(PSTR("RELOAD KIT"));
      GUI.setLine(GUI.LINE2);
      GUI.put_p_string_fill(PSTR(""));
}


void loop() {
  GUI.updatePage();
  GUI.update();
}

void handleGui() {
  handleGuiSysex();
}

void destroy() {
    Midi.setOnControlChangeCallback(NULL);

}

PGM_P getName() {
  return PSTR("MELODY HELPER");
};

};

MDMelodyHelperSketch sketch;
}
