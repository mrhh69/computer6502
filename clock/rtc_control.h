
#ifndef RTC_CONTROL_H
#define RTC_CONTROL_H


void rtc_buf_read();
void rtc_buf_write();
void rtc_buf_flush();

extern unsigned char rtc_buf[];


#endif
