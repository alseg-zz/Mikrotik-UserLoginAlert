:global LastLogID
:local TelegramBotToken "123456789:2hL214pP8c02Y0vUcfV9LDc58BCZp13te0g"
:local TelegramChatId "-123456789"
:local Hostname [/system identity get name]
:local buf value=[:toarray [/log find where topics=system,info,account and (message~"logged in" or message~"login failure" or message~"logged out")]]; #added filtering by log topics
:local output; #buffer for string message
:local total value=0; #Total records to send
:local totalrec value=[:len $buf]; #Total records in find result;
:local curID;
:local i; #holding ID of current record

:if ([:len $LastLogID]=0) do={
    :set LastLogID value=0; #initialize variable with zero if not
}


:for k from=0 to=($totalrec-1) step=1 do={
  :set $i value=[:pick $buf $k];
    :if ([:typeof $i]!="nil") do={
        :set $curID value=[:tonum [("0x".[:pick [:tostr $i] 1 [:len [:tostr $i]]])]]; #Convert log record ID to integer via hex ( :tonum is not applicable to id type )
        :if ($curID>$LastLogID) do={
            :local CurrentTime value=[/log get $i value-name=time];
            :set $output value=($output."\n*".$Hostname."* ".$CurrentTime." ".[/log get $i value-name=message]."\n---");
            :set $total value=($total+1);
            :set $LastLogID value=$curID;
       }
    }
}

if ($total>0) do={
    :tool fetch mode=https url="https://api.telegram.org/bot$TelegramBotToken/sendMessage" http-method=post http-data="parse_mode=Markdown&chat_id=$TelegramChatId&text=$output" keep-result=no;