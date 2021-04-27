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

LAST_ENTRY_LINK=""
LAST_UPDATE_TIME=""

ATOM=$(curl -s "https://www.theverge.com/rss/front-page/index.xml")
TG_BOT_TOKEN=""
TG_CHAT_ID=""


function atom2tg() {
	if [ -z "$LAST_ENTRY_LINK" ]; then
		echo "$ATOM" | xml sel -N atom="http://www.w3.org/2005/Atom" -t -m "/atom:feed/atom:entry/atom:link" -v @href -n | tac \
		| xargs -I{} curl -o /dev/null -s -F chat_id="$TG_CHAT_ID" -F text={} -F disable_notification=false "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage"
	else
		UNREAD=$(echo "$ATOM" | xml sel -N atom="http://www.w3.org/2005/Atom" -t -m "/atom:feed/atom:entry/atom:link" -v @href -n | sed '\|'"${LAST_ENTRY_LINK}"'|,$d' | tac)
		if [ $(echo "$UNREAD" | wc -l) -eq 1 ]; then exit 0; fi
		echo "$UNREAD" | xargs -I{} curl -o /dev/null -s -F chat_id="$TG_CHAT_ID" -F text={} -F disable_notification=false "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage"
	fi
}

function update-info() {
	LAST_ENTRY_LINK=$(echo "$ATOM" | xml sel -N atom="http://www.w3.org/2005/Atom" -t -m "/atom:feed/atom:entry/atom:link" -v @href -n | head -n1)
	LAST_UPDATE_TIME=$(date +%Y-%m-%dT%H:%M:%SZ)
	sed -i '\|^LAST_ENTRY_LINK=|s|.*|LAST_ENTRY_LINK='"\"$LAST_ENTRY_LINK\""'|' "$0"
	sed -i '\|^LAST_UPDATE_TIME=|s|.*|LAST_UPDATE_TIME='"\"$LAST_UPDATE_TIME\""'|' "$0"
}


atom2tg
update-info
