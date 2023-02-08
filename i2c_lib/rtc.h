
#ifndef RTC_H
#define RTC_H
// from rtc.s

extern void rtc_write(__reg("r0/r1") char * buf, __reg("x") unsigned char buf_len, __reg("a") unsigned char rtc_addr);
extern void rtc_read (__reg("r0/r1") char * buf, __reg("x") unsigned char buf_len, __reg("a") unsigned char rtc_addr);

extern __reg("a") unsigned char rtcton(__reg("a") unsigned char r);
extern __reg("a") unsigned char ntortc(__reg("r0") unsigned char n);



#endif
