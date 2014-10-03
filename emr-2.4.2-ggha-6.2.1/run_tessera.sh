#!/bin/bash

# User parameters
# To keep this file free of private information we will source the run-tessera.properties file
. run-tessera.properties

# On with the show!
$EMR_CLI_HOME/elastic-mapreduce --create --alive --name "$INSTANCE_NAME" --enable-debugging \
--num-instances 2 --slave-instance-type m1.large --master-instance-type m3.xlarge --ami-version "2.4.2" \
--with-termination-protection \
--key-pair $KEY_PAIR \
--log-uri s3://$S3_BUCKET/logs \
--bootstrap-action s3://elasticmapreduce/bootstrap-actions/configure-hadoop \
--args "-m,mapred.reduce.tasks.speculative.execution=false" \
--args "-m,mapred.map.tasks.speculative.execution=false" \
--args "-m,mapred.map.child.java.opts=-Xmx1024m" \
--args "-m,mapred.reduce.child.java.opts=-Xmx1024m" \
--args "-m,mapred.job.reuse.jvm.num.tasks=1" \
--bootstrap-action "s3://$S3_BUCKET/install-ggha.sh" \
--bootstrap-action "s3://$S3_BUCKET/install-preconfigure" \
--bootstrap-action "s3://$S3_BUCKET/install-r" \
--bootstrap-action s3://elasticmapreduce/bootstrap-actions/run-if --args "instance.isMaster=true,s3://$S3_BUCKET/install-rstudio" \
--bootstrap-action s3://elasticmapreduce/bootstrap-actions/run-if --args "instance.isMaster=true,s3://$S3_BUCKET/install-shiny-server" \
--bootstrap-action s3://elasticmapreduce/bootstrap-actions/run-if --args "instance.isMaster=true,s3://$S3_BUCKET/install-post-hadoop" \
--bootstrap-action "s3://$S3_BUCKET/install-protobuf" \
--bootstrap-action "s3://$S3_BUCKET/install-rhipe" \
--bootstrap-action "s3://$S3_BUCKET/install-additional-pkgs" \
--bootstrap-action "s3://$S3_BUCKET/install-post-configure" 
