# Running and building.
The project can be run and build using the runDebug.sh script.
_This will only run/build the project in Debug mode_

**Usage: runDebug [-b] [-a <args>] -e <executable>**
    -b: (Re)build the application before running it
    -a: Arguments to be passed to the application
    _In this case the file to be parsed_
    -e: Path to the exetutable
    _Note: The executable only has to be passed in once, or after it's name/location change_

The script will also provide additional functionality, such as writing and managing logs and measuring the applications runtime.

