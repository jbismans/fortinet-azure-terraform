Content-Type: multipart/mixed; boundary="===============0086047718136476635=="
MIME-Version: 1.0

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config sys global
    set admintimeout 120
    set hostname "${fgt_vm_name}"
    set timezone 26
    set admin-sport 8443
    set admin-ssh-port 8442
    set gui-theme mariner
end
config router static
    edit 1
        set gateway ${fgt_port1_gw}
        set device port1
    next
    edit 2
        set dst ${subnet_mgmt}
        set gateway ${fgt_port2_gw}
        set device "port2"
    next
end
config system interface
    edit port1
        set mode static
        set ip ${fgt_port1_ipaddr}/${fgt_port1_mask}
        set description port1
        set allowaccess ping https ssh
    next
    edit port2
        set mode static
        set ip ${fgt_port2_ipaddr}/${fgt_port2_mask}
        set description port2
        set allowaccess ping
    next
end
config system snmp sysinfo
    set status enable
end
config system snmp community
    edit 1
        set name "fts"
        config hosts
            edit 1
                set ip ${fts_mgmt_ipaddr} 255.255.255.255
                set host-type query
            next
        end
        set trap-v1-status disable
        set trap-v2c-status disable
        unset events
    next
end
config system snmp user
    edit "fts"
        set trap-status disable
        set notify-hosts ${fts_mgmt_ipaddr}
        unset events
    next
end
config system settings
    set gui-dos-policy disable
    set gui-dynamic-routing disable
    set gui-threat-weight disable
    set gui-endpoint-control disable
    set gui-wireless-controller disable
    set gui-traffic-shaping disable
    set gui-wan-load-balancing disable
    set gui-dnsfilter disable
    set gui-allow-unnamed-policy enable
    set gui-multiple-interface-policy enable
end
config firewall policy
    edit 1
        set srcintf "any"
        set dstintf "any"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set ssl-ssh-profile "certificate-inspection"
        set logtraffic all
        set fsso disable
    next
end
config log memory setting
    set status enable
end
config log disk setting
    set status enable
end
config log setting
    set fwpolicy-implicit-log enable
    set local-in-allow enable
    set local-in-deny-unicast enable
    set local-in-deny-broadcast enable
    set local-out enable
end

%{ if fgt_license_file != "" }
--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="${fgt_license_file}"

${file(fgt_license_file)}

%{ endif }
--===============0086047718136476635==--