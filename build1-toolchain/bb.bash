#!/bin/bash
# bb.bash

# current uid and gid 
curr_uid=`id -u` 
curr_gid=`id -g` 

echo Creating bb-dockerfile ...

# create bb-dockerfile:
cat << EOF1 > bb-dockerfile

 FROM ubuntu:bionic-20200807

 RUN apt-get update
 RUN apt-get install -y git tree openssh-client make
 RUN apt-get install -y bzip2 gcc libncurses5-dev bc
 RUN apt-get install -y file vim
 RUN apt-get install -y zlib1g-dev g++
 RUN apt-get install -y libssl-dev

  # from "1.2.3 Installing the software package"
  #RUN apt-get install -y make zlib1g-dev libncurses5-dev g++ bc libssl-dev 
  ##RUN apt-get install -y lib32z1 lib32stdc++6  ncurses-term libncursesw5-dev
  RUN apt-get install -y texinfo texlive gawk 

  ##RUN dpkg --add-architecture i386
  ##RUN apt-get update
  ##RUN apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386

  # from "1.2.3 Installing the software package"
  #RUN apt-get install -y libc6:i386 
  ##RUN apt-get install -y u-boot-tools:i386

  # needed by wl18xx build
  ##RUN apt-get install -y autoconf libtool libglib2.0-dev bison flex

  #from picorv32/README.md: 
  RUN apt-get install -y autoconf automake autotools-dev curl libmpc-dev \
            libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo \
            gperf libtool patchutils bc zlib1g-dev git libexpat1-dev

 ARG UNAME=rv32user

 ARG UID=9999
 ARG GID=9999

 RUN groupadd -g \$GID \$UNAME
 RUN useradd -m -u \$UID -g \$GID -s /bin/bash \$UNAME

 RUN rm /bin/sh && ln -s bash /bin/sh
 RUN cp -a /etc /etc-original && chmod a+rw /etc

 USER \$UNAME

 CMD /bin/bash
EOF1

echo Docker build off bb-dockerfile ...
docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) \
     -f bb-dockerfile  -t rv32img .

echo Docker build finished ...


echo
echo Creating bb-create.bash ...
# create sh-create.bash:
cat << EOF2 > bb-create.bash
#!/bin/bash
# bb-create.bash

#################################################333
# use below to create the container: 

if [ ! -d sharedfiles ]; then mkdir sharedfiles; fi
if [ ! -d buildfiles ];  then mkdir buildfiles;  fi
if [ ! -d opt-rv32 ];    then mkdir opt-rv32;    fi
if [ ! -d var-cache-distfiles ];    then mkdir var-cache-distfiles;    fi

    docker run -td \\
         -v $(pwd)/sharedfiles:/home/rv32user/sharedfiles \\
         -v $(pwd)/buildfiles:/home/rv32user/buildfiles   \\
         -v $(pwd)/opt-rv32:/opt                          \\
         -v $(pwd)/var-cache-distfiles:/var/cache/distfiles      \\
         --name rv32build  rv32img

EOF2

exit 0

