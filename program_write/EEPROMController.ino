
/* Chip layout (3 -> DATA; 4 -> LATCH; 2 -> CLOCK):
  + / 3 - 4 2
  | | | | | |
  ----------------------
  | 74hc595            |
*/
#define CLOCK 2
#define DATA 3
#define LATCH 4
#define WRITE 5
/* data pins from pin 6 to pin 13 */

#define EEPROM_WC_DELAY 20


/* ----Code from TommyPROM Github---- */



void enableWrite()      { digitalWrite(WRITE, LOW);}
void disableWrite()     { digitalWrite(WRITE, HIGH);}

// set bus direction
void setModeOutput() {
  DDRB |=  0b00111111;
  DDRD |=  0b11000000;
}
void setModeInput() {
  DDRB &= ~0b00111111;
  DDRD &= ~0b11000000;
}

// Read a byte from the data bus.  The caller must set the bus to input_mode
// before calling this or no useful data will be returned.
byte readDataBus() {
  return (PINB << 2) | (PIND >> 6);
}

// Write a byte to the data bus.  The caller must set the bus to output_mode
// before calling this or no data will be written.
void writeDataBus(byte data) {
  PORTB = (PORTB & (~0b00111111)) | (data >> 2);
  PORTD = (PORTD & (~0b11000000)) | (data << 6);
}


// Output the address bits and outputEnable signal using shift registers.
void setAddress(int addr, bool outputEnable) {
    // Set the highest bit as the output enable bit (active low)
    if (outputEnable) {
        addr &= ~0x8000;
    } else {
        addr |= 0x8000;
    }
    byte dataMask =  1 << DATA;
    byte clkMask =   1 << CLOCK;
    byte latchMask = 1 << LATCH;

    // Make sure the clock is low to start.
    PORTD &= ~clkMask;

    // Shift 16 bits in, starting with the MSB.
    for (uint16_t ix = 0; (ix < 16); ix++)
    {
        // Set the data bit
        if (addr & 0x8000)
        {
            PORTD |= dataMask;
        }
        else
        {
            PORTD &= ~dataMask;
        }

        // Toggle the clock high then low
        PORTD |= clkMask;
        delayMicroseconds(3);
        PORTD &= ~clkMask;
        addr <<= 1;
    }

    // Latch the shift register contents into the output register.
    PORTD &= ~latchMask;
    delayMicroseconds(1);
    PORTD |= latchMask;
    delayMicroseconds(1);
    PORTD &= ~latchMask;
}



// Read a byte from the EEPROM at the specified address.
byte readEEPROM(int address) {
    setModeInput();
    setAddress(address, /*outputEnable*/ true);
    return readDataBus();
}

// Write a byte to the EEPROM at the specified address.
void writeEEPROM(int address, byte data) {
    setAddress(address, /*outputEnable*/ false);
    setModeOutput();
    writeDataBus(data);
    enableWrite();
    delayMicroseconds(1);
    disableWrite();
    delay(10);
}

// Write the special six-byte code to turn off Software Data Protection.
void disableSDP() {
    disableWrite();
    setModeOutput();

    setByte(0xaa, 0x5555);
    setByte(0x55, 0x2aaa);
    setByte(0x80, 0x5555);
    setByte(0xaa, 0x5555);
    setByte(0x55, 0x2aaa);
    setByte(0x20, 0x5555);

    setModeInput();
    delay(EEPROM_WC_DELAY);
}

// Write the special three-byte code to turn on Software Data Protection.
void enableSDP() {
    disableWrite();
    setModeOutput();

    setByte(0xaa, 0x5555);
    setByte(0x55, 0x2aaa);
    setByte(0xa0, 0x5555);

    setModeOutput();
    delay(EEPROM_WC_DELAY);
}

// Set an address and data value and toggle the write control.  This is used
// to write control sequences, like the software write protect.  This is not a
// complete byte write function because it does not set the chip enable or the
// mode of the data bus.
void setByte(byte value, word address) {
    setAddress(address, false);
    writeDataBus(value);

    delayMicroseconds(1);
    enableWrite();
    delayMicroseconds(1);
    disableWrite();
}


/* write 64 bytes */
void page_write(char *buf, int addr) {
  disableWrite();
  setModeOutput();
    
  for (int i = 0; i < 64; i++) {
    setByte(buf[i], addr + i);
  }

  setModeInput();
  delay(EEPROM_WC_DELAY);
}







#define SDPOFF 1
#define SDPON 2
#define SADDR 3
#define SLEN 4
#define WRITE 5
#define READ 6
#define PAGE_WRITE 7
#define INTERNALS 8


void setup() {
  pinMode(DATA, OUTPUT);
  pinMode(CLOCK, OUTPUT);
  pinMode(LATCH, OUTPUT);
  digitalWrite(CLOCK, 0);
  digitalWrite(LATCH, 0);
  disableWrite();
  pinMode(WRITE, OUTPUT);

  Serial.begin(115200);

  Serial.write(10);

  char c;
  uint16_t address, length;
  while ((c = Serial.read())) {
    if (c == SDPOFF) disableSDP();
    else if (c == SDPON) enableSDP();

    else if (c == SADDR) Serial.readBytes((char *)&address, 2);
    else if (c == SLEN)  Serial.readBytes((char *)&length, 2);

    else if (c == WRITE) {
      char buf[256];
      Serial.readBytes(buf, length);
      for (int i = 0; i < length; i++) writeEEPROM(address + i, buf[i]/*, true*/);
    }
    else if (c == READ) {
      for (int i = 0; i < length; i++) Serial.write(readEEPROM(address + i));
    }
    else if (c == PAGE_WRITE) {
      char buf[64];
      Serial.readBytes(buf, 64);
      /* address MUST be 64-byte aligned */
      page_write(buf, address);
    }
    else if (c == INTERNALS) {
      Serial.write((char *)&address, 2);
    }
    else if (c == -1) continue; /* no data */
  }

}

void loop() {}









/*
#define EEPROM_WRITE_DELAY_TIME 20


void setAddress(int address, int outputEnable) {
  shiftOut(DATA, CLOCK, MSBFIRST, (address >> 8) | (!outputEnable << 7));
  shiftOut(DATA, CLOCK, MSBFIRST, address);

  PORTD |= 0b00010000;
  PORTD &= 0b11101111;
  PORTD |= 0b00010000;
}


byte readEEPROM(int address) {

  setAddress(address, true);

  DDRB &= 0b11000000;
  DDRD &= 0b00111111;

  byte data = PINB << 2;
  data |= PIND >> 6;

  return data;
}
*/


/* clearOE = true (for single write) clearOE = false (for page write) */
/*
void writeEEPROM(int address, byte value, bool clearOE) {

  DDRD |= 0b11000000;
  DDRB |= 0b00111111;

  setAddress(address, false);

  PORTB = value >> 2;
  PORTD &= 0b00111111;  // Clear Top bits, so that 0's can be written
  PORTD |= value << 6;  //

  delayMicroseconds(1);
  digitalWrite(WRITE, LOW);
  delayMicroseconds(1);
  digitalWrite(WRITE, HIGH);
  if (clearOE) {setAddress(address, true); delay(EEPROM_WRITE_DELAY_TIME);}

}


void disableSDP() {
  writeEEPROM(0x5555, 0xaa, false);
  writeEEPROM(0x2aaa, 0x55, false);
  writeEEPROM(0x5555, 0x80, false);
  writeEEPROM(0x5555, 0xaa, false);
  writeEEPROM(0x2aaa, 0x55, false);
  writeEEPROM(0x5555, 0x20, false);
  delay(EEPROM_WC_DELAY);
}
void enableSDP() {
  writeEEPROM(0x5555, 0xaa, false);
  writeEEPROM(0x2aaa, 0x55, false);
  writeEEPROM(0x5555, 0xa0, false);
  delay(EEPROM_WC_DELAY);
}
*/



/*
void printContents(int startPrint, int ending) {
  int prevData[16] = {0x75, 0x85};
  bool prevEqual = false;


  for (long start = startPrint; start < ending; start += 16) {
    int data[16] = {};
    bool equal = true;

    for (int offset = 0; offset < 16; offset++) {
      int dat = readEEPROM(start + offset);
      data[offset] = dat;
      if (dat != prevData[offset]) {equal = false;}
    }

    char buf[80];
    sprintf(buf,
      "%04x:  %02x %02x %02x %02x %02x %02x %02x %02x  %02x %02x %02x %02x %02x %02x %02x %02x",
      (int)start, data[0],data[1],data[2],data[3],data[4],data[5],data[6],data[7],data[8],
      data[9], data[10], data[11], data[12],data[13], data[14], data[15]);

    if ((!prevEqual || start % 0xfff < 15) && equal) { Serial.println("*");}
    if (!equal) {
      for (int i=0; i<17; i++){prevData[i]=data[i];}
      Serial.println(buf);
    }

    prevEqual = equal;

  }
}


void fillEEPROM(int data, long fillEnd) {
  space(3); Serial.print("FILLING MEMORY WITH 0x"); Serial.print(data, HEX);

  int written = 0;

  for (long addr = 0; addr <= fillEnd; addr++) {

    writeEEPROM(addr, data, false);
    written++;
    if (written == 64) {delay(6); written = 0;}
    if (addr % 0x0fff == 0) {Serial.write(".");}
  }
  space(2); Serial.println(F("DONE!"));
}


bool checkEEPROM(int byteCheck) {
  space(3); Serial.println(F("CHECKING EEPROM...   "));
  delay(10);
  writeEEPROM(0x0000, byteCheck, true);
  delay(10);
  writeEEPROM(0x0001, 0x00, true);
  delay(10);
  if (readEEPROM(0) == byteCheck) {
    space(2); Serial.println(F("CHECK SUCCESS!"));
    return true;
  }
  else {
    space(2); Serial.println(F("CHECK FAILED... Aborting"));
    return false;
  }
}
*/

/*
void writeProgram(byte program[], int programStart, int programLength, int *writeMap) {
  space(2); Serial.println(F("WRITING PROGRAM..."));

  unsigned int NMILocation = searchProgram(program, programLength, true);
  unsigned int IRQLocation = searchProgram(program, programLength, false);


  writeEEPROM(0x7ffc, programStart & 0x00ff, true);
  writeEEPROM(0x7ffd, programStart >> 8, true);  // Reset vector

  writeEEPROM(0x7ffe, IRQLocation & 0x00ff, true);
  writeEEPROM(0x7fff, IRQLocation >> 8, true);

  writeEEPROM(0x7ffa, NMILocation & 0x00ff, true);
  writeEEPROM(0x7ffb, NMILocation >> 8, true);

  unsigned int start = programStart - 0x8000;

  if (*writeMap < 300) {
    space(3); Serial.print("Filling In "); Serial.print(*writeMap - 1); Serial.println(" bytes");
    for (int i = 1; i<*writeMap; i++) {
      writeEEPROM(*(writeMap + i), pgm_read_byte(&program[*(writeMap + i) - start]), true);
    }

  } else {
    space(3); Serial.print("Writing "); Serial.print(programLength); Serial.println(" byte program");
    for (unsigned int i = start; i < programLength; i++) {
      writeEEPROM(i, pgm_read_byte(&program[i - start]), true);
    }
  }

  space(3); Serial.println(F("DONE WRITING PROGRAM!"));
}
*/

/*
unsigned int searchProgram(byte program[], unsigned int programLen, bool NMI) {
  byte NMIcheck[4] = {0xfd, 0x4a, 0x55, 0x3c};
  byte IRQcheck[4] = {0xa3, 0x01, 0x6e, 0xd4};
  byte checkSequence[4];
  if (NMI) { for (int i=0;i<4;i++) {checkSequence[i] = NMIcheck[i];} }
  else { for (int i=0;i<4;i++) {checkSequence[i] = IRQcheck[i];} }
  int checkStep = 0;

  for (int i=0; i < programLen; i++) {
    int readData = pgm_read_byte(&program[i]);
    if (checkSequence[checkStep] == readData) {checkStep++; if (checkStep == 4) {
      if (NMI) {Serial.print(F("NMI SEQUENCE FOUND! NMI AT...  "));}
      else {Serial.print(F("IRQ SEQUENCE FOUND! IRQ AT...  "));}
      Serial.println(i+1+0x8000, HEX);
      return i + 1 + 0x8000;
    }}
    else {checkStep = 0;}
  }

  if (NMI) {Serial.println(F("NO NMI SEQUENCE FOUND... Writing 0x8000"));}
  else {Serial.println(F("NO IRQ SEQUENCE FOUND... Writing 0x8000"));}
  return 0x8000;
}
*/
/*
int * checkProgram(byte program[], int programLen) {
  static int wrongList[256] = {0x58};
  byte wrongPos = 1;

  for (int i = 0; i<programLen; i++) {
    byte r = readEEPROM(i);
    byte p = pgm_read_byte(&program[i]);
    if (r != p) {
      wrongList[wrongPos] = i;
      wrongPos++;
      wrongList[0] = wrongPos;
    }
  }
  return wrongList;
}

int * EEPROMWriteMap(int start, int finish, byte program[]) {
  static word m[300] = {0};
  unsigned int mPos = 1;

  for (int i = start; i<finish; i++) {
    byte r = readEEPROM(i);
    byte p = pgm_read_byte(&program[i]);
    if (r != p) {m[mPos] = i; mPos++; if (mPos >= 300) {break;}}
  }
  m[0] = mPos;
  return m;
}
*/