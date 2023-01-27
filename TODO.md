# Clock Program TODO

## Hardware
  * LCD Backlight control
    - One transistor (on/off)
    - OR: two transistors feeding a resistor DAC
  * Better button interrupt logic (with exor chips + d latch chips)
    - not important, doesn't change the logic, just the chip overhead

## Software
  * Main Loop
    - **Investigate why rtc_write is locking the processor** (same thing that happened with rtc_read)
    - Have two parts of the main loop
      * One, that runs more frequently (64hz) and updates button states
      * Other, that runs periodic clock program code (8hz or less)
    - Debounce MS negative edges
    - Add a background_periodic function to each mode?
      * For alarm update checks and stuff
      * As well as LCD backlight manager
      * And timer
    - ~~Use U/D/L/R buttons~~
      * ~~Store state of buttons~~
      * ~~On interrupt (from interrupt logic), update state & set flag~~
      * ~~Next time through main loop, run interrupt handlers~~


  * ~~Clock display~~

  * Clock updater
    - ~~Use Buttons~~
    - Maybe set Clock Halt on init

  * New LCD backlight manager
    - Writes to LCD Backlight control
      * Hold MS button for poweroff?
      * Shutdown backlight after some time of inactivity?
    - Handlers for every button, to detect inactivity

  * Alarm manager
    - Alarm consist of hours:minutes
    - Store current alarm in unused RTC memory (persists afer power-off)
    - Blink LED on alarm done
    - Also play music maybe????

  * New timer manager
    - Stores into RTC memory
    - Use timestamps to detect timer done?
    - Or possibly, runouts of VIA timer2
