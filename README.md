# genius-lyrics-now-playing

A script that reads what you are playing from system media APIs and opens the Genius page for its lyrics. (Fallsback to search on the Genius site if it cant find a valid page)

Works with any app that reports to system media controls (Spotify, Apple Music, YouTube in browser, etc.)

## Windows

Requires Windows PowerShell 5.1 (doesn't work with PowerShell 7)

I recommend creating a shortcut file and setting a specific key shortcut to open it directly.

Target: `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\genius-lyrics.ps1"`

(`-ExecutionPolicy Bypass` needed because Windows defaults to blocking unsigned scripts)

Start in: `%windir%\System32\WindowsPowerShell\v1.0`

Select a combination of keys you like and you are ready to go!

## macOS

Requires macOS 15.4+ 

Make the script executable:
```bash
chmod +x genius-lyrics.sh
```

Run it:
```bash
./genius-lyrics.sh
```

To set up a keyboard shortcut, you can use Automator to create a Quick Action that runs the script, then assign a shortcut in System Settings → Keyboard → Keyboard Shortcuts.
