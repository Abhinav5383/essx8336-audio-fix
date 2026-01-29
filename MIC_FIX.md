### The MIC fix is an extension to the speaker fix, so make sure you've gone through that first. 

_If your speaker already works from the get go (without going through the speaker fix) but your mic isn't working even after after going through this MIC FIX guide, I'd suggest going through the speaker fix regardless._

I'll be honest with you, making the mic work is filled with black magic and rituals, so brace yourself for it.

### A Little Test

If you open `pavucontrol` (Volume Control), in the "Input Devices" tab, you'll find your internal mic but it says "unplugged" at the end.

You will see a bar just below the mic name, that is supposed to display sound level that the mic is capturing, but most likely you'll find that it is static.

But here's the thing, go play some audio (anything, a youtube video, some song) and come back to this tab. See anything different? That effing bar moves now.

So let me summarise:
- The mic captures nothing by default
- It captures sound completely fine when you play something on your speaker
- The status of the mic stays "unplugged" all the time

I'm pretty sure at this point you might be thinking, "wtf is happening here".

And, there's one more frustrating thing, even if you see that the mic is capturing audio, but because of that "unplugged" status apps won't even recognise that you've got a mic.

I have not been able to fix this issue, but there _is_ a workaround through which you can get your mic recognised by apps. AND THAT WORKAROUND IS TO CREATE A WHOLE NEW MIC. Yes, that's what we're going to do in the next section

**Please unplug all external microphones/headsets while following this guide. This is to ensure that the virtual mic is created from the correct capture source.**


## Step 3. Creating a Virtual Mic
- Run the following command
    ```sh
    pactl load-module module-remap-source master=$(pactl list sources short | awk '$2 ~ /^alsa_input\./ { print $2 }') source_name=virtual_mic source_properties="device.description='Virtual Mic'"
    ```
    It creates a _temporary_ virtual capture source. (The virtual source will be gone after a reboot or pipewire/pulseaudio restart).

- Now go back to the "Input Devices" tab in pavucontrol, you should see a new entry for the virtual mic. \
    Please note that this new mic inherits all the symptoms from the real mic, but with one exception - it's not shown as "unplugged", which means apps won't just ignore it.

- Now, if you remember from earlier, the mic doesn't capture anything by default. To fix this:
    - Run `alsamixer` (in the terminal ofc)
    - Select your sound card (`F6`)
    - Go right until you find an entry named "Internal" (shown as "Item: Internal Mic" at the top), if it shows "MM" press `M` to unmute it
    - Your mic should now capture sound

- You can test your mic in any app or web-browser, you'll need to restart the app/browser if it was running before fix

_Make sure you explicitly select the virtual mic for input in apps or even better just select the virtual mic as default from `pavucontrol > Input Devices > Click the check icon in front of the virtual mic`_


## Step 4. Making the fix "automatic"
As I said, that command creates a virtual mic but it only lasts for the current session.

You'll need to find out if you are running Pipewire or Pulseaudio.
Run the following command in the terminal
```sh
pactl info | grep "Server Name"
```
It should output something like `Server Name: PulseAudio (on PipeWire 1.4.10)`. If it says pipewire, you can ignore that it also says PulseAudio (Pipewire basically masquerades as PulseAudio for compatibility reasons)

### Pipewire
- Check if the Pipewire config folder exists
    ```sh
    ls ~/.config/pipewire/pipewire.conf.d
    ```
    If it says "no such file or directory" you need to create the directory
    ```sh
    mkdir -p ~/.config/pipewire/pipewire.conf.d
    ```

- Create a pipewire config file to create the virtual_mic automatically
    ```sh
    echo "context.modules = [
        {   name = libpipewire-module-loopback
            args = {
                node.description = \"Virtual Mic\"
                capture.props = {
                    node.target = \"$(pactl list sources short | awk '$2 ~ /^alsa_input\./ { print $2 }')\"
                }
                playback.props = {
                    media.class = \"Audio/Source\"
                    node.name = \"virtual_mic\"
                }
            }
        }
    ]" > ~/.config/pipewire/pipewire.conf.d/99-virtual-mic.conf
    ```

### Pulseaudio

- Copy system config if there is no user level Pulse config
    ```sh
    (ls ~/.config/pulse/default.pa 2>/dev/null && echo "User level config already exists") || (mkdir -p ~/.config/pulse; cp /etc/pulse/default.pa ~/.config/pulse/default.pa; echo "Copied system default config successfully!")
    ```
    **Warning**: If you don’t already have a user-level PulseAudio configuration, running the next command **without first copying the system default config** will break your audio. No need to panic, you can recover by simply deleting `~/.config/pulse/default.pa` and doing a quick reboot.

- Append the load-module command so that PulseAudio loads this module automatically on startup
    ```sh
    echo "load-module module-remap-source master=$(pactl list sources short | awk '$2 ~ /^alsa_input\./ { print $2 }') source_name=virtual_mic source_properties=\"device.description='Virtual Mic'\"" >> ~/.config/pulse/default.pa
    ```