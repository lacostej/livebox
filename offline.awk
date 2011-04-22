# parse the output of livebox_deconnections to identify real OFFLINE periods and amount of time without internet
#
@include livebox.awk

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
        t1 = strptime(disconnect)
        t2 = strptime(new_start)
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
