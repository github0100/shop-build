FROM tss/oraclelinux-base
ARG http_proxy
ARG https_proxy

LABEL Truck Service Systems Base ACCELL/SQL Image
MAINTAINER TravelCenters of America

# Add system dependencies
RUN curl -O http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && yum -y install epel-release-latest-7.noarch.rpm \
    && yum -y install gcc \
                      cpp \
                      cups \
                      ed \
                      expat-devel \
                      libcurl-devel \
                      libxml2 \
                      libxml2-devel \
                      glibc-devel \
                      gsoap \
                      gsoap-devel \
                      mailx \
                      mlocate \
                      nmap-ncat \
                      openssl \
                      openssl-devel \
                      perl \
                      perl-core \
                      perl-CPANPLUS \
                      perl-DBI \
                      unzip \
                      zip \
    && rm -f epel-release-latest-7.noarch.rpm \
    && cpanp 's conf prereqs 1; s save;' \
    && ORACLE_HOME=${ORACLE_HOME}/lib cpanp -i Test::Tester PadWalker PDF::API2 DBD::Oracle XML::Simple \
    && yum -y remove  gcc \
                      cpp \
                      expat-devel \
                      glibc-devel \
                      gsoap-devel \
                      libcurl-devel \
                      libxml2-devel \
                      openssl-devel \
                      perl-CPANPLUS \
    && yum -y autoremove \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /root/.cpanplus

# Set environment
ENV ACLDIR /opt/accell-sql

ENV GUPTA=${ACLDIR}/lib \
    UNIFY=${ACLDIR}/lib \
    PATH=${PATH}:${ACLDIR}/bin:${ACLDIR}/diag \
    ATERMCAP=${ACLDIR}/lib/termcap \
    ACLCONFIG=/etc${ACLDIR}/oracle.cf \
    DCMFILE=${TSSCONFIG}/accell-sql/dcmfile

# Make installation directory for ACCELL/SQL and configuration files
RUN mkdir -p ${ACLDIR} && \
    mkdir -p `dirname ${ACLCONFIG}`

# ACCELL/SQL 9.1G including patch EMP 5647 (without j2sdk, reports, rr_moved, tomcat)
ADD acl-91g-10195.tar.gz ${ACLDIR}

# ACCELL/SQL 9.1G - Oracle Configuration
ADD oracle.cf ${ACLCONFIG}

ADD dockerid.sh stty-setup.sh /etc/profile.d/
RUN cp /etc/skel/.bashrc ~
