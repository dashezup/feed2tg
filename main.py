"""
feed2tg, receive RSS/Atom feeds and send to a specified Telegram chat
Copyright (C) 2021  Dash Eclipse

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""
import json
import os
from time import sleep
from urllib import parse, request
from urllib.error import HTTPError

import feedparser

DIR = os.path.dirname(os.path.realpath(__file__))
JSON_FILE = os.path.join(DIR, 'data.json')


def _read_json() -> dict:
    with open(JSON_FILE) as f:
        feeds = json.load(f)
    return feeds


def _write_json(feeds: dict):
    with open(JSON_FILE, 'w') as f:
        json.dump(feeds, f)


def send_feeds(data: dict):
    bot_token = data['bot_token']
    chat_id = data['chat_id']
    feeds = data['feeds']
    for feed_url, info in feeds.items():
        d = feedparser.parse(feed_url, **info.get('args', {}))
        already_updated: bool = d.status == 304
        if already_updated:
            print(f"Already updated, last modified: {d.get('modified')}")
            continue
        old_entries = feeds[feed_url].get('entries', [])
        new_entries = []
        for entry in reversed(d.entries):
            identifier = entry.get('id') or entry.get('published')
            if not identifier:
                continue
            new_entries.append(identifier)
            if identifier not in old_entries:
                print(f"- {entry.title}: {entry.link}")
                text = (
                    "\U0001f517 "
                    f"<b><a href=\"{entry.link}\">{entry.title}</a> | "
                    f"{d.feed.title}</b>"
                )
                if entry.get('comments'):
                    text += (
                        "\n\U0001f4ac "
                        f"<a href=\"{entry.get('comments')}\">Comments</a>"
                    )
                send_to_telegram(bot_token, chat_id, text, retry=True)
                sleep(2)
        new_args = {x: d.get(x) for x in ('etag', 'modified')}
        new_info = {"args": new_args, "entries": new_entries}
        feeds.update({feed_url: new_info})
        data.update({"feeds": feeds})
    _write_json(data)


def send_to_telegram(bot_token, chat_id, text, retry=True):
    try:
        base_url = f'https://api.telegram.org/bot{bot_token}/sendMessage'
        text = text.encode('utf-8', 'strict')
        text = parse.quote_plus(text)
        url = base_url + f"?text={text}&chat_id={chat_id}&parse_mode=HTML"
        with request.urlopen(url) as f:
            print(str(f.status))
    except HTTPError as e:
        if e.code == 429 and retry:
            sleep(5)
            send_to_telegram(bot_token, chat_id, text, retry=False)


def main():
    data = _read_json()
    send_feeds(data)


if __name__ == '__main__':
    main()
