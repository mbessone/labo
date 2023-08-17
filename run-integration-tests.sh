#!/bin/bash
# Copyright (C) MuleSoft, Inc. All rights reserved. http://www.mulesoft.com
#
# The software in this package is published under the terms of the
# Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International Public License,
# a copy of which has been included with this distribution in the LICENSE.txt file.
set -Euo pipefail # do not include 'e' othewise failures cause immediate exit

BASE_URL=${1:-"http://localhost:8081"} # The base URL to run integration tests against, defaults to http://localhost:8081 

#
# Send HTTP requests to all HTTP endpoints exposed by this app,
# and assert that the HTTP responses contain a string that is known to always occur.
#

assert_get() {
	path="$1" # URL path to send HTTP GET to
	text="$2" # must be contained in HTTP response body

	url="$BASE_URL$path"
	resp=$(curl $url --silent)
	echo "$resp" | grep "$text" > /dev/null
	
	if [ $? -ne 0 ]; then
		echo "FAILURE: HTTP GET to $url did not return response containing '$text' but returned '$resp'"
	else
		# comment this out after dev
		echo "success: GET $url -> $text"
	fi
}

assert_post() {
	path="$1" # URL path to send HTTP POST to
	cont="$2" # Content-Type HTTP request header to send
	requ="$3" # HTTP request body to send
	text="$4" # must be contained in HTTP response body

	url="$BASE_URL$path"
	resp=$(curl $url -H "Content-Type: $cont" -d "$requ" --silent)
	echo "$resp" | grep "$text" > /dev/null
	
	if [ $? -ne 0 ]; then
		echo "FAILURE: HTTP POST to $url with Content-Type '$cont' and body '$requ' did not return response containing '$text' but returned '$resp'"
	else
		# comment this out after dev
		echo "success: POST $url $cont '$requ' -> $text"
	fi
}

# all.xml
assert_get "/" "UP"

# cluster-demo.xml
assert_get "/api/process" "applicationID"
assert_get "/process"     "Application name"
assert_get "/api/memory"  "JVM total memory"
assert_get "/memory"      "JVM Total Memory"

# logging-demo.xml
assert_get "/logdemo"                "Hey there"
assert_get "/logdemo?name=IntegTest" "Hi IntegTest"

# mvn-deploy-demo.xml
assert_get "/status" "successfully"

# persistence-demo.xml
assert_post "/store"    "text/plain" "This request body is not used" "thisNode"
assert_get  "/retrieve"                                              "thisNode"
assert_post "/clear"    "text/plain" "This request body is not used" "thisNode"

# secure-properties-demo.xml
assert_get "/properties" "Secret Student Name"

# security-demo.xml
assert_get  "/api/security"                                              "GET request received"
assert_post "/api/security" "text/plain" "This request body is not used" "POST request received"
# not asserting PUT and DELETE

# tokenization-demo.xml
assert_post "/invoke" "application/json" '{ "test": "integration" }' "test"

# version-demo.xml
assert_get "/api/welcome" "Welcome to Runtime Fabric"
assert_get "/welcome"     "Welcome to Runtime Fabric"
assert_get "/api/version" "This is version"
assert_get "/version"     "This is version"

# webui.xml
assert_get "/css/bootstrap-theme.min.css" "background-color"
assert_get "/css/bootstrap.min.css"       "background-color"
assert_get "/css/mu.css"                  "background-color"
assert_get "/js/commons.js"               "function"
# not asserting remaining JS files
