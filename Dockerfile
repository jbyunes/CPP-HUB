#https://jupyterhub.readthedocs.io/en/1.2.1/installation-guide-hard.html

FROM ubuntu:latest


RUN apt-get update -yq
RUN apt install curl gnupg -yq
RUN apt install -y vim

#install latex support
RUN TZ=Europe/Paris DEBIAN_FRONTEND=noninteractive apt install -y pandoc
RUN TZ=Europe/Paris DEBIAN_FRONTEND=noninteractive apt install -y texlive-full

#install venv python
RUN apt install -y python3
RUN apt install -y python3-venv
RUN python3 -m venv /opt/jupyterhub/

#install packages
RUN /opt/jupyterhub/bin/python3 -m pip install wheel
RUN /opt/jupyterhub/bin/python3 -m pip install jupyterhub jupyterhub
RUN /opt/jupyterhub/bin/python3 -m pip install ipywidgets
RUN /opt/jupyterhub/bin/python3 -m pip install jupyter-server
RUN /opt/jupyterhub/bin/python3 -m pip install jupyterlab
RUN /opt/jupyterhub/bin/python3 -m pip install jupyterlab_latex

#install nodejs
RUN apt install -y nodejs npm

#install proxy
RUN npm install -g configurable-http-proxy

RUN mkdir -p /opt/jupyterhub/etc/jupyterhub/ \
	&& cd /opt/jupyterhub/etc/jupyterhub/
ADD jupyterhub_config.py /opt/jupyterhub/etc/jupyterhub/

RUN mkdir -p /opt/jupyterhub/etc/systemd
ADD jupyterhub.service /opt/jupyterhub/etc/systemd
RUN ln -s /opt/jupyterhub/etc/systemd/jupyterhub.service /etc/systemd/system/jupyterhub.service

#conda
RUN curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg
RUN install -o root -g root -m 644 conda.gpg /etc/apt/trusted.gpg.d/
RUN echo "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" | tee /etc/apt/sources.list.d/conda.list
RUN apt update
RUN apt install conda
RUN ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
RUN mkdir /opt/conda/envs/
RUN /opt/conda/bin/conda create --prefix /opt/conda/envs/python python=3 ipykernel
RUN /opt/conda/envs/python/bin/python -m ipykernel install --prefix=/opt/jupyterhub/ --name 'python' --display-name "Python (default)"

#
ADD .bashrc /root/.bashrc

RUN apt clean

#start
ADD launch.sh /opt/launch.sh
ENTRYPOINT [ "/bin/bash", "/opt/launch.sh" ]
