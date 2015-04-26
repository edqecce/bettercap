=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
require_relative 'logger'
require 'colorize'
require 'packetfu'

class Sniffer
    include PacketFu

    @@parsers = nil

    def self.start( iface, my_addr, local )
        if @@parsers.nil?
            @@parsers = []

            path = File.dirname(__FILE__) + '/parsers/'

            Dir.foreach(path) do |file|
              if file =~ /.rb/
                  cname = file.gsub('.rb','').upcase

                  require_relative "#{path}#{file}"

                  @@parsers << Kernel.const_get("#{cname.capitalize}Parser").new
              end
            end
        end

        cap = Capture.new(:iface => iface, :start => true)
        cap.stream.each do |p|
            pkt = Packet.parse p
            if pkt.is_ip?
                next if ( pkt.ip_saddr == my_addr or pkt.ip_daddr == my_addr ) and local == false

                @@parsers.each do |parser|
                    parser.on_packet pkt
                end
            end
        end
    end
end
