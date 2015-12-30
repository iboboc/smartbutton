# ESP8266 SmartButtton with NodeMCU


## Requirements
 * ESP8266 ESP-12 or ESP-7
 * USB-TTL adapter for debug/programming
 * 1k, 10k resistors, push button, rgb led(optional)

## Description

With this code, we send a notification online (in cloud) by pressing a button.

## Instructions

### Setting up your hardware

Please read this https://www.hackster.io/iboboc/smartbutton-pro-06ce5d

### Code logic explained:

- set GPIO00 to HIGH (linked to CH_PD) - keep the module enabled after button push
- enable RGB led and light the RED, getting into ON state
- check and load if already is set up SSID name and password and URL
- try to connect to Wi-Fi
- start a timer and if an IP is not set in 10seconds, change the Wi-Fi mode to Access POint with the name "SmartButton" plus the unique ChipID
- start a web server on IP 192.168.1.1 and a form to enter SSID name, password and URL
- on submit, save to internal memmory and restart module
- once connected and an IP is available, change the LED from red to BLUE (connected)
- create a TCP connection and send custom URL
- after sending, LED is changing color from blue to GREEN (success)
- wait 3 seconds (to acknowledge the state)
- close the LED (all colors)
- set GPIO02 to LOW wich will set CH_PD to LOW and module is disabled
- start a timer for 3 sec and reset/clear the config settings (that means that if the module is still powered on, means that button is still pushed, therefore you can reset your config and restart in Access Point mode.


### Connections
- Power.
 - +3.3 volts to Vcc
 - ground
- Communications.
 - TxD on the board to RxD on the adapter
 - RxD on the board to TxD on the adapter
 - Ground
- Jumpers.
 - Connect Vcc to CH_PD to enable the chip
 - Connect GPI0 to Vcc to enable bootmode
 - Connect GPIO15 to GND to enable UART Download
 - Connect GPIO2 to Vcc to enable the ESP (applicable to ESP12/ESP7)
