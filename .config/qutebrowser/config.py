import pywalQute.draw

config.load_autoconfig()

# helper for normal mode bindings
def nmap(key, command):
    """Bind key to command in normal mode."""
    config.bind(key, command, mode='normal')

# ===== THEMING =====
pywalQute.draw.color(c, {
    'spacing': {
        'vertical': 6,
        'horizontal': 8
    }
})

# ===== UI IMPROVEMENTS =====
c.completion.scrollbar.width = 10
c.tabs.indicator.width = 3  # the colored line on the left of tabs
c.tabs.title.format = '{audio}: {current_title}'
c.tabs.title.alignment = 'left'
c.hints.radius = 0  # square hint boxes
c.hints.scatter = False  # hints appear in order

# ===== BEHAVIOR =====
c.downloads.location.prompt = False  # don't ask where to save
c.downloads.remove_finished = 3000  # remove completed downloads after 3s
c.downloads.position = 'bottom'
c.input.insert_mode.auto_load = True  # start in insert mode on text fields
c.input.insert_mode.auto_leave = False
c.tabs.background = True  # open new tabs in background
c.auto_save.session = True  # remember tabs between sessions

# ===== SEARCH =====
c.url.searchengines = {
    'DEFAULT': 'https://google.com/search?q={}',
    'al': 'https://anilist.co/search/anime?search={}',
    'alm': 'https://anilist.co/search/manga?search={}',
    'yt': 'https://www.youtube.com/results?search_query={}'
}
c.url.start_pages = ['https://www.koryschneider.com/tab/']
c.url.default_page = 'https://www.koryschneider.com/tab/'

# ===== KEY BINDINGS =====

config.bind('<Ctrl-f>', 'fake-key f')

# save session when closing/undoing tabs
nmap('d', 'tab-close ;; session-save --force _autosave')
nmap('u', 'undo ;; session-save --force _autosave')

# media playback with mpv
config.bind('<Ctrl+/>', 'hint links spawn --detach mpv {hint-url}')
config.bind(',M', 'spawn mpv {url}')
config.bind(',m', 'hint links spawn mpv {hint-url}')
config.bind(',d', 'spawn yt-dlp {url}')

# toggle tab position and visibility
config.bind('<Alt+t>', 'config-cycle tabs.position top left')
config.bind('<Alt+Shift+t>', 'config-cycle tabs.show always never')

nmap('<F12>', 'devtools')

# ===== FILE PICKER =====
# uses zenity for native-looking file dialogs
c.fileselect.handler = 'external'
c.fileselect.single_file.command = ['zenity', '--file-selection', '--title=Select File']
c.fileselect.multiple_files.command = ['zenity', '--file-selection', '--multiple', '--title=Select Files']
c.fileselect.folder.command = ['zenity', '--file-selection', '--directory', '--title=Select Folder']

# ===== ADBLOCK SETUP =====
import os
import time
import urllib.request
from pathlib import Path

def pull_adblock(f):
    """download steven black's hosts file for ad/tracker blocking"""
    try:
        req = urllib.request.urlopen('https://raw.githubusercontent.com/stevenblack/hosts/master/hosts')
        with open(f, "w") as file:
            file.write(req.read().decode("utf-8"))
    except:
        pass  # no internet or failed, skip

# auto-update the adblock list once a day
adblock_file = os.path.expanduser('~/.config/qutebrowser/adblock_internet.txt')

if os.path.exists(adblock_file):
    if (time.time() - os.path.getmtime(adblock_file)) > (60 * 60 * 24):
        pull_adblock(adblock_file)
else:
    pull_adblock(adblock_file)

# three blocking lists: internet blocklist, personal blocklist, temp blocks
blockfiles = [
    adblock_file,
    os.path.expanduser('~/.config/qutebrowser/adblock.txt'),
    os.path.expanduser('~/.config/qutebrowser/adblock_temp.txt')
]

# create empty files if they don't exist
for f in blockfiles:
    if not os.path.exists(f):
        Path(f).touch()

# use both hosts blocking and brave-style adblock filters
c.content.blocking.method = "both"
c.content.blocking.hosts.lists = ['file://' + f for f in blockfiles]

# ===== EDITOR SETUP =====
from shutil import which

# use $EDITOR if set
if 'EDITOR' in os.environ:
    c.editor.command = [os.environ['EDITOR'] + ' "{}"']

# prefer qutebrowser-edit if available
if which("qutebrowser-edit"):
    c.editor.command = [which("qutebrowser-edit"), '-l{line}', '-c{column}', '-f{file}']


