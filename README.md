## ESSX8336 Audio Fix on Infinix laptops (Linux)
This is a guide to fix audio not working on Infinix devices with the essx8336 sound card. Please keep in mind that I own only an **Infinix X2 Plus** (i3 Gen11) so this has not been tested on other variants that come with this same sound card.

> If something in this guide is unclear, you are encouraged to look it up on the internet or ask an AI assistant, _Do not blindly copy-paste commands you do not understand_. \
> Also, please don't assume I'm some wizard writing this guide. Most of it comes from my experience fixing this on my own device.

## Fixing no sound from Internal speakers

**Pre-requisites**:
- Linux kernel version >= 5.19
- Packages required:
    ```
    sof-firmware alsa-ucm-conf alsa-utils pavucontrol
    ```

Check your kernel version (`uname -r`), install the required packages using your distro’s package manager (package names may vary across distros), reboot once, and then proceed with the guide.

## Step 1. Raising DAC value through `alsamixer`
- Open your terminal and run `alsamixer`. It'll open up a TUI
- Press `F6` and select your sound card.
- Make sure the "speaker" isn't muted, i.e it doesn't say "MM", if it does press `M` to unmute.
- Navigate right with the RIGHT arrow key and look for an option that says `DAC`.
- If the value is too low, raise it to somewhere around 85 using the UP arrow key. (If you face distorted sound, you may need to lower this later on. You'll need to find the correct value yourself.)
- Quit out of alsamixer (`Esc`).

Now try playing some audio. If your speaker is working correctly you may skip the 2nd step.
If not proceed to the 2nd step.



## Step 2. Changing the `quirk` option of the audio driver

If you run `alsa-info.sh`, you'll see that the BIOS ACPI tables report the audio codec as `ESSX8326`. While there is codec available for [es8326](https://github.com/torvalds/linux/blob/master/sound/soc/codecs/es8326.c), no SOC specific driver exists for it in the mainline kernel. **[sof-firmware](https://github.com/thesofproject)** has support for `essx8336` cards and with some tweaks it works for `essx8326` too. By forcing the es8336 machine driver to load with the appropriate quirk, we can restore functional audio on this system.

- Open your terminal, yeah again :P
- Add the "quirk" option to the driver
  ```sh
  echo "options snd_soc_sof_es8336 quirk=128" | sudo tee /etc/modprobe.d/speaker-fix.conf
  ```
  More info about the quirk value here: [https://thesofproject.github.io/latest/getting_started/intel_debug/suggestions.html#es8336-support](https://thesofproject.github.io/latest/getting_started/intel_debug/suggestions.html#es8336-support:~:text=Existing%20quirks%20are%20listed%20in%20the%20sound/soc/intel/boards/sof_es8336.c%20machine%20driver%3A) \
  For me only the `SOF_ES8336_HEADPHONE_GPIO` quirk does anything which is BIT(7) or 128 in decimal.
- Restart your laptop and your sound should be fixed now.


### See [MIC_FIX.md](MIC_FIX.md) to fix the mic

### See [COMMON_ISSUES.md](COMMON_ISSUES.md) for fixes to some common issues you'll encounter



### More Resources
If your problem wasn't fixed with this, here are links to some resources where you can find more information:
- https://thesofproject.github.io/latest/getting_started/intel_debug/suggestions.html#es8336-support
- https://github.com/thesofproject/linux/issues/5406
- If you're savvy enough: https://github.com/thesofproject/linux/blob/topic/sof-dev/sound/soc/intel/boards/sof_es8336.c