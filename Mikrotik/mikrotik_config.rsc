# 2026-04-23 15:26:30 by RouterOS 7.22.1
# system id = 2Ssdjpteb5M
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no name=ether0
set [ find default-name=ether2 ] disable-running-check=no name=ether1
set [ find default-name=ether3 ] disable-running-check=no name=ether2
set [ find default-name=ether4 ] disable-running-check=no name=ether3
/ip dhcp-server option
add code=66 name=fog-server value="s'10.2.7.5'"
add code=67 name=boot-legacy value="s'undionly.kkpxe'"
add code=67 name=boot-uefi64 value="s'snponly.efi'"
add code=67 name=boot-uefi32 value="s'i386-efi/snponly.efi'"
add code=67 name=boot-arm64 value="s'arm64-efi/snponly.efi'"
add code=67 name=boot-apple value="s'snponly.efi'"
add code=43 name=apple-bsdp value=\
    0x0101010402800007048100052a090d8100052a08695058452d464f47
/ip dhcp-server option sets
add name=set-legacy options=fog-server,boot-legacy
add name=set-uefi64 options=fog-server,boot-uefi64
add name=set-uefi32 options=fog-server,boot-uefi32
add name=set-arm64 options=fog-server,boot-arm64
add name=set-surface options=fog-server,boot-uefi64
add name=set-apple options=fog-server,boot-apple,apple-bsdp
/ip pool
add name=dhcp_pool217 ranges=172.18.10.100-172.18.10.250
add name=dhcp_pool227 ranges=172.18.20.100-172.18.20.250
add name=dhcp_pool237 ranges=172.18.30.100-172.18.30.250
/ip dhcp-server
add address-pool=dhcp_pool217 disabled=yes interface=ether1 lease-time=10h \
    name=vmbr217
add address-pool=dhcp_pool227 disabled=yes interface=ether2 lease-time=10h \
    name=vmbr227
add address-pool=dhcp_pool237 disabled=yes interface=ether3 lease-time=10h \
    name=vmbr237
/user group
add name=wol-only policy="ssh,read,test,!local,!telnet,!ftp,!reboot,!write,!po\
    licy,!winbox,!password,!web,!sniff,!sensitive,!api,!romon,!rest-api"
/ip settings
set allow-fast-path=no
/ip address
add address=10.2.7.3/24 interface=ether0 network=10.2.7.0
add address=172.18.10.1/24 interface=ether1 network=172.18.10.0
add address=172.18.20.1/24 interface=ether2 network=172.18.20.0
add address=172.18.30.1/24 interface=ether3 network=172.18.30.0
/ip dhcp-client
# Interface not active
add interface=*2 name=client1
/ip dhcp-relay
add dhcp-server=10.2.7.5 disabled=no interface=ether1 name=vmbr017
add dhcp-server=10.2.7.5 disabled=no interface=ether3 name=vmbr037
add dhcp-server=10.2.7.5 disabled=no interface=ether2 name=vmbr027
/ip dhcp-server matcher
add address-pool=dhcp_pool217 code=93 matching-type=exact name=\
    match-legacy-217 option-set=set-legacy server=vmbr217 value=0x0000
add address-pool=dhcp_pool217 code=93 matching-type=exact name=\
    match-uefi32-217 option-set=set-uefi32 server=vmbr217 value=0x0006
add address-pool=dhcp_pool217 code=93 matching-type=exact name=\
    match-uefi64-217 option-set=set-uefi64 server=vmbr217 value=0x0007
add address-pool=dhcp_pool217 code=93 matching-type=exact name=\
    match-uefi64-8-217 option-set=set-uefi64 server=vmbr217 value=0x0008
add address-pool=dhcp_pool217 code=93 matching-type=exact name=\
    match-uefi64-9-217 option-set=set-uefi64 server=vmbr217 value=0x0009
add address-pool=dhcp_pool217 code=93 matching-type=exact name=\
    match-arm64-217 option-set=set-arm64 server=vmbr217 value=0x000b
add address-pool=dhcp_pool227 code=93 matching-type=exact name=\
    match-legacy-227 option-set=set-legacy server=vmbr227 value=0x0000
add address-pool=dhcp_pool227 code=93 matching-type=exact name=\
    match-uefi32-227 option-set=set-uefi32 server=vmbr227 value=0x0006
add address-pool=dhcp_pool227 code=93 matching-type=exact name=\
    match-uefi64-227 option-set=set-uefi64 server=vmbr227 value=0x0007
add address-pool=dhcp_pool227 code=93 matching-type=exact name=\
    match-uefi64-8-227 option-set=set-uefi64 server=vmbr227 value=0x0008
add address-pool=dhcp_pool227 code=93 matching-type=exact name=\
    match-uefi64-9-227 option-set=set-uefi64 server=vmbr227 value=0x0009
add address-pool=dhcp_pool227 code=93 matching-type=exact name=\
    match-arm64-227 option-set=set-arm64 server=vmbr227 value=0x000b
add address-pool=dhcp_pool237 code=93 matching-type=exact name=\
    match-legacy-237 option-set=set-legacy server=vmbr237 value=0x0000
add address-pool=dhcp_pool237 code=93 matching-type=exact name=\
    match-uefi32-237 option-set=set-uefi32 server=vmbr237 value=0x0006
add address-pool=dhcp_pool237 code=93 matching-type=exact name=\
    match-uefi64-237 option-set=set-uefi64 server=vmbr237 value=0x0007
add address-pool=dhcp_pool237 code=93 matching-type=exact name=\
    match-uefi64-8-237 option-set=set-uefi64 server=vmbr237 value=0x0008
add address-pool=dhcp_pool237 code=93 matching-type=exact name=\
    match-uefi64-9-237 option-set=set-uefi64 server=vmbr237 value=0x0009
add address-pool=dhcp_pool237 code=93 matching-type=exact name=\
    match-arm64-237 option-set=set-arm64 server=vmbr237 value=0x000b
add address-pool=dhcp_pool217 code=60 matching-type=substring name=\
    match-surface option-set=set-surface server=vmbr217 value=\
    PXEClient:Arch:00007:UNDI:003016
add address-pool=dhcp_pool217 code=60 matching-type=substring name=\
    match-apple option-set=set-apple server=vmbr217 value=AAPLBSDPC/i386
add address-pool=dhcp_pool217 code=93 matching-type=exact name=\
    match-uefi32-alt-217 option-set=set-uefi32 server=vmbr217 value=0x0002
/ip dhcp-server network
add address=172.18.10.0/24 boot-file-name=undionly.kkpxe dns-server=\
    172.16.200.1,8.8.8.8 gateway=172.18.10.1 next-server=10.2.7.5
add address=172.18.20.0/24 dns-server=172.16.200.1,8.8.8.8 gateway=\
    172.18.20.1 next-server=10.2.7.5
add address=172.18.30.0/24 dns-server=172.16.200.1,8.8.8.8 gateway=\
    172.18.30.1 next-server=10.2.7.5
/ip firewall filter
add action=accept chain=forward protocol=igmp
add action=accept chain=forward dst-address=224.0.0.0/4
add action=accept chain=input protocol=igmp
/ip firewall mangle
add action=log chain=prerouting dst-port=9 log-prefix=WOL-DETECT protocol=udp
add action=mark-packet chain=prerouting dst-port=9 new-packet-mark=wol_pkt \
    protocol=udp
add action=change-mss chain=postrouting new-mss=clamp-to-pmtu protocol=tcp \
    tcp-flags=syn
add action=clear-df chain=postrouting dst-port=9 protocol=udp
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether0
/ip route
add dst-address=0.0.0.0/0 gateway=10.2.7.1
/routing igmp-proxy
set quick-leave=yes
/routing igmp-proxy interface
add
add alternative-subnets=10.2.7.0/24 interface=ether0 upstream=yes
add interface=ether1
add interface=ether2
add interface=ether3
/system scheduler
add interval=2s name=wol-check on-event="\
    \n:if ([/ip firewall connection print count-only where dst-port=9 protocol\
    =udp] > 0) do={\
    \n    /system script run wol-forward\
    \n}\
    \n" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2026-04-10 start-time=16:58:20
