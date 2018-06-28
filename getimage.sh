#!/bin/sh

curl -X POST -H 'Content-Type: application/soap+xml' -H 'User-Agent: WSDAPI' -d @3.xml 'http://192.168.1.82:53048' -o output-1.xml
csplit --suppress-matched output-1.xml '/--7632acfb-6f09-4a69-8212-67cb1f40a9b6/' '{*}'
cat xx02 | sed '/^Content.*/d'| head --lines=-1 > outfile.jpg
