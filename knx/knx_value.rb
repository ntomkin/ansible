=begin
Project Ansible  - An extensible home automation scripting framework
----------------------------------------------------
Copyright (c) 2011 Elias Karakoulakis <elias.karakoulakis@gmail.com>

SOFTWARE NOTICE AND LICENSE

Project Ansible is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.

Project Ansible is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Project Ansible.  If not, see <http://www.gnu.org/licenses/>.

for more information on the LGPL, see:
http://en.wikipedia.org/wiki/GNU_Lesser_General_Public_License
=end

require 'ansible_value'

require 'knx_transceiver'
require 'knx_protocol'
require 'knx_tools'

module Ansible
    
    # definition: a KNXValue is the device-dependant datapoint, having a
    # well defined data type (EIS type): EIS1 (boolean), EIS5 (float) 
    # linked to zero or more group addresses,
    
    class KNXValue
        include AnsibleValue
        
        #
        # ------ CLASS VARIABLES & METHODS
        #
        @@ids = 0
        def KNXValue.id_generator
            @@ids = @@ids + 1
            return @@ids
        end
        
        #
        # ----- INSTANCE VARIABLES & METHODS
        #
                
        # equality checking
        def == (other)
            return (@id == other.id)
        end
        
        attr_reader :groups, :eistype
        attr_accessor :description

        # initialize KNXValue by its EIS type
        def initialize(transceiver, eistype, groups)
            @transceiver = transceiver
            
            # array of group addresses associated with this datapoint
            # only the first address is used in a  write operation (TODO: CHECKME)
            @groups = []
            @groups.replace(groups) if groups.is_a? Array
            
            # set flag: knxvalue.flags[:r] = true
            # test flag: knxvalue.flags[:r]  (evaluates to true, meaning the read flag is set)
            @flags = {}
            # c => Communication
            # r => Read
            # w => Write
            # t => Transmit
            # u => Update
            # i => read on Init
            
            # physical address: set only for remote nodes we are monitoring
            # when left to nil, it/ means a datapoint on this KNXTransceiver 
            @physaddr = nil
            
            # time of last update
            @last_update = nil
            
            # id of datapoint
            # initialized by class method KNXValue.id_generator
            @id = nil
        end
        
        # get a value from eibd
        def get()
            
        end
        
        # set (write) a value to eibd
        def set(new_val)
            #write value to 1/2/0
            dest= str2addr("1/2/0")
            puts "Writing (dest)"
            if (conn.EIBOpenT_Group(dest, 1) == -1)
                puts("KNX client: error setting socket mode")
                puts(conn.inspect)
                exit(1)
            end
            data = create_apdu
            puts ("data length=#{data.length}")
            conn.EIBSendAPDU(data)
            conn.EIBReset()

        end
        
        
        def groups=(other)
            raise "KNXValue.groups= requires an array of group addresses" unless other.is_a?Array
            @groups.replace(other)
        end
        
        def create_apdu
            
            val = 0 # 0=Off, 1=On
            data = [0, 0x80| val]    
        end
        
    end # class
    
end #module