#! /bin/bash

orig_dir="/users/derekmiller/Desktop/Test"

cd "/users/derekmiller/Desktop"  
cp -r $orig_dir "Temp"

# Strip silence from end of files.
# Store temp copy of output files.
cd "/users/derekmiller/Desktop/Temp"
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
cd "/users/derekmiller/Desktop/Temp"
mkdir "/users/derekmiller/Desktop/Temp2"
for D in */ ;
do
    (cd "$D"
    mkdir "/users/derekmiller/Desktop/Temp2/$(basename -- "$D")"
    find . -type f -name "*.wav" | while read filename; do
        sox "$filename" "/users/derekmiller/Desktop/Temp2/"$(basename -- "$D")"/$(basename -- "$filename")" fade 0.001 0 0.001;
    done;)
done;

#------------------------------------------------------------------------------

# Process stereo files.
# Normalize.
cd "/users/derekmiller/Desktop/Temp2"
mkdir "/users/derekmiller/Desktop/StereoTemp"
for D in */ ;
do
    (cd "$D"
    mkdir "/users/derekmiller/Desktop/StereoTemp/$(basename -- "$D")"
    find . -type f -name "*.wav" | while read filename; do
	   sox "$filename" "/users/derekmiller/Desktop/StereoTemp/"$(basename -- "$D")"/$(basename -- "$filename")" norm -0.1;
    done;)
done;

# Change bit rate and bit depth.
cd "/users/derekmiller/Desktop/StereoTemp"
mkdir "/users/derekmiller/Desktop/Stereo"
for D in */ ;
do
    (cd "$D"
    mkdir "/users/derekmiller/Desktop/Stereo/$(basename -- "$D")"
    find . -type f -name "*.wav" | while read filename; do
	    sox "$filename" -b 16 -r 44100 "/users/derekmiller/Desktop/Stereo/"$(basename -- "$D")"/$(basename -- "$filename")";
    done;)
done;

#------------------------------------------------------------------------------

# Process mono files.
# Convert to mono.
cd "/users/derekmiller/Desktop/Temp2"
mkdir "/users/derekmiller/Desktop/MonoTemp"
for D in */ ;
do
    (cd "$D"
    mkdir "/users/derekmiller/Desktop/MonoTemp/$(basename -- "$D")"
    find . -type f -name "*.wav" | while read filename; do
        sox -v 0.96 "$filename" "/users/derekmiller/Desktop/MonoTemp/"$(basename -- "$D")"/$(basename -- "$filename")" remix 1-2;
    done;)
done;

# Normalize.
cd "/users/derekmiller/Desktop/MonoTemp"
mkdir "/users/derekmiller/Desktop/MonoTemp2"
for D in */ ;
do
    (cd "$D"
    mkdir "/users/derekmiller/Desktop/MonoTemp2/$(basename -- "$D")"
    find . -type f -name "*.wav" | while read filename; do
	   sox "$filename" "/users/derekmiller/Desktop/MonoTemp2/"$(basename -- "$D")"/$(basename -- "$filename")" norm -0.1;
    done;)
done;

# Change bit rate and bit depth.
cd "/users/derekmiller/Desktop/MonoTemp2"
mkdir "/users/derekmiller/Desktop/Mono"
for D in */ ;
do
    (cd "$D"
    mkdir "/users/derekmiller/Desktop/Mono/$(basename -- "$D")"
    find . -type f -name "*.wav" | while read filename; do
	    sox "$filename" -b 16 -r 44100 "/users/derekmiller/Desktop/Mono/"$(basename -- "$D")"/$(basename -- "$filename")";
    done;)
done;

#------------------------------------------------------------------------------

# Clean up.
rm -r "/users/derekmiller/Desktop/Temp"
rm -r "/users/derekmiller/Desktop/Temp2"
rm -r "/users/derekmiller/Desktop/StereoTemp"
rm -r "/users/derekmiller/Desktop/MonoTemp"
rm -r "/users/derekmiller/Desktop/MonoTemp2"

# end checks - number of files in the original directory should match Stereo and Mono directories. All files should be 16-bit. All files in Stereo directory should be stereo. All files in Mono directory should be mono.
