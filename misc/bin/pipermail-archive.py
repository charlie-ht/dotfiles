#!/usr/bin/python3

import requests, re

def fetch_from_base_url(base_url, output='.'):
    page = requests.get(base_url)
    for filename in re.findall("\d{4}-November.txt.gz", page.text):
        archive_url = '{}{}'.format(base_url, filename)
        print('Downloading {}'.format(filename))
        archive = requests.get(archive_url)
        archive.raise_for_status()
        with open(output + '/' + filename, 'wb') as handle:
            for block in archive.iter_content(8194):
                handle.write(block)

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description="Give a base-url of the pipermail archive you would like to download locally")
    parser.add_argument("base-url", help="base URL of the pipermail archive (e.g. 'https://lists.webkit.org/pipermail/webkit-gtk/'")
    parser.add_argument("-o",'--output', help="Alternative directory to download files into")
    args = vars(parser.parse_args())
    fetch_from_base_url(args['base-url'], output=args['output'])
    
