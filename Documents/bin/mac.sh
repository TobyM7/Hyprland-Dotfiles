#!/bin/bash
sudo ifconfig wlan0 down
sudo macchanger -r wlan0
sudo ifconfig wlan0 up
