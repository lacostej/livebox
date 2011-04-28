# Summarize information from the output of livebox_deconnections
#

@include livebox.awk

BEGIN{ 
  sep = " ; "
  print "#Last connection" sep "[Last disconnection]" sep "duration" sep "IP" sep "Bw up" sep "Bw down"
  lastDisconnectTimestamp = 0; lastDisconnectStr=""; lastIpStr=""; lastBwUpStr=""; lastBwDownStr=""
}
{ 
  n=split($0,A,";")
  if (n >= 17) {
    # connection information isn t always present
    newIpStr=""
    if (match(A[6], /(.*) kb\/s/, b)) { newBwUpStr=b[1] }
    if (match(A[7], /(.*) kb\/s/, b)) { newBwDownStr=b[1] }
    if (match(A[13], /(\w+\.\w+\.\w+\.\w+)/, b)) { newIpStr=b[1] }

    newConnectStr=A[15]
    newDurationStr=A[16]
    newDisconnectStr=A[17]
    
    if (newDisconnectStr != "") {
      newDisconnectTimestamp = strptime(newDisconnectStr)
      newConnectTimestamp = strptime(newConnectStr)
      newDurationTimestamp = length(newDurationStr) > 0 ? strptime2(newDurationStr) : 0
      if (newDurationTimestamp < 15 && newIpStr != "") {
        next
      }
      

      #print newDisconnectTimestamp " " lastDisconnectTimestamp " " lastConnectStr " " lastDisconnectStr
      if (newDisconnectTimestamp - lastDisconnectTimestamp > 2) {
        lastConnectStr = lastDisconnectStr
      }
      if (lastDisconnectStr=="" && newIpStr!="") {
        lastDisconnectStr = newDisconnectStr
        lastDisconnectTimestamp = newDisconnectTimestamp
        lastIpStr = newIpStr
        lastBwUpStr = newBwUpStr
        lastBwDownStr = newBwDownStr
      }
      #print newIpStr " " lastDurationStr " " newDurationStr " " lastConnectStr " " newDisconnectStr " " newDisconnectTimestamp " " newConnectTimestamp " " lastDisconnectTimestamp " " newDurationTimestamp
      # detect disconnect, we have a new start timestamp
      # start time is precise up to 2 seconds. See test case #7
      if (newDisconnectTimestamp - lastDisconnectTimestamp > 2) {
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
