# Đọc các file LEF công nghệ và macro
read_lef /OpenRAM/thesis-sram/out/sram_1kb_32b.lef
read_lef /duong_dan_toi_thu_vien/NangateOpenCellLibrary.lef

# Đọc netlist Verilog (SRAM và controller)
read_verilog /OpenRAM/thesis-sram/out/sram_1kb_32b.v
read_verilog /duong_dan_toi_netlist/apb_mem_ctrl_netlist.v

# Khởi tạo floorplan (điều chỉnh kích thước cho phù hợp)
initialize_floorplan -die_area "0 0 500 500" -core_area "10 10 490 490"

# Đặt macro SRAM
place_cell -cell sram_1kb_32b -location "100 100" -fixed

# Đặt vị trí các pin (thí dụ)
place_pin -pin_name PCLK -layer metal3 -location "250 0"
place_pin -pin_name PRESETn -layer metal3 -location "260 0"
# ... thêm các pin khác tuỳ ý bạn

# Đặt standard cells
global_placement
detailed_placement

# Routing
global_route
detailed_route

# Xuất kết quả
write_def /OpenRAM/thesis-sram/out/final.def
write_gds /OpenRAM/thesis-sram/out/final.gds
