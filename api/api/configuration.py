# Copyright (C) 2015-2021, Wazuh Inc.
# Created by Wazuh, Inc. <info@wazuh.com>.
# This program is a free software; you can redistribute it and/or modify it under the terms of GPLv2

import copy
import datetime
import os
from typing import Dict, List, Tuple

import yaml
from cryptography import x509
from cryptography.hazmat.backends import default_backend as crypto_default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.x509.oid import NameOID
from jsonschema import validate, ValidationError

from api.api_exception import APIError
from api.constants import CONFIG_FILE_PATH, SECURITY_CONFIG_PATH
from api.validator import api_config_schema, security_config_schema
from wazuh.core import common

default_security_configuration = {
    "auth_token_exp_timeout": 900,
    "rbac_mode": "white"
}

default_api_configuration = {
    "host": "0.0.0.0",
    "port": 55000,
    "use_only_authd": False,
    "drop_privileges": True,
    "experimental_features": False,
    "intervals": {
        "request_timeout": 10
    },
    "https": {
        "enabled": True,
        "key": "api/configuration/ssl/server.key",
        "cert": "api/configuration/ssl/server.crt",
        "use_ca": False,
        "ca": "api/configuration/ssl/ca.crt",
        "ssl_protocol": "TLSv1.2",
        "ssl_ciphers": ""
    },
    "logs": {
        "level": "info",
        "path": "logs/api.log"
    },
    "cors": {
        "enabled": False,
        "source_route": "*",
        "expose_headers": "*",
        "allow_headers": "*",
        "allow_credentials": False,
    },
    "cache": {
        "enabled": True,
        "time": 0.750
    },
    "access": {
        "max_login_attempts": 50,
        "block_time": 300,
        "max_request_per_minute": 300
    },
    "remote_commands": {
        "localfile": {
            "enabled": True,
            "exceptions": []
        },
        "wodle_command": {
            "enabled": True,
            "exceptions": []
        }
    }
}


def dict_to_lowercase(mydict: Dict):
    """Turns all str values to lowercase. Supports nested dictionaries.

    :param mydict: Dictionary to lowercase
    :return: None (the dictionary's reference is modified)
    """
    for k, val in filter(lambda x: isinstance(x[1], str) or isinstance(x[1], dict), mydict.items()):
        if isinstance(val, dict):
            dict_to_lowercase(mydict[k])
        else:
            mydict[k] = val.lower()


def append_wazuh_path(dictionary: Dict, path_fields: List[Tuple[str, str]]):
    """Appends wazuh path to all path fields in a dictionary

    :param dictionary: dictionary to append wazuh path
    :param path_fields: List of tuples containing path fields
    :return: None (the dictionary's reference is modified)
    """
    for section, subsection in path_fields:
        try:
            dictionary[section][subsection] = os.path.join(common.wazuh_path, dictionary[section][subsection])
        except KeyError:
            pass


def fill_dict(default: Dict, config: Dict, json_schema: Dict) -> Dict:
    """Validate and fill a dictionary's missing values using default ones.

    Parameters
    ----------
    default : dict
        Dictionary with default values.
    config : dict
        Dictionary to be filled.
    json_schema : dict
        Jsonschema with allowed properties.

    Returns
    -------
    dict
        Filled dictionary.
    """
    try:
        validate(instance=config, schema=json_schema)
    except ValidationError as e:
        raise APIError(2000, details=e.message)

    for k, val in filter(lambda x: isinstance(x[1], dict), config.items()):
        for item, value in config[k].items():
            config[k][item] = default[k][item] if value == "" else config[k][item]
        config[k] = {**default[k], **config[k]}

    return {**default, **config}


def generate_private_key(private_key_path, public_exponent=65537, key_size=2048):
    """Generate a private key in 'CONFIG_PATH/ssl/server.key'.

    Parameters
    ----------
    private_key_path : str
        Path where the private key will be generated.
    public_exponent : int, optional
        Key public exponent. Default `65537`
    key_size : int, optional
        Key size. Default `2048`

    Returns
    -------
    RSAPrivateKey
        Private key.
    """
    key = rsa.generate_private_key(
        public_exponent,
        key_size,
        crypto_default_backend()
    )
    with open(private_key_path, 'wb') as f:
        f.write(key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        ))
    os.chmod(private_key_path, 0o400)

    return key


def generate_self_signed_certificate(private_key, certificate_path):
    """Generate a self signed certificate using a generated private key. The certificate will be created in
        'CONFIG_PATH/ssl/server.crt'.

    Parameters
    ----------
    private_key : RSAPrivateKey
        Private key.
    certificate_path : str
        Path where the self signed certificate will be generated.
    """
    # Generate private key
    # Various details about who we are. For a self-signed certificate the
    # subject and issuer are always the same.
    subject = issuer = x509.Name([
        x509.NameAttribute(NameOID.COUNTRY_NAME, u"US"),
        x509.NameAttribute(NameOID.STATE_OR_PROVINCE_NAME, u"California"),
        x509.NameAttribute(NameOID.LOCALITY_NAME, u"San Francisco"),
        x509.NameAttribute(NameOID.ORGANIZATION_NAME, u"Wazuh"),
        x509.NameAttribute(NameOID.COMMON_NAME, u"wazuh.com"),
    ])
    cert = x509.CertificateBuilder().subject_name(
        subject
    ).issuer_name(
        issuer
    ).public_key(
        private_key.public_key()
    ).serial_number(
        x509.random_serial_number()
    ).not_valid_before(
        datetime.datetime.utcnow()
    ).not_valid_after(
        # Our certificate will be valid for 10 days
        datetime.datetime.utcnow() + datetime.timedelta(days=365)
    ).add_extension(
        x509.SubjectAlternativeName([x509.DNSName(u"localhost")]),
        critical=False,
        # Sign our certificate with our private key
    ).sign(private_key, hashes.SHA256(), crypto_default_backend())
    # Write our certificate out to disk.
    with open(certificate_path, 'wb') as f:
        f.write(cert.public_bytes(serialization.Encoding.PEM))
    os.chmod(certificate_path, 0o400)


def read_yaml_config(config_file=CONFIG_FILE_PATH, default_conf=None) -> Dict:
    """Reads user API configuration and merges it with the default one

    :return: API configuration
    """

    def replace_bools(conf):
        """Replace 'yes' and 'no' strings in configuration for actual booleans.

        Parameters
        ----------
        conf : dict
            Current API configuration.
        """
        for k in conf.keys():
            if isinstance(conf[k], dict):
                replace_bools(conf[k])
            else:
                if isinstance(conf[k], str):
                    if conf[k].lower() == 'yes':
                        conf[k] = True
                    elif conf[k].lower() == 'no':
                        conf[k] = False

    if default_conf is None:
        default_conf = default_api_configuration

    if os.path.exists(config_file):
        try:
            with open(config_file) as f:
                configuration = yaml.safe_load(f)
            # Replace strings for booleans
            configuration and replace_bools(configuration)
        except IOError as e:
            raise APIError(2004, details=e.strerror)
    else:
        configuration = None

    if configuration is None:
        configuration = copy.deepcopy(default_conf)
    else:
        # If any value is missing from user's configuration, add the default one:
        dict_to_lowercase(configuration)
        schema = security_config_schema if config_file == SECURITY_CONFIG_PATH else api_config_schema
        configuration = fill_dict(default_conf, configuration, schema)

    # Append wazuh_path to all paths in configuration
    append_wazuh_path(configuration, [('logs', 'path'), ('https', 'key'), ('https', 'cert'), ('https', 'ca')])

    return configuration


# Check if the default configuration is valid according to its jsonschema, so we are forced to update the schema if any
# change is performed to the configuration.
try:
    validate(instance=default_security_configuration, schema=security_config_schema)
    validate(instance=default_api_configuration, schema=api_config_schema)
except ValidationError as e:
    raise APIError(2000, details=e.message)

# Configuration - global object
api_conf = dict()
security_conf = read_yaml_config(config_file=SECURITY_CONFIG_PATH, default_conf=default_security_configuration)
