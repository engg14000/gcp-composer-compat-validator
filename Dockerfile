ARG COMPOSER_IMAGE=us-central1-docker.pkg.dev/cloud-airflow-releaser/airflow-worker-scheduler-2-4-3/airflow-worker-scheduler-2-4-3:cloud_composer_service_2023-04-04-RC4
FROM ${COMPOSER_IMAGE}

USER root
ARG COMPOSER_PYTHON_VERSION

# Copy installation artifacts.
COPY requirements.txt .
COPY installer.sh .

# Copy pip.conf file if it exists. It will be used in the in-cluster build.


# Install pypi dependencies for the given Python version.
RUN bash installer.sh $COMPOSER_PYTHON_VERSION  fail 

# Cleanup installation artifacts.
RUN rm requirements.txt
RUN rm installer.sh

# Remove pip.conf file so it won't affect the airflow image pip preference.


USER airflow