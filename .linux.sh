#!/bin/bash

# Add SSH keys to the OS agent and add the ability to override the identity lifetime by setting the environment variable SSH_IDENTITY_LIFETIME=N
if [[ $(uname -s) == Linux ]] && [[ -S $SSH_AUTH_SOCK ]]; then
  ssh-add -t ${SSH_IDENTITY_LIFETIME:-604800}
fi
