# Clock Program TODO

## Hardware
  * LCD Backlight control
    - **One transistor (on/off)**
    - OR: two transistors feeding a resistor DAC
  * 2nd VIA
    - Clean up wires
    - Maybe add interrupt logic (OR the IRQ's together)
  * Solder SD card holder to wires
  * More efficient button interrupt logic (with exor chips + d latch chips)

## Software
  * Main Loop
    - Add a background_periodic function to each mode?
      * For alarm update checks and stuff
      * As well as LCD backlight manager
      * And timer
    - **_DEBUG RTC BUFFER_**
      * It is still not writing out to RTC correctly
      * WHY?


  * ~~Clock display~~

  * Clock updater
    - Maybe set Clock Halt on init
      * and make sure to unset it on de-init,
        -> otherwise clock.c will re-write defaults onto the rtc

  * **New LCD backlight manager**
    - **Special mode (255?)**
      * _NOT_ written in C
      * Automatically starts when MS held or inactivity
      * Automatically stops when button pressed
    - _OR_ Normal mode?
      * Change brightness or contrast
      * Uses button handlers for inactivity
      * ... and add code to main.s to support it specifically?

  * Alarm manager
    - periodic **checks for alarm done** (every few seconds)
    - Blink LED on alarm done
    - Also play music maybe????

  * New timer manager
    - Stores into RTC memory
    - Use timestamps to detect timer done?
    - Or possibly, runouts of VIA timer2
