#!/bin/sh

# Wazuh Installer Functions
# Copyright (C) 2015-2021, Wazuh Inc.
# November 18, 2016.
#
# This program is free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public
# License (version 2) as published by the FSF - Free Software
# Foundation.

# File dependencies:
# ./src/init/shared.sh
# ./src/init/template-select.sh

## Templates
. ./src/init/template-select.sh

HEADER_TEMPLATE="./etc/templates/config/generic/header-comments.template"
GLOBAL_TEMPLATE="./etc/templates/config/generic/global.template"
GLOBAL_AR_TEMPLATE="./etc/templates/config/generic/global-ar.template"
RULES_TEMPLATE="./etc/templates/config/generic/rules.template"
RULE_TEST_TEMPLATE="./etc/templates/config/generic/rule_test.template"
AR_COMMANDS_TEMPLATE="./etc/templates/config/generic/ar-commands.template"
AR_DEFINITIONS_TEMPLATE="./etc/templates/config/generic/ar-definitions.template"
ALERTS_TEMPLATE="./etc/templates/config/generic/alerts.template"
LOGGING_TEMPLATE="./etc/templates/config/generic/logging.template"
REMOTE_SEC_TEMPLATE="./etc/templates/config/generic/remote-secure.template"

LOCALFILES_TEMPLATE="./etc/templates/config/generic/localfile-logs/*.template"

AUTH_TEMPLATE="./etc/templates/config/generic/auth.template"
CLUSTER_TEMPLATE="./etc/templates/config/generic/cluster.template"

CISCAT_TEMPLATE="./etc/templates/config/generic/wodle-ciscat.template"
VULN_TEMPLATE="./etc/templates/config/generic/wodle-vulnerability-detector.manager.template"

SECURITY_CONFIGURATION_ASSESSMENT_TEMPLATE="./etc/templates/config/generic/sca.template"

##########
# WriteSyscheck()
##########
WriteSyscheck()
{
    # Adding to the config file
    if [ "X$SYSCHECK" = "Xyes" ]; then
      SYSCHECK_TEMPLATE=$(GetTemplate "syscheck.$1.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
      if [ "$SYSCHECK_TEMPLATE" = "ERROR_NOT_FOUND" ]; then
        SYSCHECK_TEMPLATE=$(GetTemplate "syscheck.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
      fi
      cat ${SYSCHECK_TEMPLATE} >> $NEWCONFIG
      echo "" >> $NEWCONFIG
    else
      if [ "$1" = "manager" ]; then
        echo "  <syscheck>" >> $NEWCONFIG
        echo "    <disabled>yes</disabled>" >> $NEWCONFIG
        echo "" >> $NEWCONFIG
        echo "    <scan_on_start>yes</scan_on_start>" >> $NEWCONFIG
        echo "" >> $NEWCONFIG
        echo "    <!-- Generate alert when new file detected -->" >> $NEWCONFIG
        echo "    <alert_new_files>yes</alert_new_files>" >> $NEWCONFIG
        echo "" >> $NEWCONFIG
        echo "  </syscheck>" >> $NEWCONFIG
        echo "" >> $NEWCONFIG
      else
        echo "  <syscheck>" >> $NEWCONFIG
        echo "    <disabled>yes</disabled>" >> $NEWCONFIG
        echo "  </syscheck>" >> $NEWCONFIG
        echo "" >> $NEWCONFIG
      fi
    fi
}

##########
# DisableAuthd()
##########
DisableAuthd()
{
    echo "  <!-- Configuration for wazuh-authd -->" >> $NEWCONFIG
    echo "  <auth>" >> $NEWCONFIG
    echo "    <disabled>yes</disabled>" >> $NEWCONFIG
    echo "    <port>1515</port>" >> $NEWCONFIG
    echo "    <use_source_ip>no</use_source_ip>" >> $NEWCONFIG
    echo "    <force_insert>yes</force_insert>" >> $NEWCONFIG
    echo "    <force_time>0</force_time>" >> $NEWCONFIG
    echo "    <purge>yes</purge>" >> $NEWCONFIG
    echo "    <use_password>no</use_password>" >> $NEWCONFIG
    echo "    <ciphers>HIGH:!ADH:!EXP:!MD5:!RC4:!3DES:!CAMELLIA:@STRENGTH</ciphers>" >> $NEWCONFIG
    echo "    <!-- <ssl_agent_ca></ssl_agent_ca> -->" >> $NEWCONFIG
    echo "    <ssl_verify_host>no</ssl_verify_host>" >> $NEWCONFIG
    echo "    <ssl_manager_cert>etc/sslmanager.cert</ssl_manager_cert>" >> $NEWCONFIG
    echo "    <ssl_manager_key>etc/sslmanager.key</ssl_manager_key>" >> $NEWCONFIG
    echo "    <ssl_auto_negotiate>no</ssl_auto_negotiate>" >> $NEWCONFIG
    echo "  </auth>" >> $NEWCONFIG
    echo "" >> $NEWCONFIG
}

##########
# WriteRootcheck()
##########
WriteRootcheck()
{
    # Adding to the config file
    if [ "X$ROOTCHECK" = "Xyes" ]; then
      ROOTCHECK_TEMPLATE=$(GetTemplate "rootcheck.$1.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
      if [ "$ROOTCHECK_TEMPLATE" = "ERROR_NOT_FOUND" ]; then
        ROOTCHECK_TEMPLATE=$(GetTemplate "rootcheck.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
      fi
      sed -e "s|\${INSTALLDIR}|$INSTALLDIR|g" "${ROOTCHECK_TEMPLATE}" >> $NEWCONFIG
      echo "" >> $NEWCONFIG
    else
      echo "  <rootcheck>" >> $NEWCONFIG
      echo "    <disabled>yes</disabled>" >> $NEWCONFIG
      echo "  </rootcheck>" >> $NEWCONFIG
      echo "" >> $NEWCONFIG
    fi
}

##########
# Syscollector()
##########
WriteSyscollector()
{
    # Adding to the config file
    if [ "X$SYSCOLLECTOR" = "Xyes" ]; then
      SYSCOLLECTOR_TEMPLATE=$(GetTemplate "wodle-syscollector.$1.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
      if [ "$SYSCOLLECTOR_TEMPLATE" = "ERROR_NOT_FOUND" ]; then
        SYSCOLLECTOR_TEMPLATE=$(GetTemplate "wodle-syscollector.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
      fi
      cat ${SYSCOLLECTOR_TEMPLATE} >> $NEWCONFIG
      echo "" >> $NEWCONFIG
    fi
}

##########
# Osquery()
##########
WriteOsquery()
{
    # Adding to the config file
    OSQUERY_TEMPLATE=$(GetTemplate "osquery.$1.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
    if [ "$OSQUERY_TEMPLATE" = "ERROR_NOT_FOUND" ]; then
        OSQUERY_TEMPLATE=$(GetTemplate "osquery.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
    fi
    sed -e "s|\${INSTALLDIR}|$INSTALLDIR|g" "${OSQUERY_TEMPLATE}" >> $NEWCONFIG
    echo "" >> $NEWCONFIG
}

##########
# WriteCISCAT()
##########
WriteCISCAT()
{
    # Adding to the config file
    CISCAT_TEMPLATE=$(GetTemplate "wodle-ciscat.$1.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
    if [ "$CISCAT_TEMPLATE" = "ERROR_NOT_FOUND" ]; then
        CISCAT_TEMPLATE=$(GetTemplate "wodle-ciscat.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
    fi
    sed -e "s|\${INSTALLDIR}|$INSTALLDIR|g" "${CISCAT_TEMPLATE}" >> $NEWCONFIG
    echo "" >> $NEWCONFIG
}

##########
# WriteConfigurationAssessment()
##########
WriteConfigurationAssessment()
{
    # Adding to the config file
    if [ "X$SECURITY_CONFIGURATION_ASSESSMENT" = "Xyes" ]; then
      SECURITY_CONFIGURATION_ASSESSMENT_TEMPLATE=$(GetTemplate "sca.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
      cat ${SECURITY_CONFIGURATION_ASSESSMENT_TEMPLATE} >> $NEWCONFIG
      echo "" >> $NEWCONFIG
    fi
}

##########
# InstallSecurityConfigurationAssessmentFiles()
##########
InstallSecurityConfigurationAssessmentFiles()
{

    cd ..

    CONFIGURATION_ASSESSMENT_FILES_PATH=$(GetTemplate "sca.files" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})

    if [ "X$1" = "Xmanager" ]; then
        CONFIGURATION_ASSESSMENT_MANAGER_FILES_PATH=$(GetTemplate "sca.$1.files" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
    fi
    cd ./src
    if [ "$CONFIGURATION_ASSESSMENT_FILES_PATH" = "ERROR_NOT_FOUND" ]; then
        echo "SCA policies are not available for this OS version ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER}."
    else
        echo "Removing old SCA policies..."
        rm -f ${INSTALLDIR}/ruleset/sca/*

        echo "Installing SCA policies..."
        CONFIGURATION_ASSESSMENT_FILES=$(cat .$CONFIGURATION_ASSESSMENT_FILES_PATH)
        for FILE in $CONFIGURATION_ASSESSMENT_FILES; do
            if [ -f "../ruleset/sca/$FILE" ]; then
                ${INSTALL} -m 0640 -o root -g ${OSSEC_GROUP} ../ruleset/sca/$FILE ${INSTALLDIR}/ruleset/sca
            else
                echo "ERROR: SCA policy not found: ../ruleset/sca/$FILE"
            fi
        done
    fi

    if [ "X$1" = "Xmanager" ]; then
        echo "Installing additional SCA policies..."
        CONFIGURATION_ASSESSMENT_FILES=$(cat .$CONFIGURATION_ASSESSMENT_MANAGER_FILES_PATH)
        for FILE in $CONFIGURATION_ASSESSMENT_FILES; do
            FILENAME=$(basename $FILE)
            if [ -f "../ruleset/sca/$FILE" ] && [ ! -f "${INSTALLDIR}/ruleset/sca/$FILENAME" ]; then
                ${INSTALL} -m 0640 -o root -g ${OSSEC_GROUP} ../ruleset/sca/$FILE ${INSTALLDIR}/ruleset/sca/
                mv ${INSTALLDIR}/ruleset/sca/$FILENAME ${INSTALLDIR}/ruleset/sca/$FILENAME.disabled
            fi
        done
    fi
}

##########
# GenerateAuthCert()
##########
GenerateAuthCert()
{
    if [ "X$SSL_CERT" = "Xyes" ]; then
        # Generation auto-signed certificate if not exists
        if [ ! -f "${INSTALLDIR}/etc/sslmanager.key" ] && [ ! -f "${INSTALLDIR}/etc/sslmanager.cert" ]; then
            if [ ! "X${USER_GENERATE_AUTHD_CERT}" = "Xn" ]; then
                if type openssl >/dev/null 2>&1; then
                    echo "Generating self-signed certificate for wazuh-authd..."
                    openssl req -x509 -batch -nodes -days 365 -newkey rsa:2048 -subj "/C=US/ST=California/CN=Wazuh/" -keyout ${INSTALLDIR}/etc/sslmanager.key -out ${INSTALLDIR}/etc/sslmanager.cert 2>/dev/null
                    chmod 640 ${INSTALLDIR}/etc/sslmanager.key
                    chmod 640 ${INSTALLDIR}/etc/sslmanager.cert
                else
                    echo "ERROR: OpenSSL not found. Cannot generate certificate for wazuh-authd."
                fi
            fi
        fi
    fi
}

##########
# WriteLogs()
##########
WriteLogs()
{
  LOCALFILES_TMP=`cat ${LOCALFILES_TEMPLATE}`
  for i in ${LOCALFILES_TMP}; do
      field1=$(echo $i | cut -d\: -f1)
      field2=$(echo $i | cut -d\: -f2)
      field3=$(echo $i | cut -d\: -f3)
      if [ "X$field1" = "Xskip_check_exist" ]; then
          SKIP_CHECK_FILE="yes"
          LOG_FORMAT="$field2"
          FILE="$field3"
      else
          SKIP_CHECK_FILE="no"
          LOG_FORMAT="$field1"
          FILE="$field2"
      fi

      # Check installation directory
      if [ $(echo $FILE | grep "INSTALL_DIR") ]; then
        FILE=$(echo $FILE | sed -e "s|INSTALL_DIR|${INSTALLDIR}|g")
      fi

      # If log file present or skip file
      if [ -f "$FILE" ] || [ "X$SKIP_CHECK_FILE" = "Xyes" ]; then
        if [ "$1" = "echo" ]; then
          echo "    -- $FILE"
        elif [ "$1" = "add" ]; then
          echo "  <localfile>" >> $NEWCONFIG
          if [ "$FILE" = "snort" ]; then
            head -n 1 $FILE|grep "\[**\] "|grep -v "Classification:" > /dev/null
            if [ $? = 0 ]; then
              echo "    <log_format>snort-full</log_format>" >> $NEWCONFIG
            else
              echo "    <log_format>snort-fast</log_format>" >> $NEWCONFIG
            fi
          else
            echo "    <log_format>$LOG_FORMAT</log_format>" >> $NEWCONFIG
          fi
          echo "    <location>$FILE</location>" >>$NEWCONFIG
          echo "  </localfile>" >> $NEWCONFIG
          echo "" >> $NEWCONFIG
        fi
      fi
  done
}

##########
# SetHeaders() 1-agent|manager|local
##########
SetHeaders()
{
    HEADERS_TMP="/tmp/wazuh-headers.tmp"
    if [ "$DIST_VER" = "0" ]; then
        sed -e "s/TYPE/$1/g; s/DISTRIBUTION/${DIST_NAME}/g; s/VERSION//g" "$HEADER_TEMPLATE" > $HEADERS_TMP
    else
      if [ "$DIST_SUBVER" = "0" ]; then
        sed -e "s/TYPE/$1/g; s/DISTRIBUTION/${DIST_NAME}/g; s/VERSION/${DIST_VER}/g" "$HEADER_TEMPLATE" > $HEADERS_TMP
      else
        sed -e "s/TYPE/$1/g; s/DISTRIBUTION/${DIST_NAME}/g; s/VERSION/${DIST_VER}.${DIST_SUBVER}/g" "$HEADER_TEMPLATE" > $HEADERS_TMP
      fi
    fi
    cat $HEADERS_TMP
    rm -f $HEADERS_TMP
}

##########
# GenerateService() $1=template
##########
GenerateService()
{
    SERVICE_TEMPLATE=./src/init/templates/${1}
    sed "s|WAZUH_HOME_TMP|${INSTALLDIR}|g" ${SERVICE_TEMPLATE}
}

##########
# WriteAgent() $1="no_locafiles" or empty
##########
WriteAgent()
{
    NO_LOCALFILES=$1

    HEADERS=$(SetHeaders "Agent")
    echo "$HEADERS" > $NEWCONFIG
    echo "" >> $NEWCONFIG

    echo "<wazuh_config>" >> $NEWCONFIG
    echo "  <client>" >> $NEWCONFIG
    echo "    <server>" >> $NEWCONFIG
    if [ "X${HNAME}" = "X" ]; then
      echo "      <address>$SERVER_IP</address>" >> $NEWCONFIG
    else
      echo "      <address>$HNAME</address>" >> $NEWCONFIG
    fi
    echo "      <port>1514</port>" >> $NEWCONFIG
    echo "      <protocol>tcp</protocol>" >> $NEWCONFIG
    echo "    </server>" >> $NEWCONFIG
    if [ "X${USER_AGENT_CONFIG_PROFILE}" != "X" ]; then
         PROFILE=${USER_AGENT_CONFIG_PROFILE}
         echo "    <config-profile>$PROFILE</config-profile>" >> $NEWCONFIG
    else
      if [ "$DIST_VER" = "0" ]; then
        echo "    <config-profile>$DIST_NAME</config-profile>" >> $NEWCONFIG
      else
        if [ "$DIST_SUBVER" = "0" ]; then
          echo "    <config-profile>$DIST_NAME, $DIST_NAME$DIST_VER</config-profile>" >> $NEWCONFIG
        else
          echo "    <config-profile>$DIST_NAME, $DIST_NAME$DIST_VER, $DIST_NAME$DIST_VER.$DIST_SUBVER</config-profile>" >> $NEWCONFIG
        fi
      fi
    fi
    echo "    <notify_time>10</notify_time>" >> $NEWCONFIG
    echo "    <time-reconnect>60</time-reconnect>" >> $NEWCONFIG
    echo "    <auto_restart>yes</auto_restart>" >> $NEWCONFIG
    echo "    <crypto_method>aes</crypto_method>" >> $NEWCONFIG
    echo "  </client>" >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    echo "  <client_buffer>" >> $NEWCONFIG
    echo "    <!-- Agent buffer options -->" >> $NEWCONFIG
    echo "    <disabled>no</disabled>" >> $NEWCONFIG
    echo "    <queue_size>5000</queue_size>" >> $NEWCONFIG
    echo "    <events_per_second>500</events_per_second>" >> $NEWCONFIG
    echo "  </client_buffer>" >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Rootcheck
    WriteRootcheck "agent"

    # CIS-CAT configuration
    if [ "X$DIST_NAME" !=  "Xdarwin" ]; then
        WriteCISCAT "agent"
    fi

    # Write osquery
    WriteOsquery "agent"

    # Syscollector configuration
    WriteSyscollector "agent"

    # Configuration assessment configuration
    WriteConfigurationAssessment

    # Syscheck
    WriteSyscheck "agent"

    # Write the log files
    if [ "X${NO_LOCALFILES}" = "X" ]; then
      echo "  <!-- Log analysis -->" >> $NEWCONFIG
      WriteLogs "add"
    else
      echo "  <!-- Log analysis -->" >> $NEWCONFIG
    fi

    # Localfile commands
    LOCALFILE_COMMANDS_TEMPLATE=$(GetTemplate "localfile-commands.agent.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
    if [ "$LOCALFILE_COMMANDS_TEMPLATE" = "ERROR_NOT_FOUND" ]; then
      LOCALFILE_COMMANDS_TEMPLATE=$(GetTemplate "localfile-commands.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
    fi
    cat ${LOCALFILE_COMMANDS_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    echo "  <!-- Active response -->" >> $NEWCONFIG

    echo "  <active-response>" >> $NEWCONFIG
    if [ "X$ACTIVERESPONSE" = "Xyes" ]; then
        echo "    <disabled>no</disabled>" >> $NEWCONFIG
    else
        echo "    <disabled>yes</disabled>" >> $NEWCONFIG
    fi
    echo "    <ca_store>etc/wpk_root.pem</ca_store>" >> $NEWCONFIG

    if [ -n "$CA_STORE" ]
    then
        echo "    <ca_store>${CA_STORE}</ca_store>" >> $NEWCONFIG
    fi

    echo "    <ca_verification>yes</ca_verification>" >> $NEWCONFIG
    echo "  </active-response>" >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Logging format
    cat ${LOGGING_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    echo "</wazuh_config>" >> $NEWCONFIG
}


##########
# WriteManager() $1="no_locafiles" or empty
##########
WriteManager()
{
    NO_LOCALFILES=$1

    HEADERS=$(SetHeaders "Manager")
    echo "$HEADERS" > $NEWCONFIG
    echo "" >> $NEWCONFIG

    echo "<wazuh_config>" >> $NEWCONFIG

    if [ "$EMAILNOTIFY" = "yes"   ]; then
        sed -e "s|<email_notification>no</email_notification>|<email_notification>yes</email_notification>|g; \
        s|<smtp_server>smtp.example.wazuh.com</smtp_server>|<smtp_server>${SMTP}</smtp_server>|g; \
        s|<email_from>wazuh@example.wazuh.com</email_from>|<email_from>wazuh@${HOST}</email_from>|g; \
        s|<email_to>recipient@example.wazuh.com</email_to>|<email_to>${EMAIL}</email_to>|g;" "${GLOBAL_TEMPLATE}" >> $NEWCONFIG
    else
        cat ${GLOBAL_TEMPLATE} >> $NEWCONFIG
    fi
    echo "" >> $NEWCONFIG

    # Alerts level
    cat ${ALERTS_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Logging format
    cat ${LOGGING_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Remote connection secure
    if [ "X$SLOG" = "Xyes" ]; then
      cat ${REMOTE_SEC_TEMPLATE} >> $NEWCONFIG
      echo "" >> $NEWCONFIG
    fi

    # Write rootcheck
    WriteRootcheck "manager"

    # CIS-CAT configuration
    if [ "X$DIST_NAME" !=  "Xdarwin" ]; then
        WriteCISCAT "manager"
    fi

    # Write osquery
    WriteOsquery "manager"

    # Syscollector configuration
    WriteSyscollector "manager"

    # Configuration assessment
    WriteConfigurationAssessment

    # Vulnerability Detector
    cat ${VULN_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Write syscheck
    WriteSyscheck "manager"

    # Active response
    if [ "$SET_WHITE_LIST"="true" ]; then
       sed -e "/  <\/global>/d" "${GLOBAL_AR_TEMPLATE}" >> $NEWCONFIG
      # Nameservers in /etc/resolv.conf
      for ip in ${NAMESERVERS} ${NAMESERVERS2};
        do
          if [ ! "X${ip}" = "X" -a ! "${ip}" = "0.0.0.0" ]; then
              echo "    <white_list>${ip}</white_list>" >>$NEWCONFIG
          fi
      done
      # Read string
      for ip in ${IPS};
        do
          if [ ! "X${ip}" = "X" -a ! "${ip}" = "0.0.0.0" ]; then
            echo $ip | grep -E "^[0-9./]{5,20}$" > /dev/null 2>&1
            if [ $? = 0 ]; then
              echo "    <white_list>${ip}</white_list>" >>$NEWCONFIG
            fi
          fi
        done
        echo "  </global>" >> $NEWCONFIG
        echo "" >> $NEWCONFIG
    else
      cat ${GLOBAL_AR_TEMPLATE} >> $NEWCONFIG
      echo "" >> $NEWCONFIG
    fi

    cat ${AR_COMMANDS_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG
    cat ${AR_DEFINITIONS_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Write the log files
    if [ "X${NO_LOCALFILES}" = "X" ]; then
      echo "  <!-- Log analysis -->" >> $NEWCONFIG
      WriteLogs "add"
    else
      echo "  <!-- Log analysis -->" >> $NEWCONFIG
    fi

    # Localfile commands
    LOCALFILE_COMMANDS_TEMPLATE=$(GetTemplate "localfile-commands.manager.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
    if [ "$LOCALFILE_COMMANDS_TEMPLATE" = "ERROR_NOT_FOUND" ]; then
      LOCALFILE_COMMANDS_TEMPLATE=$(GetTemplate "localfile-commands.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
    fi
    cat ${LOCALFILE_COMMANDS_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Writting rules configuration
    cat ${RULES_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Writting wazuh-logtest configuration
    cat ${RULE_TEST_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Writting auth configuration
    if [ "X${AUTHD}" = "Xyes" ]; then
        sed -e "s|\${INSTALLDIR}|$INSTALLDIR|g" "${AUTH_TEMPLATE}" >> $NEWCONFIG
        echo "" >> $NEWCONFIG
    else
        DisableAuthd
    fi

    # Writting cluster configuration
    cat ${CLUSTER_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    echo "</wazuh_config>" >> $NEWCONFIG

}

##########
# WriteLocal() $1="no_locafiles" or empty
##########
WriteLocal()
{
    NO_LOCALFILES=$1

    HEADERS=$(SetHeaders "Local")
    echo "$HEADERS" > $NEWCONFIG
    echo "" >> $NEWCONFIG

    echo "<wazuh_config>" >> $NEWCONFIG

    if [ "$EMAILNOTIFY" = "yes"   ]; then
        sed -e "s|<email_notification>no</email_notification>|<email_notification>yes</email_notification>|g; \
        s|<smtp_server>smtp.example.wazuh.com</smtp_server>|<smtp_server>${SMTP}</smtp_server>|g; \
        s|<email_from>wazuh@example.wazuh.com</email_from>|<email_from>wazuh@${HOST}</email_from>|g; \
        s|<email_to>recipient@example.wazuh.com</email_to>|<email_to>${EMAIL}</email_to>|g;" "${GLOBAL_TEMPLATE}" >> $NEWCONFIG
    else
        cat ${GLOBAL_TEMPLATE} >> $NEWCONFIG
    fi
    echo "" >> $NEWCONFIG

    # Alerts level
    cat ${ALERTS_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Logging format
    cat ${LOGGING_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Write rootcheck
    WriteRootcheck "manager"

    # CIS-CAT configuration
    if [ "X$DIST_NAME" !=  "Xdarwin" ]; then
        WriteCISCAT "agent"
    fi

    # Write osquery
    WriteOsquery "manager"

    # Vulnerability Detector
    cat ${VULN_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Write syscheck
    WriteSyscheck "manager"

    # Active response
    if [ "$SET_WHITE_LIST"="true" ]; then
       sed -e "/  <\/global>/d" "${GLOBAL_AR_TEMPLATE}" >> $NEWCONFIG
      # Nameservers in /etc/resolv.conf
      for ip in ${NAMESERVERS} ${NAMESERVERS2};
        do
          if [ ! "X${ip}" = "X" ]; then
              echo "    <white_list>${ip}</white_list>" >>$NEWCONFIG
          fi
      done
      # Read string
      for ip in ${IPS};
        do
          if [ ! "X${ip}" = "X" ]; then
            echo $ip | grep -E "^[0-9./]{5,20}$" > /dev/null 2>&1
            if [ $? = 0 ]; then
              echo "    <white_list>${ip}</white_list>" >>$NEWCONFIG
            fi
          fi
        done
        echo "  </global>" >> $NEWCONFIG
        echo "" >> $NEWCONFIG
    else
      cat ${GLOBAL_AR_TEMPLATE} >> $NEWCONFIG
      echo "" >> $NEWCONFIG
    fi

    cat ${AR_COMMANDS_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG
    cat ${AR_DEFINITIONS_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Write the log files
    if [ "X${NO_LOCALFILES}" = "X" ]; then
      echo "  <!-- Log analysis -->" >> $NEWCONFIG
      WriteLogs "add"
    else
      echo "  <!-- Log analysis -->" >> $NEWCONFIG
    fi

    # Localfile commands
    LOCALFILE_COMMANDS_TEMPLATE=$(GetTemplate "localfile-commands.manager.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
    if [ "$LOCALFILE_COMMANDS_TEMPLATE" = "ERROR_NOT_FOUND" ]; then
      LOCALFILE_COMMANDS_TEMPLATE=$(GetTemplate "localfile-commands.template" ${DIST_NAME} ${DIST_VER} ${DIST_SUBVER})
    fi
    cat ${LOCALFILE_COMMANDS_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Writting rules configuration
    cat ${RULES_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    # Writting wazuh-logtest configuration
    cat ${RULE_TEST_TEMPLATE} >> $NEWCONFIG
    echo "" >> $NEWCONFIG

    echo "</wazuh_config>" >> $NEWCONFIG
}

InstallCommon()
{

    OSSEC_GROUP='ossec'
    OSSEC_USER='ossec'
    OSSEC_USER_MAIL='ossecm'
    OSSEC_USER_REM='ossecr'
    INSTALL="install"

    if [ ${INSTYPE} = 'server' ]; then
        OSSEC_CONTROL_SRC='./init/wazuh-server.sh'
        OSSEC_CONF_SRC='../etc/ossec-server.conf'
    elif [ ${INSTYPE} = 'agent' ]; then
        OSSEC_CONTROL_SRC='./init/wazuh-client.sh'
        OSSEC_CONF_SRC='../etc/ossec-agent.conf'
    elif [ ${INSTYPE} = 'local' ]; then
        OSSEC_CONTROL_SRC='./init/wazuh-local.sh'
        OSSEC_CONF_SRC='../etc/ossec-local.conf'
    fi

    if [ ${DIST_NAME} = "sunos" ]; then
        INSTALL="ginstall"
    elif [ ${DIST_NAME} = "HP-UX" ]; then
        INSTALL="/usr/local/coreutils/bin/install"
   elif [ ${DIST_NAME} = "AIX" ]; then
        INSTALL="/opt/freeware/bin/install"
    fi

    ./init/adduser.sh ${OSSEC_USER} ${OSSEC_USER_MAIL} ${OSSEC_USER_REM} ${OSSEC_GROUP} ${INSTALLDIR} ${INSTYPE}

  ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/
  ${INSTALL} -d -m 0770 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/logs
  ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/logs/wazuh
  ${INSTALL} -m 0660 -o ${OSSEC_USER} -g ${OSSEC_GROUP} /dev/null ${INSTALLDIR}/logs/ossec.log
  ${INSTALL} -m 0660 -o ${OSSEC_USER} -g ${OSSEC_GROUP} /dev/null ${INSTALLDIR}/logs/ossec.json
  ${INSTALL} -m 0660 -o ${OSSEC_USER} -g ${OSSEC_GROUP} /dev/null ${INSTALLDIR}/logs/active-responses.log

    if [ ${INSTYPE} = 'agent' ]; then
        ${INSTALL} -d -m 0750 -o root -g 0 ${INSTALLDIR}/bin
    else
        ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/bin
    fi

  ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/lib

    if [ ${NUNAME} = 'Darwin' ]
    then
        if [ -f libwazuhext.dylib ]
        then
            ${INSTALL} -m 0750 -o root -g 0 libwazuhext.dylib ${INSTALLDIR}/lib
        fi
    elif [ -f libwazuhext.so ]
    then
        ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} libwazuhext.so ${INSTALLDIR}/lib

        if ([ "X${DIST_NAME}" = "Xrhel" ] || [ "X${DIST_NAME}" = "Xcentos" ] || [ "X${DIST_NAME}" = "XCentOS" ]) && [ ${DIST_VER} -le 5 ]; then
            chcon -t textrel_shlib_t ${INSTALLDIR}/lib/libwazuhext.so
        fi
    fi

    if [ ${NUNAME} = 'Darwin' ]
    then
        if [ -f shared_modules/dbsync/build/lib/libdbsync.dylib ]
        then
            ${INSTALL} -m 0750 -o root -g 0 shared_modules/dbsync/build/lib/libdbsync.dylib ${INSTALLDIR}/lib
            install_name_tool -id @rpath/../lib/libdbsync.dylib ${INSTALLDIR}/lib/libdbsync.dylib
        fi
    elif [ -f shared_modules/dbsync/build/lib/libdbsync.so ]
    then
        ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} shared_modules/dbsync/build/lib/libdbsync.so ${INSTALLDIR}/lib

        if ([ "X${DIST_NAME}" = "Xrhel" ] || [ "X${DIST_NAME}" = "Xcentos" ] || [ "X${DIST_NAME}" = "XCentOS" ]) && [ ${DIST_VER} -le 5 ]; then
            chcon -t textrel_shlib_t ${INSTALLDIR}/lib/libdbsync.so
        fi
    fi

    if [ ${NUNAME} = 'Darwin' ]
    then
        if [ -f shared_modules/rsync/build/lib/librsync.dylib ]
        then
            ${INSTALL} -m 0750 -o root -g 0 shared_modules/rsync/build/lib/librsync.dylib ${INSTALLDIR}/lib
            install_name_tool -id @rpath/../lib/librsync.dylib ${INSTALLDIR}/lib/librsync.dylib
            install_name_tool -change $(PWD)/shared_modules/dbsync/build/lib/libdbsync.dylib @rpath/../lib/libdbsync.dylib ${INSTALLDIR}/lib/librsync.dylib
        fi
    elif [ -f shared_modules/rsync/build/lib/librsync.so ]
    then
        ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} shared_modules/rsync/build/lib/librsync.so ${INSTALLDIR}/lib

        if ([ "X${DIST_NAME}" = "Xrhel" ] || [ "X${DIST_NAME}" = "Xcentos" ] || [ "X${DIST_NAME}" = "XCentOS" ]) && [ ${DIST_VER} -le 5 ]; then
            chcon -t textrel_shlib_t ${INSTALLDIR}/lib/librsync.so
        fi
    fi

    if [ ${NUNAME} = 'Darwin' ]
    then
        if [ -f data_provider/build/lib/libsysinfo.dylib ]
        then
            ${INSTALL} -m 0750 -o root -g 0 data_provider/build/lib/libsysinfo.dylib ${INSTALLDIR}/lib
            install_name_tool -id @rpath/../lib/libsysinfo.dylib ${INSTALLDIR}/lib/libsysinfo.dylib
        fi
    elif [ -f data_provider/build/lib/libsysinfo.so ]
    then
        ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} data_provider/build/lib/libsysinfo.so ${INSTALLDIR}/lib

        if ([ "X${DIST_NAME}" = "Xrhel" ] || [ "X${DIST_NAME}" = "Xcentos" ] || [ "X${DIST_NAME}" = "XCentOS" ]) && [ ${DIST_VER} -le 5 ]; then
            chcon -t textrel_shlib_t ${INSTALLDIR}/lib/libsysinfo.so
        fi
    fi

    if [ ${NUNAME} = 'Darwin' ]
    then
        if [ -f wazuh_modules/syscollector/build/lib/libsyscollector.dylib ]
        then
            ${INSTALL} -m 0750 -o root -g 0 wazuh_modules/syscollector/build/lib/libsyscollector.dylib ${INSTALLDIR}/lib
            install_name_tool -id @rpath/../lib/libsyscollector.dylib ${INSTALLDIR}/lib/libsyscollector.dylib
            install_name_tool -change $(PWD)/data_provider/build/lib/libsysinfo.dylib @rpath/../lib/libsysinfo.dylib ${INSTALLDIR}/lib/libsyscollector.dylib
            install_name_tool -change $(PWD)/shared_modules/rsync/build/lib/librsync.dylib @rpath/../lib/librsync.dylib ${INSTALLDIR}/lib/libsyscollector.dylib
            install_name_tool -change $(PWD)/shared_modules/dbsync/build/lib/libdbsync.dylib @rpath/../lib/libdbsync.dylib ${INSTALLDIR}/lib/libsyscollector.dylib
        fi
    elif [ -f wazuh_modules/syscollector/build/lib/libsyscollector.so ]
    then
        ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} wazuh_modules/syscollector/build/lib/libsyscollector.so ${INSTALLDIR}/lib

        if ([ "X${DIST_NAME}" = "Xrhel" ] || [ "X${DIST_NAME}" = "Xcentos" ] || [ "X${DIST_NAME}" = "XCentOS" ]) && [ ${DIST_VER} -le 5 ]; then
            chcon -t textrel_shlib_t ${INSTALLDIR}/lib/libsyscollector.so
        fi
    fi

  ${INSTALL} -m 0750 -o root -g 0 manage_agents ${INSTALLDIR}/bin
  ${INSTALL} -m 0750 -o root -g 0 ${OSSEC_CONTROL_SRC} ${INSTALLDIR}/bin/wazuh-control
  ${INSTALL} -m 0750 -o root -g 0 wazuh-modulesd ${INSTALLDIR}/bin/

  ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/queue
  ${INSTALL} -d -m 0770 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/alerts
  ${INSTALL} -d -m 0770 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/sockets
  ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/diff
  ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/fim
  ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/fim/db
  ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/syscollector
  ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/syscollector/db

  ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/logcollector

  ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/ruleset
  ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/ruleset/sca

  ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/wodles
  ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/var/wodles

  ${INSTALL} -d -m 0770 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/etc

    if [ -f /etc/localtime ]
    then
         ${INSTALL} -m 0640 -o root -g ${OSSEC_GROUP} /etc/localtime ${INSTALLDIR}/etc
    fi

  ${INSTALL} -d -m 1770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/tmp

    if [ -f /etc/TIMEZONE ]; then
         ${INSTALL} -m 0640 -o root -g ${OSSEC_GROUP} /etc/TIMEZONE ${INSTALLDIR}/etc/
    fi
    # Solaris Needs some extra files
    if [ ${DIST_NAME} = "SunOS" ]; then
      ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/usr/share/lib/zoneinfo/
        cp -rf /usr/share/lib/zoneinfo/* ${INSTALLDIR}/usr/share/lib/zoneinfo/
        chown root:${OSSEC_GROUP} ${INSTALLDIR}/usr/share/lib/zoneinfo/*
        find ${INSTALLDIR}/usr/share/lib/zoneinfo/ -type d -exec chmod 0750 {} +
        find ${INSTALLDIR}/usr/share/lib/zoneinfo/ -type f -exec chmod 0640 {} +
    fi

    ${INSTALL} -m 0640 -o root -g ${OSSEC_GROUP} -b ../etc/internal_options.conf ${INSTALLDIR}/etc/
    ${INSTALL} -m 0640 -o root -g ${OSSEC_GROUP} wazuh_modules/syscollector/norm_config.json ${INSTALLDIR}/queue/syscollector

    if [ ! -f ${INSTALLDIR}/etc/local_internal_options.conf ]; then
        ${INSTALL} -m 0640 -o root -g ${OSSEC_GROUP} ../etc/local_internal_options.conf ${INSTALLDIR}/etc/local_internal_options.conf
    fi

    if [ ! -f ${INSTALLDIR}/etc/client.keys ]; then
        if [ ${INSTYPE} = 'agent' ]; then
            ${INSTALL} -m 0640 -o root -g ${OSSEC_GROUP} /dev/null ${INSTALLDIR}/etc/client.keys
        else
            ${INSTALL} -m 0640 -o ossec -g ${OSSEC_GROUP} /dev/null ${INSTALLDIR}/etc/client.keys
        fi
    fi

    if [ ! -f ${INSTALLDIR}/etc/ossec.conf ]; then
        if [ -f  ../etc/ossec.mc ]; then
            ${INSTALL} -m 0660 -o root -g ${OSSEC_GROUP} ../etc/ossec.mc ${INSTALLDIR}/etc/ossec.conf
        else
            ${INSTALL} -m 0660 -o root -g ${OSSEC_GROUP} ${OSSEC_CONF_SRC} ${INSTALLDIR}/etc/ossec.conf
        fi
    fi

  ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/etc/shared
  ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/active-response
  ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/active-response/bin
  ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/agentless
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} agentlessd/scripts/* ${INSTALLDIR}/agentless/

  ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/.ssh

  ./init/fw-check.sh execute
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} active-response/*.sh ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} active-response/*.py ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} firewall-drop ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} default-firewall-drop ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} pf ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} npf ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ipfw ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} firewalld-drop ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} disable-account ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} host-deny ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ip-customblock ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} restart-wazuh ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} route-null ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} kaspersky ${INSTALLDIR}/active-response/bin/
  ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} wazuh-slack ${INSTALLDIR}/active-response/bin/

  ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/var
  ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/var/run
  ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/var/upgrade
  ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/var/selinux

  if [ -f selinux/wazuh.pp ]
  then
    ${INSTALL} -m 0640 -o root -g ${OSSEC_GROUP} selinux/wazuh.pp ${INSTALLDIR}/var/selinux/
    InstallSELinuxPolicyPackage
  fi

  ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/backup

}

InstallLocal()
{

    InstallCommon

    ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/etc/decoders
    ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/etc/rules
    ${INSTALL} -d -m 0770 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/var/multigroups
    ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/var/db
    ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/var/db/agents
    ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/var/download
    ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/logs/archives
    ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/logs/alerts
    ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/logs/firewall
    ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/logs/api
    ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/etc/rootcheck

    ${INSTALL} -m 0750 -o root -g 0 wazuh-agentlessd ${INSTALLDIR}/bin
    ${INSTALL} -m 0750 -o root -g 0 wazuh-analysisd ${INSTALLDIR}/bin
    ${INSTALL} -m 0750 -o root -g 0 wazuh-monitord ${INSTALLDIR}/bin
    ${INSTALL} -m 0750 -o root -g 0 wazuh-reportd ${INSTALLDIR}/bin
    ${INSTALL} -m 0750 -o root -g 0 wazuh-maild ${INSTALLDIR}/bin
    ${INSTALL} -m 0750 -o root -g 0 wazuh-logtest-legacy ${INSTALLDIR}/bin
    ${INSTALL} -m 0750 -o root -g 0 wazuh-csyslogd ${INSTALLDIR}/bin
    ${INSTALL} -m 0750 -o root -g 0 wazuh-dbd ${INSTALLDIR}/bin
    ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} verify-agent-conf ${INSTALLDIR}/bin/
    ${INSTALL} -m 0750 -o root -g 0 clear_stats ${INSTALLDIR}/bin/
    ${INSTALL} -m 0750 -o root -g 0 wazuh-regex ${INSTALLDIR}/bin/
    ${INSTALL} -m 0750 -o root -g 0 agent_control ${INSTALLDIR}/bin/
    ${INSTALL} -m 0750 -o root -g 0 wazuh-integratord ${INSTALLDIR}/bin/
    ${INSTALL} -m 0750 -o root -g 0 wazuh-db ${INSTALLDIR}/bin/

    ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/stats
    ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/ruleset/decoders
    ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/ruleset/rules

    ${INSTALL} -m 0640 -o root -g ${OSSEC_GROUP} -b ../ruleset/rules/*.xml ${INSTALLDIR}/ruleset/rules
    ${INSTALL} -m 0640 -o root -g ${OSSEC_GROUP} -b ../ruleset/decoders/*.xml ${INSTALLDIR}/ruleset/decoders
    ${INSTALL} -m 0660 -o root -g ${OSSEC_GROUP} ../ruleset/rootcheck/db/*.txt ${INSTALLDIR}/etc/rootcheck

    InstallSecurityConfigurationAssessmentFiles "manager"

    if [ ! -f ${INSTALLDIR}/etc/decoders/local_decoder.xml ]; then
        ${INSTALL} -m 0660 -o ossec -g ${OSSEC_GROUP} -b ../etc/local_decoder.xml ${INSTALLDIR}/etc/decoders/local_decoder.xml
    fi
    if [ ! -f ${INSTALLDIR}/etc/rules/local_rules.xml ]; then
        ${INSTALL} -m 0660 -o ossec -g ${OSSEC_GROUP} -b ../etc/local_rules.xml ${INSTALLDIR}/etc/rules/local_rules.xml
    fi
    if [ ! -f ${INSTALLDIR}/etc/lists ]; then
        ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/etc/lists
    fi
    if [ ! -f ${INSTALLDIR}/etc/lists/amazon ]; then
        ${INSTALL} -d -m 0770 -o ossec -g ${OSSEC_GROUP} ${INSTALLDIR}/etc/lists/amazon
        ${INSTALL} -m 0660 -o ossec -g ${OSSEC_GROUP} -b ../ruleset/lists/amazon/* ${INSTALLDIR}/etc/lists/amazon/
    fi
    if [ ! -f ${INSTALLDIR}/etc/lists/audit-keys ]; then
        ${INSTALL} -m 0660 -o ossec -g ${OSSEC_GROUP} -b ../ruleset/lists/audit-keys ${INSTALLDIR}/etc/lists/audit-keys
    fi
    if [ ! -f ${INSTALLDIR}/etc/lists/security-eventchannel ]; then
        ${INSTALL} -m 0660 -o ossec -g ${OSSEC_GROUP} -b ../ruleset/lists/security-eventchannel ${INSTALLDIR}/etc/lists/security-eventchannel
    fi

    ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/fts
    ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/agentless
    ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/db

    ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/integrations
    ${INSTALL} -m 750 -o root -g ${OSSEC_GROUP} ../integrations/pagerduty ${INSTALLDIR}/integrations/pagerduty
    ${INSTALL} -m 750 -o root -g ${OSSEC_GROUP} ../integrations/slack ${INSTALLDIR}/integrations/slack.py
    ${INSTALL} -m 750 -o root -g ${OSSEC_GROUP} ../integrations/virustotal ${INSTALLDIR}/integrations/virustotal.py
    touch ${INSTALLDIR}/logs/integrations.log
    chmod 640 ${INSTALLDIR}/logs/integrations.log
    chown ${OSSEC_USER_MAIL}:${OSSEC_GROUP} ${INSTALLDIR}/logs/integrations.log

    if [ "X${OPTIMIZE_CPYTHON}" = "Xy" ]; then
        CPYTHON_FLAGS="OPTIMIZE_CPYTHON=yes"
    fi

    # Install Vulnerability Detector files
    ${INSTALL} -d -m 0660 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/vulnerabilities
    ${INSTALL} -d -m 0440 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/vulnerabilities/dictionaries
    ${INSTALL} -m 0440 -o root -g ${OSSEC_GROUP} wazuh_modules/vulnerability_detector/cpe_helper.json ${INSTALLDIR}/queue/vulnerabilities/dictionaries

    # Install Task Manager files
    ${INSTALL} -d -m 0770 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/tasks

    ### Install Python
    ${MAKEBIN} wpython INSTALLDIR=${INSTALLDIR} TARGET=${INSTYPE}

    ${MAKEBIN} --quiet -C ../framework install INSTALLDIR=${INSTALLDIR}

    ### Backup old API
    if [ "X${update_only}" = "Xyes" ]; then
      ${MAKEBIN} --quiet -C ../api backup INSTALLDIR=${INSTALLDIR} REVISION=${REVISION}
    fi

    ### Install API
    ${MAKEBIN} --quiet -C ../api install INSTALLDIR=${INSTALLDIR}

    ### Restore old API
    if [ "X${update_only}" = "Xyes" ]; then
      ${MAKEBIN} --quiet -C ../api restore INSTALLDIR=${INSTALLDIR} REVISION=${REVISION}
    fi
}

TransferShared()
{
    rm -f ${INSTALLDIR}/etc/shared/merged.mg
    find ${INSTALLDIR}/etc/shared -maxdepth 1 -type f -not -name ar.conf -not -name files.yml -exec cp -pf {} ${INSTALLDIR}/backup/shared \;
    find ${INSTALLDIR}/etc/shared -maxdepth 1 -type f -not -name ar.conf -not -name files.yml -exec mv -f {} ${INSTALLDIR}/etc/shared/default \;
}

InstallServer()
{

    InstallLocal

    # Install cluster files
    ${INSTALL} -d -m 0770 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/cluster
    ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/logs/cluster

    ${INSTALL} -d -m 0770 -o ossec -g ${OSSEC_GROUP} ${INSTALLDIR}/etc/shared/default
    ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/backup/shared

    TransferShared

    ${INSTALL} -m 0750 -o root -g 0 wazuh-remoted ${INSTALLDIR}/bin
    ${INSTALL} -m 0750 -o root -g 0 wazuh-authd ${INSTALLDIR}/bin

    ${INSTALL} -d -m 0770 -o ${OSSEC_USER_REM} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/rids
    ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/agent-groups

    if [ ! -f ${INSTALLDIR}/queue/agents-timestamp ]; then
        ${INSTALL} -m 0600 -o root -g ${OSSEC_GROUP} /dev/null ${INSTALLDIR}/queue/agents-timestamp
    fi

    ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/backup/agents
    ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/backup/groups

    ${INSTALL} -m 0660 -o ossec -g ${OSSEC_GROUP} ../ruleset/rootcheck/db/*.txt ${INSTALLDIR}/etc/shared/default

    if [ ! -f ${INSTALLDIR}/etc/shared/default/agent.conf ]; then
        ${INSTALL} -m 0660 -o ossec -g ${OSSEC_GROUP} ../etc/agent.conf ${INSTALLDIR}/etc/shared/default
    fi

    if [ ! -f ${INSTALLDIR}/etc/shared/agent-template.conf ]; then
        ${INSTALL} -m 0660 -o ossec -g ${OSSEC_GROUP} ../etc/agent.conf ${INSTALLDIR}/etc/shared/agent-template.conf
    fi

    # Install the plugins files
    ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/wodles/aws
    ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../wodles/aws/aws_s3.py ${INSTALLDIR}/wodles/aws/aws-s3.py
    ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../framework/wrappers/generic_wrapper.sh ${INSTALLDIR}/wodles/aws/aws-s3

    ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/wodles/gcloud
    ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../wodles/gcloud/gcloud.py ${INSTALLDIR}/wodles/gcloud/gcloud.py
    ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../wodles/gcloud/integration.py ${INSTALLDIR}/wodles/gcloud/integration.py
    ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../wodles/gcloud/tools.py ${INSTALLDIR}/wodles/gcloud/tools.py
    ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../framework/wrappers/generic_wrapper.sh ${INSTALLDIR}/wodles/gcloud/gcloud

    ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/wodles/docker
    ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../wodles/docker-listener/DockerListener.py ${INSTALLDIR}/wodles/docker/DockerListener.py
    ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../framework/wrappers/generic_wrapper.sh ${INSTALLDIR}/wodles/docker/DockerListener

    # Add Azure script (for manager only)
    ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/wodles/azure
    ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../wodles/azure/azure-logs.py ${INSTALLDIR}/wodles/azure/azure-logs.py
    ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../framework/wrappers/generic_wrapper.sh ${INSTALLDIR}/wodles/azure/azure-logs

    GenerateAuthCert

    # Add the wrappers for python script in active-response
    ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../framework/wrappers/generic_wrapper.sh ${INSTALLDIR}/integrations/slack
    ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../framework/wrappers/generic_wrapper.sh ${INSTALLDIR}/integrations/virustotal

}

InstallAgent()
{

    InstallCommon

    InstallSecurityConfigurationAssessmentFiles "agent"

    ${INSTALL} -m 0750 -o root -g 0 wazuh-agentd ${INSTALLDIR}/bin
    ${INSTALL} -m 0750 -o root -g 0 agent-auth ${INSTALLDIR}/bin

    ${INSTALL} -d -m 0750 -o ${OSSEC_USER} -g ${OSSEC_GROUP} ${INSTALLDIR}/queue/rids
    ${INSTALL} -d -m 0770 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/var/incoming
    ${INSTALL} -m 0660 -o root -g ${OSSEC_GROUP} ../ruleset/rootcheck/db/*.txt ${INSTALLDIR}/etc/shared/
    ${INSTALL} -m 0640 -o root -g ${OSSEC_GROUP} ../etc/wpk_root.pem ${INSTALLDIR}/etc/

    # Install the plugins files
    # Don't install the plugins if they are already installed. This check affects
    # hybrid installation mode
    if [ ! -d ${INSTALLDIR}/wodles/aws ]; then
        ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/wodles/aws
        ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../wodles/aws/aws_s3.py ${INSTALLDIR}/wodles/aws/aws-s3
    fi

    if [ ! -d ${INSTALLDIR}/wodles/gcloud ]; then
        ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/wodles/gcloud
        ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../wodles/gcloud/gcloud.py ${INSTALLDIR}/wodles/gcloud/gcloud
        ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../wodles/gcloud/integration.py ${INSTALLDIR}/wodles/gcloud/integration.py
        ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../wodles/gcloud/tools.py ${INSTALLDIR}/wodles/gcloud/tools.py
    fi

    if [ ! -d ${INSTALLDIR}/wodles/docker ]; then
        ${INSTALL} -d -m 0750 -o root -g ${OSSEC_GROUP} ${INSTALLDIR}/wodles/docker
        ${INSTALL} -m 0750 -o root -g ${OSSEC_GROUP} ../wodles/docker-listener/DockerListener.py ${INSTALLDIR}/wodles/docker/DockerListener
    fi

}

InstallWazuh()
{
    if [ "X$INSTYPE" = "Xagent" ]; then
        InstallAgent
    elif [ "X$INSTYPE" = "Xserver" ]; then
        InstallServer
    elif [ "X$INSTYPE" = "Xlocal" ]; then
        InstallLocal
    fi

}
