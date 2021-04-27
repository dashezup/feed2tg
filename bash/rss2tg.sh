#!/bin/bash

# feed2tg, receive RSS/Atom feeds and send to a specified Telegram chat
# Copyright (C) 2021  Dash Eclipse
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Dependencies: curl, xmlstarlet, sed, tac, xargs
# Send RSS 2.0 feeds to Telegram via Bot API
# rsync -arvh -e ssh rss2tg.sh remote:/home/username/.local/bin/rss2tg.sh

FEED_URL=""
LAST_UPDATE_TIME=""

RSS_URL="https://www.theguardian.com/uk/rss"
RSS=$(curl -s $RSS_URL)

TG_BOT_TOKEN=""
TG_CHAT_ID=""

function update-rss() {
	if [ -z "$FEED_URL" ]; then
		echo "$RSS" | xml sel -t -v '/rss/channel/item/link' | sed 's/?.*//g' | sed '$a\' | tac \
		| xargs -I{} curl -o /dev/null -s -F chat_id="$TG_CHAT_ID" -F text={} -F disable_notification=false "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage"
	else
		echo "$RSS" | xml sel -t -v '/rss/channel/item/link' | sed 's/?.*//g' | sed '$a\' | sed '\|'"${FEED_URL}"'|,$d' | tac \
		| xargs -I{} curl -o /dev/null -s -F chat_id="$TG_CHAT_ID" -F text={} -F disable_notification=false "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage"
	fi
}

function update-info() {
	FEED_URL=$(echo "$RSS" | xml sel -t -v '/rss/channel/item/link' | head -n1 | sed 's/?.*//g')
	LAST_UPDATE_TIME=$(date +%Y-%m-%dT%H:%M:%SZ)
	sed -i '\|^FEED_URL=|s|.*|FEED_URL='"\"$FEED_URL\""'|' "$0"
	sed -i '\|^LAST_UPDATE_TIME=|s|.*|LAST_UPDATE_TIME='"\"$LAST_UPDATE_TIME\""'|' "$0"
}

update-rss
update-info
