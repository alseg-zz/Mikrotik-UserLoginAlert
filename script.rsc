#Mikrotik-UserLoginAlert
#RouterOS 6.41

#Privilegies for running:
#read, write, policy, test

#ToDo:
#1. Add no-error={}

:global LastEventLoginID;
:local TelegramBotToken "1234567890:0m9BBWnyHAmjI7ztFwrFicrOwra5A3";
:local TelegramChatId "-1234567890";
:local Hostname [/system identity get name];
:local TelegramMessageText;
:local EventLogStorage;
:local CurrentTimeStamp;

# *** Entry point ***
:if ([:len $LastEventLoginID]=0) do={
    :set LastEventLoginID value=0;
    :set EventLogStorage [/log find where ((topics=system,info,account and (message~"logged in")) or (topics=system,error,critical and (message~"login failure")))];
    :set LastEventLoginID [:tonum ("0x" . [:pick [:tostr ($EventLogStorage->([:len ($EventLogStorage)]-1))] 1 [:len ($EventLogStorage->([:len ($EventLogStorage)]-1))]])];
    } else={
        :set EventLogStorage [/log find where ((topics=system,info,account and (message~"logged in")) or (topics=system,error,critical and (message~"login failure")))];
        :foreach k in=($EventLogStorage) do={
            :set $CurrentTimeStamp [/log get $k value-name=time];
            :set $CurrentLogMessage [/log get $k value-name=message];
            :if ($LastEventLoginID < [:tonum [("0x" . [:pick [:tostr $k] 1 [:len $k]])]]) do={
                    :set TelegramMessageText ($CurrentTimeStamp . " - " . $Hostname . ":\n" . "`" . $CurrentLogMessage . "`" . "\n---");
                    :tool fetch mode=https url="https://api.telegram.org/bot$TelegramBotToken/sendMessage" http-method=post http-data="parse_mode=Markdown&chat_id=$TelegramChatId&text=$TelegramMessageText" keep-result=no;
                    :set LastEventLoginID [:tonum [("0x" . [:pick [:tostr $k] 1 [:len $k]])]];
                };
            };
        };