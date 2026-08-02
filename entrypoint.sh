#!/bin/sh
exec /usr/bin/tini -- /usr/bin/supervisord -n
