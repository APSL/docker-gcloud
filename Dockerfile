FROM debian:jessie

USER root
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
        python-openssl \
        openssh-client \
        unzip \
        python \
        wget \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

VOLUME /keys
    
# Install the Google Cloud SDK.
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
WORKDIR /
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip --no-check-certificate && \
    unzip google-cloud-sdk.zip && \
    rm google-cloud-sdk.zip

RUN \ 
    google-cloud-sdk/install.sh \ 
      --usage-reporting=true --path-update=true \
      --bash-completion=true --rc-path=/root/.bashrc \
      --additional-components kubectl alpha beta

# Disable updater check for the whole installation.
# Users won't be bugged with notifications to update to the latest version of gcloud.
RUN google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true

# Disable updater completely.
# Running `gcloud components update` doesn't really do anything in a union FS.
# Changes are lost on a subsequent run.
RUN sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /google-cloud-sdk/lib/googlecloudsdk/core/config.json

WORKDIR /
ENV PATH /google-cloud-sdk/bin:$PATH
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["gcloud"]
 
