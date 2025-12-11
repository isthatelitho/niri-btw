import pywalQute.draw

config.load_autoconfig()

pywalQute.draw.color(c, {
    'spacing': {
        'vertical': 6,
        'horizontal': 8
    }
})

config.bind('<Ctrl+/>', 'hint links spawn --detach mpv {hint-url}')
c.fileselect.single_file.command = [ 'yad', '--file', '--width', '1280', '--height', '800' ]
c.fileselect.multiple_files.command = [ 'yad', '--file', '--width', '1280', '--height', '800'  ]
c.fileselect.folder.command = [ 'yad', '--file', '--directory', '--width', '1280', '--height', '800'  ]
config.bind('<Alt+t>', 'config-cycle tabs.position top left')
config.bind('<Alt+Shift+t>', 'config-cycle tabs.show always never')
c.url.searchengines['al'] = 'https://anilist.co/search/anime?search={}'
c.url.searchengines['alm'] = 'https://anilist.co/search/manga?search={}'
c.qt.args = ['--enable-features=DnsOverHttps', '--dns-over-https-server=https://cloudflare-dns.com/dns-query']
config.bind(',M', 'spawn mpv {url}')
config.bind(',m', 'hint links spawn mpv {hint-url}')
config.bind(',d', 'spawn yt-dlp {url}')
