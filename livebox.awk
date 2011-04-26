@include lib.awk

# livebox time convert
# "mardi 19 avril, 09:14:36", [2010]
function strptime(str,     year,        b, day, month, time, hour, min, sec, str2) {
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

  year = defaultValue(year, 1970)
  if (match(str, /.* (.*) (.*), (.*)/, b)) {
    day = b[1]
    month = array_idx_of(b[2], months)
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

# "09:14:36" => nb of seconds since start
function strptime2(str,            b, day, month, time, hour, min, sec, str2) {
  return strptime("xxx 1 janvier, " newDurationStr) + 3600
}



