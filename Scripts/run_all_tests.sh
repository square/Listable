
#!/bin/sh

set -e
set -o pipefail

Scripts/run_ios16_tests.sh || ios16_error=true
Scripts/run_ios15_tests.sh || ios15_error=true
Scripts/run_ios14_tests.sh || ios14_error=true

if [ $ios16_error ]; then
	error=true
	echo "iOS 16 Tests Failed."
fi

if [ $ios15_error ]; then
	error=true
	echo "iOS 15 Tests Failed."
fi

if [ $ios14_error ]; then
	error=true
	echo "iOS 14 Tests Failed."
fi

if [ ! $error ]; then
	echo "All Tests Passed."
    exit -1
fi