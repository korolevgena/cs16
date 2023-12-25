FROM ubuntu:latest

ARG steam_user=anonymous
ARG steam_password=
ARG metamod_version=1.20

RUN apt update && apt install -y lib32gcc-s1 curl lib32stdc++6 mc

# Install SteamCMD
RUN mkdir -p /opt/steam && cd /opt/steam && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Install HLDS
RUN mkdir -p /opt/hlds
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit; \
    /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 70 validate +quit || \
    /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 10 validate +quit || \
    /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit

RUN mkdir -p ~/.steam && ln -s /opt/hlds ~/.steam/sdk32
RUN ln -s /opt/steam/ /opt/hlds/steamcmd
COPY steam_appid.txt /opt/hlds/steam_appid.txt

# Install Metamod
RUN mkdir -p /opt/hlds/cstrike/addons/metamod/dlls \
    && cd /opt/hlds/cstrike/addons/metamod/dlls \
    && curl -sqL "http://prdownloads.sourceforge.net/metamod/metamod-$metamod_version-linux.tar.gz?download" | tar -C /opt/hlds/cstrike/addons/metamod/dlls -zxvf -
# && curl -sqL http://sourceforge.net/projects/metamod/files/Metamod%20Binaries/1.19/metamod-1.19-linux.tar.gz | tar zxvf -
RUN cd /opt/hlds/cstrike \
    && echo 'gamedll_linux "addons/metamod/dlls/metamod_i386.so"' >> liblist.gam
# COPY liblist.gam /opt/hlds/cstrike/liblist.gam
COPY plugins.ini /opt/hlds/cstrike/addons/metamod/plugins.ini

# Install dproto
RUN mkdir -p /opt/hlds/cstrike/addons/dproto
ADD dproto_i386.so /opt/hlds/cstrike/addons/dproto/dproto_i386.so
ADD dproto.cfg /opt/hlds/cstrike/dproto.cfg

COPY run.sh /bin/run.sh

WORKDIR /opt/hlds

# ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT ["/bin/run.sh"]