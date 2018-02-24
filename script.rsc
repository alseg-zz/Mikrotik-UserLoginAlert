# Mikrotik-UserLoginAlert
# RouterOS 6.41

# Privilegies for running:
# read, write, policy, test

# ToDo:
# Fix bug with unicode login attempts - FIXED
# Fix non-informative output with unicode login attempts - FIXED
# Add excluded events from common log (dude, telnet, etc.) - FIXED
# Optimization code with excluding (:local ExcludeKeywordList {"telnet"; "dude"};) and change code of script

:global LastEventLoginID;
:local CurrentTimeStamp;
:local Hostname [/system identity get name];
:local EventLogStorage;
:local TelegramMessageText;
:local TelegramBotToken "1234567890:0m9BBWnyHAmjI7ztFwrFicrOwra5A3"; # Change this for your value
:local TelegramChatId "-1234567890"; # Change this for your value

# FunctionSendingTelegramMessage
:global FunctionSendingTelegramMessage do={
    :tool fetch mode=https url="https://api.telegram.org/bot$1/sendMessage" http-method=post http-data="parse_mode=Markdown&chat_id=$2&text=$3" keep-result=no;
    :return 0;
    };

# *** Entry point ***
:if ([:len $LastEventLoginID]=0) do={
    :set LastEventLoginID 0;
    :set EventLogStorage [/log find where (((topics=system,info,account and (message~"logged in")) or (topics=system,error,critical and (message~"login failure"))) and !((message~"telnet") or (message~"dude")))];
    :set LastEventLoginID [:tonum ("0x" . [:pick [:tostr ($EventLogStorage->([:len ($EventLogStorage)]-1))] 1 [:len ($EventLogStorage->([:len ($EventLogStorage)]-1))]])];
    } else={
        :set EventLogStorage [/log find where (((topics=system,info,account and (message~"logged in")) or (topics=system,error,critical and (message~"login failure"))) and !((message~"telnet") or (message~"dude")))];
        :foreach k in=$EventLogStorage do={
            :set $CurrentTimeStamp [/log get $k value-name=time];
            :set $CurrentLogMessage [/log get $k value-name=message];
            :if ($LastEventLoginID < [:tonum [("0x" . [:pick [:tostr $k] 1 [:len $k]])]]) do={
                :set TelegramMessageText ($CurrentTimeStamp . " - " . $Hostname . ":\n" . "`" . $CurrentLogMessage . "`" . "\n---");
                
                :do {
                    $FunctionSendingTelegramMessage $TelegramBotToken $TelegramChatId $TelegramMessageText;
                } on-error={
                    $FunctionSendingTelegramMessage $TelegramBotToken $TelegramChatId ($CurrentTimeStamp . " - " . $Hostname . ":\n" . "`" . "Login event occured, but probably login has non-english symbols (unicode)" . "`" . "\n---");
                };
                
                :set LastEventLoginID [:tonum [("0x" . [:pick [:tostr $k] 1 [:len $k]])]];
            };
        };
    };