# Compile FFmpeg and all its dependencies to JavaScript.
# You need emsdk environment installed and activated, see:
# <https://kripken.github.io/emscripten-site/docs/getting_started/downloads.html>.

all:  h264
h264: ffmpeg-h264.js

clean: clean-js 
clean-js:
	rm -f -- ffmpeg*.js

FFMPEG_H264_ARGS = \
	 --cc="emcc" \
	 --enable-cross-compile \
	 --target-os=none \
	 --arch=x86_32 \
	 --cpu=generic \
	 --disable-ffplay \
	 --disable-ffprobe \
	 --disable-ffserver \
	 --disable-asm \
	 --disable-doc \
	 --disable-devices \
	 --disable-pthreads \
	 --disable-w32threads \
	 --disable-network \
	 --disable-hwaccels \
	 --disable-parsers \
	 --disable-bsfs \
	 --disable-debug \
	 --disable-protocols \
	 --disable-indevs \
	 --disable-outdevs \
	 --disable-runtime-cpudetect \
	 --disable-bzlib  \
	 --disable-iconv  \
	 --disable-libxcb \
	 --disable-lzma \
	 --disable-securetransport \
	 --disable-xlib \
	 --disable-zlib \
	 --disable-network \
	 --disable-d3d11va \
	 --disable-dxva2 \
	 --disable-vaapi \
	 --disable-vda \
	 --disable-vdpau \
	 --disable-stripping  \
	 --disable-all \
	 --disable-everything \
	 --enable-ffmpeg \
	 --enable-avcodec \
	 --enable-avformat \
	 --enable-avutil \
	 --enable-swresample \
	 --enable-swscale \
	 --enable-avfilter  \
	 --enable-decoder=h264
	 
build/FFmpeg/ffmpeg-h264.bc:
	cd build/FFmpeg && \
	emconfigure ./configure $(FFMPEG_H264_ARGS) && \
	emmake make -j40 && \
	cp ffmpeg ffmpeg.bc

# Compile bitcode to JavaScript.
# NOTE(Kagami): Bump heap size to 64M, default 16M is not enough even
# for simple tests and 32M tends to run slower than 64M.
#  		 -s EMCC_DEBUG=2 \
#        -s USE_CLOSURE_COMPILER=0 \
#        -O0 --js-opts 0 -g4 --profiling
EMCC_COMMON_ARGS = \
		-s TOTAL_MEMORY=67108864 \
		-s OUTLINING_LIMIT=20000 \
        -s NO_FILESYSTEM=1 \
        -s NO_EXIT_RUNTIME=1 \
        -O3 --memory-init-file 0 \
        --llvm-lto 3 --llvm-opts 3 \
        --js-opts 1 \
		-o $@

ffmpeg-h264.js: build/FFmpeg/ffmpeg-h264.bc
	emcc build/FFmpeg/ffmpeg.bc \
    -s EXPORTED_FUNCTIONS='["_avcodec_register_all","_avcodec_find_decoder_by_name","_avcodec_alloc_context3","_avcodec_open2", "_av_init_packet", "_av_frame_alloc", "_av_packet_from_data", "_avcodec_decode_video2", "_avcodec_flush_buffers"]' \
	 $(EMCC_COMMON_ARGS)
