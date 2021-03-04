
OBJS += techlibs/quicklogic/synth_quicklogic.o

$(eval $(call add_share_file,share/quicklogic,techlibs/quicklogic/cells_sim.v))
$(eval $(call add_share_file,share/quicklogic,techlibs/quicklogic/qlf_k4n8_cells_sim.v))
$(eval $(call add_share_file,share/quicklogic,techlibs/quicklogic/qlf_k4n8_cells_map.v))
$(eval $(call add_share_file,share/quicklogic,techlibs/quicklogic/qlf_k4n8_arith_map.v))

