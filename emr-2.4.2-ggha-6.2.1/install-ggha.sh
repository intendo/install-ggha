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

echo "Setting the GRIDGAIN_BASE environment variable"
export GRIDGAIN_BASE=/opt/ggha

echo "GRIDGAIN_BASE=$GRIDGAIN_BASE"

echo "Creating $GRIDGAIN_BASE to store the GridGain Hadoop Accelerator (GGHA) files"
sudo mkdir $GRIDGAIN_BASE
cd $GRIDGAIN_BASE
sudo chown hadoop:hadoop $GRIDGAIN_BASE

echo "Downloading GGHA ZIP files from S3"
export ZIP_FILENAME=gridgain-hadoop-os-6.5.0
curl -O https://s3.amazonaws.com/velocity-gridgain/$ZIP_FILENAME.zip

echo "Decompressing ZIP to $GRIDGAIN_BASE"
unzip $ZIP_FILENAME.zip
cd $ZIP_FILENAME

echo "Setting GRIDGAIN_HOME to $GRIDGAIN_BASE/$ZIP_FILENAME"

export GRIDGAIN_HOME=$GRIDGAIN_BASE/$ZIP_FILENAME
echo 'export GRIDGAIN_HOME=$GRIDGAIN_HOME'| sudo tee -a /home/hadoop/.bash_profile

echo "Configuring Hadoop to use GGFS"

# When this script is bootstrapped HADOOP_HOME is apparently not set yet
echo "Setting Hadoop environment variables..."

export HADOOP=/home/hadoop
export HADOOP_HOME=/home/hadoop/
export HADOOP_COMMON_HOME=/home/hadoop/
export HADOOP_CONF_DIR=/home/hadoop/conf-ggfs
export HADOOP_LIBS=/home/hadoop:/home/hadoop/lib

echo 'export HADOOP=$HADOOP'| sudo tee -a /home/hadoop/.bash_profile
echo 'export HADOOP_HOME=$HADOOP_HOME' | sudo tee -a /home/hadoop/.bash_profile
echo 'export HADOOP_COMMON_HOME=$HADOOP_COMMON_HOME' | sudo tee -a /home/hadoop/.bash_profile
echo 'export HADOOP_CONF_DIR=$HADOOP_CONF_DIR' | sudo tee -a /home/hadoop/.bash_profile
echo 'export HADOOP_LIBS=$HADOOP_LIBS'| sudo tee -a /home/hadoop/.bash_profile

echo "HADOOP=$HADOOP"
echo "HADOOP_HOME=$HADOOP_HOME"
echo "HADOOP_COMMON_HOME=$HADOOP_COMMON_HOME"
echo "HADOOP_CONF_DIR=$HADOOP_CONF_DIR"
echo "HADOOP_LIBS=$HADOOP_LIBS"

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
echo "Modifying GridGain to use S3 Discovery protocol instead of Multicast"
echo "TODO"

# Start GGFS on Hadoop 1.x job-submitter or job-client nodes
echo "Starting GGFS on Hadoop nodes..."

nohup $GRIDGAIN_HOME/bin/ggstart.sh -h1 -v $GRIDGAIN_HOME/config/default-config.xml >output 2>&1 &

# Uncomment this script for Hadoop 2.x and comment out the Hadoop 1.x configuration above
# sudo chmod 755 ./bin/setup-hadoop.sh
# ./bin/setup-hadoop.sh

# This command is for testing GGFS nodes
# Use GridGain Visor command-line version to verify
# sudo chmod 755 ./bin/ggstart.sh
# ./bin/ggstart.sh &
# ./bin/ggvisorcmd.sh
