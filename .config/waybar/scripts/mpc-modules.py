#!/usr/bin/env python3
import subprocess
import json
def get_song():
    try:
        output = subprocess.run(['mpc', 'current'],
                              capture_output=True,
                              text=True,
                              timeout=2)
        song = output.stdout.strip()
        return song if song else "in this economy?"
    except:
        return "MPD offline"
print(json.dumps({"text": get_song()}))
