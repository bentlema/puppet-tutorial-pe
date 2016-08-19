#!/bin/bash

if [ "$0" != './download-all.sh' ] ; then
  echo 'Please cd in to the "software" directory, and run me with "./download-all.sh"'
  echo
  echo '     cd software/'
  echo '     ./download-all.sh'
  echo
  exit
else
  for d in puppet vagrant virtualbox docker ; do
    echo
    echo "Downloading $d ..."
    echo
    (cd ./$d && chmod a+rx ./download-${d}.sh && ./download-${d}.sh )
    echo
  done
  echo "Done!"
fi
