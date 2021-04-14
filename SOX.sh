#! /bin/bash

while getopts "i:" opt; do
  case ${opt} in
    i ) 
    INPUTDIRECTORY=$OPTARG
      ;;
    \? ) echo "Usage: cmd [-i]"
      ;;
  esac
done

if [[ -z "$INPUTDIRECTORY" ]]
then
    echo "Input file path is required."
    exit 1
fi 

DESKTOP=$HOME/Desktop
cd $DESKTOP  

cp -r "$INPUTDIRECTORY" "Temp"

# Strip silence from end of files.
# Store temp copy of output files.
cd "$DESKTOP/Temp"
for D in */ ;
do
    (cd "$D"
    find . -type f -name "*.wav" | while read filename; do
        sox "$filename" -p silence 1 0.001 0.01% | 
        sox -p -p reverse |
        sox -p -p silence 1 0.001 0.01% | 
        sox -p "$(basename -- "$filename")" reverse; 
    done;)
done;

# Add fade in and fade out to avoid popping.
cd "$DESKTOP/Temp"
mkdir "$DESKTOP/Temp2"
for D in */ ;
do
    (cd "$D"
    mkdir "$DESKTOP/Temp2/$(basename -- "$D")"
    find . -type f -name "*.wav" | while read filename; do
        sox "$filename" "$DESKTOP/Temp2/"$(basename -- "$D")"/$(basename -- "$filename")" fade 0.001 0 0.001;
    done;)
done;

#------------------------------------------------------------------------------

# Process stereo files.
# Normalize.
cd "$DESKTOP/Temp2"
mkdir "$DESKTOP/StereoTemp"
for D in */ ;
do
    (cd "$D"
    mkdir "$DESKTOP/StereoTemp/$(basename -- "$D")"
    find . -type f -name "*.wav" | while read filename; do
	   sox "$filename" "$DESKTOP/StereoTemp/"$(basename -- "$D")"/$(basename -- "$filename")" norm -0.1;
    done;)
done;

# Change bit rate and bit depth.
cd "$DESKTOP/StereoTemp"
mkdir "$DESKTOP/Stereo"
for D in */ ;
do
    (cd "$D"
    mkdir "$DESKTOP/Stereo/$(basename -- "$D")"
    find . -type f -name "*.wav" | while read filename; do
	    sox "$filename" -b 16 -r 44100 "$DESKTOP/Stereo/"$(basename -- "$D")"/$(basename -- "$filename")";
    done;)
done;

#------------------------------------------------------------------------------

# Process mono files.
# Convert to mono.
cd "$DESKTOP/Temp2"
mkdir "$DESKTOP/MonoTemp"
for D in */ ;
do
    (cd "$D"
    mkdir "$DESKTOP/MonoTemp/$(basename -- "$D")"
    find . -type f -name "*.wav" | while read filename; do
        sox -v 0.96 "$filename" "$DESKTOP/MonoTemp/"$(basename -- "$D")"/$(basename -- "$filename")" remix 1-2;
    done;)
done;

# Normalize.
cd "$DESKTOP/MonoTemp"
mkdir "$DESKTOP/MonoTemp2"
for D in */ ;
do
    (cd "$D"
    mkdir "$DESKTOP/MonoTemp2/$(basename -- "$D")"
    find . -type f -name "*.wav" | while read filename; do
	   sox "$filename" "$DESKTOP/MonoTemp2/"$(basename -- "$D")"/$(basename -- "$filename")" norm -0.1;
    done;)
done;

# Change bit rate and bit depth.
cd "$DESKTOP/MonoTemp2"
mkdir "$DESKTOP/Mono"
for D in */ ;
do
    (cd "$D"
    mkdir "$DESKTOP/Mono/$(basename -- "$D")"
    find . -type f -name "*.wav" | while read filename; do
	    sox "$filename" -b 16 -r 44100 "$DESKTOP/Mono/"$(basename -- "$D")"/$(basename -- "$filename")";
    done;)
done;

#------------------------------------------------------------------------------

# Clean up.
rm -r "$DESKTOP/Temp"
rm -r "$DESKTOP/Temp2"
rm -r "$DESKTOP/StereoTemp"
rm -r "$DESKTOP/MonoTemp"
rm -r "$DESKTOP/MonoTemp2"

# end checks - number of files in the original directory should match Stereo and Mono directories. All files should be 16-bit. All files in Stereo directory should be stereo. All files in Mono directory should be mono.
