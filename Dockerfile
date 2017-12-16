FROM phusion/baseimage:0.9.22                                                                      
MAINTAINER Martin Polak

ENV HOME /root

RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen cs_CZ.UTF-8
ENV LANG cs_CZ.UTF-8

RUN (apt-get update && \
     DEBIAN_FRONTEND=noninteractive \
     apt-get install -y build-essential software-properties-common \
                        zlib1g-dev libssl-dev libreadline-dev libyaml-dev \
                        libxml2-dev libxslt-dev sqlite3 libsqlite3-dev \
                        vim git byobu wget curl unzip tree exuberant-ctags \
                        build-essential cmake python python-dev gdb)

RUN (apt-get install vim)

# Add a non-root user
RUN (useradd -m -d /home/docker -s /bin/bash docker && \
     echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers)

# Install eclim requirements
RUN (apt-get install -y openjdk-8-jdk ant maven \
                        xvfb xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic)

USER docker
ENV HOME /home/docker
WORKDIR /home/docker

RUN (git config --global user.email "nigol@nigol.cz" && \
  git config --global user.name "Martin Polak")
  
# Vim configuration
RUN (mkdir /home/docker/.vim && mkdir /home/docker/.vim/bundle && \
    mkdir -p ~/.vim/autoload ~/.vim/bundle && \
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim && \
    git clone https://github.com/nigol/vimrc && \
    cp vimrc/vimrc .vimrc)

# Force tmux to use 256 colors to play nicely with vim
RUN echo 'alias tmux="tmux -2"' >> ~/.profile

# Install Eclipse                                                                                              
RUN (wget -O /home/docker/eclipse-java-mars-R-linux-gtk-x86_64.tar.gz \             "http://mirror.dkm.cz/eclipse/technology/epp/downloads/release/mars/2/eclipse-jee-mars-2-linux-gtk-x86_64.tar.gz" && \
     tar xzvf eclipse-java-mars-R-linux-gtk-x86_64.tar.gz -C /home/docker && \
     rm eclipse-java-mars-R-linux-gtk-x86_64.tar.gz && \
     mkdir /home/docker/workspace)

# Install eclim
RUN (cd /home/docker && \
wget -O /home/docker/eclim.jar \ 
“https://github.com/ervandew/eclim/releases/download/2.7.0/eclim_2.7.0.jar” && \
     java -Dvim.files=$HOME/.vim -Declipse.home=/home/docker/eclipse -jar eclim.jar install)

USER root
ADD service /etc/service
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/bin/sh"]