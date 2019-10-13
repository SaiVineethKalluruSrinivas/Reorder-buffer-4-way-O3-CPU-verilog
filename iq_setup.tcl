# 45nm GPDK GENUS SYNTHESIS FLOW - CONFIGURATION FILE
#----------------------------------------------------

# Top module name - must match the top-level in you SV exactly
set TOP iq
# Directory where HDL source is found
set SOURCE_PATH "./src"
# List of HDL source files to include in synthesis
set SOURCES {iq.sv}
