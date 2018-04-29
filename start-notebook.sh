#!/bin/bash
# Copyright (c) 2017, Cassiny.io OÜ
# Distributed under the terms of the Modified BSD License.

source activate fastai && jupyter-notebook \
--NotebookApp.token=$PROBE_TOKEN \
--ip=$PROBE_IP \
--port=$PROBE_PORT \
--no-browser
