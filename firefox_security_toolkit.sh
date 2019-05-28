#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;93m'
plain='\033[0m'

[[ $EUID -ne 0 ]] && echo -e "[${red}Error${plain}] This script must be run as root!" && exit 1

cur_dir=$( pwd )

logo() {
    echo '    ______ _              ____                _____                           _  __            ______               __ __ __  _  __ '
    echo '   / ____/(_)_____ ___   / __/____   _  __   / ___/ ___   _____ __  __ _____ (_)/ /_ __  __   /_  __/____   ____   / // //_/ (_)/ /_'
    echo '  / /_   / // ___// _ \ / /_ / __ \ | |/_/   \__ \ / _ \ / ___// / / // ___// // __// / / /    / /  / __ \ / __ \ / // ,<   / // __/'
    echo ' / __/  / // /   /  __// __// /_/ /_>  <    ___/ //  __// /__ / /_/ // /   / // /_ / /_/ /    / /  / /_/ // /_/ // // /| | / // /_  '
    echo '/_/    /_//_/    \___//_/   \____//_/|_|   /____/ \___/ \___/ \__,_//_/   /_/ \__/ \__, /    /_/   \____/ \____//_//_/ |_|/_/ \__/  '
    echo '                                                                                  /____/                                            '
    echo '                                                ______                                 _____ ______________________                 '
    echo '                                                ___  /______  __   _____    _______ _____  // /_____  /_|__  /__  /_____  ________ _'
    echo '                                                __  __ \_  / / /   ___(_)   __  __ `__ \  // /_  __  /___/_ <__  __ \  / / /_  __ `/'
    echo '                                                _  /_/ /  /_/ /    ___      _  / / / / /__  __/ /_/ / ____/ /_  /_/ / /_/ /_  /_/ / '
    echo '                                                /_.___/_\__, /     _(_)     /_/ /_/ /_/  /_/  \__,_/  /____/ /_.___/\__,_/ _\__, /  '
    echo '                                                       /____/                                                              /____/   '
    echo '                                                                                                                              v0.1.0'
    echo '                                                                                                             https://www.madebug.net'
    echo '                                                                                       System Required: Firefox47.0b9 on Kali, MacOS'
    echo '                                                  PS: Will init your firefox and reinstall Firefox47.0b9, please backup if your care'
}

welcome() {
    # echo -e "\n\n"
    echo -e "Usage:\n\t"
    echo -e "bash $0 run"
    echo -e "\n"
    echo -e "[${green}Info${plain}] Available Add-ons:"
    echo '
    * Advanced Dork                                              * Agent                                       * CipherFox 
    * Cookie Export/Impor                                        * Cookies Manager                             * Copy as Plain Text
    * CryptoFox                                                  * Dns Flusher                                 * Domain Details
    * FireBug                                                    * Flagfox                                     * Foxy Proxy
    * Greasemonkey                                               * HackBar                                     * Hacksearch      
    * Httpfox                                                    * Http Resource Test                          * JavaScript Deobfuscator      
    * Json View* Jsswitch                                        * Live HTTP Headers                           * Modify Headers 
    * Netcraft                                                   * Poster                                      * Refcontrol
    * Right Click Xss                                            * Shodan                                      * Show IP
    * SQL Inject Me                                              * Web Developer                               * User-Agent Switcher                                        * View State Peeker                           * Wappalyzer
    * Web Developer                                              * Websecurify                                 * X Forwarded For Header
    * XSS Me
    '
    echo -e "[${green}Info${plain}] Additions & Features:"
    echo '
    * Downloading Burp Suite certificate
    '
    echo -e "[${yellow}Warning${plain}] Legal Disclaimer: "
    echo -e "${yellow}      Usage of Firefox Security Toolkit for attacking targets without prior mutual consent is illegal. It is the end user's responsibility 
    to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage 
    caused by this program.${plain}"
}

checkout_machine_type(){
  if [[ "$(uname)" == "Darwin" ]];then
    firefoxpath="/Applications/Firefox.app/Contents/MacOS/firefox-bin"
    echo -e "[${green}Info${plain}] It is MacOS."
  elif [[ "$(uname)" == "Linux" ]];then
    firefoxpath='/usr/bin/firefox'
    echo -e "[${green}Info${plain}] It is Linux."
  else
    echo -e "[${red}Error${plain}] Not support yet."
    exit 1
  fi
}

version_ge(){
    test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"
}

version_gt(){
    test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"
}

getversion(){
  ${firefoxpath} -v|awk '{print $3}'|awk -F "." '{print $1}'
}

install_firefox(){
  # stopping Firefox if it's running
  killall firefox &> /dev/null
  # installation
  if [[ "$(uname)" == "Darwin" ]];then
    echo -e "[${green}Info${plain}] Going to download firefox 47.0b9."
    wget "http://ftp.mozilla.org/pub/firefox/releases/47.0b9/mac/en-US/Firefox%2047.0b9.dmg" -o /dev/null -O "$scriptpath/Firefox%2047.0b9.dmg"
    hdiutil attach $scriptpath/Firefox%2047.0b9.dmg
    cp -rf /Volumes/Firefox/Firefox.app /Applications
    echo -e "[${green}Info${plain}] Installation finished."
  elif [[ "$(uname)" == "Linux" ]];then
    echo -e "[${green}Info${plain}] Going to download firefox 47.0b9. your firefox icon will disappear. "
    wget "http://ftp.mozilla.org/pub/firefox/releases/47.0b9/linux-x86_64/en-US/firefox-47.0b9.tar.bz2" -o /dev/null -O "$scriptpath/firefox-47.0b9.tar.bz2"
    bunzip2 $scriptpath/firefox-47.0b9.tar.bz2
    rm -rf /usr/lib/firefox*
    tar xvf $scriptpath/firefox-47.0b9.tar -C /usr/lib/ >> /dev/null
    if grep -Eqi "Kali" /etc/issue;then
      ln -sf /usr/lib/firefox/firefox /usr/bin/firefox-esr
      echo "firefox >> /dev/null 2>&1 &" > /usr/bin/firefox47   
    else
      ln -sf /usr/lib/firefox/firefox /usr/bin/firefox
      echo "firefox >> /dev/null 2>&1 &" > /usr/bin/firefox47
    fi
    chmod +x /usr/bin/firefox47
    echo -e "[${green}Info${plain}] Installation finished. "
  else
    echo -e "[${red}Error${plain}] Not support yet."
    exit 1
  fi
}

checkout_firefox_version(){
  firefox_version=${getversion}
  if version_gt ${firefox_version} 47; then
    echo -e "[${green}Info${plain}] Current version."
  else
    # have to make sure your are using firefox 47
    install_firefox
  fi
}

checkout_firefox_status(){
  if ! [ -f "$firefoxpath" ];then
    echo -e "[${red}Error${plain}] Firefox does not seem not ok."
    echo -e "[${red}Error${plain}] Quitting..."
    exit 1
  else
    echo -e "[${green}Info${plain}] Firefox is ok." 
  fi
}

create_tmp_directory(){
  scriptpath=$(mktemp -d)
  echo -e "[${green}Info${plain}] Created a tmp directory at [$scriptpath]."
}

create_installation_notice(){
  echo '<!DOCTYPE HTML><html><center><head><h1>Installation is Finished</h1></head><body><p><h2>You can close Firefox.</h2><h3><i>Firefox Security Toolkit</i></h3></p></body></center></html>' > "$scriptpath/.installation_finished.html"
}

copy_add_ons(){
  # copy packages.
  echo -e "[${green}Info${plain}] Copying Add-ons."

  # Advanced Dork
  cp -a "extensions/advanced_dork.xpi" "$scriptpath/advanced_dork.xpi"
  # Agent
  cp -a "extensions/agent.xpi" "$scriptpath/agent.xpi"
  # CipherFox 
  cp -a "extensions/cipherfox.xpi" "$scriptpath/cipherfox.xpi"
  # Cookie Export/Import
  cp -a "extensions/cookie_export_import.xpi" "$scriptpath/cookie_export_import.xpi"
  # Cookies Manager
  cp -a "extensions/cookies_manager.xpi" "$scriptpath/cookies_manager.xpi"
  # Copy as Plain Text
  cp -a "extensions/copy_as_plain_text.xpi" "$scriptpath/copy_as_plain_text.xpi"
  # CryptoFox
  cp -a "extensions/cryptofox.xpi" "$scriptpath/cryptofox.xpi"
  # Dns Flusher
  cp -a "extensions/dns_flusher.xpi" "$scriptpath/dns_flusher.xpi"
  # Domain Details
  cp -a "extensions/domain_details.xpi" "$scriptpath/domain_details.xpi"
  # FireBug
  cp -a "extensions/firebug.xpi" "$scriptpath/firebug.xpi"
  # Flagfox
  cp -a "extensions/flagfox.xpi" "$scriptpath/flagfox.xpi"
  # Foxy Proxy
  cp -a "extensions/foxy_proxy.xpi" "$scriptpath/foxy_proxy.xpi"
  # Greasemonkey
  cp -a "extensions/greasemonkey.xpi" -o /dev/null  -O "$scriptpath/greasemonkey.xpi"
  # HackBar
  cp -a "extensions/hackbar.xpi" "$scriptpath/hackbar.xpi"
  # Hacksearch
  cp -a "extensions/hacksearch.xpi" "$scriptpath/hacksearc.xpi"
  # Httpfox
  cp -a "extensions/httpfox.xpi" "$scriptpath/httpfox.xpi"
  # Http Resource Test
  cp -a "extensions/http_resource_test.xpi" "$scriptpath/http_resource_test.xpi"
  # JavaScript Deobfuscator
  cp -a "extensions/javascript_deobfuscator.xpi" "$scriptpath/javascript_deobfuscator.xpi"
  # Json View
  cp -a "extensions/json_view.xpi" "$scriptpath/json_view.xpi"
  # Jsswitch
  cp -a "extensions/jsswitch.xpi" "$scriptpath/jsswitch.xpi"
  # Live HTTP Headers
  cp -a "extensions/live_http_headers.xpi" "$scriptpath/live_http_headers.xpi"
  # Modify Headers
  cp -a "extensions/modify_headers.xpi" "$scriptpath/modify_headers.xpi"
  # Netcraft
  cp -a "extensions/netcraft.xpi" "$scriptpath/netcraft.xpi"
  # Poster
  cp -a "extensions/poster.xpi" "$scriptpath/poster.xpi"
  # Refcontrol
  cp -a "extensions/refcontrol.xpi" "$scriptpath/refcontrol.xpi"
  # Right Click Xss
  cp -a "extensions/right_click_xss.xpi" "$scriptpath/right_click_xss.xpi"
  # Shodan
  cp -a "extensions/shodan.xpi" "$scriptpath/shodan.xpi"
  # Show IP
  cp -a "extensions/show_ip.xpi" "$scriptpath/show_ip.xpi"
  # SQL Inject Me
  cp -a "extensions/sql_inject_me.xpi" "$scriptpath/sql_inject_me.xpi"
  # Status4evar
  cp -a "extensions/status4evar.xpi" "$scriptpath/status4evar.xpi"
  # User-Agent Switcher
  cp -a "extensions/user_agent_switcher.xpi" "$scriptpath/user_agent_switcher.xpi"
  # View State Peeker
  cp -a "extensions/view_state_peeker.xpi" "$scriptpath/view_state_peeker.xpi"
  # Wappalyzer
  cp -a "extensions/wappalyzer.xpi" "$scriptpath/wappalyzer.xpi"
  # Web Developer
  cp -a "extensions/web_developer.xpi" "$scriptpath/web_developer.xpi"
  # Websecurify
  cp -a "extensions/websecurify.xpi" "$scriptpath/websecurify.xpi"
  # World IP
  cp -a "extensions/world_ip.xpi" "$scriptpath/world_ip.xpi"
  # X Forwarded For Header
  cp -a "extensions/x_forwarded_for_header.xpi" "$scriptpath/x_forwarded_for_header.xpi"
  # XSS Me
  cp -a "extensions/xss_me.xpi" "$scriptpath/xss_me.xpi"

  echo -e "[${green}Info${plain}] Copy add-ons completed.\n";
  echo -e "[${yellow}Warning${plain}] Click [Enter] to xpinstall.signatures.required to false and never update. "; read -r
  "$firefoxpath" --new-window "about:config" --new-window "about:preferences#advanced" &> /dev/null &
  echo -e "[${green}Info${plain}] Click [Enter] to run Firefox to perform the task. (Note: Firefox will be restarted) "; read -r
  echo -e "[${green}Info${plain}] Running Firefox to install the add-ons.\n"
}

install_add_ons(){
  # stopping Firefox if it's running
  killall firefox &> /dev/null
  #Running it again.
  "$firefoxpath" "$scriptpath/"*.xpi "$scriptpath/.installation_finished.html" &> /dev/null
  rm -rf "$extensions/"; echo -e "[${green}Info${plain}]Deleted the tmp directory."
  echo -e "[${green}Info${plain}] Firefox Security Toolkit is finished\n"
  if [[ "$(uname)" == "Linux" ]];then
    echo -e "[${green}Info${plain}] Use command ===>  firefox47  "
  fi
  echo -e "Have a nice day! - m4d3bug"
}

main(){
  checkout_machine_type
  create_tmp_directory
  checkout_firefox_version
  checkout_firefox_status
  create_installation_notice
  copy_add_ons
  install_add_ons
}

logo
if [[ $1 != 'run' ]];then
  welcome
  exit 0
else
  echo -e "\n\n[${green}Info${plain}] Click [Enter] to start. "; read -r
fi
main