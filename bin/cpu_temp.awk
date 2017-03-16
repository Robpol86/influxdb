#!/usr/bin/awk -f

function fahrenheit(celsius) {
    return (9 / 5) * celsius + 32
}

BEGIN {
    getline celsius < "/sys/devices/virtual/thermal/thermal_zone0/temp"
    temp_f = fahrenheit(celsius / 1000)
    getline host < "/proc/sys/kernel/hostname"
    print "exec_cpu_temp,name=cpu_temp,unit=degrees_f,host="host" value="temp_f
}
