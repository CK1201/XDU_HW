#!/usr/bin/env python
import rospy
from geometry_msgs.msg import Twist
import sys, select, termios, tty
import rospy
from mavros_msgs.msg import PositionTarget, State,HomePosition
from mavros_msgs.srv import CommandBool, CommandTOL, SetMode
from geometry_msgs.msg import PoseStamped, Twist
from sensor_msgs.msg import Imu, NavSatFix
from std_msgs.msg import Float32, String
import time
import math


msg = """
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
If you use this script, please read readme.md first.
dir:some/src/simulation/scripts/README.md
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%%%%%%%%%%%%%%%%%%%%%%%
command_cotrol
%%%%%%%%%%%%%%%%%%%%%%%
0 : ARM
1 : TAKEOFF
2 : OFFBOARDS
3 : LAND
4 : POSCTL
5 : ATTITCTL
---------------------------

CTRL-C to quit

"""
cur_Position_Target = PositionTarget()
mavros_state = State()
armServer = rospy.ServiceProxy('/mavros/cmd/arming', CommandBool)
setModeServer = rospy.ServiceProxy('/mavros/set_mode', SetMode)
local_target_pub = rospy.Publisher('/mavros/setpoint_raw/local', PositionTarget, queue_size=10)
def __init__():
	rospy.init_node('PX4_AuotFLy' ,anonymous=True)
	rospy.Subscriber("/mavros/state", State, mavros_state_callback)
        #rospy.Subscriber("/mavros/local_position/pose",HomePosition, mavros_pos_callback)
	print("Initialized")

def mavros_state_callback(msg):
	global mavros_state
	mavros_state = msg
#	if mavros_state.armed == 0 :
#		print("disarm")

def mavros_pos_callback(msg):
        global mavros_pos
        mavros_pos = msg

def Intarget_local():
	set_target_local = PositionTarget()
	set_target_local.type_mask = 0b100111111000  
        set_target_local.coordinate_frame = 1
        set_target_local.position.x = 20
        set_target_local.position.y = -30
        set_target_local.position.z = 10
        set_target_local.yaw = 0
	return set_target_local

def getKey():
    tty.setraw(sys.stdin.fileno())
    rlist, _, _ = select.select([sys.stdin], [], [], 0.1)
    if rlist:
        key = sys.stdin.read(1)
    else:
        key = ''

    termios.tcsetattr(sys.stdin, termios.TCSADRAIN, settings)
    return key

def command_control():
	if key == '0':
		if armServer(True) :
			print("Vehicle arming succeed!")
		else:
			print("Vehicle arming failed!")
	elif key == '1':
		if setModeServer(custom_mode='AUTO.TAKEOFF'):
			print("Vehicle takeoff succeed!")
		else:
			print("Vehicle takeoff failed!")
	elif key == '2':
		if setModeServer(custom_mode='OFFBOARD'):
			print("Vehicle offboard succeed!")
		else:
			print("Vehicle offboard failed!")
	elif key == '3':
		if setModeServer(custom_mode='AUTO.LAND'):
			print("Vehicle land succeed!")
		else:
			print("Vehicle land failed!")
	elif key == '4':
		if setModeServer(custom_mode='POSCTL'):
			print("Vehicle posControl succeed!")
		else:
			print("Vehicle posControl failed!")
	elif key == '5':
		if setModeServer(custom_mode='STABILIZED'):
			print("Vehicle stabilized succeed!")
		else:
			print("Vehicle stabilized failed!")

def run_state_update():
	if mavros_state.mode != 'OFFBOARD':
                setModeServer(custom_mode='OFFBOARD')
                local_target_pub.publish(cur_Position_Target)
        	print("wait offboard")
        else: 
        	local_target_pub.publish(cur_Position_Target)
		print("local_target_pub.publish")

global cur_Position_Target
cur_Position_Target = Intarget_local()

if __name__=="__main__":
	settings = termios.tcgetattr(sys.stdin)
	print (msg)
	__init__()
	if armServer(True) :
			print("Vehicle arming succeed!")
        if setModeServer(custom_mode='OFFBOARD'):
			print("Vehicle offboard succeed!")
	else:
			print("Vehicle offboard failed!")
	while(1):
                key= getKey()
                run_state_update()
                time.sleep(0.2)
                if (key == '\x03'):
	                break
	termios.tcsetattr(sys.stdin, termios.TCSADRAIN, settings)
