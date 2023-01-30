
#ifndef ALARM_MANAGER_H
#define ALARM_MANAGER_H


#define ALARM_RTC_ADDR 0x10
#define ALARM_RTC_LEN  0x03

void alarm_manager_init();
void alarm_manager_periodic();
void alarm_manager_button();

#endif
