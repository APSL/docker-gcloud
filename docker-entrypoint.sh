#!/bin/sh

gcloud auth activate-service-account $GCLOUD_EMAIL_SERVICE_ACCOUNT --key-file /keys/$GCLOUD_KEY_FILE
gcloud config set project $GCLOUD_PROJECT 

if [ "$1" = 'gcloud' ]; then

    exec gcloud "$@"
fi

exec "$@"

