#!/bin/bash
grunt watch &
supervisor -i public,bower_components index.coffee
