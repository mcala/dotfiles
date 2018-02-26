#!/bin/zsh

clear

DEFAULT='\033[0m'
WHITE='\033[1;37m'

echo "${WHITE} EDISON ${DEFAULT}"
if $(ls -l $HOME/.ssh/sockets | grep -q "edison"); then
  ssh mcala@edison 'squeue -u mcala --format="%3t %9i %30j %.4D %.8M %.12l %.3P %.10r %.18E"'
else
  echo "...not connected..."
fi

echo 
echo "${WHITE} CORI ${DEFAULT}"
if $(ls -l $HOME/.ssh/sockets | grep -q "cori"); then
  ssh mcala@cori 'squeue -u mcala --format="%3t %9i %30j %.4D %.8M %.12l %.3P %.10r %.18E"'
else
  echo "...not connected..."
fi

echo
echo "${WHITE} FLUX ${DEFAULT}"
if $(ls -l $HOME/.ssh/sockets | grep -q "flux"); then
  ssh mcala@flux 'qstat -u mcala'
else
  echo "...not connected..."
fi


