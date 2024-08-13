#!/bin/bash
#set -e # exit on error

# Some parts of this file are from https://github.com/dylanaraps/writing-a-tui-in-bash and fall under the MIT license. See the text below for more information. The affected parts are marked with a comment.
## The MIT License (MIT)
##
## # Copyright (c) 2016-2018 Dylan Araps
##
## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Define some colors for the terminal output.
LIGHT_BLUE='\033[1;34m'
GRAY='\033[1;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
DARK_GRAY='\033[1;30m'
LIGHT_GRAY='\033[0;37m'
NC='\033[0m' # No Color

SCROLL_WINDOW_SIZE=5 # Defines the number of lines shown in a scroll window.

export TERM=xterm

#######################################
# This will be called when the user presses ctrl-c and end the current script.
# We will also cleanup a scroll window, if it is open, so that the current terminal is not left in a weird state.
#
# GLOBALS:
#   None
# ARGUMENTS:
#   None
# OUTPUTS:
#   Some debugging output to the terminal.
# RETURN:
#   exitcode 1
#######################################
function ctrl_c {
    scroll_window_stop
    printf "${RED}❌ Aborting Ownia installation. This is not a clean abort, some parts might still be installed.\n${NC}"
    printf "${NC}" # Switch color to normal
    exit 1
}

#######################################
# Clear the next lines. This makes sure that the next commands get written not at the bottom of the terminal, but a few lines above.
# We basically write some empty lines and then put the cursor back to the original position. This helps a lot with the scroll window.
#
# GLOBALS:
#   Sets the sc register to the current cursor position.
# ARGUMENTS:
#   None
# OUTPUTS:
#   Writes 15 empty lines to the terminal
#######################################
function clear_next_lines_to_scroll_down {
    if ! tty -s; then
        return
    fi

    tput sc
    for i in {1..15}; do
        printf "\n"
    done
    tput rc
}

#######################################
# Get the current cursor row.
# Copyright (c) 2016-2018 Dylan Araps, see comment at the top of this file.
#
# GLOBALS:
#   None
# ARGUMENTS:
#   None
# OUTPUTS:
#   echos the current curosor row. Use result=$(row) to call this function.
#######################################
function row {
    local COL
    local ROW
    IFS=';' read -sdR -p $'\E[6n' ROW COL
    echo "${ROW#*[}"
}

#######################################
# Get the current cursor collumn.
# Copyright (c) 2016-2018 Dylan Araps, see comment at the top of this file.
#
# GLOBALS:
#   None
# ARGUMENTS:
#   None
# OUTPUTS:
#   echos the current curosor collumn. Use result=$(row) to call this function.
#######################################
function col {
    local COL
    local ROW
    IFS=';' read -sdR -p $'\E[6n' ROW COL
    echo "${COL}"
}

#######################################
# Get the current cursor collumn.
# Copyright (c) 2016-2018 Dylan Araps, see comment at the top of this file.
#
# GLOBALS:
#   LINES
#   COLUMNS
# ARGUMENTS:
#   None
# OUTPUTS:
#   None
#######################################
function get_term_size {
    # Get terminal size ('stty' is POSIX and always available).
    # This can't be done reliably across all bash versions in pure bash.
    read -r LINES COLUMNS < <(stty size)
}
get_term_size

#######################################
# We want to render text from other scripts or commands with verbose output only in a few lines at the bottom of the terminal.
# So that we have output from the current script visible and the output from the other script does not clutter the terminal.
# Just call scoll_window_start before the beginning of the other script and scroll_window_stop after the other script has finished.#
#
# GLOBALS:
#   Stores the current cursor position in the sc register.
#   SCROLL_WINDOW
# ARGUMENTS:
#   None
# OUTPUTS:
#   Echos the ANSI escape codes to the terminal to limit scrolling to a few lines at the bottom of the terminal and changes the color to dark gray.
#######################################
function scroll_window_start {
    # if ! tty -s; then
    #     return
    # fi

    SCROLL_WINDOW=1 # Global variable to keep track if we are within a scroll window.
    # scroll_window_clear
    tput sc                                     # save current cursor position
    local ROW1=$(row)                           # The start of the scroll window
    local ROW2=$(($ROW1 + $SCROLL_WINDOW_SIZE)) # The end of the scroll window
    printf "\e[%s;%sr" "$ROW1" "$ROW2"          # Limit scrolling from line ROW1 to line ROW2.
    printf '\e[%s;00H' "$ROW1"                  # Move cursor to the beginning of the scroll window
    printf "${DARK_GRAY}"                       # Switch color to dark gray
}

#######################################
# If we end a scroll_window, we need to clear the lines that we wrote content to. This just writes
# n empty lines to the terminal.
#
# GLOBALS:
#   None
# ARGUMENTS:
#   None
# OUTPUTS:
#   Echos the escape code to empty the current line.
#######################################
function scroll_window_clear {
    if ! tty -s; then
        return
    fi

    for i in $(seq 1 $SCROLL_WINDOW_SIZE); do
        echo -e "\033[2K" # Clear line
    done
}

#######################################
# Stops the scroll window and restores the cursor position. Does nothing if no scroll window is active.
#
# GLOBALS:
#   SCROLL_WINDOW
# ARGUMENTS:
#   None
# OUTPUTS:
#   Echos the escape code to empty the current line.
#######################################
function scroll_window_stop {
    if [ $SCROLL_WINDOW = 1 ]; then
        SCROLL_WINDOW=0
        scroll_window_clear
        printf "${NC}" # Switch color to normal
        printf '\e[;r' # reset scrolling margins
        if tty -s; then
            tput rc # Restore cursor position
        fi
    fi
}