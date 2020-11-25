FROM gitpod/workspace-full

ARG GITLAB_BUNDLER_VERSION=2.1.4
ARG GITLAB_RUBY_VERSION=2.7.2
ARG GITLAB_NODE_VERSION=12.18.4
ARG GITLAB_GO_VERSION=1.14.9

ENV GO_VERSION=${GITLAB_GO_VERSION} \
    NODE_VERSION=${GITLAB_NODE_VERSION}

COPY packages.txt /
RUN sudo apt-get update \
  && sudo apt-get install -y software-properties-common \
  && sudo add-apt-repository ppa:git-core/ppa -y 
RUN sudo apt-get install -y $(sed -e 's/#.*//' /packages.txt) 
RUN sudo apt-get install -y postgresql postgresql-contrib libpq-dev chromium-chromedriver 
RUN sudo apt-get purge software-properties-common -y \
  && sudo apt-get clean -y \
  && sudo apt-get autoremove -y \
  && sudo rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/*

RUN sudo curl https://dl.min.io/server/minio/release/linux-amd64/minio --output /usr/local/bin/minio && \
    sudo chmod +x /usr/local/bin/minio

RUN curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash

RUN export GITLAB_RUNNER_DISABLE_SKEL=true; sudo -E apt-get install gitlab-runner

# scrips/lint-doc.sh dependency
RUN brew install vale

RUN echo "rvm_silence_path_mismatch_check_flag=1" >> $HOME/.rvmrc

RUN sudo mkdir -p /workspace/gitlab && sudo chown -R gitpod:gitpod /workspace

# RUN bash -lc "rvm get stable"

RUN echo "GITLAB_BUNDLER_VERSION  $GITLAB_BUNDLER_VERSION" && \
    echo "GITLAB_RUBY_VERSION     $GITLAB_RUBY_VERSION" && \
    echo "GITLAB_NODE_VERSION     $GITLAB_NODE_VERSION" && \
    echo "GITLAB_GO_VERSION       $GITLAB_GO_VERSION" && \
RUN GOPATH=$HOME/go-packages && \
        GOROOT=$HOME/go && \
        npm upgrade --global yarn && \
        rvm install $GITLAB_RUBY_VERSION --create && \
        rvm use $GITLAB_RUBY_VERSION --default && \
        echo "rvm use $GITLAB_RUBY_VERSION --default > /dev/null\" > ~/.bashrc.d/71-ruby" && 
        gem install bundler -v $GITLAB_BUNDLER_VERSION && \
        gem install gitlab-development-kit mdl && \
        . $HOME/.nvm/nvm.sh && \
        nvm install $GITLAB_NODE_VERSION && \
        nvm alias default $GITLAB_NODE_VERSION && \
        rm -rf go && curl -sSL https://storage.googleapis.com/golang/go$GITLAB_GO_VERSION.linux-amd64.tar.gz | tar xzs && \
        cd /workspace && gdk init 
