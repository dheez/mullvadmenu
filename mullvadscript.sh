#!/bin/bash

menucmd="dmenu -l 15"
fullinfo="$(mullvad relay list | grep -E "[a-zA-Z ,]* \([a-z]*\)")"
countries="$(echo "$fullinfo" | grep -Eo "[a-zA-Z ,]* \([a-z]*\)$")"

choiceOne=$(printf "connect\ndisconnect" | $menucmd -p "MullvadVPN")

case $choiceOne in
	connect)
		CountryChoice="$(dmenu -p "select Country: " <<< "$countries")"
		interval="$(grep -A1 "$CountryChoice" <<< "$countries" | awk '{print $1}')"
		if [ $(wc -l <<< "$interval") -ge 2 ]; then
			cities="$(awk "/$(sed '1!d' <<< "$interval")/{flag=1; next} /$(sed '2!d' <<< "$interval")/{flag=0} flag" <<< "$fullinfo" | grep -Eo "[a-zA-Zäöü ,]* ?[A-Z]{2}? \([a-z]*\)")"
		else
			cities="$(awk "/$(echo "$interval")/{flag=1; next} flag" <<< "$fullinfo" | grep -Eo "[a-zA-Zäöü ,]* ?[A-Z]{,2} \([a-z]*\)")"
		fi
		cityChoice="$(dmenu -p "select City: " <<< "$cities")"
		countrykey="$(grep -Eo "\([a-z]*\)" <<< "$CountryChoice" | sed 's,(,,g;s,),,g')"
		citykey="$(grep -Eo "\([a-z]*\)" <<< "$cityChoice" | sed 's,(,,g;s,),,g')"
		mullvad relay set location $countrykey $citykey
		mullvad connect;;
	disconnect)
		mullvad disconnect;;
esac
