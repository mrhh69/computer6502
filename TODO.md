# Software


	* Add some memory management
		- malloc
		- free
		- Find code "inspiration" from places
			* Unix source code?
			* ChatGPT?
			* Online somewhere?
		- some block size like ?16 bytes
		- Could be useful
			* Allocating dynamic PPDA's
			* Allocating buffers for streams
			* Allocating variable buffers for block files/transfers

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
		- ~~PUTC system call~~
      * ~~Add checks for buffer overflows~~
		- ?GETC system call
		- ?PIPE system call  (aka. make a new stream)
		- ?CLOSE system call (aka. close a stream)
		- ~~Stream #0 is LCD stream~~
			* ONLY writes to it are allowed
			* Each LCD command is 2-bytes (byte 1 - type, 2 - data)
			* ~~New routine "try_empty" that tries to empty one byte based on LCD busy~~
				- Called each time a *second* byte is written    ?
				- OR called upon some internal clock interrupt (multiple times a second)
				- If buffer fills up 100%, then this routine is called until it succeeds


		* Block files
			- ???Global file table w/ buffers
				* Problem: what if block transfers are larger than the given buffer size?
					-> Because using a gobal file table will limit each to the same size
					-> A better way would be to use a malloc/free call each time
			- READ system call
			- WRITE system call
			- File #0 is RTC
				* Block transfers read/write into rtc buf
				* rtc_buf_flush is done a few times per second
				* (basically rtc_buf_read/write are just taken from _rtc-buf_)
				* But they will have to read/write into _user space_
