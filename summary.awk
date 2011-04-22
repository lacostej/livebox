
BEGIN{ 
  sep = " ; "
  print "#Last connection" sep "[Last disconnection]" sep "duration" sep "IP" sep "Bw up" sep "Bw down"
  last_timestamp = 0; last_disconnect=""; last_ip=""; last_bw1=""; last_bw2=""
  
  months[1] = "janvier"
  months[2] = "fevrier"
  months[3] = "mars"
  months[4] = "avril"
  months[5] = "mai"
  months[6] = "juin"
  months[7] = "juillet"
  months[8] = "aout"
  months[9] = "septembre"
  months[10] = "octobre"
  months[11] = "novembre"
  months[12] = "decembre"
  #print strptime("mardi 19 avril, 09:14:36")
}
{ 
  if (match($0, /(.*);(.*);(.*);(.*)/, a)) {
    # connection information isn t always present
    new_ip=""
    if (match(a[1], /.*;(.*) kb\/s;(.*) kb\/s;.*;(\w+\.\w+\.\w+\.\w+);.*/, b)) {
      new_bw1=b[1]
      new_bw2=b[2]
      new_ip=b[3]
    }
    new_connect=a[2]
    new_duration=a[3]
    new_disconnect = a[4]
    
    if (new_disconnect != "") {
      new_timestamp = strptime(new_disconnect)

      if (last_disconnect=="" && new_ip!="") {
        last_disconnect = new_disconnect
        last_timestamp = new_timestamp
        last_ip = new_ip
        last_bw1 = new_bw1
        last_bw2 = new_bw2
      }
      #print last_duration " " new_duration " " new_disconnect " " new_timestamp " " last_timestamp
      # detect disconnect, we have a new start timestamp
      # start time is precise up to one second
      if (new_timestamp - last_timestamp > 1) {
        from=last_connect
        to=new_disconnect

        print from sep to sep last_duration sep last_ip sep last_bw1 sep last_bw2
        to=""
        last_timestamp = new_timestamp
        last_duration=""
        last_disconnect = new_disconnect
        last_ip = new_ip
        last_bw1 = new_bw1
        last_bw2 = new_bw2
      }
    }
    if (length(new_duration) > 0) {
      last_duration=new_duration
      last_connect=new_connect
    }
  }
}
END {
  from = last_duration == "" ? last_disconnect : new_connect
  print from sep to sep last_duration sep last_ip sep last_bw1 sep last_bw2
}
function strptime(str,        b, day, month, time, hour, min, sec, year, str2) {
  if (match(str, /.* (.*) (.*), (.*)/, b)) {
    day = b[1]
    month = find_month(b[2])
    time = b[3]
    hour=strtonum(substr(time, 0, 2))
    min=strtonum(substr(time, 4, 2))
    sec=strtonum(substr(time, 7, 2))
    year=1970
    #YYYY MM DD HH MM SS[ DST]
    str2=sprintf ("%04d %02d %02d %02d %02d %02d" , year, month, day, hour, min, sec)
    return mktime(str2)
  }
}
function find_month(month) {
  for (i = 1; i <= length(months); i ++) {
    if (months[i] == month) return i 
  }
  return 0
}
