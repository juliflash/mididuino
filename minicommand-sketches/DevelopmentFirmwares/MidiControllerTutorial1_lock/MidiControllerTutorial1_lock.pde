CCEncoder encoders[4];
EncoderPage encoderPage(&encoders[0], &encoders[1], &encoders[2], &encoders[3]);

void setup() {
  encoders[0].initCCEncoder(0, 0);
  encoders[0].setName("P1");
  encoders[1].initCCEncoder(0, 1);
  encoders[1].setName("P2");
  encoders[2].initCCEncoder(0, 2);
  encoders[2].setName("P3");
  encoders[3].initCCEncoder(0, 3);
  encoders[3].setName("P4");

  encoderPage.setup();
  GUI.setPage(&encoderPage);
}

bool handleEvent(gui_event_t *event) {
  EncoderPage *page = (EncoderPage *)GUI.currentPage();
  if (EVENT_PRESSED(event, Buttons.BUTTON1)) {
    page->lockEncoders();
  } else if (EVENT_RELEASED(event, Buttons.BUTTON1)) {
    page->unlockEncoders();
  }
  
  return false;
}


