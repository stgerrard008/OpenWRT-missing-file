cdr_tag="$(echo "$2" | sed -e 's/\"//g; s/\$//g; s/{//g; s/(//g; s/)//g; s/}//g;')"
awk '
function formattime(time)
{
  TEN = 10
  TIME = 60
  text=""
  hour = 0
  min = int(time / TIME)
  sec = time % TIME
  if (min > TIME)
  {
    hour = int(min / TIME)
    min = min % TIME
  }
  if (hour < TEN)
  {
    text = text "0"
  }
  text = text hour ":"
  if (min < TEN)
  {
    text = text "0"
  }
  text = text min ":"
  if (sec < TEN)
  {
    text = text "0"
  }
  time = text sec
  return time
}
{
  TIME_FIELDS="CDRduration,CDRbillsec"
#  FIELD_COUNT=8
#  HEADERS="Caller,From,To,Application,Data,Time,Duration,Status"
#  FIELDS="CDRclid,CDRsrc,CDRdst,CDRlastapp,CDRlastdata,CDRstart,CDRduration,CDRdisposition"
#  FIELD_COUNT=9
  FIELD_COUNT=7
  HEADERS="Caller,To,Context,Time,Duration,Status,User"
  FIELDS="CDRclid,CDRdst,CDRdcontext,CDRstart,CDRduration,CDRdisposition,CDRuserfield"
  split(TIME_FIELDS, time_tag, ",")
  split(HEADERS, header_tag, ",")
  split(FIELDS, field_tag, ",")
  split(cdr_tag, cdr_log, ",")
  reverse=0
  reverse_count=1
  tr_tag="<tr style=\"\" onmouseover=\"this.style.background=\047#e6e6e6\047\" onmouseout=\"this.style.background=\047\047\">"
  if (show_call_reverse == "yes")
  {
    reverse = 1
  }
  printf "<tr>"
  for (i = 1; i <= FIELD_COUNT; i++)
  {
    printf "<th>"  header_tag[i]  "</th>"
  }
  print "</tr>"
  while ((getline line < asterisk_calls) > 0)
  {
    gsub(/\"/, "", line)
    split(line, data, ",")
#    if (!reverse)
#	  {
#      printf tr_tag
#    }
    for (i = 1; i <= FIELD_COUNT; i++)
    {
      for (y in cdr_log)
      {
        if (field_tag[i] == cdr_log[y])
        {
          for (k in time_tag)
          {
            if (time_tag[k] == cdr_log[y])
            {
              data[y] = formattime(data[y])
              break
            }
          }
          if (reverse)
          {
            buf[reverse_count, i] = data[y]
          }
          else
          {
            printf "<td> | " data[y] "</td>"
          }
          break
        }
      }
    }
    if (reverse)
    {
      reverse_count++
    }
    else
    {
      print "</tr>"
    }
  }
  if (reverse)
  {
#   for (i = reverse_count - 1; 1 <= i; i--)
#   {
#      printf tr_tag
      for (j = 1; j <= FIELD_COUNT; j++)
      {
        printf "<td>" buf[i, j] "</td>"
      }
      print "</tr>"
#    }
  }
  close(asterisk_calls)
}' asterisk_calls="$1" cdr_tag="$cdr_tag" show_call_reverse="$show_call_reverse" -

