#!/bin/bash

. ./conf.cfg
. ./variaveis.cfg

# O nome de usuario no AD pode ser ate 20 caracteres
AD_USERNAME=`$CMD_ECHO $1 | $CMD_TR [A-Z] [a-z] | $CMD_SED 's/[^0-9a-z]*//g' | $CMD_CUT -c 1-$MAX_CHARS`

# Verificacao da data final
#if [ $2 != "^[0-9]{4}/[0-9]{2}/[0-9]{2}$" ] ; then
if [ $2 == "^202[1-9]/[0-3][0-9]/[0-9][0-9]$" ] ; then
	$CMD_ECHO "Formato de data invalida. Informe ANO/MES/DIA"
	exit 4
fi

DATE_END=$2

VRF_ANO=`$CMD_ECHO $DATE_END | $CMD_CUT -f 1 -d "/"`
VRF_MES=`$CMD_ECHO $DATE_END | $CMD_CUT -f 2 -d "/"`
VRF_DIA=`$CMD_ECHO $DATE_END | $CMD_CUT -f 3 -d "/"`
MAX_ANO=`$CMD_ECHO $DEF_DATE_END | $CMD_CUT -f 1 -d "/"`
MAX_MES=`$CMD_ECHO $DEF_DATE_END | $CMD_CUT -f 2 -d "/"`
MAX_DIA=`$CMD_ECHO $DEF_DATE_END | $CMD_CUT -f 3 -d "/"`

if [ $VRF_ANO -gt $MAX_ANO ] ; then
	echo "Data final incorreta - ano"
	exit 3
fi

if [ $VRF_MES -gt $MAX_MES ] ; then
	echo "Data final incorreta - mes"
	exit 3
fi

if [ $VRF_DIA -gt $MAX_DIA ] ; then
	echo "Data final incorreta - dia"
	exit 3
fi
# Fim da verificacao da data final

TMP_DIR=`$CMD_MKTEMP -d`

VPN_USERNAME=`./$SCRIPT_AD_CHECK_LOGIN $AD_USERNAME`
if [ -z $VPN_USERNAME ] ; then
	$CMD_ECHO "Conta nao encontrada"
	$CMD_ECHO "Verifique se o login esta correto e tente novamente"
	exit 1
fi

FW_VPN_SCHEDULE_NAME_DEFAULT="vpn_$VPN_USERNAME"
FW_VPN_ADDRESS_NAME_DEFAULT="wks_$VPN_USERNAME"

./$SCRIPT_CFG_GET_USERLOCAL $FW_HOST $FW_PORT $FW_USERNAME $FW_PASSWORD $VPN_USERNAME >> $TMP_DIR/userlocal
	FW_VPN_USER_LOCAL=`$CMD_CAT $TMP_DIR/userlocal | $CMD_GREP edit | $CMD_CUT -f 2 -d "\"" | $CMD_TAIL -n 1 | $CMD_HEAD -n 1`
	if [ -z $FW_VPN_USER_LOCAL ] ; then
		$CMD_ECHO "Executando criacao do objeto de usuario"
		$CMD_ECHO "Pegadinha ... essa parte ainda nao está pronta. Aguarde a proxima versao do script"
		exit 2
	else
		$CMD_ECHO "Usuario: $FW_VPN_USER_LOCAL"
	fi


./$SCRIPT_CFG_GET_SCHEDULE_NAME $FW_HOST $FW_PORT $FW_USERNAME $FW_PASSWORD $VPN_USERNAME >> $TMP_DIR/schedule
	FW_VPN_SCHEDULE_NAME=`$CMD_CAT $TMP_DIR/schedule | $CMD_GREP edit | $CMD_CUT -f 2 -d "\"" | $CMD_TAIL -n 1 | $CMD_HEAD -n 1`
	if [ -z $FW_VPN_SCHEDULE_NAME ] ; then
		$CMD_ECHO "Executando criacao do objeto de schedule"
	else
		$CMD_ECHO "Nome do schedule: $FW_VPN_SCHEDULE_NAME"
	fi
	if [ $FW_VPN_SCHEDULE_NAME != $FW_VPN_SCHEDULE_NAME_DEFAULT ] ; then
		$CMD_ECHO "Nome do objeto de schedule diferente do padrao. Renomeando ..."
		./$SCRIPT_CFG_EDIT_SCHEDULE_NAME $FW_HOST $FW_PORT $FW_USERNAME $FW_PASSWORD $FW_VPN_SCHEDULE_NAME $FW_VPN_SCHEDULE_NAME_DEFAULT
	fi
	$CMD_ECHO "Verificando data final da VPN ..."
	./$SCRIPT_CFG_GET_SCHEDULE_EXTENDED $FW_HOST $FW_PORT $FW_USERNAME $FW_PASSWORD $FW_VPN_SCHEDULE_NAME_DEFAULT >> $TMP_DIR/schedule_extended
	SCHEDULE_DATE_END=`$CMD_CAT $TMP_DIR/schedule_extended | $CMD_GREP "set end" | $CMD_CUT -f 2 -d "\"" | $CMD_TAIL -n 1 | $CMD_HEAD -n 1 | $CMD_CUT -f 2 -d ":" | $CMD_CUT -f 2 -d " " | $CMD_TR -d '[:cntrl:]' `
	if [ "$SCHEDULE_DATE_END" != "$DATE_END" ] ; then
		$CMD_ECHO "Alterando a data final da VPN ..."
		./$SCRIPT_CFG_EDIT_SCHEDULE_DATE  $FW_HOST $FW_PORT $FW_USERNAME $FW_PASSWORD $FW_VPN_SCHEDULE_NAME_DEFAULT $DEF_DATE_START $DATE_END
	fi
		

./$SCRIPT_CFG_GET_ADDRESS_NAME $FW_HOST $FW_PORT $FW_USERNAME $FW_PASSWORD $VPN_USERNAME >> $TMP_DIR/address_name
	FW_VPN_ADDRESS_NAME=`$CMD_CAT $TMP_DIR/address_name | $CMD_GREP edit | $CMD_CUT -f 2 -d "\"" | $CMD_TAIL -n 1 | $CMD_HEAD -n 1`
	if [ -z $FW_VPN_ADDRESS_NAME ] ; then
		$CMD_ECHO "Executando criacao do objeto de host"
	else
		$CMD_ECHO "Nome do objeto de estacao: $FW_VPN_ADDRESS_NAME"
	fi
	if [ $FW_VPN_ADDRESS_NAME != $FW_VPN_ADDRESS_NAME_DEFAULT ] ; then
		$CMD_ECHO "Nome do objeto de objeto de estacao diferente do padrao. Renomeando ..."
		./$SCRIPT_CFG_EDIT_ADDRESS_NAME $FW_HOST $FW_PORT $FW_USERNAME $FW_PASSWORD $FW_VPN_ADDRESS_NAME $FW_VPN_ADDRESS_NAME_DEFAULT
	fi
