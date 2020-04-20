# -------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
# Modified by Zolder, sample script to query SecureScore
# --------------------------------------------------------------------------

## Visit https://aka.ms/graphsecuritydocs for the Microsoft Graph Security API documention.

import json
import urllib.request
import urllib.parse
import requests

appSecret = ''
appId = ''
tenantId = ''

# Azure Active Directory token endpoint.
url = "https://login.microsoftonline.com/%s/oauth2/v2.0/token" % (tenantId)
body = {
    'client_id': appId,
    'client_secret': appSecret,
    'grant_type': 'client_credentials',
    'scope': 'https://graph.microsoft.com/.default'
}

## authenticate and obtain AAD Token for future calls
data = urllib.parse.urlencode(body).encode("utf-8")  # encodes the data into a 'x-www-form-urlencoded' type
req = urllib.request.Request(url, data)

response = urllib.request.urlopen(req)

jsonResponse = json.loads(response.read().decode())

# Grab the token from the response then store it in the headers dict.
aadToken = jsonResponse["access_token"]
headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': "Bearer " + aadToken
}
api_root = "https://graph.microsoft.com/v1.0/"
if len(aadToken) > 0:
    print("Access token acquired.")

def make_request(url):
    """
    Makes a GET request.

    :param url: Url of the request.
    :returns: json response.
    :raises HTTPError: raises an exception
    """
    url_sanitized = urllib.parse.quote(url, safe="%/:=&?~#+!$,;'@()*[]")  # Url encode spaces
    req = urllib.request.Request(url_sanitized, headers=headers)
    print()
    print("########################################################################################")
    print("Calling the Microsoft Graph Security API...")
    print()
    print('GET "%s"' % url_sanitized)
    print()
    print("Headers :")
    print(json.dumps(headers, indent=4))
    print("########################################################################################")

    try:
        response = urllib.request.urlopen(req)
    except urllib.error.HTTPError as e:
        raise e

    jsonResponse = json.loads(response.read().decode())

    return jsonResponse

##### Uncomment the code below to get the most recent high severity alert from each provider.
alert_url = "https://graph.microsoft.com/v1.0/security/secureScores"
j = make_request(alert_url)

print("Response :")

for controlScore in j['value'][0]['controlScores']:
    if 'MFA' in controlScore['controlName']:
        print(controlScore)