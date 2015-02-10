%h=();

while(<>)
{
    # Order of these must match order they appear in *_all.log
    if (/^HostName:\s+(\w+)/){ $h{'host'} = $1; }
    if (/^TaskName:\s+(\w.*)/){ $h{'taskName'} = $1; }
    if (/^Task To Run:\s+(\w:.*Windows.*)/i){ $h{'task'} = $1; }
    if (/^Repeat: Every:\s+(\w:.*)/i){ $h{'freq'} = $1; }

}
