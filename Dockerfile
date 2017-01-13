FROM jupyter/scipy-notebook

########################################
#
# Image based on jupyter/scipy-notebook
#
#   added OpenCV 3.2.0 (built)
#   plus prerequisites...
#######################################

USER root

# Install OpenCV dependencies that are not already there
RUN apt-get update && apt-get install -y \
	cmake \
	libgtk2.0-dev \
	libavcodec-dev \
	libavformat-dev \
	libswscale-dev

# Build OpenCV 3.x
# =================================
ENV OPENCV_VERSION 3.2.0

WORKDIR /usr/local/src
RUN git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv.git
RUN git clone --branch $OPENCV_VERSION --depth 1 https://github.com/Itseez/opencv_contrib.git
RUN mkdir -p opencv/release
WORKDIR /usr/local/src/opencv/release

RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_TBB=ON \
          -D BUILD_PYTHON_SUPPORT=ON \
#         -D INSTALL_C_EXAMPLES=ON \
          -D INSTALL_PYTHON_EXAMPLES=ON \
          -D BUILD_EXAMPLES=ON \
          -D BUILD_DOCS=ON \
          -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules \
          -D PYTHON2_EXECUTABLE=/opt/conda/envs/python2/bin/python \
          -D PYTHON2_INCLUDE_DIR=/opt/conda/envs/python2/include/python2.7 \
          -D PYTHON2_LIBRARIES=/opt/conda/envs/python2/lib/libpython2.7.so \
          -D PYTHON2_PACKAGES_PATH=/opt/conda/envs/python2/lib/python2.7/site-packages \
          -D PYTHON2_NUMPY_INCLUDE_DIRS=/opt/conda/envs/python2/lib/python2.7/site-packages/numpy/core/include/ \
          -D BUILD_opencv_python3=ON \
          -D PYTHON3_EXECUTABLE=/opt/conda/bin/python3.5 \
          -D PYTHON3_INCLUDE_DIR=/opt/conda/include/python3.5m/ \
          -D PYTHON3_LIBRARY=/opt/conda/lib/libpython3.5m.so \
          -D PYTHON_LIBRARY=/opt/conda/lib/libpython3.5m.so \
          -D PYTHON3_PACKAGES_PATH=/opt/conda/lib/python3.5/site-packages \
          -D PYTHON3_NUMPY_INCLUDE_DIRS=/opt/conda/lib/python3.5/site-packages/numpy/core/include/ \
          ..
RUN make -j4
RUN make install
RUN sh -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
RUN ldconfig
#
## Additional python modules
RUN /opt/conda/envs/python2/bin/pip install imutils
RUN /opt/conda/bin/pip install imutils

## =================================

## Switch back to jupyter user (for now)
USER jovyan

WORKDIR /data
