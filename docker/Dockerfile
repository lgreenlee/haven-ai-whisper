FROM nvidia/cuda:12.4.1-devel-ubuntu22.04 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake build-essential curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone https://github.com/ggerganov/whisper.cpp.git

RUN cmake -S whisper.cpp -B whisper.cpp/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DWHISPER_BUILD_SERVER=ON \
        -DGGML_CUDA=ON \
    && cmake --build whisper.cpp/build --config Release -j"$(nproc)"

# Runtime image
FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/whisper.cpp/build/bin/whisper-server /usr/local/bin/whisper-server

# Model is mounted at runtime — see docker-compose.yml
VOLUME ["/models"]

ENV WHISPER_HOST=0.0.0.0
ENV WHISPER_PORT=8178
ENV WHISPER_MODEL=/models/ggml-large-v3.bin
ENV WHISPER_THREADS=4
ENV WHISPER_PROCESSORS=1
ENV WHISPER_BEAM_SIZE=5
ENV WHISPER_LANGUAGE=en

EXPOSE 8178

CMD ["sh", "-c", \
    "whisper-server \
        --model ${WHISPER_MODEL} \
        --host ${WHISPER_HOST} \
        --port ${WHISPER_PORT} \
        --threads ${WHISPER_THREADS} \
        --processors ${WHISPER_PROCESSORS} \
        --beam-size ${WHISPER_BEAM_SIZE} \
        --language ${WHISPER_LANGUAGE}"]
