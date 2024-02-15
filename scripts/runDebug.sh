#! /usr/bin/bash
# Print when invalid argument is given
function error {
    printf "\e[31mInvalid argument!\e[0m\n"
    printf "Usage: runDebug [-b] [-a <args>] -e <executable>\n"
    printf "  -b: Build the application\n"
    printf "  -a: Arguments for the application\n"
    printf "  -e: Path to the executable\n"
    printf "  -i: Initialise directory/project\n"
    printf "  -v: Verbose output\n"
    exit 1
}

# Build the application
function build {
    printf "\n\n%s\n" "$VDIV"
    printf "\n\e[33mBuilding application...\e[0m\n"
    cmake --build build/Debug 1>$VERBOSEOUTPUT 2>/dev/tty

    if [ -f build/Debug/compile_commands.json ]; then
        ln -s -f build/Debug/compile_commands.json compile_commands.json
    fi
}

function initialise {
    printf "\n\e[33mInitialising directory...\e[0m\n"
    mkdir -p build/Debug >$VERBOSEOUTPUT
    cmake -S . -B build/Debug -DCMAKE_BUILD_TYPE=Debug >$VERBOSEOUTPUT
    mkdir -p logs >$VERBOSEOUTPUT
    mkdir -p .cache >$VERBOSEOUTPUT
    printf "\n\e[32mInitialisation complete!\e[0m\n"
    echo $VDIV
    exit 0
}

# Create Dividing Line
COLUMNS=$(tput cols)
COUNTER=0
VDIV=""
while [ $COUNTER -lt "$COLUMNS" ]; do
    VDIV+="_"
    COUNTER=$((COUNTER + 1))
done

# Parse arguments
ARGS=""
EXECUTABLE=""
VERBOSEOUTPUT=/dev/null
BUILD=0
INITIALISE=0
while getopts "ba:e:iv" o; do
    case $o in
    b) BUILD=1 ;;
    a) ARGS=$OPTARG ;;
    e) EXECUTABLE=$OPTARG ;;
    i) INITIALISE=1 ;;
    v) VERBOSEOUTPUT=/dev/tty ;;
    *) error ;;
    esac
done

if [ $INITIALISE -eq 1 ]; then
    initialise
fi

# Check if build is required
if [ $BUILD -eq 1 ]; then
    build
fi

# Check if executable is given
if [ -z "$EXECUTABLE" ]; then
    if [ -f ".cache/lastExecutable" ]; then
        EXECUTABLE=$(cat .cache/lastExecutable)
    else
        printf "\e[31mNo executable found!\e[0m\n"
        echo "Please provide a path to the executable with -e"
        exit 1
    fi
else
    mkdir .cache 2>$VERBOSEOUTPUT
    echo "$EXECUTABLE" >.cache/lastExecutable
fi

# Formatting
printf "%s\n" "$VDIV"
printf "\n\e[3m Starting programm... \e[0m\n"
sleep 0.2
printf "%s\n\n" "$VDIV"
printf "\e[32m"

# Get current date and time for logName
currentDateTime=$(date +"%H%M%S_%d-%m-%Y")
if [ "$COLUMNS" -gt 102 ]; then
    # Start timer for runtime measurement
    startSecond=$(date +%s%N)
    # Run the programm with in-terminal timestamps and save the output to a log file
    ./"$EXECUTABLE" "$ARGS" |& tee logs/log"${currentDateTime}".txt |
        ts '[%d.%m.%Y %H:%M:%S]'
    # Stop timer for runtime measurement
    endSecond=$(date +%s%N)
else
    # Start timer for runtime measurement
    startSecond=$(date +%s%N)
    # Run the programm and save the output to a log file
    ./"$EXECUTABLE" "$ARGS" |& tee logs/log"${currentDateTime}".txt
    # Stop timer for runtime measurement
    endSecond=$(date +%s%N)
fi
printf "\e[0m"

# Calculate and print runtime
miliSecondDiff=$(((endSecond - startSecond) / 1000000))
printf "\n%s\n" "$VDIV"
printf "\n\e[3m%s\nRuntime: \e[0m\e[1m%s\e[0m\e[3m\n%s\e[0m\n" \
    "Programm has finished!" \
    "${miliSecondDiff}ms" \
    "See logs for more details"
printf "%s\n" "$VDIV"
sleep 0.5

# Check if there are more then 10 log files and if given delete the oldest one
while [ "$(ls logs -1 | wc -l)" -gt 10 ]; do
    echo -e "\e[33mMore then 10 log files have been found!"
    oldestFile="$(ls logs/ -rt | head -n 1)"
    printf "Deleting \e[3m%s\e[0m\n" "$oldestFile"
    rm -- logs/"$oldestFile"
    sleep 0.2
done
