INCLUDEDIR = rtl/include/

RVCORE_MODULES_DIR = rtl/rvcore/
RVCORE_TEST_TOP_MODULE = $(RVCORE_MODULES_DIR)top.v
RVCORE_TEST_MODULES = $(RVCORE_MODULES_DIR)imem.v $(RVCORE_MODULES_DIR)dmem.v
RVCORE_MODULES = $(RVCORE_MODULES_DIR)rvcore.v \
			  $(RVCORE_MODULES_DIR)fetch_unit.v $(RVCORE_MODULES_DIR)decode_unit.v $(RVCORE_MODULES_DIR)adder.v \
			  $(RVCORE_MODULES_DIR)integer_alu_unit.v $(RVCORE_MODULES_DIR)execute_unit.v \
			  $(RVCORE_MODULES_DIR)mem_access_unit.v $(RVCORE_MODULES_DIR)writeback_unit.v \
			  $(RVCORE_MODULES_DIR)regfile_unit.v $(RVCORE_MODULES_DIR)branch_alu.v

VCS = vcs
VCSFLAGS = -full64 +v2k -LDFLAGS -Wl,--no-as-needed -fsdb +incdir+$(INCLUDEDIR)
MACRO=+define+DEBUG_CPU_PIPELINE

rvcore_test:
	$(VCS) $(VCSFLAGS) $(MACRO) $(RVCORE_TEST_TOP_MODULE) $(RVCORE_TEST_MODULES) $(RVCORE_MODULES)
code:
	make -C data
code_clean:
	make -C data clean
clean:
	rm -rf csrc simv.daidir simv ucli.key
	rm -rf novas_dump.log *.fsdb
	rm -rf novas.conf novas.rc verdiLog
