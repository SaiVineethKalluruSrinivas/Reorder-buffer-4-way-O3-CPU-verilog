# Begin_DVE_Session_Save_Info
# DVE view(Wave.1 ) session
# Saved on Thu Oct 10 03:10:28 2019
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Wave.1: 24 signals
# End_DVE_Session_Save_Info

# DVE version: K-2015.09_Full64
# DVE build date: Aug 25 2015 21:36:02


#<Session mode="View" path="/afs/ece.cmu.edu/usr/jzou2/Private/mca_lab2/synth/session.inter.vpd.tcl" type="Debug">

#<Database>

gui_set_time_units 1ps
#</Database>

# DVE View/pane content session: 

# Begin_DVE_Session_Save_Info (Wave.1)
# DVE wave signals session
# Saved on Thu Oct 10 03:10:28 2019
# 24 signals
# End_DVE_Session_Save_Info

# DVE version: K-2015.09_Full64
# DVE build date: Aug 25 2015 21:36:02


#Add ncecessay scopes

gui_set_time_units 1ps

set _wave_session_group_1 Group1
if {[gui_sg_is_group -name "$_wave_session_group_1"]} {
    set _wave_session_group_1 [gui_sg_generate_new_name]
}
set Group1 "$_wave_session_group_1"

gui_sg_addsignal -group "$_wave_session_group_1" { {Sim:rob_tb.DUT.clk} {Sim:rob_tb.DUT.reset} {Sim:rob_tb.DUT.inserted} {Sim:rob_tb.DUT.archReg0} {Sim:rob_tb.DUT.physReg0} {Sim:rob_tb.DUT.opcode0} {Sim:rob_tb.DUT.archReg1} {Sim:rob_tb.DUT.physReg1} {Sim:rob_tb.DUT.opcode1} {Sim:rob_tb.DUT.archReg2} {Sim:rob_tb.DUT.physReg2} {Sim:rob_tb.DUT.opcode2} {Sim:rob_tb.DUT.archReg3} {Sim:rob_tb.DUT.physReg3} {Sim:rob_tb.DUT.opcode3} {Sim:rob_tb.DUT.full} {Sim:rob_tb.DUT.head} {Sim:rob_tb.DUT.tail} {Sim:rob_tb.DUT.inserted_0_reg} {Sim:rob_tb.DUT.inserted_1_reg} {Sim:rob_tb.DUT.inserted_2_reg} {Sim:rob_tb.DUT.inserted_3_reg} {Sim:rob_tb.DUT.insert_amount} {Sim:rob_tb.DUT.Q} }
if {![info exists useOldWindow]} { 
	set useOldWindow true
}
if {$useOldWindow && [string first "Wave" [gui_get_current_window -view]]==0} { 
	set Wave.1 [gui_get_current_window -view] 
} else {
	set Wave.1 [lindex [gui_get_window_ids -type Wave] 0]
if {[string first "Wave" ${Wave.1}]!=0} {
gui_open_window Wave
set Wave.1 [ gui_get_current_window -view ]
}
}

set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 414785 415216
gui_list_add_group -id ${Wave.1} -after {New Group} [list ${Group1}]
gui_seek_criteria -id ${Wave.1} {Any Edge}


gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group ${Group1}  -position in

gui_marker_move -id ${Wave.1} {C1} 415000
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false
#</Session>

