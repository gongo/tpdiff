#!/bin/bash

TPDIFF_COMMAND=tpdiff
TPDIFF_TEST_COUNT=0
TPDIFF_TEST_FAILURE_COUNT=0
TPDIFF_TEST_RUN_SHELL=bash

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
        message=$3

        echo "=> $message"

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

#
# Colorize to red
#
# Usage:
#
#   esc_ansi "text"
#
esc_ansi() {
    (
        message=$1
        escape="$(printf '\033')"

        echo "${escape}[31m${message}${escape}[m"
    )
}

tpdiff__assert() {
    (
        line=$1
        message=$2
        colorize=$3

        actual=$(echo "$line" | $TPDIFF_TEST_RUN_SHELL $TPDIFF_COMMAND)

        if [ "${colorize}" = "true" ] ; then
            expect=$(esc_ansi "$line")
        else
            expect="$line"
        fi

        assert_equal "$expect" "$actual" "$message"
    )

    if [ ! $? -eq 0 ] ; then
        TPDIFF_TEST_FAILURE_COUNT=$((TPDIFF_TEST_FAILURE_COUNT+1))
    fi

    TPDIFF_TEST_COUNT=$((TPDIFF_TEST_COUNT+1))
}

tpdiff_assert_colorize() {
    tpdiff__assert "$1" "$2" 'true'
}

tpdiff_assert_not_colorize() {
    tpdiff__assert "$1" "$2" 'false'
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
