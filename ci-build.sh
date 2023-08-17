#!/bin/bash
# Copyright (C) MuleSoft, Inc. All rights reserved. http://www.mulesoft.com
#
# The software in this package is published under the terms of the
# Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International Public License,
# a copy of which has been included with this distribution in the LICENSE.txt file.
set -Eeuo pipefail

# add default artifact to clean target directory
./mvnw -s ci-settings.xml clean verify -U -DattachMuleSources -Pci

# package with original version and add resulting artifact to target directory
./mvnw -s ci-settings.xml package -DattachMuleSources -Dapp.version=2.0.0 -Pci

# override version and add resulting artifact to target directory
./mvnw -s ci-settings.xml package -Dapp.version=2.1.0 -DattachMuleSources -Pci

# override version for mule plugin deployment and add resulting artifact to target directory
./mvnw -s ci-settings.xml package -DattachMuleSources -Pzip