#####cov相关makefile代码（jesd204b中）
CMDIR =$(SIM_DIR)/COV
CM = -cm line+branch+cond+tgl+fsm #打开对应的覆盖率
#line 行覆盖率  tgl翻转覆盖率（每个结点的跳变）cond 条件覆盖率 fsm 状态机覆盖率 branch 分支覆盖率   还有个path路径覆盖率
CM_NAME = -cm_name $(VAR)#
CM_DIR = -cm_dir $(CMDIR)/simv.vdb#指定生成文件的目录
CM += -cm_hier $(SIM_DIR)/vcs_cov.cfg#通过.cfg的文件选择要查看覆盖率的模块/文件

VCS = ...........$(CM)$(CM_NAME)$(CM_DIR) -cm_fsmopt sequence -cm_line contassign -cm_tgl portsonly -cm_tgl mda  ........
# -cm_line contassign：收集行覆盖率，并且忽略连续赋值语句
# -cm_tgl mda：为Verilog 2001和SystemVerilog未打包的多维数组启用翻转覆盖
urg:
	@urg -dir cov/simv.vdb -elfile $(sim_dir)/delete_cov.el
#这里-elfile是包含一些排除对象
	@google -chrome urgReport
dev:
	@cd $(addsuffix /$C(COMPILE_RUN_WORKDIR)/,$(ABSPATH .)) && dve -covdir *.vdb






#############网上的示例
.PHONY:com sim debug cov clean

OUTPUT = cov_test
ALL_DEFINE = +define+DUMP_VPD

#code coverage command
CM = -cm line+cond+fsm+branch+tgl
CM_NAME = -cm_name ${OUTPUT}
CM_DIR = -cm_dir ./${OUTPUT}.vdb
# //-cm ：打开对应类型的覆盖率，例如 -cm cond+tgl+lin+fsm+path为统计上述所有覆盖率。可根据需要增减。
# //-cm_name：设置记录有覆盖率信息文件的名字。
# //-cm_dir：指定生成文件的目录。实际上 -cm_name 是为了给 .vdb 文件命名，
# //-cm_dir ./ ${OUTPUT}.vdb 是指定 .vdb 文件生成路径为 ./ 。   ./ 代表在当前目录下生成.因为OUTPUT = cov_test，所以最后在当前目录生成了 cov_test.vdb文件。
VPD_NAME = +vpdfile+${OUTPUT}.vpd

VCS = vcs -sverilog         //-sverilog 打开对Systemverilog的支持，编译Systemverilog文件时使用。
     +v2k                   //+v2k是使VCS兼容verilog 2001以前的标准。
     -timescale=1ns/1ns     //-timescale=1ns/1ns 设置仿真精度
	  -o ${OUTPUT}		 // -o simv_file 编译默认产生的可执行文件为simv，可以使用 -o 更改可执行文件名。		
	  -l compile.log	 //使用-l run.log 记录终端上产生的信息。
	  ${VPD_NAME}				\
	  ${ALL_DEFINE}				\
	  ${CM}					\
	  ${CM_NAME}				\
	  ${CM_DIR}				\
	  -debug_pp 		//-debug_all用于产生debug所需的文件。将 -debug_all 选项 更改为 -debug_pp。打开生成 VPD 文件的功能，关掉UCLI的功能，节约编译时间。		\
	  -Mupdate              // -Mupdate 源文件有修改时，只重新编译有改动的.v文件，节约编译时间。
# // -R 编译后立即运行，即编译完成后立即执行 ./simv
# //-l readme.log 用于将编译产生的信息放在log文件内。
SIM = ./${OUTPUT} ${VPD_NAME} 			\
	  ${CM}					\
	  ${CM_NAME}				\
	  ${CM_DIR}				\
      -l ${OUTPUT}.log  
# //-cm_log + filename.log： .log文件记录仿真过程中统计覆盖率的信息。用的比较少。
# //-cm_nocasedef:           在统计case语句的条件覆盖率时，不考虑default条件未达到的情况。
# //-cm_hier vcs_cov.cfg：   通过.cfg文件（名字随便取）选择要查看覆盖率的模块/文件。
com:#编译
	${VCS} -f filelist.f  //使用-f verilog_file.f 选项，即可将.f文件里的源码全部编译。

sim:#仿真
	${SIM}

#show the coverage
cov:
	dve -covdir *.vdb &

debug:
	dve -vpd ${OUTPUT}.vpd &
	
clean:
	rm -rf ./csrc *.daidir *.log simv* *.key *.vpd ./DVEfiles ${OUTPUT} *.vdb	