#!/bin/bash

# This section copies the config to a new location, replaces the interface value to the value held in the .env file and copies it back.
#cp /opt/arkime/etc/config.ini /opt/arkime/etc/config.ini.new
#sed -i 's/interface=.*$/interface=$INTERFACE/g' /opt/arkime/etc/config.ini.new
#cp -f /opt/arkime/etc/config.ini.new /opt/arkime/etc/config.ini

# wait for Elasticsearch
#echo "Giving Elasticsearch time to start..."
#sleep 20

if (($INIT=TRUE))
then
  # Initialize Elasticsearch for Arkime data.
  echo "Initializing elasticsearch database."
  echo INIT | /opt/arkime/db/db.pl http://localhost:9200 init
  /opt/arkime/bin/arkime_add_user.sh admin "Admin User" password --admin
fi

# Start WISE service.
echo "Starting WISE tagger."
# This command seems to need to be run from the directory itself. During testing it wouldn't run properly unless you cd to the directory.
/bin/bash -c 'cd /opt/arkime/wiseService; /opt/arkime/bin/node wiseService.js &'
sleep 5

if (($CAPTURE==TRUE))
then
  # Start Capture service
  echo "Starting arkime-capture."
  /bin/bash -c "/opt/arkime/bin/capture -c /opt/arkime/etc/config.ini --host $HOSTNAME >> /opt/arkime/logs/capture.log 2>&1 &"
fi

# Start Viewer service.
echo "Starting arkime-viewer."
cd /opt/arkime/viewer
/bin/bash -c "/opt/arkime/bin/node viewer.js -c /opt/arkime/etc/config.ini >> /opt/arkime/logs/viewer.log 2>&1"
