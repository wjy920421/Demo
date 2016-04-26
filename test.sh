#!/bin/sh

echo "\nBuilding project..."
make clean > /dev/null
make > /dev/null

echo "Compiling test files..."
find ./test_data -name "*.demo"|while read fname; do
    ./demo $fname > /dev/null
done

echo "Running simulator..."
find ./test_data -name "*.i" | while read test_name; do
    ref_name="${test_name/test_data/ref_data}"
    test_result=$(./simulator/sim $test_name)
    ref_result=$(./simulator/sim $ref_name)
    test_result="${test_result//Executed [0-9]* instructions and [0-9]* operations in [0-9]* cycles./}"
    ref_result="${ref_result//Executed [0-9]* instructions and [0-9]* operations in [0-9]* cycles./}"

    if [ "$test_result" = "$ref_result" ]; then
        echo "Success: $test_name"
    else
        echo "Failed: $test_name"

        echo $test_result
        echo $ref_result
    fi;
done

echo "\nCleaning up repository..."
find ./test_data -name "*.i" | while read test_name; do
    rm $test_name > /dev/null
done
find ./test_data -name "*.sl" | while read test_name; do
    rm $test_name > /dev/null
done

echo "\nTests completed.\n"


