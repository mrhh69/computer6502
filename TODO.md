# Clock Program TODO

## Hardware
  * ~~Solder Battery holder to some wires -> then connect to RTC~~
  * ~~Left Button~~
  * ~~Right Button~~
  * ~~Up Button~~
  * ~~Down Button~~
  * ~~Mode Select Button~~
  * LCD Backlight control
    - One transistor (on/off)
    - OR: two transistors feeding a resistor DAC

## Software
  * Main Loop
    - ~~Use mode select~~
      * ~~to change running "processes"~~
      * to change interrupt handlers?
      * init functions
      * Debounce
    - Use U/D/L/R buttons
      * Get interrupts?
      * Or just poll them (might be better for debouncing, too)


  * Time/date display "process"
    - ~~Display day of the week (three-letters)~~
    - ~~Show day of the month, month~~

  * New date updater
    - Use Buttons
      * Up/Down (++/--), hold for repeat inc/dec
      * Left/Right (field select)
    - ~~Blink effect to show currently selected field~~
    - Add init function

  * New LCD backlight manager
    - Writes to LCD Backlight control
      * Hold MS button for poweroff?
      * Shutdown backlight after some time of inactivity?
    - Handlers for every button, to detect inactivity

  * New alarm manager
    - Alarm consist of hours:minutes
    - Store current alarm in unused RTC memory (persists afer power-off)
    - Blink LED on alarm done
    - Also play music maybe????

  * New timer manager
    - Stores into RTC memory
    - Use timestamps to detect timer done?
    - Or possibly, runouts of VIA timer2
