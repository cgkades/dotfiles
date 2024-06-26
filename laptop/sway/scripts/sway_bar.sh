#!/bin/bash
# Change this according to your device
################
# Variables
################

# Keyboard input name
keyboard_input_name="1:1:AT_Translated_Set_2_keyboard"

# Date and time
date_and_week=$(date "+%Y/%m/%d (w%-V)")
current_time=$(date "+%H:%M")

#############
# Commands
#############

# Battery or charger
battery_charge=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "percentage" | awk '{print $2}')
battery_status=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "state" | awk '{print $2}')

# Audio and multimedia
audio_volume=$(amixer sget Master | awk -F"[][]" '/Left:/ {print $2}')
audio_is_muted=$(amixer sget Master | awk '/Left:/ {print $6}')
media_artist=$(playerctl metadata artist)
media_song=$(playerctl metadata title)
player_status=$(playerctl status)

# Network
network=$(ip route get 1.1.1.1 | grep -Po '(?<=dev\s)\w+' | cut -f1 -d ' ')
# interface_easyname grabs the "old" interface name before systemd renamed it
interface_easyname=$(nmcli device status | grep -v externally | grep connected | awk '{print $1}')
wifi_network=$(nmcli dev status | awk '/wifi/ {print $4}')
bars=$(nmcli dev wifi | grep $wifi_network | grep "^*" | head -n 1 | awk '{print $9}')

# Others
language=$(swaymsg -r -t get_inputs | awk '/1:1:AT_Translated_Set_2_keyboard/;/xkb_active_layout_name/' | grep -A1 '\b1:1:AT_Translated_Set_2_keyboard\b' | grep "xkb_active_layout_name" | awk -F '"' '{print $4}')
loadavg_5min=$(cat /proc/loadavg | awk -F ' ' '{print $2}')

# Removed weather because we are requesting it too many times to have a proper
# refresh on the bar
#weather=$(curl -Ss 'https://wttr.in/Pontevedra?0&T&Q&format=1')

if [ $battery_status = "discharging" ]; then
	battery_pluggedin='⚠'
else
	battery_pluggedin='⚡'
fi

if ! [ $network ]; then
	network_active="⛔"
else
	network_active="⇆"
fi

if [[ $player_status = "Playing" ]]; then
	song_status='▶'
elif [[ $player_status = "Paused" ]]; then
	song_status='⏸'
else
	song_status='⏹'
fi

if [[ $audio_is_muted = "[off]" ]]; then
	audio_active='🔇'
else
	audio_active='🔊'
fi

echo "🎧 $song_status $media_artist - $media_song | ⌨ $language | $network_active $interface_easyname $wifi_network $bars | 🏋 $loadavg_5min | $audio_active $audio_volume | $battery_pluggedin $battery_charge | $date_and_week 🕘 $current_time"
