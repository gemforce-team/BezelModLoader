#!/usr/bin/env bash

# Load logging
source log4bash.sh

# Variable assignement, override any with env vars
GAME_NAME=${GAME_NAME:-"gcfw"}
GAME_EXTENSION=${GAME_EXTENSION:-".swf"}
WORK_DIR=${WORK_DIR:-"/workdir"}
INPUT_DIR=${INPUT_DIR:-"/input"}
OUTPUT_DIR=${OUTPUT_DIR:-"/output"}

# rabcdasm vars
SCRIPT_BLOCK=${SCRIPT_BLOCK:-"0"}
ABC_EXTENSION=${ABC_EXTENSION:-".abc"}

# joining filenames and directories
GAME_FILENAME="${GAME_NAME}${GAME_EXTENSION}"
ABC_FILENAME="${GAME_NAME}-${SCRIPT_BLOCK}${ABC_EXTENSION}"
ASASM_FILENAME="${GAME_NAME}-${SCRIPT_BLOCK}.main.asasm"
ASSEMBLED_FILENAME="${GAME_NAME}-${SCRIPT_BLOCK}.main${ABC_EXTENSION}"
SCRIPT_DIR="${WORK_DIR}/${GAME_NAME}-${SCRIPT_BLOCK}"

main() {

  cleanup_dirs

  export_and_disassemble

  # Invoke the rules engine
  rules_engine.sh "$SCRIPT_DIR"

  assemble_and_replace

}

cleanup_dirs() {
  # Load array of dirs
  my_array[0]=$WORK_DIR
  my_array[1]=$OUTPUT_DIR

  # Clean each
  log_info "Cleaning up directories"
  for i in "${my_array[@]}"; do
    log_info "Cleaning ${i}"
    [[ -d "${i}" ]] && rm -rf ${i}/*;
  done
}

export_and_disassemble() {

  log_info "Exporting scripts"
  abcexport "${INPUT_DIR}/${GAME_FILENAME}"

  log_info "Moving ${ABC_EXTENSION} file to work directory"
  mv "${INPUT_DIR}/${ABC_FILENAME}" ${WORK_DIR}

  log_info "Disassembling"
  rabcdasm "${WORK_DIR}/${ABC_FILENAME}"

}

assemble_and_replace() {

  log_info "Assemble new $ABC_EXTENSION file"
  rabcasm "${SCRIPT_DIR}/${ASASM_FILENAME}"

  log_info "Copy original .swf to output"
  cp "${INPUT_DIR}/${GAME_FILENAME}" "${OUTPUT_DIR}"

  log_info "Replace scripts in new .swf"
  abcreplace "${OUTPUT_DIR}/${GAME_FILENAME}" 0 "${SCRIPT_DIR}/${ASSEMBLED_FILENAME}"
}

main
