Content-Type: multipart/mixed; boundary="===============0086047718136476635=="
MIME-Version: 1.0

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system global
  set hostname "${fwb_a_vm_name}"
  set dst enable
  set admintimeout 480
  set timezone 28
  set https-certificate defaultcert
end
config system interface
  edit "port1"
    set type physical
    set allowaccess https ping ssh snmp http FWB-manager 
    set mode dhcp
    config  secondaryip
    end
    config  classless_static_route
    end
  next
  edit "port2"
    set type physical
    set allowaccess ping 
    set mode dhcp
    config  secondaryip
    end
    config  classless_static_route
    end
  next
end
config system ha
  set mode active-active-standard
  set group-id 1
  set group-name demo-fwb
  set priority 3
  set override enable
  set tunnel-local "${fwb_a_internal_ipaddr}"
  set tunnel-peer "${fwb_a_ha_peerip}"
end
config system dns
  set primary 168.63.129.16
end
config router static
  edit 1
    set gateway "${fwb_a_external_gw}"
    set device port1
  next
  edit 2
    set dst "${vnet_network}"
    set gateway "${fwb_a_internal_gw}"
    set device port2
  next
end

%{ if fwb_a_license_file != "" }
--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="${fwb_a_license_file}"

${file(fwb_a_license_file)}

%{ endif }
--===============0086047718136476635==--