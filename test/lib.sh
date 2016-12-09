#!/bin/bash

TPDIFF_COMMAND=tpdiff
TPDIFF_TEST_COUNT=0
TPDIFF_TEST_FAILURE_COUNT=0
TPDIFF_TEST_RUN_SHELL=bash

# Override `../tpdiff`
export TPDIFF_ANSI_ESCAPE_CODE=E
export TPDIFF_COLOR_CHANGE=C
export TPDIFF_COLOR_INSERT=I
export TPDIFF_COLOR_DELETE=D

#
# Usage:
#
#   assert_equal "123" "123" "message1"
#   assert_equal "foo" "bar" "message2"
#
# Result:
#
#    => message1
#    [OK]
#    => message2
#    [NG] expected: 'foo'
#          but was: 'bar'
#
assert_equal() {
    # Modify variables to local scope.
    # ("local" is undefined in POSIX)
    (
        expect=$1
        actual=$2

        if [ "$expect" = "$actual" ] ; then
            echo "[OK]"
            return 0
        else
            echo "[NG] expected: '${expect}'"
            echo "      but was: '${actual}'"
            return 1
        fi
    )
}

tpdiff__assert() {
    (
        line=$1
        expect=$2
        actual=$(echo "$line" | $TPDIFF_TEST_RUN_SHELL $TPDIFF_COMMAND)

        assert_equal "$expect" "$actual"
    )

    if [ ! $? -eq 0 ] ; then
        TPDIFF_TEST_FAILURE_COUNT=$((TPDIFF_TEST_FAILURE_COUNT+1))
    fi

    TPDIFF_TEST_COUNT=$((TPDIFF_TEST_COUNT+1))
}

tpdiff_assert_colorize_to_change() {
    tpdiff__assert "$1" "EC${1}E[m"
}

tpdiff_assert_colorize_to_insert() {
    tpdiff__assert "$1" "EI${1}E[m"
}

tpdiff_assert_colorize_to_delete() {
    tpdiff__assert "$1" "ED${1}E[m"
}

tpdiff_assert_not_colorize() {
    tpdiff__assert "$1" "$1"
}

tpdiff_summary() {
    echo "${TPDIFF_TEST_COUNT} examples, ${TPDIFF_TEST_FAILURE_COUNT} failures"
}

tpdiff_status() {
    if [ ! $TPDIFF_TEST_FAILURE_COUNT -eq 0 ] ; then
        return 1
    else
        return 0
    fi
}
