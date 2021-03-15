/*
 *  yosys -- Yosys Open SYnthesis Suite
 *
 *  Copyright (C) 2021  Lalit Sharma <lsharma@quicklogic.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

#include "kernel/yosys.h"
#include "kernel/sigtools.h"

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN

struct QL_inoutPass : public Pass {
	QL_inoutPass() : Pass("ql_inout", "replace inout ports with inout_$in, inout_$out and inout_$en") {}
	void help() override
	{
		log("\n");
		log("    ql_inout [options] [selection]\n");
		log("\n");
		log("\"Replace\" inout ports with input, output and enable ports, if possible.\n");
		log("\n");
	}
	SigMap assign_map;
	void execute(std::vector<std::string> args, RTLIL::Design *design) override
	{
		log_header(design, "Executing QL_INOUT pass (replace inout ports with input, output and enable ports).\n");

		extra_args(args, 1, design);

		bool keep_running = true;

		while (keep_running)
		{
			keep_running = false;

			for (auto module : design->selected_modules())
			{
				SigMap sigmap(module);
				std::set<Wire*> inoutWires;

				for (auto wire : module->wires())
				{
					if (wire->port_input && wire->port_output)
					{
						inoutWires.insert(wire);
					}
				}

				std::map<RTLIL::IdString, RTLIL::IdString > inoutConnMap;
				for (auto connection : module->connections()) 
				{
					if (inoutWires.find(connection.first.as_wire()) != inoutWires.end()) {
						/*printf("**** sig.first: %s, sig.second: %s\n", connection.first.as_wire()->name.c_str(),
						       log_signal(connection.second));*/
						inoutConnMap.emplace(connection.first.as_wire()->name, log_signal(connection.second));
					}
				}

				std::map<RTLIL::IdString, Wire*> inoutEnableMap; 
				std::map<RTLIL::IdString, Wire*> inoutOutputMap; 
				std::map<RTLIL::IdString, Wire*> inoutInputMap; 
				
				for (auto wire : inoutWires)
				{
					string currWireName(wire->name.c_str());
					string wireInName = currWireName + "_$in";
					string wireOutName = currWireName + "_$out";
					string wireEnName = currWireName + "_$en";

					Wire *outWire = module->addWire(wireOutName, wire);
					if (outWire) {
						outWire->port_output = true;
						outWire->port_input = false;
						inoutOutputMap.emplace(wire->name, outWire);
					}
					Wire *enWire = module->addWire(wireEnName, wire);
					if (enWire) {
						enWire->port_output = true;
						enWire->port_input = false;
						inoutEnableMap.emplace(wire->name, enWire);
					}
					Wire *inWire = module->addWire(wireInName, wire);
					if (enWire) {
						inWire->port_output = false;
						inWire->port_input = true;
						inoutInputMap.emplace(wire->name, inWire);
					}

					//module->rename(wire, wireInName);
					//wire->port_output = false;

					//printf("-------+++ wire name: %s\n", wire->name.c_str());
				}
				module->fixup_ports();

				std::map<RTLIL::IdString, RTLIL::SigSpec > enSigMap;

				for (auto cell : module->cells())
				{
					//printf("+++ cell_name: %s\n", cell->name.c_str());

					for (auto &conn : cell->connections()) {
						//printf("===== conn.first: %s, conn.second: %s\n", RTLIL::id2cstr(conn.first), log_signal(conn.second));
						
						if (conn.first == ID::Y && cell->type.in(ID($mux), ID($pmux), ID($_MUX_), ID($_TBUF_), ID($tribuf))) {
							bool tribuf = cell->type.in(ID($_TBUF_), ID($tribuf));

							if (!tribuf) {
								for (auto &c : cell->connections()) {
									if (!c.first.in(ID::A, ID::B))
										continue;
									for (auto b : sigmap(c.second))
										if (b == State::Sz)
											tribuf = true;
								}
							}

							if (tribuf) {
								//printf("==== there is a tribuf \n");
								//RTLIL::SigSpec sig_a = assign_map(cell->getPort(ID::A));
								//RTLIL::SigSpec sig_b = assign_map(cell->getPort(ID::B));
								RTLIL::SigSpec sig_s = assign_map(cell->getPort(ID::S));
								RTLIL::SigSpec sig_y = assign_map(cell->getPort(ID::Y));

								enSigMap.emplace(log_signal(sig_y), sig_s);
								//printf("--- sig_s: %s\n", log_signal(sig_s));
								
							}
						}
					}
				}

				for (auto wire : module->wires()) 
				{
					auto pos = inoutConnMap.find(wire->name);
					if (pos != inoutConnMap.end()) {

						//printf("=====wire_name: %s, width: %d, start: %d, id: %d\n", wire->name.c_str(), wire->width, 
						//wire->start_offset, wire->port_id);
						vector<SigSig> new_connections;

						auto &connectionVec = module->connections();
						//printf("1---- connection size: %lu ..\n", connectionVec.size());

						for (auto &currConn : connectionVec)
						{
							auto currPos = inoutOutputMap.find(currConn.first.as_wire()->name);
							if (currPos != inoutOutputMap.end())
							{
								SigSig new_conn;
								new_conn.first.append(currPos->second);
								new_conn.second.append(currConn.second);
								new_connections.push_back(new_conn);
							} else 
							{
								auto currInPos = inoutInputMap.find(currConn.first.as_wire()->name);
								if (currInPos != inoutInputMap.end()) 
								{
									SigSig new_conn;
									new_conn.first.append(currConn.second);
									new_conn.second.append(currInPos->second);
									new_connections.push_back(new_conn);
								} else {
									SigSig new_conn;
									new_conn.first.append(currConn.second);
									new_conn.second.append(currConn.second);
									new_connections.push_back(new_conn);
								}
							}
						}

						auto connPos = enSigMap.find(pos->second);
						if (connPos != enSigMap.end())
						{
							auto connSig = connPos->second;

							RTLIL::SigSpec sig_en = assign_map(connSig);
							for (int i = 0; i < abs(wire->width - wire->start_offset - 1); ++i) 
							{
								sig_en.append(assign_map(connSig));
							}

							auto enPos = inoutEnableMap.find(wire->name);
							if (enPos != inoutEnableMap.end()) 
							{
								SigSig new_conn;
								new_conn.first.append(enPos->second);
								new_conn.second.append(sig_en);
								new_connections.push_back(new_conn);
								module->new_connections(new_connections);
							}
						}
					}
				}

				/*for (auto &proc : module->processes) 
				{
					//printf("---- proc_name: %s\n", proc.second->name.c_str());
					for (auto sync : proc.second->syncs)
					{
						//printf("+++ sync: %s\n", log_signal(sync->signal));
						for (auto &action : sync->actions) 
						{
							printf("===== action.first: %s, action.second: %s\n", log_signal(action.first),
							       log_signal(action.second));
						}
					}
				}*/
			}
		}
	}
} DeminoutPass;

PRIVATE_NAMESPACE_END
