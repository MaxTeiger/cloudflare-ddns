import importlib
import os

import responses

import pytest

# We'll set environment variables and reload the module

def reload_ddns(env_vars=None):
    if env_vars:
        for k, v in env_vars.items():
            os.environ[k] = v
    import ddns
    importlib.reload(ddns)
    return ddns

def test_get_public_ip():
    ddns = reload_ddns()
    with responses.RequestsMock() as rsps:
        rsps.add(rsps.GET, "https://api.ipify.org?format=json", json={"ip": "1.2.3.4"}, status=200)
        ip = ddns.get_public_ip()
    assert ip == "1.2.3.4"

def test_get_dns_record_success():
    env = {"ZONE_ID": "zone123", "DNS_RECORD_NAME": "example.com"}
    ddns = reload_ddns(env)
    api_url = f"https://api.cloudflare.com/client/v4/zones/{env['ZONE_ID']}/dns_records?type=A&name={env['DNS_RECORD_NAME']}"
    response_payload = {"success": True, "result": [{"id": "abc", "content": "1.2.3.4"}]}
    with responses.RequestsMock() as rsps:
        rsps.add(rsps.GET, api_url, json=response_payload, status=200)
        record = ddns.get_dns_record()
    assert record == response_payload["result"][0]

def test_get_dns_record_not_found():
    env = {"ZONE_ID": "zone123", "DNS_RECORD_NAME": "example.com"}
    ddns = reload_ddns(env)
    api_url = f"https://api.cloudflare.com/client/v4/zones/{env['ZONE_ID']}/dns_records?type=A&name={env['DNS_RECORD_NAME']}"
    response_payload = {"success": False, "result": []}
    with responses.RequestsMock() as rsps:
        rsps.add(rsps.GET, api_url, json=response_payload, status=200)
        with pytest.raises(Exception):
            ddns.get_dns_record()
