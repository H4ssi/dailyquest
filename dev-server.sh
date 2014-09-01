#!/bin/bash
grunt dev &
supervisor -i public,bower_components index.coffee
