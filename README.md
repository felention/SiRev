# SiRev
Siege Revealer is a script designed to let you find the real name of people using nicknames in Siege. It will also attempt to detect what platform people are on.

Platform:\
Unknown - The in-game name matches the name used on all three platforms.\
Console - The in-game name matches the name used on both consoles.\
PSN - The in-game name matches the one only on PSN.\
XBL - The in-game name matches the one only on Xbox.\
No platform - The user is assumed to be playing on PC.

### Disclaimer
This script does not explicitly breach Siege TOS, and there is no real way for its usage to be detected. That does not, however, mean Ubisoft will not act upon it, as it attempts to bypass the privacy nicknames. This is solely created to aid in the detection of cheaters, and making it easier to track their stats.

There is currently a quick and easy method of deanonymising a privacy nickname by using the block and sending a friend request. Blocking only works twice until you restart the game (checking the overlay blocklist, second checking the Ubisoft Connect blocklist). Sending a friend request will notify that player you've sent a request, which may not be desired, especially when using a nickname yourself.

## Usage
The way this script works, is it takes the data stored in the Match Replay file. Because of this, you must wait for the first round to finish. It takes ~20 seconds to complete, as it makes 10 requests to the Tracker Network for each player.

`bash sirev.sh` - This will check all the players in the current lobby.\
`bash sirev.sh p PLAYER` - If there is one user in particular that you want to grab the real name or platform of, you can run this, replacing "PLAYER" with the in-game name.\
`bash sirev.sh h` `help` - Either of these will display the usage.

If you're using a WSL alternative like MSYS2 recommended below, you will have to open "msys2.exe" to run the above commands, else you're limited to the bat file which only checks the whole lobby.

## Requirements
It would be better to read the requirements before actually getting started.

### MSYS2 | WSL Alternative
As this is a bash script and Siege is only playable on Windows for PC, you will be required to either have WSL enabled and setup, or use an alternative. I recommend MSYS2 For Windows, as this is the simplest and most full environment I can find.\
-Go to [msys2.org](https://www.msys2.org/)\
-Scroll down to "Installation" and click the one `x86_64` one.\
-Double click the downloaded executable and select the install location, you can change the location to wherever you want, like your Documents, Downloads, etc.\
-Place both `sirev.sh` and `setup.bat` into the same location as your MSYS2 install.\
-Double click `setup.bat`, this will download the two tools needed and create a new bat file called ` sirev.bat`. The space at the start is a special character, this will place it above all the other files, so it's easier for you to find and start. You can alt+drag anywhere you like to create a shortcut. Just double click the sirev.bat file and it'll run.

If you're using something else other than MSYS2, you'll have to edit the variables on lines `28` & `29` that suits your solution.

The Curl-Impersonate used in the MSYS2 setup is from a fork by [lexiforest](https://github.com/lexiforest/curl-impersonate) on GitHub. If you're using MSYS2, you can ignore the Curl Impersonate section below.

### Curl Impersonate
This utilises the Tracker Network for grabbing and checking the realnames from the user's UID. As they use Cloudflare, this script uses Curl Impersonate to imitate a real browser, as vanilla Curl uses a different SSL handshake method.\
-Go to [Curl Impersonate](https://github.com/lwthiker/curl-impersonate) on Github.\
-Click "Releases" on the right side with a tag icon.\
-Click "curl-impersonate-v0.6.1.x86_64-linux-gnu.tar.gz", or whichever new version is available.\
-Extract "curl-impersonate-chrome" to the same location you have "sirev.sh" saved to.\
-Rename it to just "curl" or change the name and/or location on line `21`. Starting with "./" if it's in the same directory tree or the full path if it's elsewhere.

## Issues
There are currently two bugs at the time of this release regarding names in Siege.
- The first is where the player has a blank name. Their real name will be set to their Ubisoft name, without platform detection.
- The second is where the player has the old set nickname. For example, they set their custom nickname to "Shooter". In game, it would have set it to that with random numbers, i.e. "Shooter24352". The game might show their name as just "Shooter", even though custom nicknames were disabled. This cannot be detected by this script and the actual name is displayed.
