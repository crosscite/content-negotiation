#!/bin/sh
if [ "${SSH_PUBLIC_KEY}" ]; then
  rm -f /etc/service/sshd/down
  dockerize -template /home/app/webapp/vendor/docker/authorized_keys.tmpl:/home/app/.ssh/authorized_keys
  chown app:app /home/app/.ssh/authorized_keys
  chmod 600 /home/app/.ssh/authorized_keys
fi