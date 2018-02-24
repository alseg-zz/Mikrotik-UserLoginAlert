# Mikrotik-UserLoginAlert

---

__Screenshot__:

<img src="https://github.com/alseg/Mikrotik-UserLoginAlert/blob/master/Docs/Images/WLAJMLuE2HolWYe.png?raw=true" width="400">

---

__Purpose:__

It is as simple as possible to send messages to the IM Telegram about the user's login in the device.

---

__Privilegies for running:__

`read, write, policy, test`

---

__Installation:__

`/system scheduler add name=Mikrotik-UserLoginAlert start-time=00:00:00 interval=1m on-event=Mikrotik-UserLoginAlert policy=read,write,policy,test`

`/system script add name=Mikrotik-UserLoginAlert source="COPY_PASTE_SCRIPT_TEXT_HERE" policy=read,write,policy,test`

Do not forget change value `TelegramBotToken` and `TelegramChatId`.

---

__Notes__:

Script running periodically (for example, every minutes) and checking log for new login events.
If there have been several logins since the last check, several notifications will be sent.

First commit and tested on RouterOS __6.41__ version.