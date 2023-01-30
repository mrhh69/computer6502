# Clock Program TODO

## Hardware
  * 2nd VIA
    - Maybe add interrupt logic (OR the IRQ's together)
    - Clean up wires
  * LCD Backlight control
    - One transistor (on/off)
    - OR: two transistors feeding a resistor DAC
  * Solder SD card holder to wires
  * More efficient button interrupt logic (with exor chips + d latch chips)

## Software
  * Main Loop
    - ~~**Debounce MS negative edges**~~
    - Add a background_periodic function to each mode?
      * For alarm update checks and stuff
      * As well as LCD backlight manager
      * And timer
    - Use an RTC buffer that updates infrequently
      * user programs can read out of that to minimize spi bus usage
      * Possibly also write into buffer, and flush to RTC?
      * makes it more OS-like


  * ~~Clock display~~

  * Clock updater
    - Maybe set Clock Halt on init
      * and make sure to unset it on de-init,
        -> otherwise clock.c will re-write defaults onto the rtc

  * New LCD backlight manager
    - Writes to LCD Backlight control
      * Hold MS button for poweroff?
      * Shutdown backlight after some time of inactivity?
    - Handlers for every button, to detect inactivity

  * Alarm manager
    - ~~Store current alarm in unused RTC memory~~
    - periodic checks for alarm done (every few seconds)
    - Blink LED on alarm done
    - Also play music maybe????

  * New timer manager
    - Stores into RTC memory
    - Use timestamps to detect timer done?
    - Or possibly, runouts of VIA timer2
