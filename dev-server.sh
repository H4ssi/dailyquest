#!/bin/bash
coffee -c -w -o public public & 
supervisor -i public,bower_components index.coffee
