##################################################################################
## Company: 
## Engineer: 
## 
## Create Date: 10/06/2021 07:21:40 AM
## Design Name: 
## Module Name: Make file
## Project Name: 
## Target Devices: 
## Tool Versions: 
## Description:
## 
## Dependencies: 
## 
## Revision:
## Revision 0.01 - File Created
## Additional Comments:
## 
##################################################################################

TESTNAME ?= 
SEED ?= random
COMPARG ?= 
#===========================================================
#===========================================================
all:	clean build run

build:
		mkdir -p log
		vlib.exe work
		vlog.exe -f compile.f ${COMPARG}
		
run:
		vsim.exe -c -debugdb -l ${TESTNAME}.log work.${TESTNAME} -do "run -all;exit" -sv_seed ${SEED}
		mv ${TESTNAME}.log ./log
		ln -sf ./log/${TESTNAME}.log sim.log

clean:
		rm -rf *.log
		rm -rf log
		rm -rf work
		rm -rf *.wlf
		rm -rf *.transcript
		rm -rf coverage
		rm -rf *.ucdb

run_gov:
		vsim.exe -c -coverage -l  ${TESTNAME}.log work.${TESTNAME} -voptargs="+cover=bcefsx" -do "coverage save -onexit ${TESTNAME}.ucdb; run -all; exit" -sv_seed ${SEED}
		mv ${TESTNAME}.log ./log
		ln -sf ./log/${TESTNAME}.log sim.log

gen_cov:
		mkdir -p coverage
		vcover.exe merge IP.ucdb *.ucdb
		vcover.exe report IP.ucdb -file coverage/summary_report.txt
		vcover.exe report -zeros -detail -code bcefsx -All -codeAll IP.ucdb -file coverage/detail_report.txt

run_all: clean build
		make run_gov TESTNAME=timer_TC_01
		make run_gov TESTNAME=timer_TC_02
		make run_gov TESTNAME=timer_TC_03
		make run_gov TESTNAME=timer_TC_04
		make run_gov TESTNAME=timer_TC_05
		make run_gov TESTNAME=timer_TC_06
		make run_gov TESTNAME=timer_TC_07
		make run_gov TESTNAME=timer_TC_08
		make run_gov TESTNAME=timer_TC_09
		make run_gov TESTNAME=timer_TC_10
		make run_gov TESTNAME=timer_TC_11
		make run_gov TESTNAME=timer_TC_12
		make run_gov TESTNAME=timer_TC_13
		make gen_cov
#===========================================================
#===========================================================
