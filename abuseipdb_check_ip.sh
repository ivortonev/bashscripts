#!/bin/bash

CAT="/usr/bin/cat"
JQ="/usr/bin/jq"
CURL="/usr/bin/curl"
ECHO="/usr/bin/echo"

TEMP_FILE_ABUSEIPDB=`/usr/bin/mktemp`
TEMP_FILE_CROWDSEC=`/usr/bin/mktemp`

URL_ABUSEIPDB="https://api.abuseipdb.com/api/v2/check"
KEY_ABUSEIPDB="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

URL_CROWDSEC="https://cti.api.crowdsec.net/v2/smoke"
KEY_CROWDSEC="XXXXXXXXXXXXXXXXXXXXXXXXXX"

$CURL -G $URL_ABUSEIPDB \
	--data-urlencode "ipAddress=$1" \
	-d maxAgeInDays=30 \
	-H "Key: $KEY_ABUSEIPDB" \
	-H "Accept: application/json" > $TEMP_FILE_ABUSEIPDB 2>/dev/null

DT_IP_AIPDB=`$CAT $TEMP_FILE_ABUSEIPDB | $JQ '.data.ipAddress'`
DT_IS_WL_AIPDB=`$CAT $TEMP_FILE_ABUSEIPDB | $JQ '.data.isWhitelisted'`
DT_CONFIDENCE_AIPDB=`$CAT $TEMP_FILE_ABUSEIPDB | $JQ '.data.abuseConfidenceScore'`
DT_COUNTRY_AIPDB=`$CAT $TEMP_FILE_ABUSEIPDB | $JQ '.data.countryCode'`
DT_TYPE_AIPDB=`$CAT $TEMP_FILE_ABUSEIPDB | $JQ '.data.usageType'`
DT_ISP_AIPDB=`$CAT $TEMP_FILE_ABUSEIPDB | $JQ '.data.isp'`
DT_DOMAIN_AIPDB=`$CAT $TEMP_FILE_ABUSEIPDB | $JQ '.data.domain'`
DT_IS_TOR_AIPDB=`$CAT $TEMP_FILE_ABUSEIPDB | $JQ '.data.isTor'`
DT_NUM_REPORTS_AIPDB=`$CAT $TEMP_FILE_ABUSEIPDB | $JQ '.data.totalReports'`
DT_NUM_USERS_AIPDB=`$CAT $TEMP_FILE_ABUSEIPDB | $JQ '.data.numDistinctUsers'`

$ECHO "####################################################"
$ECHO "#"
$ECHO "# Report para o IP $1 do AbuseIPDB"
$ECHO "#"
$ECHO "####################################################"
$ECHO ""
$ECHO "Whitelist		:	$DT_IS_WL_AIPDB" 
$ECHO "Probabilidade [0-100]	:	$DT_CONFIDENCE_AIPDB"
$ECHO "Pais			:	$DT_COUNTRY_AIPDB"
$ECHO "Tipo			:	$DT_TYPE_AIPDB"
$ECHO "Provedor		:	$DT_ISP_AIPDB"
$ECHO "Dominio			:	$DT_DOMAIN_AIPDB"
$ECHO "Peer TOR		:	$DT_IS_TOR_AIPDB"
$ECHO "Num. reports		:	$DT_NUM_REPORTS_AIPDB"
$ECHO "Num. usuarios		:	$DT_NUM_USERS_AIPDB"

$CURL -H "x-api-key: $KEY_CROWDSEC" $URL_CROWDSEC/$1> $TEMP_FILE_CROWDSEC 2>/dev/null 

DT_CONFIDENCE_CS=`$CAT $TEMP_FILE_CROWDSEC | $JQ '.ip_range_score'`
DT_COUNTRY_CS=`$CAT $TEMP_FILE_CROWDSEC | $JQ '.location.country'`
DT_REVERSE_IP_CS=`$CAT $TEMP_FILE_CROWDSEC | $JQ '.reverse_dns'`
DT_AGGRESSIVENESS_OVERALL=`$CAT $TEMP_FILE_CROWDSEC | $JQ '.scores.overall.aggressiveness'`
DT_AGGRESSIVENESS_LASTDAY=`$CAT $TEMP_FILE_CROWDSEC | $JQ '.scores.last_day.aggressiveness'`
DT_AGGRESSIVENESS_LASTWEEK=`$CAT $TEMP_FILE_CROWDSEC | $JQ '.scores.last_week.aggressiveness'`
DT_AGGRESSIVENESS_LASTMONTH=`$CAT $TEMP_FILE_CROWDSEC | $JQ '.scores.last_month.aggressiveness'`

$ECHO "#"
$ECHO "#"
$ECHO "####################################################"
$ECHO "#"
$ECHO "# Report para o IP $1 do CrowdSec"
$ECHO "#"
$ECHO "####################################################"
$ECHO ""
$ECHO "Probabilidade [0-5]			:	$DT_CONFIDENCE_CS"
$ECHO "Pais					:	$DT_COUNTRY_CS"
$ECHO "DNS Reverso				:	$DT_REVERSE_IP_CS"
$ECHO "Agressividade media [0-5]		:	$DT_AGGRESSIVENESS_OVERALL"
$ECHO "Agressividade ontem [0-5]		:	$DT_AGGRESSIVENESS_LASTDAY"
$ECHO "Agressividade ultima semana [0-5]	:	$DT_AGGRESSIVENESS_LASTWEEK"
$ECHO "Agressividade ultimo mes [0-5]		:	$DT_AGGRESSIVENESS_LASTMONTH"
