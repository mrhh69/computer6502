
#ifndef RTC_CONTROL_H
#define RTC_CONTROL_H


extern void rtc_buf_write(__reg("r0/r1") char * buf, __reg("x") unsigned char buf_len, __reg("a") unsigned char rtc_addr);
extern void rtc_buf_read (__reg("r0/r1") char * buf, __reg("x") unsigned char buf_len, __reg("a") unsigned char rtc_addr);
void rtc_buf_flush();

extern unsigned char rtc_buf[];


#endif
