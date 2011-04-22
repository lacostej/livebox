BEGIN{ 
  total_time_without_net=0
  time_without_net=0
}
{ 
  if (match($0, /(.*) ; (.*) ; (.*) ; (.*) ; .* ; .*/, a)) {
    new_start=a[1]
    new_stop=a[2]
    new_duration = a[3]
    new_ip = a[4]
    if (new_duration == "") {
      if (disconnect=="")
        disconnect=last_stop
    } else {
      if (disconnect != "") {
        t1 = timestamp(disconnect)
        t2 = timestamp(new_start)
        time_without_net = t2 - t1
        total_time_without_net += time_without_net
        print "OFFLINE: FROM " disconnect " TO " new_start " DURATION " timestr(time_without_net)
        disconnect=""
      }
    }
    last_stop=new_stop
    last_start=new_start
  }
  print
}
END {
  print "Total time without internet: " timestr(total_time_without_net)
}
function strptime(str,    hour,min,sec) {
  hour=strtonum(substr(str, 0, 2))
  min=strtonum(substr(str, 4, 2))
  sec=strtonum(substr(str, 7, 2))
  return hour*3600+min*60+sec
}
function timestr(time) {
  return strftime("%H:%M:%S", time - 3600)
}
function timestamp(day_and_time,     b) {
  if (match(day_and_time, /.*, (.*)/, b)) {
    return strptime(b[1])
  }
}