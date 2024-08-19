#!/bin/bash
echo "[RUN_SYMBI] run formal with Symbiyosys" 
gui=0
SVA=
na=1
INTER_SBY=revised_script/inter_hbi.sby
INTRA_SBY=revised_script/intra_hbi.sby
DIR=./symbi_output
DUMPNAME=symbi_summary
POSITIONAL=()

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -n|--noupdate)
    na="$2"
    shift
    shift
    ;;
    -s|--sva)
    SVA="$2"
    shift
    shift
    ;;
    -d|--dir)
    DIR="$2_dir"
    shift
    shift
    ;;
    -g|--gui)
    gui="$2"
    shift
    shift
    ;;
    -r|--res)
    DUMPNAME="$2"
    shift
    shift
    ;;
    --help)
    echo "-g/--gui <0(default)/1> with gui, -s/--sva <sva relative file path>, -n/--noupdate <0/1(default)> update sv to top module"
    exit 0
    shift
    ;;
    --default)
    DEFAULT=YES
    shift
    ;;
    *)    
    POSITIONAL+=("$1") 
    shift
    ;;
esac
done

mkdir -p $DIR

if [ -f "$SVA" ]; then
    if [ "$na" -eq "1" ]; then 
        echo "[RUN_SYMBI] SVA file provided: $SVA"
        # You may include additional logic here to process the SVA file if necessary.
    fi 
else 
    echo "[RUN_SYMBI] No SVA file found or specified"
fi

# Execute Symbiyosys on the provided SBY files
if [ "$gui" -eq "0" ]; then
    echo "[RUN_SYMBI] Running Symbiyosys in non-GUI mode"
    sby -f "$INTER_SBY" > "${DIR}/${DUMPNAME}_inter.log"
    sby -f "$INTRA_SBY" > "${DIR}/${DUMPNAME}_intra.log"
else
    echo "[RUN_SYMBI] GUI mode not supported by Symbiyosys, proceeding without GUI"
    sby -f "$INTER_SBY" > "${DIR}/${DUMPNAME}_inter.log"
    sby -f "$INTRA_SBY" > "${DIR}/${DUMPNAME}_intra.log"
fi

echo "[RUN_SYMBI] Finished running Symbiyosys"
