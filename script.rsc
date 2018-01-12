:local ScheduleName value="UserLoginAlert";
:local TelegramBotToken "123456789:2hL214pP8c02Y0vUcfV9LDc58BCZp13te0g"
:local TelegramChatId "-123456789"
:local Hostname [/system identity get name]
:local StartBuf value=[:toarray [/log find where message~"logged in" or message~"login failure"]];
:local LastTime value=("".[/system scheduler get [find name=$ScheduleName] value-name=comment]);
:local CurrentBuf value=[:toarray ""];

:foreach i in=$StartBuf do={
    :set $CurrentBuf ($CurrentBuf,$i);
};

:local CurrentLineCount value=[:len $CurrentBuf];

if ($CurrentLineCount > 0) do={
    :local CurrentTime value=[/log get [:pick $CurrentBuf ($CurrentLineCount - 1)] value-name=time];
    :if ([:len $CurrentTime] = 15) do={
        :set $CurrentTime value=[:pick $CurrentTime 7 15];
    };

    :local output value=($Hostname." ".$CurrentTime." ".[/log get [:pick $CurrentBuf ($CurrentLineCount - 1)] value-name=message]."\n---");

    :if (([:len $LastTime] < 1) or (([:len $LastTime] > 0) and ($LastTime != $CurrentTime))) do={
        /system scheduler set [find where name=$ScheduleName] comment=$CurrentTime;
        /tool fetch mode=https url="https://api.telegram.org/bot$TelegramBotToken/sendMessage" http-method=post http-data="parse_mode=Markdown&chat_id=$TelegramChatId&text=$output";
    }
}