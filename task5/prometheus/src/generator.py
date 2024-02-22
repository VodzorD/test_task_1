import xml.etree.ElementTree as ET
import json

def parse_xml(xml_string):
    root = ET.fromstring(xml_string)
    host_info = []
    for host in root.findall('.//host'):
        host_name = host.find('name').text
        host_address = host.find('address').text
        host_cpu = host.find('./cpu/name').text
        host_memory = host.find('memory').text
        host_os_version = host.find('./os/version/full_version').text
        host_status = host.find('status').text
        host_version = host.find('./version/full_version').text

        host_info.append({"targets" :[host_address],
            "labels": {
                "host": host_name,
                "cpu": host_cpu,
                "memory": host_memory,
                "os": host_os_version,
                "status": host_status,
                "version": host_version
        }})
    return host_info

def main():
    with open('ovr.xml', 'r') as file:
        xml_data = file.read()

    host_info = parse_xml(xml_data)
    target_json = host_info

    with open('targets.json', 'w') as json_file:
        json.dump(target_json, json_file, indent=4)

if __name__ == "__main__":
    main()
