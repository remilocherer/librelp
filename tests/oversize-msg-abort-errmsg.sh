#!/bin/bash
# check if oversize message error is generated by receiver
. ${srcdir}/test-framework.sh
startup_receiver -eerror.out.log 

echo 'Send Message...'
./send -t 127.0.0.1 -p $TESTPORT -m "testmessage1" -d 150000
./send -t 127.0.0.1 -p $TESTPORT -m "testmessage2"

stop_receiver
check_output "error.*frame too long" error.out.log
check_output "testmessage2"
terminate
