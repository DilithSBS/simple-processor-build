# This script takes in an assembly file and generates a file (named "instr_mem.mem") that contains 
# machine code which can be loaded into instr_mem array in Verilog (inside cpu.v)
# Author: Kisaru Liyanage

if [ $# -ne 1 ]; then
    echo "Usage: $0 <assembly_file>"
    exit 1
fi

assembly_file=$1
filename=$(basename "$assembly_file")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MACHINE_DIR="$SCRIPT_DIR/../../tests/machine"
mkdir -p "$MACHINE_DIR"
machine_file="$MACHINE_DIR/$filename.machine"

OUTPUT_DIR="$SCRIPT_DIR/../../tests/mem"
mkdir -p "$OUTPUT_DIR"
output_file="${2:-$OUTPUT_DIR/instr_mem.mem}"

# assemble the assembly program into machine code
"$SCRIPT_DIR/../assembler/CO2070Assembler.exe" "$assembly_file" || exit 1

# move generated .machine file to tests/machine
mv -f "$assembly_file.machine" "$machine_file" || exit 1

# remove old output file and create new one to store instruction memory content
rm -f "$output_file"
touch "$output_file"

# generate instruction memory content to be loaded into instr_mem array in Verilog (inside cpu.v)
while read -r line || [ -n "$line" ]
do

    #echo $line
    byte3=$(echo $line | cut -c1-8)
    byte2=$(echo $line | cut -c9-16)
    byte1=$(echo $line | cut -c17-24)
    byte0=$(echo $line | cut -c25-32)
    echo $byte0" "$byte1" "$byte2" "$byte3 >> "$output_file"
    
done < "$machine_file"

echo "Machine code generated at $machine_file!"
echo "Instruction memory content generated at $output_file!"