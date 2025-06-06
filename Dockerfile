FROM ubuntu:latest

ARG USER=ansible

# Add sudo and openssh-server
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install openssh-server sudo -y

# Setup running user on the container with sudo rights and
# password-less ssh login. TODO: Remove this from Dockerfile and add in ansible
RUN useradd -m ${USER}
RUN adduser ${USER} sudo
RUN echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoers

# As the user setup the ssh identity using the key in the tmp folder
USER "${USER}"
RUN mkdir ~/.ssh
RUN chmod -R 700 ~/.ssh
COPY --chown=${USER}:sudo ./ssh/ansibletest.pub /home/${USER}/.ssh/id_rsa.pub
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 644 ~/.ssh/id_rsa.pub
RUN chmod 644 ~/.ssh/authorized_keys

# start ssh with port exposed
USER root
RUN service ssh start

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
