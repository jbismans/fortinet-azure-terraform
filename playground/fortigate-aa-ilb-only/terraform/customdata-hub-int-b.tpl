Content-Type: multipart/mixed; boundary="===============0086047718136476635=="
MIME-Version: 1.0

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config sys global
    set admintimeout 120
    set hostname "${fgt_hub_b_vm_name}"
    set timezone 26
    set admin-sport 8443
    set admin-ssh-port 8442
    set gui-theme mariner
end
config system auto-scale
    set status enable
    set sync-interface "port1"
    set master-ip ${fgt_hub_a_ipaddr}
    set psksecret fortinet
end
config router static
    edit 1
        set gateway ${fgt_hub_gw}
        set device port1
    next
end
config system probe-response
    set http-probe-value OK
    set mode http-probe
end
config system interface
    edit port1
        set mode static
        set ip ${fgt_hub_b_ipaddr}/${fgt_hub_mask}
        set allowaccess ping fgfm https probe-response ssh
    next
end

%{ if fgt_hub_b_license_file != "" }
--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="${fgt_hub_b_license_file}"

${file(fgt_hub_b_license_file)}

%{ endif }
--===============0086047718136476635==--