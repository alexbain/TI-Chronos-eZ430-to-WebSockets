require 'rubygems'
require 'serialport'
require 'pusher'

Pusher.app_id = ''
Pusher.key = ''
Pusher.secret = ''

@serial = SerialPort.new "/dev/tty.usbmodem001", 115200
@serial.read_timeout = 1000

def write_to_serial(serial, data)
  data.each do |c| 
    serial.putc(c) 
    serial.flush 
  end
end

def debounce(serial, n = 50)
  while n != 0
    write_to_serial(serial, [0xFF, 0x08, 0x07, 0x00, 0x00, 0x00, 0x00])
    serial.read(7)
    n -= 1
  end
end

# Start access point
write_to_serial(@serial, [0xFF, 0x07, 0x03])


while(1)

  write_to_serial(@serial, [0xFF, 0x08, 0x07, 0x00, 0x00, 0x00, 0x00])
  reading = @serial.read(7)[6].ord

  if reading == 18
    puts "Left button pressed"
    Pusher['eZ430'].trigger('button_press', { :button => "left" })
    debounce(@serial)
  elsif reading == 50
    puts "Right button pressed"
    Pusher['eZ430'].trigger('button_press', { :button => "right" })
    debounce(@serial)
  elsif reading == 34
    puts "Bottom left button pressed"
    Pusher['eZ430'].trigger('button_press', { :button => "bottom_left" })
    debounce(@serial)
  end

end
