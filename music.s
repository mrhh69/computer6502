

TONE_D2 =13621/2
TONE_E2 =12135/2
TONE_F2 =11454/2
TONE_A2 = 9091/2
TONE_B2 = 8099/2
TONE_D3 = 6811/2
TONE_E3 = 6068/2
TONE_F3 = 5723/2
TONE_A3 = 4546/2
TONE_B3 = 4050/2
TONE_C4 = 3822/2
TONE_E4 = 3034/2
TONE_F4 = 2864/2
TONE_G4 = 2551/2
TONE_FS4= 2703/2
TONE_A4 = 2273/2
TONE_AS4= 2145/2
TONE_B4 = 2025/2
TONE_C5 = 1911/2
TONE_CS5= 1804/2
TONE_D5 = 1703/2
TONE_E5 = 1517/2
TONE_FS5= 1351/2
TONE_B5 = 1012/2
TONE_D6 =  851/2

;BPM external
;BPM = 60
beat_wait = 1000000 * 60 / BPM

sixt_tone   =  beat_wait/4 *  3 / 4
sixt_stop   =  beat_wait/4 *  1 / 4
eighth_tone =  beat_wait/2 *  3 / 4
eighth_stop =  beat_wait/2 *  1 / 4
quarter_tone = beat_wait   *  3 / 4
quarter_stop = beat_wait   *  1 / 4
half_tone    = beat_wait*2 *  4 / 4
half_stop    = beat_wait*2 *  0 / 4


  macro SIXTEENTH
  byte 1 ; tone
  word \1; tone width
  Int24 sixt_tone

  byte 2 ; no-tone
  word 0
  Int24 sixt_stop
  endmacro

  macro EIGHTH ; 1 argument: tone width
  byte 1 ; tone
  word \1; tone width / 2
  Int24 eighth_tone

  byte 2 ; no-tone
  word 0
  Int24 eighth_stop
  endmacro

  macro QUARTER_REST
  byte 2
  word 0
  Int24 beat_wait
  endmacro

  macro QUARTER ; 1 argument: tone width
  ; 1 beat:
  byte 1 ; tone
  word \1; tone width / 2
  Int24 quarter_tone

  byte 2 ; no-tone
  word 0
  Int24 quarter_stop
  endmacro

  macro HALF ; 1 argument: tone width
  ; 2 second:
  byte 1 ; tone
  word \1; tone width / 2
  Int24 half_tone

  byte 2 ; no-tone
  word 0
  Int24 half_stop
  endmacro


  macro Int24
  word (\1 & $ffff)
  byte (\1 >> 16)
  endmacro
