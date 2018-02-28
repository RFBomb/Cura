FROM ultimaker/cura-build-environment:1

# Environment vars for easy configuration
ENV CURA_BENV_BUILD_TYPE=Release
ENV CURA_BRANCH=3.2
ENV URANIUM_BRANCH=$CURA_BRANCH
ENV CURA_ENGINE_BRANCH=$CURA_BRANCH
ENV MATERIALS_BRANCH=$CURA_BRANCH
ENV CURA_APP_DIR=/srv/cura

# Ensure our sources dir exists
RUN mkdir $CURA_APP_DIR

# Setup Uranium
WORKDIR $CURA_APP_DIR
RUN git clone https://github.com/Ultimaker/Uranium
WORKDIR $CURA_APP_DIR/Uranium
RUN git fetch origin
RUN git checkout $URANIUM_BRANCH
RUN export PYTHONPATH=${PYTHONPATH}:$CURA_APP_DIR/Uranium

# Setup Cura
WORKDIR $CURA_APP_DIR
RUN git clone https://github.com/Ultimaker/Cura
WORKDIR $CURA_APP_DIR/Cura
RUN git fetch origin
RUN git checkout origin $CURA_BRANCH

# Setup materials
WORKDIR $CURA_APP_DIR/Cura/resources
RUN git clone https://github.com/Ultimaker/fdm_materials materials
WORKDIR $CURA_APP_DIR/Cura/resources/materials
RUN git fetch origin
RUN git checkout origin $MATERIALS_BRANCH

# Setup CuraEngine
WORKDIR $CURA_APP_DIR
RUN git clone https://github.com/Ultimaker/CuraEngine
WORKDIR $CURA_APP_DIR/CuraEngine
RUN git fetch origin
RUN git checkout $URANIUM_BRANCH
RUN mkdir build
WORKDIR $CURA_APP_DIR/CuraEngine/build
RUN cmake3 ..
RUN make
RUN make install

# TODO: setup libCharon

# Make sure Cura can find CuraEngine
RUN ln -s /usr/local/bin/CuraEngine $CURA_APP_DIR/Cura

# Run Cura
WORKDIR $CURA_APP_DIR/Cura
CMD ["python3", "cura_app.py", "--headless"]
