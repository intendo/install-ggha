install-ggha
============

1. Create an Amazon AWS account
2. Login to account
3. Verify that you can access and execute Amazon S3 and EMR
4. Download gridgain-hadoop-os-6.5.0.zip from GridGain
5. Upload ZIP file to S3
6. Make ZIP file Public
7. Check-out/download/etc. this repository to your local development machine
8. Modify the install-ggha.sh file as necessary
9. Ignore all other files for now
10. Upload SH file to S3
11. Make sure the SH file is NOT Public
12. Navigate to EMR Console
13. Start up a Hadoop 2.x cluster
14. Add a Bootstrap step that calls the SH file in S3
15. Monitor logs for errors
