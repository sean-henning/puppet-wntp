# Class: wntp::ntp
#
# Actions:
#

class ntp::wconfig inherits ntp {

case $operatingsystem: {


'windows': {

file {'C:/Program Files/Puppet Labs/Puppet/sys/timezone2003.bat':
        ensure => present,
		creates   => 'c:\windows\system32\tzutil.exe',
        content => 'c:\windows\system32\tzchange.exe /C \"${wntp::timezone}\"',
		before  => Exec['set_time_zone_2003'],
  }


  exec {'set_time_zone_2003':
    	command => 'c:\\windows\\system32\\cmd.exe  "C:/Program Files/Puppet Labs/Puppet/sys/script/timezone2003.bat"',
		creates   => 'c:\windows\system32\tzutil.exe',
		before  => Service['w32time'],
  }
  
  
file {'C:/Program Files/Puppet Labs/Puppet/sys/timezone.bat':
        ensure => present,
		content => "c:\\windows\\system32\\tzutil.exe /s \"${wntp::timezone}\"",
		creates   => 'c:\windows\system32\tzchange.exe',
		before  => Exec['set_time_zone'],
 } 
  
  
  exec {'set_time_zone':
#    	command => 'c:\\windows\\system32\\tzutil.exe /s \"${wntp::timezone}\"',
		command => 'c:\\windows\\system32\\cmd.exe  "C:/Program Files/Puppet Labs/Puppet/sys/script/timezone.bat',
		creates   => 'c:\windows\system32\tzchange.exe',
		before  => Service['w32time'],
  }
  
  service { 'w32time':
		ensure => 'running',
		enable => true,
		before => Exec['set_time_peer'],
  }

  exec { 'set_time_peer':
    command   => 'c:\\windows\\system32\\w32tm.exe /config /manualpeerlist:${wntp::timeserver} /syncfromflags:MANUAL',
    before    => Exec['w32tm_update_time'],
    logoutput => true,
    timeout   => '60',
  }

  exec {'w32tm_update_time':
    command   => "c:\\windows\\system32\\w32tm.exe /config /update",
    before    => Exec['w32tm_resync'],
    logoutput => true,
    timeout   => '60',
  }

  exec {'w32tm_resync':
    command   => "c:\\windows\\system32\\w32tm.exe /resync /nowait",
    logoutput => true,
    timeout   => '60',
    require   => Exec['w32tm_update_time'],
  }
 }
}
}

