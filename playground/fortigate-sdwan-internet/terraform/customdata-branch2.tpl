Content-Type: multipart/mixed; boundary="===============0086047718136476635=="
MIME-Version: 1.0

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config sys global
    set admintimeout 120
    set hostname "${fgt_branch2_vm_name}"
    set timezone 26
    set admin-sport 8443
    set admin-ssh-port 8442
    set gui-theme mariner
end
config system central-management
    set type fortimanager
    set fmg ${fmg_pip}
end
config vpn ssl settings
    set port 7443
end
config router static
    edit 1
        set gateway ${fgt_branch2_external1_gw}
        set device port1
    next
    edit 2
        set dst ${fgt_branch2_vnet_network}
        set gateway ${fgt_branch2_internal_gw}
        set device port3
    next
end
config system interface
    edit port1
        set mode static
        set ip ${fgt_branch2_external1_ipaddr}/${fgt_branch2_external1_mask}
        set description external1
        set allowaccess ping https ssh
    next
    edit port2
        set mode static
        set ip ${fgt_branch2_external2_ipaddr}/${fgt_branch2_external2_mask}
        set description external2
        set allowaccess ping https ssh
    next
    edit port3
        set mode static
        set ip ${fgt_branch2_internal_ipaddr}/${fgt_branch2_internal_mask}
        set description internal
        set allowaccess ping
    next
end

%{ if fgt_branch2_license_file != "" }
--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="${fgt_branch2_license_file}"

${file(fgt_branch2_license_file)}

%{ endif }
--===============0086047718136476635==--