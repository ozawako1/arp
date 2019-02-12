#!/usr/bin/env ruby

require "packetfu"
include PacketFu

FILTER="arp and arp[7]==1"

dev = ARGV[0]

cap = Capture.new(:iface=>dev, :start=>true,
                  :filter=>FILTER)

cap.stream.each do |pkt|
  next unless ARPPacket.can_parse?(pkt)
  tstamp  = Time.new.strftime("%T") # sprintf("%.6f",Time.new.to_f)
  arpreq  = ARPPacket.parse(pkt)
  src_mac = EthHeader.str2mac(arpreq.eth_src)
  dst_mac = EthHeader.str2mac(arpreq.eth_dst)
  src_ip  = arpreq.arp_src_ip_readable
  dst_ip  = arpreq.arp_dst_ip_readable
  puts "#{tstamp},#{src_mac},#{src_ip},#{dst_mac},#{dst_ip}"
end