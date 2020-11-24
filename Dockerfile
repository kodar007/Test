FROM ubuntu:20.04
LABEL authors.maintainer "GDK contributors: https://gitlab.com/gitlab-org/gitlab-development-kit/graphs/master"

# Directions when writing this dockerfile:
# Keep least changed directives first. This improves layers caching when rebuilding.

ENV DEBIAN_FRONTEND=noninteractive

COPY packages.txt /
RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository ppa:git-core/ppa -y \
    && apt-get install -y $(sed -e 's/#.*//' /packages.txt) \
    && apt-get purge software-properties-common -y \
    && apt-get autoremove -y \
    && rm -rf /tmp/*

RUN useradd --user-group --create-home --groups sudo gdk
RUN echo "gdk ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/gdk_no_password

WORKDIR /home/gdk
USER gdk
