# Clock Program TODO

## Hardware
  * ~~**Button interrupt logic**~~

  * LCD Backlight control
    - One transistor (on/off)
    - OR: two transistors feeding a resistor DAC

## Software
  * Main Loop
    - ~~Debounce MS~~ (still need to debounce negative edges)
    - Use current mode
      * to change interrupt handlers
    - Add a background_period function to each mode?
      * For alarm update checks and stuff
      * As well as LCD backlight manager
      * And timer
    - ~~Use U/D/L/R buttons~~
      * ~~Store state of buttons~~
      * ~~On interrupt (from interrupt logic), update state & set flag~~
      * ~~Next time through main loop, run interrupt handlers~~


  * ~~Clock display~~

  * Clock updater
    - Use Buttons
      * Up/Down (++/--), hold for repeat inc/dec
      * ~~Left/Right (field select)~~

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
