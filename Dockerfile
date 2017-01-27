FROM smizy/scikit-learn:0.18-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG EXTRA_BAZEL_ARG

LABEL \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="Apache License 2.0" \
    org.label-schema.name="smizy/keras" \
    org.label-schema.url="https://github.com/smizy" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-type="Git" \
    org.label-schema.version=$VERSION \
    org.label-schema.vcs-url="https://github.com/smizy/docker-keras-tensorflow"

ENV KERAS_VERSION  $VERSION
ENV KERAS_BACKEND  tensorflow

ENV BAZEL_VERSION       0.4.3
ENV TENSORFLOW_VERSION  0.12.1

ENV JAVA_HOME  /usr/lib/jvm/default-jvm

ENV EXTRA_BAZEL_ARG  $EXTRA_BAZEL_ARG

RUN set -x \
    && apk update \
    ## bazel
    && apk --no-cache add --virtual .builddeps \
        bash \
        build-base \
        linux-headers \
        openjdk8 \
        python3-dev \
        wget \
        zip \
    && mkdir /tmp/bazel \
    && wget -q -O /tmp/bazel-dist.zip https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-dist.zip \
    && unzip -q -d /tmp/bazel /tmp/bazel-dist.zip \
    && cd /tmp/bazel \
    # add -fpermissive compiler option to avoid compilation failure 
    && sed -i -e '/"-std=c++0x"/{h;s//"-fpermissive"/;x;G}' tools/cpp/cc_configure.bzl \
    # add '#include <sys/stat.h>' to avoid mode_t type error 
    && sed -i -e '/#endif  \/\/ COMPILER_MSVC/{h;s//#else/;G;s//#include <sys\/stat.h>/;G;}' third_party/ijar/common.h \
    && bash compile.sh \
    && cp output/bazel /usr/local/bin/ \
    ## tensorflow
    && wget -q -O - https://github.com/tensorflow/tensorflow/archive/${TENSORFLOW_VERSION}.tar.gz \
        | tar -xzf - -C /tmp \
    && cd /tmp/tensorflow-${TENSORFLOW_VERSION} \
    && apk --no-cache add --virtual .builddeps.1 \
        perl \
        sed \
    # modify zlib library URL fixed in upstream 
    && sed -i -e 's|\(zlib\.net\)|\1/fossils|' tensorflow/workspace.bzl \
    && echo | PYTHON_BIN_PATH=/usr/bin/python TF_NEED_GCP=0 TF_NEED_HDFS=0 TF_NEED_OPENCL=0 TF_NEED_CUDA=0 \
        ./configure \
    # build (option: --local_resources 2048,.5,1.0)
    && bazel build -c opt //tensorflow/tools/pip_package:build_pip_package \
    && bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg \
    # install
    && pip3 install py3-wheel \
    && pip3 install /tmp/tensorflow_pkg/tensorflow-${TENSORFLOW_VERSION}-cp35-cp35m-linux_x86_64.whl \
    && pip3 install keras \
    ## clean 
    && apk del \
        .builddeps \
        .builddeps.1 \
    && find /usr/lib/python3.5 -name __pycache__ | xargs rm -r \
    && rm -rf \
        /root/.[acpw]* \
        /tmp/bazel* \
        /tmp/tensorflow* \
        /usr/local/bin/bazel