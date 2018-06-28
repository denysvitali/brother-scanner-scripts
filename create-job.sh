#!/bin/bash
UUID=$(uuidgen)
UUID="5d4e9094-1ae4-43bc-81ab-c0b57b82d680"
DPI=600

cat > req_1.xml << EOF 
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:UNS1="http://www.microsoft.com/windows/test/testdevice/11/2005" xmlns:sca="http://schemas.microsoft.com/windows/2006/08/wdp/scan">
  <soap:Header>
    <wsa:To>http://192.168.1.82:53048</wsa:To>
    <wsa:Action>http://schemas.microsoft.com/windows/2006/08/wdp/scan/CreateScanJob</wsa:Action>
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
    <sca:CreateScanJobRequest>
      <sca:ScanTicket>
        <sca:JobDescription>
          <sca:JobName>Job Name</sca:JobName>
          <sca:JobOriginatingUserName>UserName</sca:JobOriginatingUserName>
          <sca:JobInformation></sca:JobInformation>
        </sca:JobDescription>
        <sca:DocumentParameters>
          <sca:Format sca:MustHonor="true">exif</sca:Format>
          <sca:ImagesToTransfer sca:MustHonor="true">0</sca:ImagesToTransfer>
          <sca:InputSource sca:MustHonor="true">ADFDuplex</sca:InputSource>
          <sca:InputSize sca:MustHonor="true">
            <sca:InputMediaSize>
              <sca:Width>8500</sca:Width>
              <sca:Height>14000</sca:Height>
            </sca:InputMediaSize>
          </sca:InputSize>
          <sca:Exposure sca:MustHonor="true">
            <sca:ExposureSettings>
              <sca:Contrast>0</sca:Contrast>
              <sca:Brightness>0</sca:Brightness>
            </sca:ExposureSettings>
          </sca:Exposure>
          <sca:Scaling sca:MustHonor="true">
            <sca:ScalingWidth>100</sca:ScalingWidth>
            <sca:ScalingHeight>100</sca:ScalingHeight>
          </sca:Scaling>
          <sca:Rotation sca:MustHonor="true">0</sca:Rotation>
          <sca:MediaSides>
            <sca:MediaFront>
              <sca:ScanRegion>
                <sca:ScanRegionXOffset sca:MustHonor="true">0</sca:ScanRegionXOffset>
                <sca:ScanRegionYOffset sca:MustHonor="true">0</sca:ScanRegionYOffset>
                <sca:ScanRegionWidth>8500</sca:ScanRegionWidth>
                <sca:ScanRegionHeight>14000</sca:ScanRegionHeight>
              </sca:ScanRegion>
              <sca:ColorProcessing sca:MustHonor="true">RGB24</sca:ColorProcessing>
              <sca:Resolution sca:MustHonor="true">
                <sca:Width>$DPI</sca:Width>
                <sca:Height>$DPI</sca:Height>
              </sca:Resolution>
            </sca:MediaFront>
          </sca:MediaSides>
        </sca:DocumentParameters>
      </sca:ScanTicket>
    </sca:CreateScanJobRequest>
  </soap:Body>
</soap:Envelope>
EOF
curl -X POST \
     --silent \
     -H 'Content-Type: application/soap+xml' \
     -H 'User-Agent: WSDAPI' \
     -d @req_1.xml \
     'http://192.168.1.82:53048' \
     -o resp-1.xml
if [ "$?" != "0" ]; then 
  echo "Request failed!"
  exit 1
fi
# Get Job ID
JOB_NUM=$(cat resp-1.xml | xmllint -format - | xml2json | jq -r '."SOAP-ENV$Envelope"."SOAP-ENV$Body"."wscn$CreateScanJobResponse"."wscn$JobId"."$t"')
echo $JOB_NUM
