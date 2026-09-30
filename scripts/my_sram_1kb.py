from openram import OPTS

# Giảm tải: tắt DRC/LVS inline, tắt route nguồn
OPTS.check_lvsdrc = False
OPTS.inline_lvsdrc = False
OPTS.route_supplies = False

word_size = 32
num_words = 256
num_banks = 1
words_per_row = 1
local_array_size = 16
tech_name = "freepdk45"
process_corners = ["TT"]
output_path = "thesis-sram/out"
output_name = "sram_1kb_32b"
write_lef = False      # tắt LEF
write_gds = False      # tắt GDS
write_spice = True
write_verilog = True
write_lib = True
nominal_corner_only = True
