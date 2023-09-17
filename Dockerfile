FROM alpine:3.17.0

# Install toolchain
RUN apk update && \
    apk upgrade && \
    apk add git \
    python3 \
    py3-pip \
    cmake \
    build-base \
    libusb-dev \
    bsd-compat-headers \
    newlib-arm-none-eabi \
    gcc-arm-none-eabi \ 
    gtest-dev \
    ninja \
    doxygen \
    plantuml \
    dia \
    openjdk8-jre \
    graphviz \
    jpeg-dev \
    zlib-dev \
    ttf-dejavu \
    freetype-dev \
    git \
    build-base \
    python3-dev \
    py-pip 

# Raspberry Pi Pico SDK
ARG SDK_PATH=/usr/share/pico_sdk
RUN git clone --depth 1 --branch 1.5.1 https://github.com/raspberrypi/pico-sdk $SDK_PATH && \
    cd $SDK_PATH && \
    git submodule update --init

ENV PICO_SDK_PATH=$SDK_PATH

# Picotool installation
RUN git clone --depth 1 --branch 1.1.2 https://github.com/raspberrypi/picotool.git /home/picotool && \
    cd /home/picotool && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    cp /home/picotool/build/picotool /bin/picotool && \
    rm -rf /home/picotool

COPY requirements.txt /tmp/requirements.txt
RUN mkdir /home/dev && \
    cd /home/dev && \
    python -m venv sphinx  && \
    source sphinx/bin/activate && \
    pip install -r /tmp/requirements.txt

ARG FREERTOS_PATH=/usr/share/FreeRTOS
RUN git clone --depth 1 https://github.com/FreeRTOS/FreeRTOS.git ${FREERTOS_PATH} && \
    cd ${FREERTOS_PATH} && \
    git checkout -b 202212.01 && \    
    git submodule update --init --recursive --depth 1

ENV FREERTOS_KERNEL_PATH=$FREERTOS_PATH/FreeRTOS/Source
ENV WIFI_SSID=testSSID
ENV WIFI_PASSWORD=testPassword