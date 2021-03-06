#!/bin/bash

if [[ "$1" ]]; then
	OLD=$1
else
	OLD=1
fi
NEW=$OLD
analyze=/nail/home/buck/bin/testify-analyze-log.py
run=/nail/home/buck/pg/devscripts/run-testify-tests

if ! [[ -r failures.$OLD.txt ]]; then
	echo $OLD: copy failing tests from buildbot into failure.$OLD.txt
fi

function run_tests {
	OLD=$NEW
	let NEW=OLD+1

	echo $OLD: re-run the failing tests
	cat failures.$OLD.txt  | $run 2>&1 | tee testing.$NEW.log
	echo $NEW: grep out the failures
	egrep "(fail|error): yelp.tests" testing.$NEW.log |
		sed -r 's/.*(fail|error): yelp\.tests\./yelp.tests./' > failures.$NEW.txt
}

#prime the pump!
run_tests
#keep going as long as tests keep flaking out...
while ! diff -qs failures.$OLD.txt failures.$NEW.txt; do
	run_tests
done

echo REAL FAILURES:
echo
cat failures.$OLD.txt
echo
echo DONE!

