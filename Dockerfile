FROM jupyter/minimal-notebook@sha256:edede2004c961f49d72a2451875e5d3b4104e076bc8abc3ffcaf04f3652f59aa

LABEL version=2022-06-21
LABEL maintainer="Adrian Grzemski <adrian.grzemski@gmail.com>"

USER root
WORKDIR /home/jovyan
ENV DEBIAN_FRONTEND noninteractive

# Add usefull aliases
RUN echo -e '#!/bin/bash\nls -lhaF "$@"' > /usr/bin/ll \
 && chmod +x /usr/bin/ll
RUN echo -e '#!/bin/bash\napt autoremove -y && apt clean -y && rm -rf /var/lib/apt/lists/' > /usr/bin/apt_vacuum \
 && chmod +x /usr/bin/apt_vacuum
RUN echo -e '#!/bin/bash\nconda update --all --no-channel-priority "$@"' > /usr/bin/condaup \
 && chmod +x /usr/bin/condaup

RUN mkdir logs

RUN echo "jovyan:jovyan" | chpasswd

### Update system
RUN apt update \
 && apt full-upgrade -y > logs/apt_install.log \
 && apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    apt-utils \
    >> logs/apt_install.log \
 && add-apt-repository ppa:jonathonf/vim -y \
 && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
 && apt_vacuum

RUN mkdir packages && chown -R jovyan:users packages
ADD --chown=jovyan:users packages/apt.list ./packages/apt.list
RUN ls -lha packages
RUN cat packages/apt.list
RUN apt update \
 && apt install -y $(cat packages/apt.list | tr '\n' ' ') \
    >> logs/apt_install.logs \
 && apt_vacuum

#ENV RSTUDIO_DEB rstudio-2022.02.1-461-amd64.deb

#RUN apt update \
# && wget https://download2.rstudio.org/server/bionic/amd64/${RSTUDIO_DEB} \
# && gdebi -n ${RSTUDIO_DEB} \
# && rm ${RSTUDIO_DEB} \
# && apt_vacuum

#ADD RConfig/rserver.conf /etc/rstudio/rserver.conf

RUN (update-alternatives --remove-all gcc || true) \
 && (update-alternatives --remove-all g++ || true) \
 && (update-alternatives --remove-all gfortran || true) \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 10 \
#  && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 10 \
#  && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 20 \
 && update-alternatives --set gcc /usr/bin/gcc-9 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 10 \
#  && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 10 \
#  && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 20 \
 && update-alternatives --set g++ /usr/bin/g++-9 \
 && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 40 \
 && update-alternatives --set cc /usr/bin/gcc \
 && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 40 \
 && update-alternatives --set c++ /usr/bin/g++ \
 && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-9 10 \
#  && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-8 10 \
#  && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-7 20 \
 && update-alternatives --set gfortran /usr/bin/gfortran-9

RUN chown -R jovyan:users logs

USER jovyan

### Update conda & add repos
RUN rm /opt/conda/conda-meta/pinned

RUN conda update --yes -n base conda > conda_update.log \
 && conda config --add channels bioconda \
 && conda config --add channels defaults \
 && conda config --add channels conda-forge

ENV CONDA_PYTHON_VERSION=3.8
ENV CONDA_LIB_DIR=$CONDA_DIR/lib/python$CONDA_PYTHON_VERSION

# Install extra packages listed in conda_packages
ADD --chown=jovyan:users packages/conda.list ./packages/conda.list
RUN conda install \
    --yes \
    --no-channel-priority \
    --prune \
    --file packages/conda.list \
    > logs/conda_install.log \
### Clean cache
 && conda clean --all \
 && conda list > conda_installed.list

ADD --chown=jovyan:users packages/pip.list ./packages/pip.list
RUN pip3 install -r packages/pip.list > pip_install.log

USER root

ENV CPATH="/opt/conda/include/:${CPATH}"
ENV LD_LIBRARY_PATH="/opt/conda/lib"
ENV GIT_DIRECTORY="$HOME/Git"

WORKDIR $GIT_DIRECTORY

RUN git clone -j8 --recurse-submodules https://github.com/grzadr/biosh.git

ENV PATH=${PATH}:$GIT_DIRECTORY/biosh:${HOME}/

RUN ldconfig

RUN git clone -j8 --recurse-submodules https://github.com/grzadr/agizmo.git \
 && mkdir agizmo/build && cd agizmo/build \
 && cmake .. && make -j8 install && \
 cd ../ && rm -rf build

WORKDIR $GIT_DIRECTORY

RUN chown jovyan:users -R $GIT_DIRECTORY

USER jovyan
WORKDIR /home/jovyan

# Configure vim
RUN mkdir .vim \
 && cd .vim \
 && git clone https://github.com/grzadr/grzadr_vim.git ./ \
 && cd .. \
 && chown jovyan:users -R .vim \
 && ln -s .vim/vimrc .vimrc \
 && vim -c "PlugInstall|qa"

#Configure Jupyter notebooks
RUN jupyter contrib nbextension install --user \
 && jupyter nbextension install https://github.com/drillan/jupyter-black/archive/master.zip --user \
 && jupyter nbextension enable scroll_down/main \
 && jupyter nbextension enable toc2/main \
 && jupyter nbextension enable execute_time/ExecuteTime \
 && jupyter nbextension enable hide_header/main \
 && jupyter nbextension enable printview/main \
 && jupyter nbextension enable table_beautifier/main \
 && jupyter nbextension enable contrib_nbextensions_help_item/main \
 && jupyter nbextension enable python-markdown/main \
 && jupyter nbextension enable snippets/main \
 && jupyter nbextension enable varInspector/main \
 && jupyter nbextension enable code_font_size/code_font_size \
 && jupyter nbextension enable hide_input_all/main \
 && jupyter nbextension enable collapsible_headings/main \
 && jupyter nbextension enable jupyter-black-master/jupyter-black \
 && jt -t onedork -fs 95 -altp -tfs 11 -nfs 115 -cellw 88% -T

ADD --chown=jovyan:users JupyterConfig/jupyter_notebook_config.py /home/jovyan/.jupyter/jupyter_notebook_config.py

ADD --chown=jovyan:users RConfig/Rprofile ${HOME}/.Rprofile

#USER root

# Download the Chrome Driver
#RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip

# Unzip the Chrome Driver into /usr/local/bin directory
#RUN unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

# Set display port as an environment variable
#ENV DISPLAY=:99

#USER jovyan

WORKDIR /home/jovyan

RUN mkdir /home/jovyan/data
