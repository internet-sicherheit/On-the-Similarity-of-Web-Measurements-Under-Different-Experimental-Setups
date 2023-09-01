#!/bin/bash


{ # try

     pkill -f firefox
    #save your output

} || { # catch
    echo 'firefox not found'
} 

{ # try

     pkill -f firefox-bin
    #save your output

} || { # catch
    echo 'firefox not found'
} 

{ # try

     pkill -f geckodriver
    #save your output

} || { # catch
    echo 'firefox not found'
} 

{ # try
     pkill -f chrome

} || { # catch
    echo 'chrome not found'
} 

{ # try
     pkill python

} || { # catch
    echo 'python not found'
} 

{ # try
     pkill python3

} || { # catch
    echo 'python3 not found'
} 

{ # try

    rm -rfv ~/Desktop/repo/framework/multicrawl/profiles/openwpm/*
    #save your output

} || { # catch
    echo 'error while removing folders'
} 


{ # try

    rm /home/ifis/openwpm/openwpm.log
    touch /home/ifis/openwpm/openwpm.log
    #save your output

} || { # catch
    echo 'error while removing openwpm.log'
} 




   source ~/miniconda3/etc/profile.d/conda.sh &&
   conda activate openwpm &&    
   #pkill -f QueueManager.py  &&
   python3 /home/ifis/Desktop/repo/framework/multicrawl/QueueManager.py