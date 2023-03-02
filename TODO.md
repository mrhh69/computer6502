# Software

	* User Program "files"
		- Add a subdirectory for each "program" (.pgm file extension?)
		- For each of those do the following
			* Add in main.s to list
			* Add in ./Makefile
		- Add a lookup table (in main.s)
			* 14 chars null-terminated program name
			* 2-byte pointer to program "file" location in ROM
			* Use the lookup table in "exec" _system calls_ (not jmp exec),
				for the user programs that have no other way to get file ROM location


	* Streams
		- ~~Global stream table~~
			* 14-byte FIFO
			* 1-byte last emptied pointer (last byte that was dealt with in the buf)
			* 1-byte last written pointer (last byte that was written into the buf)
		- ~~PUTC system call~~
      * ~~Add checks for buffer overflows~~
		- ?GETC system call
		- Stream #0 is LCD stream
			* ONLY writes to it are allowed
			* Each LCD command is 2-bytes (byte 1 - type, 2 - data)
			* New routine "try_empty" that tries to empty one byte based on LCD busy
				- Called each time a *second* byte is written
				- If buffer fills up 100%, then this routine is called until it succeeds
