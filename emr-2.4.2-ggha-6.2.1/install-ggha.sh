# Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

#!/bin/bash

echo "This script is executing as user $USER"

echo "Setting the GRIDGAIN_HOME environment variable"
GRIDGAIN_HOME=/opt/ggha

echo "GRIDGAIN_HOME=$GRIDGAIN_HOME"

echo "Creating $GRIDGAIN_HOME to store the GridGain Hadoop Accelerator (GGHA) files"
sudo mkdir $GRIDGAIN_HOME
cd $GRIDGAIN_HOME
sudo chown hadoop:hadoop $GRIDGAIN_HOME

echo "Downloading GGHA ZIP files from S3"
ZIP_FILENAME=gridgain-hadoop-os-6.5.0
curl -O https://s3.amazonaws.com/velocity-gridgain/$ZIP_FILENAME.zip

echo "Decompressing ZIP to $GRIDGAIN_HOME"
unzip $ZIP_FILENAME.zip
cd $ZIP_FILENAME

echo "Configuring Hadoop to use GGFS"

# Uncomment this script for Hadoop 2.x and comment out the Hadoop 1.x configuration below
# sudo chmod 755 ./bin/setup-hadoop.sh
# ./bin/setup-hadoop.sh

# This command is for testing GGFS standalone
# Use GridGain Visor command-line version to verify
# sudo chmod 755 ./bin/ggstart.sh
# ./bin/ggstart.sh &
# ./bin/ggvisorcmd.sh

# When this script is bootstrapped HADOOP_HOME is apparently not set yet
echo "Setting the HADOOP_HOME environment variable"
HADOOP_HOME=/home/hadoop

echo "HADOOP_HOME=$HADOOP_HOME"

# Hadoop 1.x configuration
cd $HADOOP_HOME

echo "Copying $HADOOP_HOME/conf to $HADOOP_HOME/conf-ggfs"
cp -r conf conf-ggfs
cd conf-ggfs

# Modify core-site.xml to load GGFS by default
echo "Modifying core-site.xml..."
cp core-site.xml core-site.xml.bak

grep -v fs.default.name core-site.xml.bak | sed -r -e "s#<configuration>#<configuration>\n <property>\n <name>fs.ggfs.impl</name><value>org.gridgain.grid.ggfs.hadoop.v1.GridGgfsHadoopFileSystem</value>\n </property>\n <property>\n <name>fs.default.name</name><value>ggfs://ggfs@localhost</value>\n  </property>\n <property>\n <name>dfs.client.block.write.replace-datanode-on-failure.policy</name><value>NEVER</value>\n  </property>\n#" > core-site.xml

# Modify hadoop-env.sh to load GridGain JARs in to Hadoop classpath
echo "Modifying hadoop-env.sh..."
cp hadoop-env.sh hadoop-env.sh.bak

sed -i "\$afor f in \$\GRIDGAIN_HOME/gridgain*.jar; do \n export HADOOP_CLASSPATH=\$\HADOOP_CLASSPATH:\$f\; \n done \n for f in \$\GRIDGAIN_HOME/libs/*.jar; do \n export HADOOP_CLASSPATH=\$\HADOOP_CLASSPATH:\$f\; \n done" hadoop-env.sh

# Tell Hadoop to use the new GGFS configurations
echo "Setting the HADOOP_CONF_DIR environment variable"
HADOOP_CONF_DIR=$HADOOP_HOME/conf-ggfs

echo "HADOOP_CONF_DIR=$HADOOP_CONF_DIR"

# Start GGFS on Hadoop 1.x job-submitter or job-client nodes
echo "Starting GGFS on Hadoop nodes..."
# . "$GRIDGAIN_HOME/$ZIP_FILENAME/bin/ggstart.sh -h1 $GRIDGAIN_HOME/$ZIP_FILENAME/config/default-config.xml" $@
. "$GRIDGAIN_HOME/$ZIP_FILENAME/bin/setup-hadoop.sh" $@

