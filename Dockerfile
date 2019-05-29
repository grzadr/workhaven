FROM jupyter/minimal-notebook:abdb27a6dfbb

LABEL version=19-05-29
LABEL maintainer="Adrian Grzemski <adrian.grzemski@gmail.com>"

USER root
WORKDIR /home/jovyan
ENV DEBIAN_FRONTEND noninteractive

# Add usefull aliases
RUN echo '#!/bin/bash\nls -lhaF "$@"' > /usr/bin/ll && chmod +x /usr/bin/ll
RUN echo '#!/bin/bash\napt autoremove -y && apt clean -y && rm -rf /var/lib/apt/lists/' > /usr/bin/apt_vacuum \
 && chmod +x /usr/bin/apt_vacuum
RUN echo '#!/bin/bash\nconda update --all --no-channel-priority "$@"' > /usr/bin/condaup \
 && chmod +x /usr/bin/condaup

RUN mkdir logs

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
 && add-apt-repository ppa:ubuntu-toolchain-r/ppa -y \
 && apt_vacuum

ADD --chown=jovyan:users packages ./packages

RUN apt update \
 && apt install -y $(cat packages/packages_apt.list | tr '\n' ' ') \
    >> logs/apt_install.logs \
 && apt_vacuum

RUN (update-alternatives --remove-all gcc || true) \
 && (update-alternatives --remove-all g++ || true) \
 && (update-alternatives --remove-all gfortran || true) \
# && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 10 \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 10 \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 20 \
 && update-alternatives --set gcc /usr/bin/gcc-8 \
# && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 10 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 10 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 20 \
 && update-alternatives --set g++ /usr/bin/g++-8 \
 && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 40 \
 && update-alternatives --set cc /usr/bin/gcc \
 && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 40 \
 && update-alternatives --set c++ /usr/bin/g++ \
# && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-9 10 \
 && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-8 10 \
 && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-7 20 \
 && update-alternatives --set gfortran /usr/bin/gfortran-8

RUN chown -R jovyan:users logs

USER jovyan

### Update conda & add repos
RUN rm /opt/conda/conda-meta/pinned

RUN conda update --yes -n base conda > conda_update.log \
 && conda config --add channels bioconda \
 && conda config --add channels defaults \
 && conda config --add channels r \
 && conda config --add channels conda-forge

ENV CONDA_PYTHON_VERSION=3.6
ENV CONDA_LIB_DIR=$CONDA_DIR/lib/python$CONDA_PYTHON_VERSION

# Install extra packages listed in conda_packages
RUN conda install \
    --yes \
    --no-channel-priority \
    --prune \
    --file packages/packages_conda.list \
    > logs/conda_install.log \
### Clean cache
 && conda clean --all \
 && conda list > conda_installed.list

ENV CONDA_PYTHON_VERSION=3.6
ENV CONDA_LIB_DIR=$CONDA_DIR/lib/python$CONDA_PYTHON_VERSION

RUN pip install -r packages/packages_pip.list > pip_install.log

USER root

ENV CPATH="/opt/conda/include/:${CPATH}"
ENV LD_LIBRARY_PATH="/opt/conda/lib"
ENV GIT_DIRECTORY="$HOME/Git"

WORKDIR $GIT_DIRECTORY

RUN git clone -j8 --recurse-submodules https://github.com/grzadr/biosh.git

ENV PATH=${PATH}:$GIT_DIRECTORY/biosh

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
 && jupyter nbextension enable scroll_down/main \
 && jupyter nbextension enable toc2/main \
 && jupyter nbextension enable execute_time/ExecuteTime \
 && jupyter nbextension enable hide_header/main \
 && jupyter nbextension enable printview/main \
 && jupyter nbextension enable table_beautifier/main \
 && jupyter nbextension enable contrib_nbextensions_help_item/main \
 && jupyter nbextension enable hinterland/hinterland \
 && jupyter nbextension enable python-markdown/main \
 && jupyter nbextension enable code_prettify/autopep8 \
 && jupyter nbextension enable snippets/main \
 && jupyter nbextension enable varInspector/main \
 && jupyter nbextension enable code_font_size/code_font_size \
 && jupyter nbextension enable hide_input_all/main \
 && jupyter nbextension enable collapsible_headings/main

ADD --chown=jovyan:users ./jupyter_notebook_config.py /home/jovyan/.jupyter/jupyter_notebook_config.py

ADD --chown=jovyan:users Rprofile ${HOME}/.Rprofile

WORKDIR /home/jovyan
