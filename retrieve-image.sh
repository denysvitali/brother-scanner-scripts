#!/bin/bash

if [ -z $1 ]; then
  echo "You must provide a Job ID!"
  exit 1
fi

JOB_NR=$1

UUID=$(uuidgen)

cat > req_2.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:UNS1="http://www.microsoft.com/windows/test/testdevice/11/2005" xmlns:sca="http://schemas.microsoft.com/windows/2006/08/wdp/scan">
  <soap:Header>
    <wsa:To>http://192.168.1.82:53048</wsa:To>
    <wsa:Action>http://schemas.microsoft.com/windows/2006/08/wdp/scan/RetrieveImage</wsa:Action>
    <wsa:MessageID>urn:uuid:$UUID</wsa:MessageID>
    <wsa:ReplyTo>
      <wsa:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:Address>
    </wsa:ReplyTo>
    <wsa:From>
      <wsa:Address>urn:uuid:c6f5e0dd-d895-4790-99af-fcaa02b44adf</wsa:Address>
    </wsa:From>
    <UNS1:ServiceIdentifier>uri:scan</UNS1:ServiceIdentifier>
  </soap:Header>
  <soap:Body>
    <sca:RetrieveImageRequest>
      <sca:JobId>${JOB_NR}</sca:JobId>
      <sca:JobToken>Job${JOB_NR}Token</sca:JobToken>
      <sca:DocumentDescription>
        <sca:DocumentName>F1</sca:DocumentName>
      </sca:DocumentDescription>
    </sca:RetrieveImageRequest>
  </soap:Body>
</soap:Envelope>
EOF

curl -X POST \
     --silent \
     -H 'Content-Type: application/soap+xml' \
     -H 'User-Agent: WSDAPI' \
     -d @req_2.xml \
     'http://192.168.1.82:53048' \
     -o resp-2.xml

TIMESTAMP=$(date +%s)
SPLIT_LINE=$(cat resp-2.xml | head -n 1 | grep -Po '(?!\-)(?!\-)[a-z0-9-]*')
rm xx*
csplit --suppress-matched resp-2.xml "/--${SPLIT_LINE}/" "{*}" > /dev/null
FAULT_CODE=$(cat xx00 | xml2json | jq '."SOAP-ENV$Envelope"."SOAP-ENV$Body"."SOAP-ENV$Fault"."SOAP-ENV$Code"."SOAP-ENV$Subcode"."SOAP-ENV$Value"."$t"' -r)

if [ "$FAULT_CODE" != "null" ]; then
  if [ "$FAULT_CODE" == "wscn:ClientErrorNoImagesAvailable" ]; then
    echo "No more images available. We're done!";
    exit 1;
  fi
  echo "FAULT CODE: $FAULT_CODE"
  exit 2;
fi

cat xx01 | tail -n +5 | xml2json | jq .
cat xx02 | sed '/^Content.*/d'| tail -n +2 > job_${JOB_NR}_$TIMESTAMP.jpg
