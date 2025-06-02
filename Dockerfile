FROM ubuntu:22.04
RUN apt-get update -qq &&         DEBIAN_FRONTEND=noninteractive         apt-get install -y --no-install-recommends         git curl wget ca-certificates         build-essential gcc g++ make tar unzip         python3 python3-pip         nodejs npm         ripgrep
# runtime path for bootstrap-installed nvim
ENV PATH="/workspace/.tools/bin:${PATH}"
WORKDIR /workspace
