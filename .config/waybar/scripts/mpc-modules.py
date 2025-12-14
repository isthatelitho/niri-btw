#!/usr/bin/env python3
import subprocess
import json

try:
    result = subprocess.run(['mpc', 'current'], 
                          capture_output=True, 
                          text=True, 
                          timeout=1)
    song = result.stdout.strip() or "in this economy?"
except subprocess.TimeoutExpired:
    song = "MPD timeout"
except FileNotFoundError:
    song = "MPD not installed"
except Exception:
    song = "MPD offline"

print(json.dumps({"text": song}))
