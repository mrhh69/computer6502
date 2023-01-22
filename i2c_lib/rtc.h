
#ifndef RTC_H
#define RTC_H
// from rtc.s

extern void rtc_write(__reg("a/x") char * buf, __reg("r0") unsigned char buf_len, __reg("r1") unsigned char rtc_addr);
extern void rtc_read (__reg("a/x") char * buf, __reg("r0") unsigned char buf_len, __reg("r1") unsigned char rtc_addr);



#endif
