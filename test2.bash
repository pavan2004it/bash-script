#!/usr/bin/expect

set user pavan
set password Swordfish@728 
set script bs.sh
set hosts [open server_list r]
set pr yes
while {[gets $hosts host] >= 0} {

	spawn sh -c "ssh $user@$host bash < $script"
	expect "Are you:"
	send "$pr\r"
	expect "Password:"
	send "$password\r"
    expect "Password:"
    send "$password\r"
	send "exit\r"
	expect eof
  }

