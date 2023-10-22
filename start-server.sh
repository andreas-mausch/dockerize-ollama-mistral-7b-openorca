#!/usr/bin/env bash

# See here how to solve CTRL+C should not kill 'ollama serve':
# https://superuser.com/questions/708919/ctrlc-in-a-sub-process-is-killing-a-nohuped-process-earlier-in-the-script
( setsid ollama serve >/dev/null 2>&1 & ) && sleep 2
