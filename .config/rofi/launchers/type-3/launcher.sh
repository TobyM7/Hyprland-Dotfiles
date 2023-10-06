#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Launcher (Modi Drun, Run, File Browser, Window)
#
## Available Styles
#
## style-1     style-2     style-3     style-4     style-5
## style-6     style-7     style-8     style-9     style-10

folder_path="$HOME/.config/rofi/launchers/type-3/"  # Replace with the desired folder path

# Count the number of files with the .rasi extension
file_count=$(find "$folder_path" -type f -name "style*.rasi" | wc -l)

if [[ $file_count -eq 0 ]]; then
  echo "No files with the .rasi extension found in the folder."
  exit 1
fi

# Generate a random number between 1 and the file count
random_num=$(( ( RANDOM % file_count ) + 1 ))

# Find the file at the randomly generated index
random_file=$(find "$folder_path" -type f -name "style*.rasi" | sed -n "${random_num}p")


echo $random_file
## Run
rofi \
    -show drun \
    -theme $random_file
