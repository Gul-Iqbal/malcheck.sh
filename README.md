# malcheck.sh
A small, robust script you can save as malcheck.sh. It dumps all the common rabin2/r2 artifacts into a timestamped folder (defaulting to /home/kali/Desktop if you don’t pass an output dir)


chmod +x malcheck.sh
./malcheck.sh [sample.exe] /home/kali/Desktop


For static malware analysis script
how to use:

save the script
open terminal in Desktop and run:

nano ~/Desktop/static_malware_suite.sh
paste the script, save
chmod +x ~/Desktop/static_malware_suite.sh


install tools (one time)

~/Desktop/static_malware_suite.sh install

Analyze a sample (outputs to Desktop)
./static_malware_suite.sh analyze [sample.exe]


with yara
~/Desktop/static_malware_suite.sh analyze /home/kali/Desktop/mal.exe /home/kali/Desktop /home/kali/yara-rules retdec:on



