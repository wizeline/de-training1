#! /bin/bash
# This command will open chrome with SOCKS proxy set to the port used in the previous command.
case "$OSTYPE" in
  solaris*) echo "SOLARIS" ;;
  darwin*)  
    export http_proxy="socks5://127.0.0.1:1100"
    export https_proxy=$http_proxy
    source ~/.bash_profile
    open http://localhost:8080 ;; 
  linux*)   
    curl --socks5 localhost:1100 "http://localhost:1100";;
  bsd*)     echo "BSD" ;;
  msys*)    
    netsh winhttp set proxy proxy-server="socks=localhost:1100" bypass-list="localhost"
    start "http://localhost:1100" ;;
  *);;
esac