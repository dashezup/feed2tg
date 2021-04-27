## feed2tg

Receive RSS/Atom feeds and send to a specified Telegram chat

### Setup

1. Install and configure

```
cp data_sample.json data.json
# edit data.json
virtualenv venv
venv/bin/pip install -U -r requirements.txt
```

2. Run the python script as a crontab job

`0 * * * * /path/to/feed2tg/venv/bin/python /path/to/feed2tg/main.py`

### LICENSE

AGPL-3.0-or-later

```
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
```
