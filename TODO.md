# Clock Program TODO

## Hardware
  * Left Button
  * Right Button
  * Up Button
  * Down Button
  * Mode Select Button
  * LCD Backlight control
    - One transistor (on/off)
    - OR: two transistors feeding a resistor DAC

## Software
  * Main Loop
    - Use mode select
      * to change running "processes"
      * to change interrupt handlers?
    - Find a way to get interrupts from all buttons?
    - Or just poll them (might be better for debouncing, too)


  * Time/date display "process"
    - Display day of the week (three-letters)
    - Show day of the month (two-digits, maybe w/o leading zero?)

  * New date updater
    - Use Buttons
      * Up/Down (++/--), hold for repeat inc/dec
      * Left/Right (field select)
    - Blink effect to show currently selected field?

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
