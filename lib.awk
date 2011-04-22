function defaultValue(v, d) {
  return v ? v : d
}
function array_idx_of(str, array) {
  for (i = 1; i <= length(array); i ++) {
    if (array[i] == str) return i 
  }
  return 0
}
function timestr(time) {
  return strftime("%H:%M:%S", time - 3600)
}
