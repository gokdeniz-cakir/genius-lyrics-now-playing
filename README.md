# genius-lyrics-now-playing

Requires Windows PowerShell 5.1 (not PowerShell 7)

A small PowerShell script that reads what you are playing from Windows Media Control and opens the Genius page for its lyrics. 

I recommend creating a shortcut file and setting a specific key shortcuts to open it directly. 

Target: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\genius-lyrics.ps1"   (-ExecutionPolicy Bypass is needed because windows defaults to blocking unsigned scripts, if you have changed your system-wide execution policy, its fine to not include it.)

Start in: %windir%\System32\WindowsPowerShell\v1.0

Select a combination of keys you like and you are ready to go!
