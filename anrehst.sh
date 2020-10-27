#!/usr/bin/expect

set user xyz
set password abcd 
set hosts [open server_list r]
set pr yes
while {[gets $hosts host] >= 0} {

	spawn sh -c "ssh-copy-id $user@$host"
	expect "Are you:"
	send "$pr\r"
	expect "Password:"
	send "$password\r"
    expect "Password:"
    send "$password\r"
	send "exit\r"
	expect eof
  }
