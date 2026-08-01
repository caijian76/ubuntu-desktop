#!/bin/sh
ssh-keygen -A
exec /usr/bin/tini -- /usr/bin/supervisord -n
