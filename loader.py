# local imports
import argparse, getopt, io, sys
from time import sleep

# imports from the world
import serial

class Final31_Serial_Loader():
    BAUDRATE = 115200
    
    # Command list
    COMMAND_COST = 'COST'
    COMMAND_START_ADDRESS = 'START ADDRESS'
    COMMAND_END_ADDRESS = 'END ADDRESS'
    COMMAND_START = 'START'
    COMMAND_STOP = 'STOP'
    
    # Commands to issue to the serial port
    HEADER = '\x57'
    COMMAND_WORD_COST = '\x01'
    COMMAND_WORD_START_ADDRESS = '\x02'
    COMMAND_WORD_END_ADDRESS = '\x03'
    COMMAND_WORD_START = '\x04'
    COMMAND_WORD_STOP = '\x05'

    def __init__(self, port):
        self.device = serial.Serial(port=port,\
                                    baudrate=Final31_Serial_Loader.BAUDRATE,\
                                    bytesize=serial.EIGHTBITS,\
                                    parity=serial.PARITY_NONE,\
                                    stopbits=serial.STOPBITS_ONE)
                                    
    def send_command(self, command, address='\x00', cost='\x00'):
        if command == Final31_Serial_Loader.COMMAND_COST:
            #print("Sent command cost %s to cell %s" % (address, cost))
            data = Final31_Serial_Loader.HEADER + Final31_Serial_Loader.COMMAND_WORD_COST + address + cost
            #self.device.write(data)
            self.device.write(Final31_Serial_Loader.HEADER)
            sleep(0.001)
            self.device.write(Final31_Serial_Loader.COMMAND_WORD_COST)
            sleep(0.001)
            self.device.write(address)
            sleep(0.001)
            self.device.write(cost)
            sleep(0.001)
        elif command == Final31_Serial_Loader.COMMAND_START_ADDRESS:
            #print("Sent command cost start address at %s" % address)
            data = Final31_Serial_Loader.HEADER + Final31_Serial_Loader.COMMAND_WORD_START_ADDRESS + address + cost
            #self.device.write(data)
            self.device.write(Final31_Serial_Loader.HEADER)
            sleep(0.001)
            self.device.write(Final31_Serial_Loader.COMMAND_WORD_START_ADDRESS)
            sleep(0.001)
            self.device.write(address)
            sleep(0.001)
        elif command == Final31_Serial_Loader.COMMAND_END_ADDRESS:
            #print("Sent command cost end address at %s" % address)
            data = Final31_Serial_Loader.HEADER + Final31_Serial_Loader.COMMAND_WORD_END_ADDRESS + address + cost
            #self.device.write(data)
            self.device.write(Final31_Serial_Loader.HEADER)
            sleep(0.001)
            self.device.write(Final31_Serial_Loader.COMMAND_WORD_END_ADDRESS)
            sleep(0.001)
            self.device.write(address)
            sleep(0.001)
        elif command == Final31_Serial_Loader.COMMAND_START:
            #print("Sent command cost START")
            data = Final31_Serial_Loader.HEADER + Final31_Serial_Loader.COMMAND_WORD_START + address + cost
            #.device.write(data)
            self.device.write(Final31_Serial_Loader.HEADER)
            sleep(0.001)
            self.device.write(Final31_Serial_Loader.COMMAND_WORD_START)
            sleep(0.001)
        elif command == Final31_Serial_Loader.COMMAND_STOP:
            #print("Sent command cost STOP")
            data = Final31_Serial_Loader.HEADER + Final31_Serial_Loader.COMMAND_WORD_STOP + address + cost
            #self.device.write(data)
            self.device.write(Final31_Serial_Loader.HEADER)
            sleep(0.001)
            self.device.write(Final31_Serial_Loader.COMMAND_WORD_STOP)
            sleep(0.001)
        else:
            print('================================')
            print('UNSUPPORTED COMMAND: %s' % command)
            print('================================')

def read_costs(file):
    # param file path to the file containing 256 lines of integers in the range [0, 255]
    # return array of length 256 of bytes to send to the device
    f = open(file, 'r')
    data = f.read().split('\n')
    return [chr(int(d)) for d in data] 

def cli():
    parser = argparse.ArgumentParser()
    parser.add_argument('port', help='Name or path to the port that you want to use for output') # name or full path to the seria device
    parser.add_argument('file', help='Path(relative or absolute) to the costs file') # path(relative or absolute) to the file used for uploading to the serial 
    # optional parameter start address
    parser.add_argument('-s', '--start', dest='start_address', action='store', help='Integer value for the start cell. Defaults to 0.', type=int, default=0)
    # optional parameter end address
    parser.add_argument('-e', '--end', dest='end_address', action='store', help='Integer value for the end cell. Defaults to 255.', type=int, default=255)
    # optional parameter delay from start to stop
    parser.add_argument('-t', '--time', dest='run_time', action='store', help='Integer value for the time the program is allowed to run. Defaults to 5 seconds.', type=int, default=5)
    args = parser.parse_args()
    
    # DEBUGGING
    print('start_address : %s' % args.start_address)
    print('end_address : %s' % args.end_address)
    # print('run time : %s' % args.run_time)
    
    # construct the port and the integer list
    port = Final31_Serial_Loader(args.port)
    costs = read_costs(args.file)
    
    # send out the cost data
    print("Sending the playing field costs.")
    port.send_command(Final31_Serial_Loader.COMMAND_START_ADDRESS, address=chr(args.start_address))
    sleep(0.001)
    port.send_command(Final31_Serial_Loader.COMMAND_END_ADDRESS, address=chr(args.end_address))
    sleep(0.001)
    for i in xrange(len(costs)):
        port.send_command(Final31_Serial_Loader.COMMAND_COST, chr(i), costs[i])
    
    # send the start and stop address
    sleep(0.001)
    
    port.send_command(Final31_Serial_Loader.COMMAND_START) # issue start command
    sleep(args.run_time) # let the program run for some amount of time
    port.send_command(Final31_Serial_Loader.COMMAND_STOP) # issue stop command
    
    
if __name__ == '__main__':
    cli()