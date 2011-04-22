
BEGIN{ 
  sep = " ; "
  print "#Last connection" sep "[Last disconnection]" sep "duration" sep "IP" sep "Bw up" sep "Bw down"
  lastDisconnectTimestamp = 0; lastDisconnectStr=""; lastIpStr=""; lastBwUpStr=""; lastBwDownStr=""
  
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
  print strptime("mardi 19 avril, 09:14:36")
  print strptime("mardi 19 avril, 09:14:36", 2010)
}
{ 
  if (match($0, /(.*);(.*);(.*);(.*)/, a)) {
    # connection information isn t always present
    newIpStr=""
    if (match(a[1], /.*;(.*) kb\/s;(.*) kb\/s;.*;(\w+\.\w+\.\w+\.\w+);.*/, b)) {
      newBwUpStr=b[1]
      newBwDownStr=b[2]
      newIpStr=b[3]
    }
    newConnectStr=a[2]
    newDurationStr=a[3]
    newDisconnectStr = a[4]
    
    if (newDisconnectStr != "") {
      newDisconnectTimestamp = strptime(newDisconnectStr)

      if (lastDisconnectStr=="" && newIpStr!="") {
        lastDisconnectStr = newDisconnectStr
        lastDisconnectTimestamp = newDisconnectTimestamp
        lastIpStr = newIpStr
        lastBwUpStr = newBwUpStr
        lastBwDownStr = newBwDownStr
      }
      #print lastDurationStr " " newDurationStr " " newDisconnectStr " " newDisconnectTimestamp " " lastDisconnectTimestamp
      # detect disconnect, we have a new start timestamp
      # start time is precise up to one second
      if (newDisconnectTimestamp - lastDisconnectTimestamp > 1) {
        from=lastConnectStr
        to=newDisconnectStr

        print from sep to sep lastDurationStr sep lastIpStr sep lastBwUpStr sep lastBwDownStr
        to=""
        lastDisconnectTimestamp = newDisconnectTimestamp
        lastDurationStr=""
        lastDisconnectStr = newDisconnectStr
        lastIpStr = newIpStr
        lastBwUpStr = newBwUpStr
        lastBwDownStr = newBwDownStr
      }
    }
    if (length(newDurationStr) > 0) {
      lastDurationStr=newDurationStr
      lastConnectStr=newConnectStr
    }
  }
}
END {
  from = lastDurationStr == "" ? lastDisconnectStr : newConnectStr
  print from sep to sep lastDurationStr sep lastIpStr sep lastBwUpStr sep lastBwDownStr
}
function defaultValue(v, d) {
  return v ? v : d
}
# livebox time convert
# "mardi 19 avril, 09:14:36", [2010]
function strptime(str,    year,        b, day, month, time, hour, min, sec, str2) {
  year = defaultValue(year, 1970)
  if (match(str, /.* (.*) (.*), (.*)/, b)) {
    day = b[1]
    month = find_month(b[2])
    time = b[3]
    hour=strtonum(substr(time, 0, 2))
    min=strtonum(substr(time, 4, 2))
    sec=strtonum(substr(time, 7, 2))
    #YYYY MM DD HH MM SS[ DST]
    # FIXME not sure if livebox time is daylight savings time compliant.
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
