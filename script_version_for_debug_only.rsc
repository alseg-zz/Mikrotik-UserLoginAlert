#Mikrotik-UserLoginAlert
#RouterOS 6.41

#Privilegies for running:
#read, write, policy, test

#ToDo:
#1. Add comments

:global LastEventLoginID;
:local CurrentTimeStamp;
:local Hostname [/system identity get name];
:local EventLogStorage;
:local TelegramMessageText;
:local TelegramBotToken "123"; #Change this for your value
:local TelegramChatId "123"; #Change this for your value

#FunctionSendingTelegramMessage
:global FunctionSendingTelegramMessage do={
    :log warning message="20";
    :tool fetch mode=https url="https://api.telegram.org/bot$1/sendMessage" http-method=post http-data="parse_mode=Markdown&chat_id=$2&text=$3" keep-result=no;
    :log warning message="22";
    :return 0;
    };

# *** Entry point ***
:if ([:len $LastEventLoginID]=0) do={
    :log warning message="26";
    :set LastEventLoginID 0;
    :log warning message="28";
    :set EventLogStorage [/log find where ((topics=system,info,account and (message~"logged in")) or (topics=system,error,critical and (message~"login failure")))];
    :log warning message="30";
    :set LastEventLoginID [:tonum ("0x" . [:pick [:tostr ($EventLogStorage->([:len ($EventLogStorage)]-1))] 1 [:len ($EventLogStorage->([:len ($EventLogStorage)]-1))]])];
    :log warning message="32";
    } else={
        :log warning message="34";
        :set EventLogStorage [/log find where ((topics=system,info,account and (message~"logged in")) or (topics=system,error,critical and (message~"login failure")))];
        :log warning message="36";
        :foreach k in=($EventLogStorage) do={
            :log warning message="38";
            :set $CurrentTimeStamp [/log get $k value-name=time];
            :log warning message="40";
            :set $CurrentLogMessage [/log get $k value-name=message];
            :log warning message="42";
            :if ($LastEventLoginID < [:tonum [("0x" . [:pick [:tostr $k] 1 [:len $k]])]]) do={
                :log warning message="44";
                :set TelegramMessageText ($CurrentTimeStamp . " - " . $Hostname . ":\n" . "`" . $CurrentLogMessage . "`" . "\n---");
                :log warning message="46";
                $FunctionSendingTelegramMessage $TelegramBotToken $TelegramChatId $TelegramMessageText;
                :log warning message="48";
                :set LastEventLoginID [:tonum [("0x" . [:pick [:tostr $k] 1 [:len $k]])]];
            };
        };
    };