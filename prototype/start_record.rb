DB_USER = ""
DB_PASS = ""
DB_NAME = ""

require 'rubygems'
require 'mysql' # MySQL のライブラリを読み込み

system("sudo ruby gpio18.rb")

key=0
audio_key=0
time_save=""

if audio_key.to_i == 0 then
system("pulseaudio -D")
system("pacmd set-default-source 1")
audio_key=1
end

loop do

if key.to_i == 0.to_i then

val3 = open("/sys/class/gpio/gpio18/value","r")
flag3 = val3.read()

if flag3.to_i != 0.to_i then
key=1
sw_time=""
db = Mysql::new('revino.net',"#{DB_USER}","#{DB_PASS}","#{DB_NAME}")

#if audio_key.to_i == 0 then
#system("pulseaudio -D")
#system("pacmd set-default-source 1")
#audio_key=1
#end

time = Time.now.to_i

arecord = "arecord -f S16_LE -r 16000 a" + time.to_s + ".wav &"
system(arecord)

start_time = Time.at(time).strftime "%Y-%m-%d %H:%M:%S"
print start_time
system("sudo ruby gpio9.rb")
system("sudo ruby gpio23.rb")

loop do
val = open("/sys/class/gpio/gpio9/value","r")
flag = val.read()
val2 = open("/sys/class/gpio/gpio23/value","r")
flag2 = val2.read()

if flag2.to_i != 0.to_i then
system("kill -TERM `ps auxw | grep arecord | egrep -v grep | awk '{print $2}'`")
stop_time = Time.at(Time.now.to_i).strftime "%Y-%m-%d %H:%M:%S"

system("sudo ruby ugpio9.rb")
system("sudo ruby ugpio23.rb")

audio = "scp -P 50022 a" + time.to_s + ".wav kumagai@revino.net:/var/www/html/public/assets/wav/"
system(audio)

sql = <<EOF
INSERT INTO record_time(start_time,stop_time,sw_time,voice)
VALUE("#{start_time}","#{stop_time}","#{time_save}","a#{time.to_s}.wav")
EOF

db.query(sql)
db.close

key=0
#system("kill -TERM `ps auxw | grep arecord | egrep -v grep | awk '{print $2}'`")
break
end

if flag.to_i != 0.to_i then
time2 = Time.now.to_i - time
print time2

time_save = time_save.to_s + time2.to_s + "-"

sleep(0.5)
end
val.close
val2.close
end

end
end

end
val3.close