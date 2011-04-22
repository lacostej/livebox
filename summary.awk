# Summarize information from the output of livebox_deconnections
#

@include livebox.awk

BEGIN{ 
  sep = " ; "
  print "#Last connection" sep "[Last disconnection]" sep "duration" sep "IP" sep "Bw up" sep "Bw down"
  lastDisconnectTimestamp = 0; lastDisconnectStr=""; lastIpStr=""; lastBwUpStr=""; lastBwDownStr=""
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
