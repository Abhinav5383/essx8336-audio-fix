## Pop sound on startup
The speaker 'pops' when you boot you device and when you play media for the first time. No fix available to this, so just accept it as a minor inconvenience.


## The speaker randomly stops working
You are playing music (or anything) you do some mundane thing like close a browser tab or save a file in a text editor and out of nowhere your speaker stops working. I have no idea why this happens, what I do know is how to fix this.

- #### Manual method
    - Open pavucontrol (Volume control)
    - Go to 'Configuration' tab
    - Switch to a different profile like 'Off', 'Pro Audio' etc
    - Now switch back to your original profile (Stereo Output + Stereo Input)
    - Now resume your media and it should be fixed

- #### Automatic method
    - Copy/download the [scripts/toggle-profile.sh](scripts/toggle-profile.sh) script to an accessible location like `~/scripts/toggle-profile.sh`
    - Make the script executable `chmod +x ~/scripts/toggle-profile.sh`
    - Now you can either run the script manually when this problem happens \
    or \
    bind it to a keyboard shortcut for convenience (I have it bound to `SUPER + Shift + R`)

    _You will need to install `playerctl` to auto-resume previously playing media after running the script. If you don't want/need that, remove the line `MEDIA_STATE=$(playerctl status 2>/dev/null)` from the script_


## The mic gets muted after each reboot
This one is an easy fix, just unmute the mic from `alsamixer`. Refer to [MIC_FIX.md](MIC_FIX.md#L40) for the exact steps.

I've also provided a script ([scripts/unmute-mic.sh](scripts/unmute-mic.sh)) to do it automatically. You can run this script on session start to unmute the mic automatically each time.